import zmq
import click


@click.group()
def cli():
    """
    CoreNLP broker process.
    """


@cli.command(name='serve')
@click.option('--frontend-host', default='*',
    help="Host to accept client requests from.")
@click.option('--frontend-port', default='5559',
    help="Port to accept client requests on.")
@click.option('--backend-host', default='*',
    help="Host to forward client requests to.")
@click.option('--backend-port', default='5560',
    help="Port to forward client requests on.")
def serve(**options):
    # Prepare our context and sockets
    context = zmq.Context()
    frontend = context.socket(zmq.ROUTER)
    backend = context.socket(zmq.DEALER)

    frontend.bind("tcp://{frontend_host}:{frontend_port}".format(**options))
    backend.bind("tcp://{backend_host}:{backend_port}".format(**options))

    # Initialize poll set
    poller = zmq.Poller()
    poller.register(frontend, zmq.POLLIN)
    poller.register(backend, zmq.POLLIN)

    # Switch messages between sockets
    while True:
        socks = dict(poller.poll())

        if socks.get(frontend) == zmq.POLLIN:
            message = frontend.recv_multipart()
            backend.send_multipart(message)

        if socks.get(backend) == zmq.POLLIN:
            message = backend.recv_multipart()
            frontend.send_multipart(message)


if __name__ == '__main__':
    cli()