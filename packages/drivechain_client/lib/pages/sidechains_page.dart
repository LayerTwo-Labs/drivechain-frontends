import 'package:auto_route/auto_route.dart';
import 'package:drivechain_client/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:drivechain_client/pages/send_page.dart';
import 'package:drivechain_client/providers/sidechain_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

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
    return QtContainer(
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => SidechainsViewModel(),
        builder: (context, model, child) => Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary13(
              'Sidechains',
              bold: true,
            ),
            const SizedBox(height: SailStyleValues.padding15),
            Expanded(
              child: ListView.builder(
                itemCount: model.sidechains.length,
                itemBuilder: (context, index) {
                  final sidechain = model.sidechains[index];
                  final textColor = sidechain == null
                      ? SailTheme.of(context).colors.textSecondary
                      : SailTheme.of(context).colors.text;

                  return SelectableListTile(
                    index: index,
                    sidechain: sidechain,
                    textColor: textColor,
                    isSelected: model.selectedIndex == index,
                    onSelected: () {
                      model.toggleSelection(index);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: SailStyleValues.padding15),
            QtContainer(
              child: Row(
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
            ),
          ],
        ),
      ),
    );
  }
}

class SelectableListTile extends StatelessWidget {
  final int index;
  final ListSidechainsResponse_Sidechain? sidechain;
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
                sidechain == null ? 'Inactive' : sidechain!.title,
                color: textColor,
              ),
            ),
            const SailSpacing(SailStyleValues.padding15),
            SizedBox(
              width: 120,
              child: SailText.primary13(
                sidechain == null ? '' : formatBitcoin(satoshiToBTC(sidechain!.amountSatoshi.toInt())),
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

  SidechainsViewModel() {
    sidechainProvider.addListener(notifyListeners);
  }

  List<ListSidechainsResponse_Sidechain?> get sidechains => sidechainProvider.sidechains;

  int? _selectedIndex;

  int? get selectedIndex => _selectedIndex;

  void toggleSelection(int index) {
    if (_selectedIndex == index) {
      _selectedIndex = null; // Deselect if the same item is selected again
    } else {
      _selectedIndex = index; // Select the new item
    }
    notifyListeners();
  }
}
