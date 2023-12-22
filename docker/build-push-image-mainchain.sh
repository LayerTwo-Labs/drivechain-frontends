#! /usr/bin/env bash

set -e
set -o pipefail

REPO=LayerTwo-Labs/mainchain
MAIN_BRANCH=master

MAINCHAIN_VERSION=$(gh api repos/$REPO/git/ref/heads/$MAIN_BRANCH | jq --raw-output .object.sha)

echo Building Docker image based off SHA $MAINCHAIN_VERSION

# TODO: update DEPENDS for non-ARM machines
docker buildx build \
    --platform linux/amd64 \
    --build-arg MAINCHAIN_VERSION=$MAINCHAIN_VERSION \
    --build-arg DEPENDS=x86_64-pc-linux-gnu \
    -t barebitcoin/mainchain \
    --file Dockerfile.mainchain . 

docker push barebitcoin/mainchain