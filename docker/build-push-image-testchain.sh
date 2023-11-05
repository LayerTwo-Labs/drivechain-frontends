set -e
set -o pipefail

REPO=LayerTwo-Labs/testchain
MAIN_BRANCH=testchain

TESTCHAIN_VERSION=$(gh api repos/$REPO/git/ref/heads/$MAIN_BRANCH | jq --raw-output .object.sha)

echo Building Docker image based off SHA $TESTCHAIN_VERSION

# TODO: update DEPENDS for non-ARM machines
docker build \
    --platform linux/amd64 \
    --build-arg TESTCHAIN_VERSION=$TESTCHAIN_VERSION \
    --build-arg DEPENDS=x86_64-pc-linux-gnu \
    -t barebitcoin/testchain \
    --file Dockerfile.testchain . 

docker push barebitcoin/testchain