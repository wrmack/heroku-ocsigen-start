#!/bin/bash

# Environment variables

# When deploying to Heroku (comment out for local use)
# $PORT is supplied by Heroku
export USER="$(whoami)"
export GROUP=dyno
export PREFIX=/home/opam/eliom/local

# When testing locally (comment out for Heroku)
# Remember to publish the port eg. docker run --rm -it -d --name container-name -p 8080:8080 image-name
# export PORT=8080
# export USER=opam
# export GROUP=opam
# export PREFIX=local

echo "PORT: ${PORT}"

# Substitute $PORT, $USER and $GROUP variables in ocsigen.conf.template and write to ocsigen.conf
envsubst < /home/opam/eliom/site/Makefile.options.template > /home/opam/eliom/site/Makefile.options

exec "$@"