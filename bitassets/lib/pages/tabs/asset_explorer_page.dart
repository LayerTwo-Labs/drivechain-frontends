import 'package:auto_route/auto_route.dart';
import 'package:bitassets/providers/asset_analytics_provider.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:bitassets/providers/favorites_provider.dart';
import 'package:bitassets/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class AssetExplorerTabPage extends StatelessWidget {
  const AssetExplorerTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder<AssetExplorerViewModel>.reactive(
        viewModelBuilder: () => AssetExplorerViewModel(),
        builder: (context, model, child) {
          final theme = SailTheme.of(context);

          return SailColumn(
            spacing: SailStyleValues.padding16,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Header with search
              SailRow(
                spacing: SailStyleValues.padding16,
                children: [
                  Expanded(
                    child: SailTextField(
                      hintText: 'Search by name or hash...',
                      controller: model.searchController,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: SailSVG.icon(SailSVGAsset.iconSearch, width: 16),
                      ),
                    ),
                  ),
                  SailButton(
                    label: 'Refresh',
                    onPressed: () async => model.refresh(),
                  ),
                ],
              ),

              // Stats row
              SailRow(
                spacing: SailStyleValues.padding16,
                children: [
                  _StatCard(
                    label: 'Total Assets',
                    value: model.filteredAssets.length.toString(),
                    icon: SailSVGAsset.iconCoins,
                  ),
                  _StatCard(
                    label: 'Favorites',
                    value: model.favoritesCount.toString(),
                    icon: SailSVGAsset.iconInfo,
                  ),
                  _StatCard(
                    label: 'With Encryption',
                    value: model.assetsWithEncryption.toString(),
                    icon: SailSVGAsset.iconShield,
                  ),
                  _StatCard(
                    label: 'With Signing Key',
                    value: model.assetsWithSigning.toString(),
                    icon: SailSVGAsset.iconPen,
                  ),
                ],
              ),

              // Filter tabs
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  _FilterTab(
                    label: 'All',
                    isActive: !model.showFavoritesOnly,
                    onTap: () => model.setShowFavoritesOnly(false),
                  ),
                  _FilterTab(
                    label: 'Favorites',
                    isActive: model.showFavoritesOnly,
                    onTap: () => model.setShowFavoritesOnly(true),
                    icon: Icons.star,
                  ),
                ],
              ),

              // Asset table
              Expanded(
                child: SailCard(
                  title: 'Registered BitAssets',
                  subtitle: 'Browse all assets on the network',
                  child: model.isLoading
                      ? const Center(child: SailCircularProgressIndicator())
                      : model.filteredAssets.isEmpty
                      ? Center(
                          child: SailColumn(
                            spacing: SailStyleValues.padding16,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SailSVG.icon(SailSVGAsset.iconCoins, width: 48),
                              const SizedBox(height: 8),
                              SailText.secondary13(
                                model.searchController.text.isNotEmpty
                                    ? 'No assets match your search'
                                    : model.showFavoritesOnly
                                    ? 'No favorite assets yet'
                                    : 'No BitAssets registered yet',
                              ),
                              if (!model.showFavoritesOnly && model.searchController.text.isEmpty)
                                SailText.secondary12('Register a new BitAsset to get started'),
                              if (!model.showFavoritesOnly && model.searchController.text.isEmpty)
                                SailButton(
                                  label: 'Register Asset',
                                  onPressed: () async {
                                    await AutoRouter.of(context).navigate(const BitAssetsTabRoute());
                                  },
                                ),
                              if (model.showFavoritesOnly)
                                SailText.secondary12('Star assets to add them to your favorites'),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            // Table header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SailStyleValues.padding16,
                                vertical: SailStyleValues.padding08,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colors.backgroundSecondary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 32), // Star column
                                  SizedBox(
                                    width: 50,
                                    child: SailText.secondary12('Seq #'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: SailText.secondary12('Name / Hash'),
                                  ),
                                  Expanded(
                                    child: SailText.secondary12('Encryption'),
                                  ),
                                  Expanded(
                                    child: SailText.secondary12('Signing'),
                                  ),
                                  Expanded(
                                    child: SailText.secondary12('Network'),
                                  ),
                                  const SizedBox(width: 80),
                                ],
                              ),
                            ),
                            // Table rows
                            Expanded(
                              child: ListView.builder(
                                itemCount: model.filteredAssets.length,
                                itemBuilder: (context, index) {
                                  final asset = model.filteredAssets[index];
                                  final isExpanded = model.expandedAssetHash == asset.hash;
                                  final isFavorite = model.isFavorite(asset.hash);

                                  return Column(
                                    children: [
                                      _AssetRow(
                                        asset: asset,
                                        isExpanded: isExpanded,
                                        isFavorite: isFavorite,
                                        onTap: () => model.toggleExpanded(asset.hash),
                                        onCopyHash: () => model.copyToClipboard(asset.hash, context),
                                        onToggleFavorite: () => model.toggleFavorite(asset.hash),
                                      ),
                                      if (isExpanded)
                                        _AssetDetails(
                                          asset: asset,
                                          onCopy: (text) => model.copyToClipboard(text, context),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final SailSVGAsset icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(SailStyleValues.padding16),
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          borderRadius: SailStyleValues.borderRadius,
        ),
        child: SailRow(
          spacing: SailStyleValues.padding12,
          children: [
            SailSVG.icon(icon, width: 24),
            SailColumn(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary12(label),
                SailText.primary20(value, bold: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterTab({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: SailStyleValues.borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.colors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: SailStyleValues.borderRadius,
          border: Border.all(
            color: isActive ? theme.colors.primary : theme.colors.divider,
          ),
        ),
        child: SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 14,
                color: isActive ? theme.colors.primary : theme.colors.textSecondary,
              ),
            SailText.primary13(
              label,
              color: isActive ? theme.colors.primary : null,
              bold: isActive,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetRow extends StatelessWidget {
  final BitAssetEntry asset;
  final bool isExpanded;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onCopyHash;
  final VoidCallback onToggleFavorite;

  const _AssetRow({
    required this.asset,
    required this.isExpanded,
    required this.isFavorite,
    required this.onTap,
    required this.onCopyHash,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final hasEncryption = asset.details.encryptionPubkey != null;
    final hasSigning = asset.details.signingPubkey != null;
    final hasNetwork = asset.details.socketAddrV4 != null || asset.details.socketAddrV6 != null;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SailStyleValues.padding16,
          vertical: SailStyleValues.padding12,
        ),
        decoration: BoxDecoration(
          color: isExpanded ? theme.colors.backgroundSecondary.withValues(alpha: 0.5) : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: theme.colors.divider, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Favorite star
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? theme.colors.orange : theme.colors.textSecondary,
                size: 20,
              ),
              onPressed: onToggleFavorite,
              tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),

            // Sequence ID
            SizedBox(
              width: 50,
              child: SailText.primary13(
                '#${asset.sequenceID}',
                monospace: true,
              ),
            ),

            // Name / Hash
            Expanded(
              flex: 2,
              child: SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  Expanded(
                    child: SailColumn(
                      spacing: 2,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (asset.plaintextName != null) SailText.primary13(asset.plaintextName!, bold: true),
                        SailText.secondary12(
                          '${asset.hash.substring(0, 16)}...',
                          monospace: true,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: SailSVG.icon(SailSVGAsset.iconCopy, width: 14),
                    onPressed: onCopyHash,
                    tooltip: 'Copy hash',
                    iconSize: 14,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                ],
              ),
            ),

            // Encryption status
            Expanded(
              child: _StatusIndicator(
                hasFeature: hasEncryption,
                label: hasEncryption ? 'Yes' : 'No',
              ),
            ),

            // Signing status
            Expanded(
              child: _StatusIndicator(
                hasFeature: hasSigning,
                label: hasSigning ? 'Yes' : 'No',
              ),
            ),

            // Network status
            Expanded(
              child: _StatusIndicator(
                hasFeature: hasNetwork,
                label: hasNetwork ? 'Available' : 'None',
              ),
            ),

            // Expand indicator (more prominent)
            SizedBox(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? theme.colors.primary.withValues(alpha: 0.1)
                          : theme.colors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: isExpanded ? theme.colors.primary : theme.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final bool hasFeature;
  final String label;

  const _StatusIndicator({
    required this.hasFeature,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailRow(
      spacing: 6,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasFeature ? theme.colors.success : theme.colors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        SailText.secondary12(label),
      ],
    );
  }
}

class _AssetDetails extends StatelessWidget {
  final BitAssetEntry asset;
  final Function(String) onCopy;

  const _AssetDetails({
    required this.asset,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding16),
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(color: theme.colors.divider, width: 1),
        ),
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary12('Asset Details', bold: true),
          const SizedBox(height: 4),

          // Full hash
          _DetailRow(
            label: 'Full Hash',
            value: asset.hash,
            onCopy: () => onCopy(asset.hash),
          ),

          // Commitment
          if (asset.details.commitment != null)
            _DetailRow(
              label: 'Commitment',
              value: asset.details.commitment!,
              onCopy: () => onCopy(asset.details.commitment!),
            ),

          // Encryption pubkey
          if (asset.details.encryptionPubkey != null)
            _DetailRow(
              label: 'Encryption Pubkey',
              value: asset.details.encryptionPubkey!,
              onCopy: () => onCopy(asset.details.encryptionPubkey!),
            ),

          // Signing pubkey
          if (asset.details.signingPubkey != null)
            _DetailRow(
              label: 'Signing Pubkey',
              value: asset.details.signingPubkey!,
              onCopy: () => onCopy(asset.details.signingPubkey!),
            ),

          // Socket addresses
          if (asset.details.socketAddrV4 != null)
            _DetailRow(
              label: 'IPv4 Address',
              value: asset.details.socketAddrV4!,
              onCopy: () => onCopy(asset.details.socketAddrV4!),
            ),

          if (asset.details.socketAddrV6 != null)
            _DetailRow(
              label: 'IPv6 Address',
              value: asset.details.socketAddrV6!,
              onCopy: () => onCopy(asset.details.socketAddrV6!),
            ),

          if (asset.details.commitment == null &&
              asset.details.encryptionPubkey == null &&
              asset.details.signingPubkey == null &&
              asset.details.socketAddrV4 == null &&
              asset.details.socketAddrV6 == null)
            SailText.secondary12('No additional metadata configured'),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: SailText.secondary12(label),
        ),
        Expanded(
          child: SailText.primary12(
            value.length > 60 ? '${value.substring(0, 60)}...' : value,
            monospace: true,
          ),
        ),
        IconButton(
          icon: SailSVG.icon(SailSVGAsset.iconCopy, width: 12),
          onPressed: onCopy,
          tooltip: 'Copy',
          iconSize: 12,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        ),
      ],
    );
  }
}

class AssetExplorerViewModel extends BaseViewModel {
  final BitAssetsProvider bitAssetsProvider = GetIt.I.get<BitAssetsProvider>();
  final AssetAnalyticsProvider analyticsProvider = GetIt.I.get<AssetAnalyticsProvider>();
  final NotificationProvider notificationProvider = GetIt.I.get<NotificationProvider>();
  final FavoritesProvider favoritesProvider = GetIt.I.get<FavoritesProvider>();

  final TextEditingController searchController = TextEditingController();

  String? expandedAssetHash;
  bool showFavoritesOnly = false;

  AssetExplorerViewModel() {
    bitAssetsProvider.addListener(notifyListeners);
    analyticsProvider.addListener(notifyListeners);
    favoritesProvider.addListener(notifyListeners);
    searchController.addListener(_onSearchChanged);
  }

  bool get isLoading => !bitAssetsProvider.initialized;

  List<BitAssetEntry> get filteredAssets {
    var assets = analyticsProvider.getFilteredAssets(bitAssetsProvider.entries);
    if (showFavoritesOnly) {
      assets = assets.where((a) => favoritesProvider.isFavorite(a.hash)).toList();
    }
    return assets;
  }

  int get assetsWithEncryption {
    return bitAssetsProvider.entries.where((a) => a.details.encryptionPubkey != null).length;
  }

  int get assetsWithSigning {
    return bitAssetsProvider.entries.where((a) => a.details.signingPubkey != null).length;
  }

  int get favoritesCount => favoritesProvider.favorites.length;

  bool isFavorite(String hash) => favoritesProvider.isFavorite(hash);

  void setShowFavoritesOnly(bool value) {
    showFavoritesOnly = value;
    notifyListeners();
  }

  Future<void> toggleFavorite(String hash) async {
    await favoritesProvider.toggleFavorite(hash);
  }

  void _onSearchChanged() {
    analyticsProvider.setAssetSearchQuery(searchController.text);
  }

  void toggleExpanded(String hash) {
    if (expandedAssetHash == hash) {
      expandedAssetHash = null;
    } else {
      expandedAssetHash = hash;
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await bitAssetsProvider.fetch();
    await analyticsProvider.fetch();
  }

  void copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    notificationProvider.add(
      title: 'Copied',
      content: 'Value copied to clipboard',
      dialogType: DialogType.success,
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    bitAssetsProvider.removeListener(notifyListeners);
    analyticsProvider.removeListener(notifyListeners);
    favoritesProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
