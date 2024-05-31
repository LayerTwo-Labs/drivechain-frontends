#!/usr/bin/env bash
#
cd packages/sidesail
flutter pub get
cd ../../

cd packages/faucet
flutter pub get
cd ../../
