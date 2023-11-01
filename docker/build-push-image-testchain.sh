set -e
set -o pipefail

REPO=LayerTwo-Labs/testchain
MAIN_BRANCH=testchain

TESTCHAIN_VERSION=$(gh api repos/$REPO/git/ref/heads/$MAIN_BRANCH | jq --raw-output .object.sha)

echo Building Docker image based off SHA $TESTCHAIN_VERSION

# TODO: update DEPENDS for non-ARM machines
docker build \
    --build-arg TESTCHAIN_VERSION=$TESTCHAIN_VERSION \
    --build-arg DEPENDS=aarch64-unknown-linux-gnu \
    -t barebitcoin/testchain \
    --file Dockerfile.testchain . 

docker push barebitcoin/testchain