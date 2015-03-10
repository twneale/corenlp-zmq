#! /bin/bash

cidfile=$1

function startup {
  # Run the container.
  echo "Starting worker ${cidfile}"
  docker run --link broker:broker --cidfile=$cidfile -w /corenlp/scala corenlp sbt run
}

function shutdown {
  echo "Recieved signal; exiting"
  # Kill the docker container.
  echo "Killing container ${cidfile}"
  docker kill $(<${cidfile})
  # Remove the container id file.
  echo "Removing cid file"
  rm $cidfile 
}

# Properly handle SIGTERM from supervisor.
trap shutdown EXIT

startup
