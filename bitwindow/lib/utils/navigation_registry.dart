class NavigationTarget {
  final int tabIndex;
  final int? sectionIndex;
  final int? subtabIndex;

  const NavigationTarget({required this.tabIndex, this.sectionIndex, this.subtabIndex});
}

// Tab indices for bitwindow
class TabIndices {
  static const int overview = 0;
  static const int wallet = 1;
  static const int sidechains = 2;
  static const int learn = 3;
  static const int console = 4;
  static const int settings = 5;
}

// Wallet subtab indices (matches InlineTabBar order in wallet_page.dart)
class WalletSubtabs {
  static const int overview = 0;
  static const int send = 1;
  static const int receive = 2;
  static const int utxos = 3;
  static const int checks = 4;
  static const int timestamps = 5;
  static const int tools = 6;
}

final Map<String, NavigationTarget> navigationRegistry = {
  // Settings sections
  'settings_network.dart': NavigationTarget(tabIndex: TabIndices.settings, sectionIndex: 0),
  'settings_security.dart': NavigationTarget(tabIndex: TabIndices.settings, sectionIndex: 1),
  'settings_appearance.dart': NavigationTarget(tabIndex: TabIndices.settings, sectionIndex: 2),
  'settings_advanced.dart': NavigationTarget(tabIndex: TabIndices.settings, sectionIndex: 3),
  'settings_reset.dart': NavigationTarget(tabIndex: TabIndices.settings, sectionIndex: 4),
  'settings_about.dart': NavigationTarget(tabIndex: TabIndices.settings, sectionIndex: 5),

  // Main tabs
  'overview_page.dart': NavigationTarget(tabIndex: TabIndices.overview),
  'sidechains_page.dart': NavigationTarget(tabIndex: TabIndices.sidechains),
  'learn_page.dart': NavigationTarget(tabIndex: TabIndices.learn),
  'console_page.dart': NavigationTarget(tabIndex: TabIndices.console),
  'bitwindow_console_tab.dart': NavigationTarget(tabIndex: TabIndices.console),

  // Wallet tab and subtabs
  'wallet_page.dart': NavigationTarget(tabIndex: TabIndices.wallet),
  'wallet_overview.dart': NavigationTarget(tabIndex: TabIndices.wallet, subtabIndex: WalletSubtabs.overview),
  'wallet_send.dart': NavigationTarget(tabIndex: TabIndices.wallet, subtabIndex: WalletSubtabs.send),
  'wallet_receive.dart': NavigationTarget(tabIndex: TabIndices.wallet, subtabIndex: WalletSubtabs.receive),
  'wallet_utxos.dart': NavigationTarget(tabIndex: TabIndices.wallet, subtabIndex: WalletSubtabs.utxos),
  'wallet_checks.dart': NavigationTarget(tabIndex: TabIndices.wallet, subtabIndex: WalletSubtabs.checks),
  'wallet_timestamps.dart': NavigationTarget(tabIndex: TabIndices.wallet, subtabIndex: WalletSubtabs.timestamps),
  'denability_page.dart': NavigationTarget(tabIndex: TabIndices.wallet, subtabIndex: WalletSubtabs.tools),
  'wallet_hd.dart': NavigationTarget(tabIndex: TabIndices.wallet, subtabIndex: WalletSubtabs.tools),
  'bitdrive_page.dart': NavigationTarget(tabIndex: TabIndices.wallet, subtabIndex: WalletSubtabs.tools),
  'wallet_multisig_lounge.dart': NavigationTarget(tabIndex: TabIndices.wallet, subtabIndex: WalletSubtabs.tools),
};
