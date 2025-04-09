import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/sail_ui.dart';

class MessageSigner extends StatelessWidget {
  const MessageSigner({super.key});

  @override
  Widget build(BuildContext context) {
    return SailPadding(
      padding: const EdgeInsets.all(SailStyleValues.padding16),
      child: Dialog(
        child: SizedBox(
          width: 800,
          height: 600,
          child: SailCard(
            withCloseButton: true,
            color: context.sailTheme.colors.background,
            padding: false,
            child: Positioned.fill(
              child: InlineTabBar(
                tabs: const [
                  TabItem(
                    label: 'Sign Message',
                    icon: SailSVGAsset.iconPen,
                    child: SignMessageTab(),
                  ),
                  TabItem(
                    label: 'Verify Message',
                    icon: SailSVGAsset.iconCheck,
                    child: VerifyMessageTab(),
                  ),
                ],
                initialIndex: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignMessageTab extends StatefulWidget {
  const SignMessageTab({super.key});

  @override
  State<SignMessageTab> createState() => _SignMessageTabState();
}

class _SignMessageTabState extends State<SignMessageTab> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _signatureController = TextEditingController();
  final WalletAPI _wallet = GetIt.I.get<BitwindowRPC>().wallet;
  String? _error;

  @override
  void dispose() {
    _addressController.dispose();
    _messageController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _signMessage() async {
    try {
      setState(() => _error = null);
      final signature = await _wallet.signMessage(_messageController.text);
      setState(() {
        _signatureController.text = signature;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _signatureController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return SailCard(
      title: 'Sign Message',
      subtitle:
          'You can sign messages/agreements with your addresses to prove you can receive Drivechain coins sent to them. Be careful not to sign anything vague or random, as phishing attacks may try to trick you into signing your identity over to them. Only sign fully-detailed statements you agree to.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailTextField(
            controller: _addressController,
            label: 'Enter a Drivechain address (e.g. n2wxQmfexkjwEPgdD6iJA7T7RtzkrnHxhFc)',
            hintText: '',
          ),
          const SizedBox(height: 24),
          SailTextField(
            controller: _messageController,
            maxLines: 5,
            hintText: 'Message',
          ),
          const SizedBox(height: 24),
          SailTextField(
            controller: _signatureController,
            readOnly: true,
            hintText: 'Signature',
          ),
          const SizedBox(height: 24),
          SailButton(
            onPressed: _signMessage,
            label: 'Sign Message',
            icon: SailSVGAsset.iconPen,
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.error, color: theme.colors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: SailText.primary13(
                    _error!,
                    color: theme.colors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class VerifyMessageTab extends StatefulWidget {
  const VerifyMessageTab({super.key});

  @override
  State<VerifyMessageTab> createState() => _VerifyMessageTabState();
}

class _VerifyMessageTabState extends State<VerifyMessageTab> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _signatureController = TextEditingController();
  final WalletAPI _wallet = GetIt.I.get<BitwindowRPC>().wallet;
  bool? _isValid;
  String? _error;

  @override
  void dispose() {
    _addressController.dispose();
    _messageController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _verifyMessage() async {
    try {
      setState(() => _error = null);
      final isValid = await _wallet.verifyMessage(
        _messageController.text,
        _signatureController.text,
        _addressController.text,
      );
      setState(() {
        _isValid = isValid;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isValid = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return SailCard(
      title: 'Verify Message',
      subtitle:
          "Enter the receiver's address, message (ensure you copy line breaks, spaces, tabs, etc. exactly) and signature below to verify the message. Be careful not to read more into the signature than what is in the signed message itself, to avoid being tricked by a man-in-the-middle attack. Note that this only proves the signing party receives with the address, it cannot prove sendership of any",
      child: SailColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: SailStyleValues.padding16,
        children: [
          SailTextField(
            controller: _addressController,
            label: 'Enter a Drivechain address (e.g. n2wxQmfexkjwEPgdD6iJA7T7RtzkrnHxhFc)',
            hintText: '',
          ),
          SailTextField(
            controller: _messageController,
            label: 'Message',
            maxLines: 5,
            hintText: '',
          ),
          SailTextField(
            controller: _signatureController,
            label: 'Signature',
            hintText: '',
          ),
          SailButton(
            label: 'Verify Message',
            icon: SailSVGAsset.iconQuestion,
            onPressed: _verifyMessage,
          ),
          if (_error != null) ...[
            Row(
              children: [
                Icon(Icons.error, color: theme.colors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: SailText.primary13(
                    _error!,
                    color: theme.colors.error,
                  ),
                ),
              ],
            ),
          ],
          if (_isValid != null && _error == null) ...[
            const SizedBox(width: 16),
            Icon(
              _isValid! ? Icons.check_circle : Icons.error,
              color: _isValid! ? theme.colors.success : theme.colors.error,
            ),
            const SizedBox(width: 8),
            SailText.primary13(
              _isValid! ? 'Message verified' : 'Invalid signature',
              color: _isValid! ? theme.colors.success : theme.colors.error,
            ),
          ],
        ],
      ),
    );
  }
}
