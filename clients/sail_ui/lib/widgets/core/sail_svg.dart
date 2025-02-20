import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sail_ui/sail_ui.dart';

enum SailSVGAsset {
  iconTabPeg,
  iconTabBMM,
  iconTabWithdrawalExplorer,

  iconTabSidechainSend,

  iconTabZCashMeltCast,
  iconTabZCashShieldDeshield,
  iconTabZCashOperationStatuses,

  iconTabConsole,
  iconTabSettings,
  iconTabTools,
  iconTabStarters,

  iconCalendar,
  iconQuestion,
  iconSearch,
  iconCopy,
  iconRestart,
  iconArrow,
  iconArrowForward,
  iconClose,
  iconGlobe,
  iconExpand,
  iconDropdown,
  iconDeposit,
  iconWithdraw,
  iconFormat,
  iconMelt,
  iconCast,
  iconTerminal,
  iconNetwork,
  iconPeers,
  iconPen,
  iconCheck,
  iconNewWindow,

  iconHome,
  iconSend,
  iconReceive,
  iconTransactions,
  iconSidechains,
  iconLearn,

  iconSuccess,
  iconPending,
  iconPendingHalf,
  iconFailed,
  iconInfo,
  iconSelected,
  iconCoins,
  iconConnectionStatus,
  iconWarning,
  iconWallet,
  iconCoinnews,
  iconDelete,
  iconMultisig,
  iconBitdrive,
  iconHDWallet,

  iconLightMode,
  iconDarkMode,
  iconLightDarkMode,

  meltCastDiagram,

  dividerDot,
}

enum SailPNGAsset {
  meltCastDiagram,
  articleBeginner,
}

/// If you don't want to overwrite the color of the svg, put it in here!
// useful for svgs that already have a color like red or blue, that are
// not supposed to be the same color of the text, or ones that have
// multiple colors
const coloredAssets = [
  SailSVGAsset.iconSuccess,
  SailSVGAsset.iconPending,
  SailSVGAsset.iconPendingHalf,
  SailSVGAsset.iconFailed,
  SailSVGAsset.iconInfo,
];

class SailSVG {
  static Widget icon(
    SailSVGAsset asset, {
    bool isHighlighted = false,
    double? width,
    double? height,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final colors = SailTheme.of(context).colors;

        return SailSVG.fromAsset(
          asset,
          color: color ?? (coloredAssets.contains(asset) ? null : (isHighlighted ? colors.primary : colors.icon)),
          width: width ?? SailStyleValues.iconSizePrimary,
          height: height ?? SailStyleValues.iconSizePrimary,
        );
      },
    );
  }

  static SvgPicture fromAsset(
    SailSVGAsset asset, {
    double? height,
    double? width,
    Color? color,
  }) {
    return SvgPicture.asset(
      asset.toAssetPath(),
      package: 'sail_ui',
      width: width,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      height: height,
    );
  }

  static Widget png(
    SailPNGAsset asset, {
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Image.asset(
      asset.toAssetPath(),
      package: 'sail_ui',
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
    );
  }
}

