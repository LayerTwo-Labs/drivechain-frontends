import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/cheque_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class CreateChequePage extends StatefulWidget {
  const CreateChequePage({super.key});

  @override
  State<CreateChequePage> createState() => _CreateChequePageState();
}

class _CreateChequePageState extends State<CreateChequePage> {
  final ChequeProvider _chequeProvider = GetIt.I.get<ChequeProvider>();
  final TextEditingController _amountController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SailTheme.of(context).colors.background,
      appBar: AppBar(
        backgroundColor: SailTheme.of(context).colors.background,
        foregroundColor: SailTheme.of(context).colors.text,
        title: SailText.primary20('Create Cheque'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(SailStyleValues.padding20),
              child: SailColumn(
                spacing: SailStyleValues.padding32,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SailText.primary24('How much should the cheque be for?'),
                  SailTextField(
                    controller: _amountController,
                    hintText: '0.00000000',
                    suffix: 'BTC',
                    textFieldType: TextFieldType.bitcoin,
                  ),
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SailButton(
                        label: 'Cancel',
                        variant: ButtonVariant.ghost,
                        onPressed: () async => context.router.maybePop(),
                      ),
                      SailButton(
                        label: 'Create',
                        loading: _isCreating,
                        onPressed: () async => _createCheque(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createCheque() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      showSnackBar(context, 'Please enter an amount');
      return;
    }

    final btcAmount = double.tryParse(amountText);
    if (btcAmount == null || btcAmount <= 0) {
      showSnackBar(context, 'Please enter a valid amount');
      return;
    }

    final sats = (btcAmount * 100000000).toInt();

    setState(() {
      _isCreating = true;
    });

    final cheque = await _chequeProvider.createCheque(sats);

    setState(() {
      _isCreating = false;
    });

    if (cheque == null) {
      if (mounted) {
        showSnackBar(context, _chequeProvider.modelError ?? 'Failed to create cheque');
      }
      return;
    }

    if (!mounted) return;

    // Navigate to the cheque detail page
    await context.router.replace(ChequeDetailRoute(chequeId: cheque.id.toInt()));
  }
}
