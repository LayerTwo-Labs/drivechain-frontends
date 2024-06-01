#!/usr/bin/env bash
#
cd faucet-backend
go install ./...

cd ../packages/faucet
flutter build web
