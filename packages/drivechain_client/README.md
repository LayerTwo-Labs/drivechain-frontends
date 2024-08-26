# drivechain_client

This package contains a frontend for interacting with a Drivechain-enabled layer 1 bitcoin network.

## Local development

To get the app(s) up and running, make sure you have the following dependencies:

* The [Flutter SDK](https://flutter.dev)
* An instance of [drivechain-server](../../drivechain-server) running
* The `DRIVECHAIN_HOST` and `DRIVECHAIN_PORT` environment variable pointing to the above instance
* A BIP 300/301 enabled node running

Running the app is as simple as the following command:

```bash
flutter run --dart-define DRIVECHAIN_HOST=http://localhost --dart-define DRIVECHAIN_PORT=8080
```

The project is set up with launch configurations for Visual Studio Code as well.