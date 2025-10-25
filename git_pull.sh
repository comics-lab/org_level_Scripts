#!/bin/bash

PROJECT_ROOT="/home/rmleonard/projects/Home Projects"
ORG_NAME="$1" # example: "comics-lab"
CLONE_DIR="$PROJECT_ROOT/$ORG_NAME" # Directory to clone repos into

cd "$CLONE_DIR" > /dev/null 2>&1 || { echo "Directory $CLONE_DIR does not exist. Please run grab_org.sh first."; exit 1; }
# Get a list of all repository names in the organization into an array
mapfile -t repos < <(gh repo list "$ORG_NAME" --limit 999 --json name --jq '.[].name')

for repo_name in "${repos[@]}"; do
  repo_dir="$CLONE_DIR/$repo_name"
  if [[ ! -d "$repo_dir" ]]; then
    echo "Directory $repo_dir does not exist. Please run grab_org.sh first."
    continue
  fi

  pushd "$repo_dir" > /dev/null 2>&1 || { echo "Failed to enter $repo_dir"; continue; }

  echo "pulling $repo_dir..."
  # Run git pull normally; stdin is the terminal because we use mapfile (not a pipe)
  git pull
  popd > /dev/null 2>&1
done

# echo "All repositories from $ORG_NAME cloned into $CLONE_DIR"
