#!/usr/bin/env bash

build="docker build -t gandalf-ui -f devops/Dockerfile ."
run="docker run -d -p 3001:80 gandalf-ui"

if [ "$1" == "run" ]; then
  eval "$run"
elif [ "$1" == "build" ]; then
  eval "$build"
else
  eval "$build"
  eval "$run"
fi

