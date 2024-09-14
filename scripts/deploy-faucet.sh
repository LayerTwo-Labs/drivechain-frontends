#!/usr/bin/env bash

set -e 

docker compose --file docker-compose.faucet.yml up --build --wait 

cd ./packages/faucet_client
flutter clean
flutter pub get --enforce-lockfile
flutter build web

instance=$(gcloud compute instances list --format="value(NAME)" | grep layertwo-labs)

# Clean old stuff
gcloud compute ssh $instance -- "rm -rf /var/www/drivechain-live/*"

# Copy over new stuff
gcloud compute scp --recurse ./build/web/* $instance:/var/www/drivechain-live/