extension AsAssetPath on SailSVGAsset {
  String toAssetPath() {
    switch (this) {
      case SailSVGAsset.iconTabPeg:
        return 'assets/svgs/icon_tab_peg.svg';
      case SailSVGAsset.iconTabBMM:
        return 'assets/svgs/icon_tab_bmm.svg';
      case SailSVGAsset.iconTabWithdrawalExplorer:
        return 'assets/svgs/icon_tab_withdrawal_explorer.svg';

      case SailSVGAsset.iconTabSidechainSend:
        return 'assets/svgs/icon_tab_send.svg';

      case SailSVGAsset.iconTabZCashMeltCast:
        return 'assets/svgs/icon_tab_melt_cast.svg';
      case SailSVGAsset.iconTabZCashShieldDeshield:
        return 'assets/svgs/icon_tab_shield_deshield.svg';
      case SailSVGAsset.iconTabZCashOperationStatuses:
        return 'assets/svgs/icon_tab_operation_statuses.svg';

      case SailSVGAsset.iconTabConsole:
        return 'assets/svgs/icon_tab_console.svg';
      case SailSVGAsset.iconTabSettings:
        return 'assets/svgs/icon_tab_settings.svg';
      case SailSVGAsset.iconTabTools:
        return 'assets/svgs/icon_tab_tools.svg';
      case SailSVGAsset.iconTabStarters:
        return 'assets/svgs/icon_tab_starters.svg';

      case SailSVGAsset.iconCalendar:
        return 'assets/svgs/icon_calendar.svg';
      case SailSVGAsset.iconQuestion:
        return 'assets/svgs/icon_question.svg';
      case SailSVGAsset.iconSearch:
        return 'assets/svgs/icon_search.svg';
      case SailSVGAsset.iconCopy:
        return 'assets/svgs/icon_copy.svg';
      case SailSVGAsset.iconRestart:
        return 'assets/svgs/icon_restart.svg';
      case SailSVGAsset.iconArrow:
        return 'assets/svgs/icon_arrow_down.svg';
      case SailSVGAsset.iconArrowForward:
        return 'assets/svgs/icon_arrow_forward.svg';
      case SailSVGAsset.iconClose:
        return 'assets/svgs/icon_close.svg';
      case SailSVGAsset.iconGlobe:
        return 'assets/svgs/icon_globe.svg';
      case SailSVGAsset.iconExpand:
        return 'assets/svgs/icon_expand.svg';
      case SailSVGAsset.iconDropdown:
        return 'assets/svgs/icon_dropdown.svg';
      case SailSVGAsset.iconDeposit:
        return 'assets/svgs/icon_deposit.svg';
      case SailSVGAsset.iconWithdraw:
        return 'assets/svgs/icon_withdraw.svg';

      case SailSVGAsset.iconFormat:
        return 'assets/svgs/icon_format.svg';
      case SailSVGAsset.iconMelt:
        return 'assets/svgs/icon_melt.svg';
      case SailSVGAsset.iconCast:
        return 'assets/svgs/icon_cast.svg';
      case SailSVGAsset.iconTerminal:
        return 'assets/svgs/icon_terminal.svg';
      case SailSVGAsset.iconNetwork:
        return 'assets/svgs/icon_network.svg';
      case SailSVGAsset.iconPeers:
        return 'assets/svgs/icon_peers.svg';
      case SailSVGAsset.iconPen:
        return 'assets/svgs/icon_pen.svg';
      case SailSVGAsset.iconCheck:
        return 'assets/svgs/icon_check.svg';
      case SailSVGAsset.iconNewWindow:
        return 'assets/svgs/icon_new_window.svg';

      case SailSVGAsset.iconHome:
        return 'assets/svgs/icon_home.svg';
      case SailSVGAsset.iconSend:
        return 'assets/svgs/icon_send.svg';
      case SailSVGAsset.iconReceive:
        return 'assets/svgs/icon_receive.svg';
      case SailSVGAsset.iconTransactions:
        return 'assets/svgs/icon_transactions.svg';
      case SailSVGAsset.iconSidechains:
        return 'assets/svgs/icon_sidechains.svg';
      case SailSVGAsset.iconLearn:
        return 'assets/svgs/icon_learn.svg';

      case SailSVGAsset.iconSuccess:
        return 'assets/svgs/icon_success.svg';
      case SailSVGAsset.iconPending:
        return 'assets/svgs/icon_pending.svg';
      case SailSVGAsset.iconPendingHalf:
        return 'assets/svgs/icon_pending_half.svg';
      case SailSVGAsset.iconFailed:
        return 'assets/svgs/icon_failed.svg';
      case SailSVGAsset.iconInfo:
        return 'assets/svgs/icon_info.svg';
      case SailSVGAsset.iconSelected:
        return 'assets/svgs/icon_selected.svg';
      case SailSVGAsset.iconCoins:
        return 'assets/svgs/icon_coins.svg';
      case SailSVGAsset.iconConnectionStatus:
        return 'assets/svgs/icon_connection_status.svg';
      case SailSVGAsset.iconWarning:
        return 'assets/svgs/icon_warning.svg';
      case SailSVGAsset.iconWallet:
        return 'assets/svgs/icon_wallet.svg';
      case SailSVGAsset.iconCoinnews:
        return 'assets/svgs/icon_coinnews.svg';
      case SailSVGAsset.iconDelete:
        return 'assets/svgs/icon_delete.svg';
      case SailSVGAsset.iconMultisig:
        return 'assets/svgs/icon_multisig.svg';
      case SailSVGAsset.iconBitdrive:
        return 'assets/svgs/icon_bitdrive.svg';
      case SailSVGAsset.iconHDWallet:
        return 'assets/svgs/icon_hdwallet.svg';

      case SailSVGAsset.iconLightMode:
        return 'assets/svgs/icon_light_mode.svg';
      case SailSVGAsset.iconDarkMode:
        return 'assets/svgs/icon_dark_mode.svg';
      case SailSVGAsset.iconLightDarkMode:
        return 'assets/svgs/icon_light_dark_mode.svg';

      case SailSVGAsset.meltCastDiagram:
        return 'assets/pngs/meltcastdiagram.png';

      case SailSVGAsset.dividerDot:
        return 'assets/svgs/divider_dot.svg';
    }
  }
}

extension PNGAsAssetPath on SailPNGAsset {
  String toAssetPath() {
    switch (this) {
      case SailPNGAsset.meltCastDiagram:
        return 'assets/pngs/meltcastdiagram.png';
      case SailPNGAsset.articleBeginner:
        return 'assets/pngs/article-beginner.png';
    }
  }
}
