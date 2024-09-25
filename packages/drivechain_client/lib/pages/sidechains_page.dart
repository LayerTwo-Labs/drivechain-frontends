import 'package:auto_route/auto_route.dart';
import 'package:drivechain_client/gen/wallet/v1/wallet.pbgrpc.dart';
import 'package:drivechain_client/pages/overview_page.dart';
import 'package:drivechain_client/pages/send_page.dart';
import 'package:drivechain_client/providers/sidechain_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
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
      builder: (context, model, child) => const Row(
        children: [
          Expanded(child: SidechainsViewContent()),
          Expanded(child: DepositView()),
        ],
      ),
    );
  }
}

class SidechainsViewContent extends ViewModelWidget<SidechainsViewModel> {
  const SidechainsViewContent({super.key});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QtButton(
                onPressed: () {
                  showSnackBar(context, 'Not implemented');
                },
                child: SailText.primary13('Add / Remove'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SelectableListTile extends StatelessWidget {
  final int index;
  final Sidechain? sidechain;
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
        color: isSelected ? SailTheme.of(context).colors.primary.withOpacity(0.5) : Colors.transparent,
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
  final SidechainProvider sidechainProvider = GetIt.I.get<SidechainProvider>();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController depositAmountController = TextEditingController();
  final TextEditingController feeController = TextEditingController();

  SidechainsViewModel() {
    sidechainProvider.addListener(notifyListeners);
    addressController.addListener(notifyListeners);
    depositAmountController.addListener(notifyListeners);
    feeController.addListener(notifyListeners);
  }

  List<Sidechain?> get sidechains => sidechainProvider.sidechains;

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

  void deposit(BuildContext context) {
    // Implement deposit functionality
    showSnackBar(context, 'Deposit functionality not implemented');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary13('An address you own on the sidechain you are depositing to:'),
            const SizedBox(height: SailStyleValues.padding08),
            Row(
              children: [
                Expanded(
                  child: SailTextField(
                    controller: viewModel.addressController,
                    hintText: 'Enter a sidechain address',
                    size: TextFieldSize.small,
                  ),
                ),
                const SizedBox(width: SailStyleValues.padding08),
                QtIconButton(
                  onPressed: viewModel.pasteAddress,
                  icon: Icon(
                    Icons.content_paste_rounded,
                    size: 20.0,
                    color: context.sailTheme.colors.text,
                  ),
                ),
                const SizedBox(width: SailStyleValues.padding08),
                QtIconButton(
                  onPressed: viewModel.clearAddress,
                  icon: Icon(
                    Icons.cancel_outlined,
                    size: 20.0,
                    color: context.sailTheme.colors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SailStyleValues.padding15),
            Row(
              children: [
                SailText.primary13('Deposit:'),
                const SizedBox(width: SailStyleValues.padding08),
                Expanded(
                  child: NumericField(
                    controller: viewModel.depositAmountController,
                    hintText: '0.00',
                  ),
                ),
                const SizedBox(width: SailStyleValues.padding08),
                UnitDropdown(
                  value: Unit.BTC,
                  onChanged: (_) => {},
                  enabled: false,
                ),
              ],
            ),
            const SizedBox(height: SailStyleValues.padding15),
            Row(
              children: [
                SailText.primary13('Fee:'),
                const SizedBox(width: SailStyleValues.padding08),
                Expanded(
                  child: NumericField(
                    controller: viewModel.feeController,
                    hintText: '0.00',
                  ),
                ),
                const SizedBox(width: SailStyleValues.padding08),
                UnitDropdown(
                  value: Unit.BTC,
                  onChanged: (_) => {},
                  enabled: false,
                ),
              ],
            ),
            const SizedBox(height: SailStyleValues.padding15),
            QtButton(
              enabled: viewModel.addressController.text != '' ||
                  viewModel.depositAmountController.text != '' ||
                  viewModel.feeController.text != '',
              onPressed: () => viewModel.deposit(context),
              child: SailText.primary12('Deposit'),
            ),
            const SizedBox(height: SailStyleValues.padding15),
            SailText.secondary12('The sidechain may also deduct a fee from your deposit.'),
            const SizedBox(height: SailStyleValues.padding30),
            const QtSeparator(),
            const SizedBox(height: SailStyleValues.padding15),
            SailText.primary13('Your Recent Deposits:'),
            const SizedBox(height: SailStyleValues.padding08),
            Expanded(
              child: RecentDepositsTable(deposits: viewModel.recentDeposits),
            ),
            const SizedBox(height: SailStyleValues.padding08),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            decoration: BoxDecoration(
              color: context.sailTheme.colors.background,
              border: Border.all(
                color: context.sailTheme.colors.formFieldBorder,
                width: 1.0,
              ),
            ),
            border: TableBorder.symmetric(
              inside: BorderSide(
                color: context.sailTheme.colors.formFieldBorder,
                width: 1.0,
              ),
            ),
            headingRowColor: WidgetStateProperty.all(
              context.sailTheme.colors.formFieldBorder,
            ),
            columnSpacing: SailStyleValues.padding15,
            headingRowHeight: 24.0,
            dataTextStyle: SailStyleValues.twelve,
            headingTextStyle: SailStyleValues.ten,
            dividerThickness: 0,
            dataRowMaxHeight: 48.0,
            columns: [
              DataColumn(label: SailText.primary12('SC #')),
              DataColumn(label: SailText.primary12('Amount')),
              DataColumn(label: SailText.primary12('Txid')),
              DataColumn(label: SailText.primary12('Address')),
              DataColumn(label: SailText.primary12('Visible on SC?')),
            ],
            rows: deposits
                .map(
                  (deposit) => DataRow(
                    cells: [
                      DataCell(SailText.primary12(viewModel._selectedIndex.toString())),
                      DataCell(SailText.primary12(deposit.amount.toString())),
                      DataCell(SailText.primary12(deposit.txid.toString())),
                      DataCell(SailText.primary12(deposit.address)),
                      DataCell(SailText.primary12(deposit.confirmations >= 2 ? 'Yes' : 'No')),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
