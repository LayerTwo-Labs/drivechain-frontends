#!/usr/bin/env bash
#
cd clients/sidesail
flutter pub get
cd ../../

cd clients/faucet
flutter pub get
cd ../../

cd clients/sail_ui
flutter pub get
cd ../../

cd clients/launcher
flutter pub get
cd ../../

cd clients/bitwindow
flutter pub get
cd ../../