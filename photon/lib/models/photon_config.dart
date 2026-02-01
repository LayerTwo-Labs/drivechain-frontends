import 'package:sail_ui/sail_ui.dart';

/// Photon configuration implemented using GenericAppConfig.
class PhotonConfig extends GenericAppConfig {
  PhotonConfig() : super(appName: 'Photon');

  PhotonConfig.fromConfig(PhotonConfig super.other) : super.fromConfig();

  static PhotonConfig parse(String content) {
    final generic = GenericAppConfig.parse(content, appName: 'Photon');
    final config = PhotonConfig();
    config.settings = generic.settings;
    return config;
  }
}
