# SideSail

![SideSail logo](logo.png)

A work-in-progress sidechain UI.

```shell
$ flutter run -d macos
```

# Releasing and that kinda stuff

### Windows

You need Windows Subsystem for Linux, with the following packages installed:

- `unzip`
- Probably more...

To sign the MSIX installer produced at the end of the build you need a valid
certificate. When this is deployed somewhere proper this needs to be a real
certificate signed by a recognized authority. For our current, internal
distribution needs we use a self signed certificate. The following instructions
are based on
[this Medium article](https://sahajrana.medium.com/how-to-generate-a-pfx-certificate-for-flutter-windows-msix-lib-a860cdcebb8).

Run in WSL `bash`:

```bash
# Generate a key
$ openssl genrsa -out mykeyname.key 2048

# Generate a CSR (certificate request)
$ openssl req -new -key mykeyname.key -out mycsrname.csr

# Generate the actual certificate
$ openssl x509 -in mycsrname.csr -out mycrtname.crt -req -signkey mykeyname.key -days 365

# Export the certificate to a usable format
$ openssl pkcs12 -export -out CERTIFICATE.pfx -inkey mykeyname.key -in mycrtname.crt

```

The final `CERTIFICATE.pfx` file is what we're going to use as the signing
certificate for the installer.

Building the MSIX installer:

```bash
# replace testchain with whatever other chain you're building
$ bash ./scripts/build-app.sh windows testchain
```

This places a `.msix` file in `build/windows/runner/Release`. Before this can be
properly installed, we need to install the certificate used to sign the
installer.

1. Open the folder containing the `.msix` file with your file explorer.
2. Right click on the `.msix` file.
3. Go to the "Digital Signatures" tab.
4. Select the signature (should be only one entry in "Signature list").
5. Click on "Details"
6. Click on "View Certificate"
7. Click on "Install Certificate..."
8. Select "Local Machine"
9. If prompted, accept the popup authorizing the certificate installation
10. Select "Place all certificates in the following store", and then "Browse..."
11. Select "Trust Root Certification Authorities"
12. Click "Next"
13. Click "Finish"
14. You should see a popup saying "The import was successful".

Tme `.msix` file can now be double clicked, which should prompt you to install
the application.

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
