#!/usr/bin/env bash

set -e

cd servers/faucet/
docker build -t faucet .
cd ../../
docker compose --file docker-compose.faucet.yml up -d --force-recreate

cd ./clients/faucet
flutter clean
flutter pub get --enforce-lockfile
flutter build web --profile \
    --dart-define=Dart2jsOptimization=O0 \
    --dart-define=FAUCET_BASE_URL=/api \
    --output=./build/web

# Clean old stuff
sudo rm -rf /var/www/drivechain-live/*
# Move over new stuff
sudo cp -r ./build/web/* /var/www/drivechain-live/
