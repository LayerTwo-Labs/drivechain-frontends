# bitwindow

This package contains a frontend for interacting with a Drivechain-enabled layer 1 bitcoin network.

## Local development

To get the app(s) up and running, make sure you have the following dependencies:

* The [Flutter SDK](https://flutter.dev)
* An instance of [bitwindowd](../../servers/bitwindow) running
* The `BITWINDOWD_HOST` and `BITWINDOWD_PORT` environment variable pointing to the above instance
* A BIP 300/301 enabled node running

Running the app is as simple as the following command:

```bash
flutter run --dart-define BITWINDOWD_HOST=localhost --dart-define BITWINDOWD_PORT=8080
```

The project is set up with launch configurations for Visual Studio Code as well.