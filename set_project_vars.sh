#!/bin/env bash


export GIT_ORG_ROOT="~/projects"
export GIT_PROJECT_ROOT="$GIT_ORG_ROOT/HOME"


  if [[ ! -d "$GIT_PROJECT_ROOT" ]]; then
    echo "Directory $GIT_PROJECT_ROOT does not exist."
    echo "creating ..."
    # mkdir -p "$GIT_PROJECT_ROOT"
  fi
