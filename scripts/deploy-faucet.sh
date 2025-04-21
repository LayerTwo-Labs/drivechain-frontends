#!/usr/bin/env bash

set -e

cd ./faucet
flutter clean
flutter pub get
flutter build web --dart-define=FAUCET_BASE_URL=/api --output=./build/web

# Replace GIT_COMMIT_HASH_FLUTTER_BUILD with actual hash in the built index.html
COMMIT_HASH=$(git rev-parse --short HEAD)
sed -i "s/GIT_COMMIT_HASH_FLUTTER_BUILD/$COMMIT_HASH/g" ./build/web/index.html

# Clean old stuff
sudo rm -rf /var/www/drivechain-live/*
# Move over new stuff
sudo cp -r ./build/web/* /var/www/drivechain-live/
