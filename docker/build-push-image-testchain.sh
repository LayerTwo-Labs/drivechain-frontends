set -e
set -o pipefail

REPO=LayerTwo-Labs/testchain
MAIN_BRANCH=testchain

TESTCHAIN_VERSION=$(gh api repos/$REPO/git/ref/heads/$MAIN_BRANCH | jq --raw-output .object.sha)

echo Building Docker image based off SHA $TESTCHAIN_VERSION

docker buildx build \
    --build-arg TESTCHAIN_VERSION=$TESTCHAIN_VERSION \
    -t barebitcoin/testchain \
    --file Dockerfile.testchain . 
docker push barebitcoin/testchain