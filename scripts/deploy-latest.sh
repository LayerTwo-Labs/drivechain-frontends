#!/usr/bin/env bash
#
git pull

cd faucet-backend
go install ./...
sudo systemctl restart faucet

cd ../packages/faucet
flutter build web
