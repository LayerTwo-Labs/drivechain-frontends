import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:launcher/models/chain_config.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: FutureBuilder<List<ChainConfig>>(
        future: loadChainConfigs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No chain configurations found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final chain = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SailRawCard(
                  padding: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary24(chain.displayName),
                      const SizedBox(height: 10),
                      SailText.secondary13('ID: ${chain.id}'),
                      SailText.secondary13('Version: ${chain.version}'),
                      SailText.secondary13('Chain Type: ${chain.chainType}'),
                      SailText.secondary13('Slot: ${chain.slot}'),
                      const SizedBox(height: 10),
                      SailText.secondary13(chain.description),
                      const SizedBox(height: 10),
                      SailText.secondary13('Repo: ${chain.repoUrl}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
