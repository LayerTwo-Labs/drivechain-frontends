#!/usr/bin/env bash

set -e 

cd faucet-backend/
docker build -t faucet-backend .
cd ../
docker compose --file docker-compose.faucet.yml up -d --force-recreate

cd ./clients/faucet
flutter clean
flutter pub get --enforce-lockfile
flutter build web --profile --dart-define=Dart2jsOptimization=O0 --output=./build/web

# Clean old stuff
sudo rm -rf /var/www/drivechain-live/*
# Move over new stuff
sudo cp -r ./build/web/* /var/www/drivechain-live/