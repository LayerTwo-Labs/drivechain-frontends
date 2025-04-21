#!/usr/bin/env bash
set -e

cd sidesail
flutter pub get
cd ../

cd faucet
flutter pub get
cd ../

cd sail_ui
flutter pub get
cd ../

cd launcher
flutter pub get
cd ../

cd bitwindow
flutter pub get
cd ../
