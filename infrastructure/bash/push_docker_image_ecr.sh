#!/usr/bin/env bash

set -e
set -x

# make docker container string
docker_repo="$1"

# get version number
refs=$(git show-ref --head | python3 -c 'import sys
import os
for line in sys.stdin:
    commit, ref = line.split(" ")
    ref = ref.strip()
    if ref == "HEAD":
        head = commit
    elif commit == head and ref.replace("refs/heads/", "") in ("main", "development" ):
        print(ref.replace("refs/heads/", ""))

if (tag:=os.popen("git tag --points-at HEAD").read().strip()):
    print(tag.replace("refs/tags/v", ""))
')

echo "Pushing refs"
for ref in $refs ; do
  echo "Pushing $ref"
  docker tag build-app:latest $docker_repo:$ref
  docker push $docker_repo:$ref
done
echo "Done pushing refs"
