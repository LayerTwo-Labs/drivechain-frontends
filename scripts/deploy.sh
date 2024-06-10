#!/usr/bin/env bash
#

cd faucet-backend
go install ./...
sudo systemctl restart faucet

cd ../packages/faucet
flutter clean
flutter pub get
flutter build web
