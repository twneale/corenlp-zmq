#! /bin/bash


function startup {
  # Run the container.
  echo "Starting worker $CORENLP_WORKER_CID_FILE"
  docker run --rm --link broker:broker --cidfile=$CORENLP_WORKER_CID_FILE -w /corenlp/scala corenlp sbt run
}

function shutdown {
  echo "Recieved signal; exiting"
  # Kill the docker container.
  echo "Killing container $CORENLP_WORKER_CID_FILE"
  docker kill $(<$CORENLP_WORKER_CID_FILE)
  # Remove the container id file.
  echo "Removing cid file"
  rm $CORENLP_WORKER_CID_FILE
}

# Properly handle SIGTERM from supervisor.
trap shutdown EXIT

startup
