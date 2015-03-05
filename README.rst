corenlp-zmq
===========

This repo provides a Dockerfile and `Ansible <https://github.com/ansible/ansible>`_ provisioning 
script to build and run a `Stanford CoreNLP <http://nlp.stanford.edu/software/corenlp.shtml>`_ server process.

Running the Server
++++++++++++++++++

Running the server involves three steps:

First, clone the repo and build the docker container:

    .. code-block:: shell

        git clone https://github.com/twneale/corenlp-zmq/
        cd corenlp-zmq
        docker build -t corenlp .

Next, install `Supervisord <http://supervisord.org/>`_ if not already present on your system. On Debian/Ubuntu,
you can apt-get install supervisor, and on RHEL/Centos you can yum install python-setuptool, then 
pip install supervisor.

Next, start a supervisor process with the config file provided in the repo:

    .. code-block:: shell

        # First create a log directory
        mkdir log

        # To start a supervisor process in the foreground:
        supervisord -n -c supervisor/supervisor.conf
        
        # To start a supervisor daemon in the background:
        supervisord -c supervisor/supervisor.conf

That's it! You can now send JSON requests of the form show below to port 5559 via on the host OS and 
recieve the CoreNLP output XML, or a Java traceback if an error occurs. Note that the Scala server's 
`sbt build <http://www.scala-sbt.org/>`_ first has to boostrap itself and download several jar files,
including the huge CoreNLP jar, so several minutes will pass before the server starts and can 
respond to requests. If you want to skip that process next time, you can run "docker ps" to get 
the container id, then "docker commit [id]" to save the container once the boostrapping in finished.

  .. code-block: javascript
  
  {annotators: "tokenize,ssplit,pos,lemma,parse", text: "I have a ham radio."}
        
How it Works
++++++++++++++

The supervisor config file instructs supervisor to start two processes. The first is a Python 
request broker that listens on port 5559 and round-robin proxies incoming ZMQ requests to any 
connected worker processes. 

    .. code-block:: shell
     
      docker run -i -t -p 5559:5559 --name broker corenlp /corenlp/virt/bin/python /corenlp/python/broker.py serve --frontend-port=5559 --backend-port=5560


The second starts one or more Scala worker processes, each of which loads the Core NLP
java jar and registeres itself with the Python request broker. On recieving a request, the Scala process
builds an appropriate edu.stanford.nlp.pipeline.StanfordCoreNLP object (and caches it, because they're expensive)
and runs the provided text through it, returning the response as a JSON object.
        
    .. code-block:: shell
    
      docker run -i -t --link broker:broker corenlp /bin/bash -c 'cd /corenlp/scala && sbt run'

You can also simply run these manually without Supervisor to test things out. 

Trying it Out
+++++++++++++

To send some text through the server, you can run the example Python client script, provided you 
have ZMQ, ZMQ-dev, and pyzmq installed:

    .. code-block:: python

        import sys
        import zmq


        def client():
            context = zmq.Context()
            socket = context.socket(zmq.REQ)
            socket.connect("tcp://localhost:5559")

            def send(string):
                obj = dict(annotators='tokenize,ssplit,pos,lemma,parse', text=string)
                socket.send_json(obj)
                message = socket.recv_json()
                return message

            import pdb; pdb.set_trace()


        if __name__ == "__main__":
            client()

Scaling Up
++++++++++

To increase the number of Scala worker processes, simply edit the "numprocs" setting in supervisor/conf.d/worker.conf,
then restart the process with supervisor. This setup provides a bonafide parallelized CoreNLP processing tool, unlike
other packages available, which may, for example, provide an HTTP interface to a single subprocess that communicates
with CoreNLP via the shell. In contrast, this package enables you to scale up the number of workers as needed,
and could easily be upgraded to a cluster by placing several servers behind nginx, or another tier of ZMQ broker/proxy.
