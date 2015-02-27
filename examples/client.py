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


