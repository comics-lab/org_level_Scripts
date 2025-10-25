#!/bin/bash

ORG_NAME="$1"
CLONE_DIR="./$ORG_NAME" # Directory to clone repos into

# mkdir -p "$CLONE_DIR"

cd "$CLONE_DIR"
# echo "$( pwd )"

# Get a list of all repository names in the organization into an array
mapfile -t repos < <(gh repo list "$ORG_NAME" --limit 999 --json name --jq '.[].name')

for repo_name in "${repos[@]}"; do
  repo_dir="$(pwd)/$repo_name"
  if [[ ! -d "$repo_dir" ]]; then
    echo "Directory $repo_dir does not exist. Skipping."
    continue
  fi

  pushd "$repo_dir" > /dev/null 2>&1 || { echo "Failed to enter $repo_dir"; continue; }

  echo "checking $repo_dir for changes..."
  git add .
  # Only commit if there are staged changes
  if git diff --cached --quiet; then
    echo "No changes in $repo_dir, skipping"
  else
    echo "committing changes in $repo_dir..."
    git commit -q -m "MASS UPDATE: $repo_dir"
    git push -q
  fi

  popd > /dev/null 2>&1
done

# echo "All repositories from $ORG_NAME cloned into $CLONE_DIR"
