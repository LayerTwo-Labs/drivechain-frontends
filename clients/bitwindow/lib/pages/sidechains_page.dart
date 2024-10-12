import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/gen/wallet/v1/wallet.pbgrpc.dart';
import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/pages/send_page.dart';
import 'package:bitwindow/pages/sidechain_activation_management_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/servers/api.dart';
import 'package:bitwindow/widgets/error_container.dart';
import 'package:bitwindow/widgets/qt_button.dart';
import 'package:bitwindow/widgets/qt_container.dart';
import 'package:bitwindow/widgets/qt_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/containers/qt_page.dart';
import 'package:stacked/stacked.dart';
import 'package:super_clipboard/super_clipboard.dart';

@RoutePage()
class SidechainsPage extends StatelessWidget {
  const SidechainsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const QtPage(
      child: SidechainsView(),
    );
  }
}

class SidechainsView extends StatelessWidget {
  const SidechainsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => SidechainsViewModel(),
      builder: (context, model, child) => Row(
        children: [
          if (model.hasErrorForKey('sidechain')) ...{
            ErrorContainer(error: model.error('sidechain').toString()),
          } else ...{
            const Expanded(child: SidechainsList()),
          },
          const Expanded(child: DepositView()),
        ],
      ),
    );
  }
}

class SidechainsList extends ViewModelWidget<SidechainsViewModel> {
  const SidechainsList({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return QtContainer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: SailTheme.of(context).colors.backgroundSecondary,
              child: ListView.builder(
                itemCount: viewModel.sidechains.length,
                itemBuilder: (context, index) {
                  final sidechain = viewModel.sidechains[index];
                  final textColor = sidechain == null
                      ? SailTheme.of(context).colors.textSecondary
                      : SailTheme.of(context).colors.text;

                  return SelectableListTile(
                    index: index,
                    sidechain: sidechain,
                    textColor: textColor,
                    isSelected: viewModel.selectedIndex == index,
                    onSelected: () {
                      viewModel.toggleSelection(index);
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: SailStyleValues.padding15),
          Center(
            child: QtButton(
              child: SailText.primary12('Add / Remove'),
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
        color: isSelected ? context.sailTheme.colors.primary.withOpacity(0.5) : Colors.transparent,
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
            const SailSpacing(SailStyleValues.padding15),
            SizedBox(
              width: 120,
              child: SailText.primary13(
                sidechain == null ? '' : formatBitcoin(satoshiToBTC(sidechain!.info.amountSatoshi.toInt())),
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
  final API api = GetIt.I.get<API>();

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

class DepositView extends ViewModelWidget<SidechainsViewModel> {
  const DepositView({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return QtContainer(
      child: SailPadding(
        child: SailColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: SailStyleValues.padding08,
          children: [
            SailText.primary13('An address you own on the sidechain you are depositing to:'),
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                Expanded(
                  child: SailTextField(
                    controller: viewModel.addressController,
                    hintText: 'Enter a sidechain address',
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
              ],
            ),
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailText.primary13('Amount:'),
                Expanded(
                  child: NumericField(
                    controller: viewModel.depositAmountController,
                    hintText: '0.00',
                  ),
                ),
                UnitDropdown(
                  value: Unit.BTC,
                  onChanged: (_) => {},
                  enabled: false,
                ),
              ],
            ),
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailText.primary13('Fee:'),
                Expanded(
                  child: NumericField(
                    controller: viewModel.feeController,
                    hintText: '0.00',
                  ),
                ),
                UnitDropdown(
                  value: Unit.BTC,
                  onChanged: (_) => {},
                  enabled: false,
                ),
              ],
            ),
            QtButton(
              disabled: viewModel.addressController.text == '' ||
                  viewModel.depositAmountController.text == '' ||
                  viewModel.feeController.text == '',
              onPressed: () => viewModel.deposit(context),
              loading: viewModel.isBusy,
              child: SailText.primary12('Deposit'),
            ),
            SailText.secondary12('The sidechain may also deduct a fee from your deposit.'),
            const SizedBox(height: SailStyleValues.padding15),
            const QtSeparator(),
            SailText.primary13('Your Recent Deposits:'),
            Expanded(
              child: RecentDepositsTable(deposits: viewModel.recentDeposits),
            ),
            SailText.secondary12('We have no way of knowing when/if your deposit will show up on the SC'),
          ],
        ),
      ),
    );
  }
}

class RecentDepositsTable extends ViewModelWidget<SidechainsViewModel> {
  final List<ListSidechainDepositsResponse_SidechainDeposit> deposits;

  const RecentDepositsTable({super.key, required this.deposits});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return QtContainer(
      tight: true,
      child: SailTable(
        getRowId: (index) => deposits[index].txid,
        headerBuilder: (context) => [
          SailTableHeaderCell(child: SailText.primary12('SC #')),
          SailTableHeaderCell(child: SailText.primary12('Amount')),
          SailTableHeaderCell(child: SailText.primary12('Txid')),
          SailTableHeaderCell(child: SailText.primary12('Address')),
          SailTableHeaderCell(child: SailText.primary12('Visible on SC?')),
        ],
        rowBuilder: (context, row, selected) {
          final deposit = deposits[row];
          return [
            SailTableCell(child: SailText.primary12(viewModel._selectedIndex.toString())),
            SailTableCell(child: SailText.primary12(deposit.amount.toString())),
            SailTableCell(child: SailText.primary12(deposit.txid.toString())),
            SailTableCell(child: SailText.primary12(deposit.address)),
            SailTableCell(child: SailText.primary12(deposit.confirmations >= 2 ? 'Yes' : 'No')),
          ];
        },
        rowCount: deposits.length,
        columnCount: 5,
        columnWidths: const [50, 100, 200, 200, 100],
        headerDecoration: BoxDecoration(
          color: context.sailTheme.colors.formFieldBorder,
        ),
        drawGrid: true,
      ),
    );
  }
}
