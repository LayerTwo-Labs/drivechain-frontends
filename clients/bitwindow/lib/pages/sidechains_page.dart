import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/sidechain_activation_management_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/widgets/error_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pbgrpc.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:super_clipboard/super_clipboard.dart';

@RoutePage()
class SidechainsPage extends StatelessWidget {
  const SidechainsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => SidechainsViewModel(),
        builder: (context, model, child) => LayoutBuilder(
          builder: (context, constraints) {
            final spacing = SailStyleValues.padding08;
            final sidechainsWidth = max(400, constraints.maxWidth * 0.25);
            final depositsWidth = constraints.maxWidth - sidechainsWidth - spacing;

            return SailRow(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: spacing,
              children: [
                if (model.hasErrorForKey('sidechain')) ...{
                  ErrorContainer(error: model.error('sidechain').toString()),
                } else ...{
                  SizedBox(
                    width: sidechainsWidth.toDouble(),
                    child: SidechainsList(),
                  ),
                },
                SizedBox(
                  width: depositsWidth,
                  child: const DepositWithdrawView(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SidechainsList extends ViewModelWidget<SidechainsViewModel> {
  const SidechainsList({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return SailRawCard(
      title: 'Sidechains',
      subtitle: 'List of sidechains and their current status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SailTable(
              getRowId: (index) => index.toString(),
              headerBuilder: (context) => [
                SailTableHeaderCell(
                  name: 'Slot',
                  onSort: () => viewModel.sortSidechains('slot'),
                ),
                SailTableHeaderCell(
                  name: 'Name',
                  onSort: () => viewModel.sortSidechains('name'),
                ),
                SailTableHeaderCell(
                  name: 'Balance',
                  onSort: () => viewModel.sortSidechains('balance'),
                ),
              ],
              rowBuilder: (context, row, selected) {
                final slot = row; // This is now the slot number (0-254)
                final sidechain = viewModel.sidechains[slot];
                final textColor =
                    sidechain == null ? context.sailTheme.colors.textSecondary : context.sailTheme.colors.text;
                return [
                  SailTableCell(value: '$slot:', textColor: textColor),
                  SailTableCell(value: sidechain?.info.title ?? '', textColor: textColor),
                  SailTableCell(
                    value: formatBitcoin(
                      satoshiToBTC(sidechain?.info.balanceSatoshi.toInt() ?? 0),
                    ),
                    textColor: textColor,
                  ),
                ];
              },
              rowCount: 255, // Show all possible slots
              columnWidths: const [21, 150, 100],
              backgroundColor: context.sailTheme.colors.backgroundSecondary,
              sortAscending: viewModel.sortAscending,
              sortColumnIndex: ['slot', 'name', 'balance'].indexOf(viewModel.sortColumn),
              onSort: (columnIndex, ascending) => viewModel.sortSidechains(viewModel.sortColumn),
              selectedRowId: viewModel.selectedIndex?.toString(),
              onSelectedRow: (rowId) => viewModel.toggleSelection(int.parse(rowId ?? '0')),
            ),
          ),
          const SizedBox(height: SailStyleValues.padding16),
          Center(
            child: QtButton(
              label: 'Add / Remove',
              onPressed: () => showSidechainActivationManagementModal(context),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectableListTile extends StatelessWidget {
  final int index;
  final SidechainOverview? sidechain;
  final Color textColor;
  final bool isSelected;
  final VoidCallback onSelected;

  const SelectableListTile({
    required this.index,
    required this.sidechain,
    required this.textColor,
    required this.isSelected,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        color: isSelected ? context.sailTheme.colors.primary.withValues(alpha: 0.5) : Colors.transparent,
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: SailText.primary13(
                '$index: ',
                color: textColor,
              ),
            ),
            SizedBox(
              width: 80,
              child: SailText.primary13(
                sidechain == null ? 'Inactive' : sidechain!.info.title,
                color: textColor,
              ),
            ),
            const SailSpacing(SailStyleValues.padding16),
            SizedBox(
              width: 120,
              child: SailText.primary13(
                sidechain == null ? '' : formatBitcoin(satoshiToBTC(sidechain!.info.balanceSatoshi.toInt())),
                color: textColor,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SidechainsViewModel extends BaseViewModel {
  final TransactionProvider transactionsProvider = GetIt.I.get<TransactionProvider>();
  final SidechainProvider sidechainProvider = GetIt.I.get<SidechainProvider>();
  final BitwindowRPC api = GetIt.I.get<BitwindowRPC>();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController depositAmountController = TextEditingController();
  final TextEditingController feeController = TextEditingController(text: '0.0001');

  SidechainsViewModel() {
    sidechainProvider
      ..addListener(notifyListeners)
      ..addListener(errorListener);
    addressController.addListener(notifyListeners);
    depositAmountController.addListener(notifyListeners);
    feeController.addListener(notifyListeners);
  }
  List<SidechainOverview?> get sidechains => sidechainProvider.sidechains;

  List<SidechainOverview?> _sortedSidechains = [];

  String sortColumn = 'index';
  bool sortAscending = true;

  List<SidechainOverview?> get sortedSidechains {
    if (!listEquals(_sortedSidechains, sidechains)) {
      _sortedSidechains = List<SidechainOverview?>.from(sidechains);
      _sortEntries();
    }
    return _sortedSidechains;
  }

  void sortSidechains(String column) {
    if (sortColumn == column) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    _sortEntries();
    notifyListeners();
  }

  void _sortEntries() {
    _sortedSidechains.sort((a, b) {
      if (a == null && b == null) return 0;
      if (a == null) return sortAscending ? 1 : -1;
      if (b == null) return sortAscending ? -1 : 1;

      dynamic aValue;
      dynamic bValue;

      switch (sortColumn) {
        case 'index':
          aValue = sidechains.indexOf(a);
          bValue = sidechains.indexOf(b);
          break;
        case 'balance':
          aValue = a.info.balanceSatoshi;
          bValue = b.info.balanceSatoshi;
          break;
        case 'title':
          aValue = a.info.title;
          bValue = b.info.title;
          break;
        default:
          return 0;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  int? _selectedIndex;

  int? get selectedIndex => _selectedIndex;

  void toggleSelection(int index) {
    if (_selectedIndex == index) {
      _selectedIndex = null; // Deselect if the same item is selected again
      // refetch sidechain deposits!
    } else {
      _selectedIndex = index; // Select the new item
    }
    notifyListeners();
  }

  void errorListener() {
    if (sidechainProvider.error != null) {
      setErrorForObject('sidechain', sidechainProvider.error);
    }
  }

  void decrementSelectedIndex() {
    _selectedIndex = max(0, (_selectedIndex ?? 0) - 1);
    notifyListeners();
  }

  void incrementSelectedIndex() {
    _selectedIndex = min(254, (_selectedIndex ?? 0) + 1);
    notifyListeners();
  }

  List<ListSidechainDepositsResponse_SidechainDeposit> _sortedDeposits = [];
  String depositSortColumn = 'amount';
  bool depositSortAscending = true;

  List<ListSidechainDepositsResponse_SidechainDeposit> get sortedDeposits {
    if (!listEquals(_sortedDeposits, recentDeposits)) {
      _sortedDeposits = List<ListSidechainDepositsResponse_SidechainDeposit>.from(recentDeposits);
      _sortDeposits();
    }
    return _sortedDeposits;
  }

  List<ListSidechainDepositsResponse_SidechainDeposit> get sortedWithdrawals {
    if (!listEquals(_sortedDeposits, recentDeposits)) {
      _sortedDeposits = List<ListSidechainDepositsResponse_SidechainDeposit>.from(recentDeposits);
      _sortDeposits();
    }
    return _sortedDeposits;
  }

  void sortDeposits(String column) {
    if (depositSortColumn == column) {
      depositSortAscending = !depositSortAscending;
    } else {
      depositSortColumn = column;
      depositSortAscending = true;
    }
    _sortDeposits();
    notifyListeners();
  }

  void _sortDeposits() {
    _sortedDeposits.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (depositSortColumn) {
        case 'amount':
          aValue = a.amount;
          bValue = b.amount;
          break;
        case 'txid':
          aValue = a.txid;
          bValue = b.txid;
          break;
        case 'address':
          aValue = a.address;
          bValue = b.address;
          break;
        case 'confirmations':
          aValue = a.confirmations;
          bValue = b.confirmations;
          break;
        default:
          return 0;
      }

      return depositSortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  List<ListSidechainDepositsResponse_SidechainDeposit> get recentDeposits =>
      sidechainProvider.sidechains[_selectedIndex ?? 254]?.deposits ?? [];

  void pasteAddress() async {
    if (SystemClipboard.instance != null) {
      await SystemClipboard.instance?.read().then((reader) async {
        if (reader.canProvide(Formats.plainText)) {
          final text = await reader.readValue(Formats.plainText);
          addressController.text = text ?? addressController.text;
          notifyListeners();
        }
      });
    }
  }

  void clearAddress() {
    addressController.clear();
    notifyListeners();
  }

  void deposit(BuildContext context) async {
    if (double.tryParse(depositAmountController.text) == null) {
      showSnackBar(context, 'Invalid amount, enter a number');
      return;
    }
    if (double.tryParse(feeController.text) == null) {
      showSnackBar(context, 'Invalid fee, enter a number');
      return;
    }

    try {
      setBusy(true);
      await api.wallet.createSidechainDeposit(
        _selectedIndex ?? 254,
        addressController.text,
        double.parse(depositAmountController.text),
        double.parse(feeController.text),
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Could not create deposit:\n$e');
      }
    } finally {
      setBusy(false);
    }

    // refetch sidechain transaction list & transaction list
    await sidechainProvider.fetch();
    await transactionsProvider.fetch();
  }

  @override
  void dispose() {
    super.dispose();
    sidechainProvider.removeListener(notifyListeners);
    addressController.removeListener(notifyListeners);
    depositAmountController.removeListener(notifyListeners);
    feeController.removeListener(notifyListeners);
  }
}

class DepositWithdrawView extends ViewModelWidget<SidechainsViewModel> {
  const DepositWithdrawView({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return InlineTabBar(
      tabs: [
        TabItem(
          label: 'Create Deposits',
          icon: SailSVGAsset.iconDeposit,
          child: MakeDepositsView(),
        ),
        TabItem(
          label: 'See Withdrawals',
          icon: SailSVGAsset.iconWithdraw,
          child: SeeWithdrawalsView(),
        ),
      ],
      initialIndex: 0,
    );
  }
}

class MakeDepositsView extends ViewModelWidget<SidechainsViewModel> {
  const MakeDepositsView({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return SailRawCard(
      bottomPadding: false,
      child: SailColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: SailStyleValues.padding08,
        children: [
          SailRow(
            spacing: SailStyleValues.padding08,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 2, // take up 2/3 of the space
                child: SailTextField(
                  label: 'Sidechain Deposit Address',
                  controller: viewModel.addressController,
                  hintText: 's${viewModel._selectedIndex ?? 0}_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx_xxxxxx',
                  size: TextFieldSize.small,
                ),
              ),
              QtIconButton(
                tooltip: 'Paste from clipboard',
                onPressed: viewModel.pasteAddress,
                icon: Icon(
                  Icons.content_paste_rounded,
                  size: 20.0,
                  color: context.sailTheme.colors.text,
                ),
              ),
              QtIconButton(
                tooltip: 'Clear',
                onPressed: viewModel.clearAddress,
                icon: Icon(
                  Icons.cancel_outlined,
                  size: 20.0,
                  color: context.sailTheme.colors.text,
                ),
              ),
              Expanded(
                flex: 1, // This makes the remaining space take up 1/3
                child: Container(),
              ),
            ],
          ),
          SailRow(
            spacing: SailStyleValues.padding08,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 2, // take up 2/3 of the space
                child: NumericField(
                  label: 'Deposit Amount',
                  controller: viewModel.depositAmountController,
                  hintText: '0.00',
                ),
              ),
              UnitDropdown(
                value: Unit.BTC,
                onChanged: (_) => {},
                enabled: false,
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          SailPadding(
            padding: EdgeInsets.symmetric(vertical: SailStyleValues.padding08),
            child: SailText.secondary13(
              'The sidechain may also deduct a fee from your deposit.',
              color: context.sailTheme.colors.textTertiary,
            ),
          ),
          QtButton(
            label: 'Deposit',
            disabled: viewModel.addressController.text == '' ||
                viewModel.depositAmountController.text == '' ||
                viewModel.feeController.text == '',
            onPressed: () => viewModel.deposit(context),
            loading: viewModel.isBusy,
          ),
          const SizedBox(height: SailStyleValues.padding16),
          Expanded(
            child: SailRawCard(
              title: 'Your Recent Deposits',
              subtitle: 'Recent deposits to sidechains, coming from your onchain-wallet.',
              shadowSize: ShadowSize.none,
              padding: false,
              child: RecentDepositsTable(),
            ),
          ),
        ],
      ),
    );
  }
}

class SeeWithdrawalsView extends ViewModelWidget<SidechainsViewModel> {
  const SeeWithdrawalsView({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return SailRawCard(
      bottomPadding: false,
      child: RecentWithdrawalsTable(),
    );
  }
}

class RecentDepositsTable extends ViewModelWidget<SidechainsViewModel> {
  const RecentDepositsTable({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return SailTable(
      getRowId: (index) => viewModel.sortedDeposits[index].txid,
      headerBuilder: (context) => [
        SailTableHeaderCell(
          name: 'SC #',
          onSort: () => viewModel.sortDeposits('sc'),
        ),
        SailTableHeaderCell(
          name: 'Amount',
          onSort: () => viewModel.sortDeposits('amount'),
        ),
        SailTableHeaderCell(
          name: 'Txid',
          onSort: () => viewModel.sortDeposits('txid'),
        ),
        SailTableHeaderCell(
          name: 'Address',
          onSort: () => viewModel.sortDeposits('address'),
        ),
        SailTableHeaderCell(
          name: 'Visible on SC?',
          onSort: () => viewModel.sortDeposits('confirmations'),
        ),
      ],
      rowBuilder: (context, row, selected) {
        final deposit = viewModel.sortedDeposits[row];
        return [
          SailTableCell(value: viewModel.selectedIndex.toString()),
          SailTableCell(value: deposit.amount.toString()),
          SailTableCell(value: deposit.txid),
          SailTableCell(value: deposit.address),
          SailTableCell(value: deposit.confirmations >= 2 ? 'Yes' : 'No'),
        ];
      },
      rowCount: viewModel.sortedDeposits.length,
      columnWidths: const [50, 100, 200, 200, 100],
      drawGrid: true,
      sortAscending: viewModel.depositSortAscending,
      sortColumnIndex: ['sc', 'amount', 'txid', 'address', 'confirmations'].indexOf(viewModel.depositSortColumn),
      onSort: (columnIndex, ascending) => viewModel.sortDeposits(viewModel.depositSortColumn),
    );
  }
}

class RecentWithdrawalsTable extends ViewModelWidget<SidechainsViewModel> {
  const RecentWithdrawalsTable({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return SailTable(
      getRowId: (index) => viewModel.sortedWithdrawals[index].txid,
      headerBuilder: (context) => [
        SailTableHeaderCell(
          name: 'SC #',
          onSort: () => viewModel.sortDeposits('sc'),
        ),
        SailTableHeaderCell(
          name: 'Age',
          onSort: () => viewModel.sortDeposits('age'),
        ),
        SailTableHeaderCell(
          name: 'Max Age',
          onSort: () => viewModel.sortDeposits('maxage'),
        ),
        SailTableHeaderCell(
          name: 'Acks',
          onSort: () => viewModel.sortDeposits('acks'),
        ),
        SailTableHeaderCell(
          name: 'Approved',
          onSort: () => viewModel.sortDeposits('approved'),
        ),
        SailTableHeaderCell(
          name: 'Withdrawal Hash',
          onSort: () => viewModel.sortDeposits('withdrawalhash'),
        ),
      ],
      rowBuilder: (context, row, selected) {
        final withdrawal = viewModel.sortedWithdrawals[row];
        return [
          SailTableCell(value: viewModel.selectedIndex.toString()),
          SailTableCell(value: withdrawal.amount.toString()),
          SailTableCell(value: withdrawal.txid),
          SailTableCell(value: withdrawal.address),
          SailTableCell(value: withdrawal.confirmations >= 2 ? 'Yes' : 'No'),
          SailTableCell(value: withdrawal.confirmations >= 2 ? 'Yes' : 'No'),
        ];
      },
      rowCount: viewModel.sortedWithdrawals.length,
      columnWidths: const [50, 100, 200, 200, 100, 200],
      drawGrid: true,
      sortAscending: viewModel.depositSortAscending,
      sortColumnIndex:
          ['sc', 'age', 'maxage', 'acks', 'approved', 'withdrawalhash'].indexOf(viewModel.depositSortColumn),
      onSort: (columnIndex, ascending) => viewModel.sortDeposits(viewModel.depositSortColumn),
    );
  }
}
