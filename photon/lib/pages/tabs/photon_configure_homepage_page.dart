import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:photon/providers/photon_homepage_provider.dart';
import 'package:photon/widgets/homepage_widget_catalog.dart';

@RoutePage()
class PhotonConfigureHomepagePage extends StatefulWidget {
  const PhotonConfigureHomepagePage({super.key});

  @override
  State<PhotonConfigureHomepagePage> createState() => _PhotonConfigureHomepagePageState();
}

class _PhotonConfigureHomepagePageState extends State<PhotonConfigureHomepagePage> {
  @override
  Widget build(BuildContext context) {
    final provider = GetIt.I.get<PhotonHomepageProvider>();

    return SailConfigureHomePage(
      widgetCatalog: PhotonWidgetCatalog.getCatalogMap(),
      provider: provider,
      backButtonLabel: 'Back to Photon homepage',
      onHomepageConfigured: () {
        // Optionally navigate back or show additional feedback
      },
    );
  }
}
