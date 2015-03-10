#! /bin/bash

function startup {
    # Delete the broker container if currently running.
    if (docker ps | grep broker); then
        echo "Deleting an already-running broker."
        docker rm -f broker
    fi
    # Run the container.
    echo "Running the container."
    docker run -p 5559:5559 --name=broker --cidfile=broker.cid corenlp /corenlp/virt/bin/python /corenlp/python/broker.py serve --frontend-port=5559 --backend-port=5560
}

function shutdown {
  echo "Recieved signal; exiting"
  # Kill the docker container.
  echo "Killing container $(<broker.cid)"
  docker kill $(<broker.cid)
  # Remove the named container.
  echo "Removing 'broker' named container."
  docker rm broker
  # Remove the container id file.
  echo "Removing broker.cid file."
  rm broker.cid
}

# Properly hanel SIGTERM from supervisor.
trap shutdown EXIT

startup
