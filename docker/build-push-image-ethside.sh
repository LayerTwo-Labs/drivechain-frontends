set -e
set -o pipefail

REPO=LayerTwo-Labs/ethereum-sidechain
MAIN_BRANCH=sidechain

DIR=$(mktemp -d)

echo Building Docker image based off SHA $ETHSIDE_VERSION

git clone --depth 1 https://github.com/$REPO.git $DIR

docker build \
    -t barebitcoin/ethside \
    $DIR

docker push barebitcoin/ethside