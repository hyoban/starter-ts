#!/usr/bin/env bash

# https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# Define the input vars
GITHUB_REPOSITORY=${1?Error: Please pass username/repo, e.g. prb/foundry-template}
GITHUB_REPOSITORY_OWNER=${2?Error: Please pass username, e.g. prb}
GITHUB_REPOSITORY_DESCRIPTION=${3:-""} # If null then replace with empty string

echo "GITHUB_REPOSITORY: $GITHUB_REPOSITORY"
echo "GITHUB_REPOSITORY_OWNER: $GITHUB_REPOSITORY_OWNER"
echo "GITHUB_REPOSITORY_DESCRIPTION: $GITHUB_REPOSITORY_DESCRIPTION"

NAME=@"$GITHUB_REPOSITORY"
if [[ $GITHUB_REPOSITORY == $GITHUB_REPOSITORY_OWNER* ]]; then
  NAME=$(echo "$GITHUB_REPOSITORY" | sed "s/^$GITHUB_REPOSITORY_OWNER\///")
fi

# jq is like sed for JSON data
JQ_OUTPUT=`jq \
  --arg NAME "$NAME" \
  --arg GITHUB_REPOSITORY "$GITHUB_REPOSITORY" \
  --arg AUTHOR_NAME "$GITHUB_REPOSITORY_OWNER" \
  --arg URL "https://github.com/$GITHUB_REPOSITORY_OWNER" \
  --arg DESCRIPTION "$GITHUB_REPOSITORY_DESCRIPTION" \
  --arg HOMEPAGE "https://github.com/$GITHUB_REPOSITORY#readme" \
  --arg REPO_URL "https://github.com/$GITHUB_REPOSITORY.git" \
  --arg BUGS_URL "https://github.com/$GITHUB_REPOSITORY/issues" \
  --arg TYPE "git" \
  '.name = $NAME | .description = $DESCRIPTION | .author |= ( .name = $AUTHOR_NAME | .url = $URL ) | .homepage = $HOMEPAGE | .repository |= ( .type = $TYPE | .url = $GITHUB_REPOSITORY ) | .bugs = $BUGS_URL' \
  package.json
`

# Overwrite package.json
echo "$JQ_OUTPUT" > package.json

# Make sed command compatible in both Mac and Linux environments
# Reference: https://stackoverflow.com/a/38595160/8696958
sedi () {
  sed --version >/dev/null 2>&1 && sed -i -- "$@" || sed -i "" "$@"
}

sedi "s|pkg-placeholder|$NAME|g" "README.md"
sedi "s|description|$GITHUB_REPOSITORY_DESCRIPTION|g" "README.md"
