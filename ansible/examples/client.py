import sys
import zmq


def client():
    context = zmq.Context()
    socket = context.socket(zmq.REQ)
    socket.connect("tcp://ec2-54-82-68-80.compute-1.amazonaws.com:5559")

    def send(string):
        obj = dict(annotators='tokenize,ssplit,pos,lemma,parse', text=string)
        socket.send_json(obj)
        message = socket.recv_json()
        return message

    import pdb; pdb.set_trace()


if __name__ == "__main__":
    client()


