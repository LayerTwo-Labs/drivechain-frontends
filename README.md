# SideSail

![SideSail logo](logo.png)

A work-in-progress sidechain UI.

```shell
$ flutter run -d macos
```

# Releasing and that kinda stuff

### Linux

```bash
# Ubuntu, might need something else on other distros
# Basic Flutter stuff I think?
$ sudo apt-get install libgtk-3-dev

# path_provider_path stuff
$ sudo apt install libsecret-1-dev libsecret-tools libsecret-1-0

$ flutter clean # Sometimes strange stuff if you don't clean first
$ flutter build linux

# result is located in ./build/linux/x64/release/bundle:
# ./sidesail: actual binary
# ./lib: the required .so library files
# ./data: assets++

# Note that this isn't a launchable "application" in the same
# way that Windows and macOS has. To get that, we have to
# package it using for example `snap`.
# https://docs.flutter.dev/deployment/linux
```

### macOS

Generate icons with
[CandyIcons](https://www.candyicons.com/free-tools/app-icon-assets-generator).
Gives the nice, rounded icon.

```bash
$ flutter build macos
# result is located in ./build/macos/Build/Products/Release
```

s
