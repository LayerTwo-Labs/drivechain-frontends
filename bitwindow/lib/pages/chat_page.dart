import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/models/bitintroduction_protocol.dart';
import 'package:bitwindow/models/bitnames_recovery.dart';
import 'package:bitwindow/models/chat_models.dart';
import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:bitwindow/providers/chat_provider.dart';
import 'package:bitwindow/services/bitnames_secure_store.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:thirds/blake3.dart';

@RoutePage()
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return QtPage(
      child: ViewModelBuilder<ChatViewModel>.reactive(
        viewModelBuilder: () => ChatViewModel(),
        onViewModelReady: (model) => model.init(),
        builder: (context, model, child) {
          if (!model.isConnected) {
            // Disconnected view (inlined)
            return Center(
              child: SailCard(
                title: 'BitNames Required',
                subtitle: 'Chat requires BitNames sidechain to be running',
                child: Padding(
                  padding: const EdgeInsets.all(SailStyleValues.padding20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SailSVG.fromAsset(
                        SailSVGAsset.iconWarning,
                        color: theme.colors.textSecondary,
                        height: 48,
                      ),
                      const SizedBox(height: SailStyleValues.padding16),
                      SailText.primary15(
                        'BitNames sidechain is not connected',
                        bold: true,
                      ),
                      const SizedBox(height: SailStyleValues.padding08),
                      SailText.secondary13(
                        'To use the Chat feature, you need to:\n'
                        '1. Go to the Sidechains tab\n'
                        '2. Download and start BitNames\n'
                        '3. Register at least one BitName identity',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Column(
            children: [
              // Identity selector (inlined)
              SailCard(
                padding: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SailStyleValues.padding16,
                    vertical: SailStyleValues.padding08,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ChainHealthBar(
                        health: model.chainHealth,
                        onRetry: model.retryChainRecovery,
                      ),
                      _PrivateStorageBar(
                        status: model.storageStatus,
                        onBackup: () => model.backupPrivateData(context),
                        onRestore: () => model.restorePrivateData(context),
                        onClear: () => model.clearPrivateData(context),
                      ),
                      // Status bars - stack all status messages
                      ...model.statusMessages.map(
                        (status) => _ClaimingStatusBar(status: status),
                      ),
                      // Main action bar
                      Row(
                        children: [
                          SailText.secondary13('Chatting as:'),
                          const SizedBox(width: SailStyleValues.padding12),
                          if (model.myIdentities.isNotEmpty)
                            _SearchableIdentityDropdown(
                              identities: model.myIdentities,
                              selectedIdentity: model.selectedIdentity,
                              onIdentitySelected: model.selectIdentity,
                            )
                          else
                            SailText.secondary13(model.chatError ?? 'No BitNames owned'),
                          if (model.selectedIdentity != null) ...[
                            const SizedBox(width: SailStyleValues.padding08),
                            if (model.messagingProfilePending)
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: LoadingIndicator(color: theme.colors.primary),
                              )
                            else
                              SailSVG.fromAsset(
                                model.messagingReady ? SailSVGAsset.check : SailSVGAsset.iconWarning,
                                color: model.messagingReady ? theme.colors.success : theme.colors.warning,
                                height: 14,
                              ),
                            const SizedBox(width: SailStyleValues.padding04),
                            SailText.secondary12(
                              model.messagingProfilePending
                                  ? 'Registered • reply profile waiting for a BitNames block'
                                  : model.messagingReady
                                  ? 'Registered • ready to message'
                                  : model.commitmentBlocked
                                  ? 'Registered • existing application commitment protected'
                                  : 'Registered • reply profile not published',
                              color: model.messagingProfilePending
                                  ? theme.colors.primary
                                  : model.messagingReady
                                  ? theme.colors.success
                                  : theme.colors.warning,
                            ),
                          ],
                          const SizedBox(width: SailStyleValues.padding12),
                          if (model.hasSufficientBalance)
                            SailTooltip(
                              message: 'Registering a BitName costs sats on the BitNames sidechain',
                              child: SailButton(
                                label: 'Register BitName',
                                variant: ButtonVariant.secondary,
                                disabled: model.isClaiming || !model.chainWritesReady,
                                onPressed: () async => _showRegisterBitNameDialog(context, model),
                                skipLoading: true,
                              ),
                            )
                          else if (GetIt.I.get<BitcoinConfProvider>().networkSupportsSidechains)
                            SailTooltip(
                              message: 'You need BitNames sidechain balance to register a BitName',
                              child: SailButton(
                                label: 'Deposit to BitNames',
                                variant: ButtonVariant.primary,
                                onPressed: () async => showDepositModal(context, BitNames().slot, 'BitNames'),
                              ),
                            ),
                          const Spacer(),
                          SailButton(
                            label: model.messagingProfilePending ? 'Reply profile pending' : 'Messaging setup',
                            variant: ButtonVariant.secondary,
                            disabled: model.selectedIdentity == null || model.messagingProfilePending,
                            onPressed: () async => _showMessagingSetupDialog(context, model),
                          ),
                          const SizedBox(width: SailStyleValues.padding08),
                          SailButton(
                            label: 'Add Contact',
                            variant: ButtonVariant.secondary,
                            disabled: model.selectedIdentity == null,
                            onPressed: () async => _showAddContactDialog(context, model),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SailStyleValues.padding08),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 280,
                      // Contact list (inlined)
                      child: SailCard(
                        title: 'Contacts',
                        bottomPadding: false,
                        child: model.contacts.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(SailStyleValues.padding20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SailText.secondary13('No conversations yet'),
                                      const SizedBox(height: SailStyleValues.padding08),
                                      SailText.secondary12(
                                        'Find a BitName to start a conversation',
                                        color: theme.colors.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: model.contacts.length,
                                itemBuilder: (context, index) {
                                  final contact = model.contacts[index];
                                  final isSelected = model.selectedContact?.id == contact.id;

                                  return SailTappable(
                                    onTap: () async => model.selectContact(contact),
                                    child: Container(
                                      padding: const EdgeInsets.all(SailStyleValues.padding12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? theme.colors.primary.withAlpha(30) : null,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: theme.colors.divider,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Avatar (inlined)
                                          Builder(
                                            builder: (context) {
                                              final initials = contact.displayName.isNotEmpty
                                                  ? contact.displayName.substring(0, 1).toUpperCase()
                                                  : '?';
                                              return Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: theme.colors.primary.withAlpha(50),
                                                ),
                                                child: Center(
                                                  child: SailText.primary13(initials, bold: true),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: SailStyleValues.padding12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SailText.primary13(
                                                  contact.displayName,
                                                  bold: true,
                                                ),
                                                SailText.secondary12(
                                                  contact.id,
                                                  color: theme.colors.textSecondary,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (contact.lastMessage != null)
                                                  SailText.secondary12(
                                                    contact.lastMessage!,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (contact.lastMessageTime != null)
                                            SailText.secondary12(
                                              _formatTime(contact.lastMessageTime!),
                                              color: theme.colors.textTertiary,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(width: SailStyleValues.padding08),
                    Expanded(
                      // Chat panel (inlined)
                      child: model.selectedContact == null
                          ? Center(
                              child: SailCard(
                                width: null,
                                bottomPadding: false,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SailSVG.fromAsset(
                                      SailSVGAsset.messageCircle,
                                      color: theme.colors.textTertiary,
                                      height: 64,
                                    ),
                                    const SizedBox(height: SailStyleValues.padding16),
                                    SailText.secondary13('Select a contact to start chatting'),
                                  ],
                                ),
                              ),
                            )
                          : SailCard(
                              title: model.selectedContact!.displayName,
                              subtitle: model.relationshipStatus,
                              bottomPadding: false,
                              child: Column(
                                children: [
                                  if (model.selectedContact!.relationshipState ==
                                      ChatRelationshipState.incomingIntroduction)
                                    Row(
                                      children: [
                                        SailButton(label: 'Accept', onPressed: () async => model.accept(context)),
                                        const SizedBox(width: SailStyleValues.padding08),
                                        SailButton(
                                          label: 'Reject',
                                          variant: ButtonVariant.secondary,
                                          onPressed: model.reject,
                                        ),
                                        const SizedBox(width: SailStyleValues.padding08),
                                        SailButton(
                                          label: 'Block',
                                          variant: ButtonVariant.destructive,
                                          onPressed: model.block,
                                        ),
                                      ],
                                    ),
                                  if (model.selectedContact!.relationshipState ==
                                      ChatRelationshipState.outgoingIntroduction)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: SailButton(
                                        label: 'Stop waiting',
                                        variant: ButtonVariant.secondary,
                                        onPressed: model.cancelIntroduction,
                                      ),
                                    ),
                                  Expanded(
                                    // Message list (inlined)
                                    child: Builder(
                                      builder: (context) {
                                        final messages = model.currentConversation;

                                        if (messages.isEmpty) {
                                          return Center(
                                            child: SailText.secondary13(
                                              'No messages yet. Say hello!',
                                              color: theme.colors.textTertiary,
                                            ),
                                          );
                                        }

                                        return ListView.builder(
                                          reverse: true,
                                          padding: const EdgeInsets.all(SailStyleValues.padding08),
                                          itemCount: messages.length + (model.hasOlderMessages ? 1 : 0),
                                          itemBuilder: (context, index) {
                                            if (index == messages.length) {
                                              return Center(
                                                child: SailButton(
                                                  label: 'Load earlier messages',
                                                  variant: ButtonVariant.secondary,
                                                  onPressed: model.loadOlderMessages,
                                                ),
                                              );
                                            }
                                            final message = messages[messages.length - 1 - index];
                                            // Message bubble (inlined)
                                            final isOwn = message.isOutgoing;

                                            return Align(
                                              alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
                                              child: Container(
                                                constraints: const BoxConstraints(maxWidth: 400),
                                                margin: const EdgeInsets.symmetric(vertical: SailStyleValues.padding04),
                                                padding: const EdgeInsets.all(SailStyleValues.padding12),
                                                decoration: BoxDecoration(
                                                  color: isOwn
                                                      ? theme.colors.primary.withAlpha(30)
                                                      : theme.colors.backgroundSecondary,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: isOwn
                                                        ? theme.colors.primary.withAlpha(50)
                                                        : theme.colors.divider,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SailText.primary13(message.content),
                                                    const SizedBox(height: SailStyleValues.padding04),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        SailText.secondary12(
                                                          _formatMessageTime(message.timestamp),
                                                          color: theme.colors.textTertiary,
                                                        ),
                                                        if (message.valueSats != null) ...[
                                                          const SizedBox(width: SailStyleValues.padding08),
                                                          SailText.secondary12(
                                                            '${message.valueSats} sats',
                                                            color: theme.colors.textTertiary,
                                                          ),
                                                        ],
                                                        const SizedBox(width: SailStyleValues.padding08),
                                                        SailText.secondary12(
                                                          _messageDelivery(message),
                                                          color: message.deliveryState == ChatDeliveryState.failed
                                                              ? theme.colors.error
                                                              : theme.colors.textTertiary,
                                                        ),
                                                        if (message.error != null &&
                                                            message.kind != ChatMessageKind.introduction &&
                                                            (message.kind != ChatMessageKind.acceptance ||
                                                                model.selectedContact!.relationshipState ==
                                                                    ChatRelationshipState.incomingIntroduction)) ...[
                                                          const SizedBox(width: SailStyleValues.padding08),
                                                          SailButton(
                                                            label: 'Send on chain',
                                                            variant: ButtonVariant.secondary,
                                                            onPressed: () async =>
                                                                model.sendViaChain(context, message.id),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: SailStyleValues.padding08),
                                  // Message input (inlined)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SailTextField(
                                          controller: model.messageController,
                                          hintText: model.sendHint,
                                          enabled: model.canSend,
                                          maxLines: 3,
                                          minLines: 1,
                                          onSubmitted: (_) => model.sendMessage(context),
                                        ),
                                      ),
                                      const SizedBox(width: SailStyleValues.padding08),
                                      SailButton(
                                        label: 'Send',
                                        loading: model.isSending,
                                        disabled: !model.canSend || model.messageController.text.isEmpty,
                                        onPressed: () async => model.sendMessage(context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    }
    return 'now';
  }

  String _formatMessageTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _messageDelivery(ChatMessage message) {
    if (message.deliveryState == ChatDeliveryState.failed) {
      return '${message.transport == ChatTransport.tor ? 'Tor' : 'Direct'} delivery failed';
    }
    if (message.deliveryState == ChatDeliveryState.pending) {
      return message.transport == ChatTransport.bitnamesChain ? 'Waiting for BitNames block' : 'Sending';
    }
    return switch (message.transport) {
      ChatTransport.bitnamesChain => 'Confirmed on BitNames',
      ChatTransport.tor => message.isOutgoing ? 'Delivered through Tor' : 'Received through Tor',
      ChatTransport.direct => message.isOutgoing ? 'Delivered directly' : 'Received directly',
    };
  }

  Future<void> _showAddContactDialog(BuildContext context, ChatViewModel model) async {
    await showThemedDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AddContactDialog(model: model),
    );
  }

  Future<void> _showRegisterBitNameDialog(BuildContext context, ChatViewModel model) async {
    await showThemedDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _RegisterBitNameDialog(model: model),
    );
  }

  Future<void> _showMessagingSetupDialog(BuildContext context, ChatViewModel model) async {
    final fee = TextEditingController(text: '${model.selectedIdentity?.details.paymailFeeSats ?? 1000}');
    var busy = false;
    Future<void> run(StateSetter setState, Future<bool> Function() action, String success) async {
      setState(() => busy = true);
      final ok = await action();
      if (context.mounted) {
        showSailToast(context, ok ? success : model.chatError ?? 'Messaging setup failed');
        setState(() => busy = false);
      }
    }

    await showThemedDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => SailDialog(
          title: 'Messaging setup',
          subtitle: model.torOnly
              ? 'Tor-only: messages and BitNames chain writes use Tor'
              : 'Direct messaging shares your detected IP address with contacts',
          actions: [
            SailButton(
              label: 'Close',
              variant: ButtonVariant.secondary,
              disabled: busy,
              onPressed: () async => Navigator.pop(context),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailTextField(
                controller: fee,
                label: 'Introduction fee (sats)',
                hintText: '1000',
                helperText: 'Leave blank to stop accepting introductions',
                textFieldType: TextFieldType.number,
              ),
              const SizedBox(height: SailStyleValues.padding12),
              SailText.secondary12(
                model.torOnly
                    ? 'Your IP address is hidden. BitNames chain writes also use the connected Tor tunnel.'
                    : 'Your reply address is detected automatically. Use Tor-only mode to hide your IP address.',
              ),
              const SizedBox(height: SailStyleValues.padding12),
              SailText.primary13(model.commitmentSummary),
              const SizedBox(height: SailStyleValues.padding04),
              SailText.secondary12(
                '${model.commitmentDetails}\n${model.commitmentMode} • ${model.commitmentNetwork}',
                color: model.commitmentBlocked
                    ? SailTheme.of(context).colors.warning
                    : SailTheme.of(context).colors.textSecondary,
              ),
              const SizedBox(height: SailStyleValues.padding12),
              Row(
                children: [
                  SailButton(
                    label: model.torReady ? 'Tor ready' : 'Download / start Tor',
                    disabled: busy || model.torReady,
                    onPressed: () async => run(setState, model.startTor, 'BitNames Tor is ready'),
                  ),
                  const SizedBox(width: SailStyleValues.padding08),
                  SailButton(
                    label: model.torOnly ? 'Use direct mode' : 'Use Tor-only mode',
                    disabled: busy || (!model.torOnly && !model.hasTorChainPeer),
                    onPressed: () async => run(
                      setState,
                      () => model.setTorOnly(!model.torOnly),
                      model.torOnly ? 'Direct mode enabled' : 'Tor-only mode enabled',
                    ),
                  ),
                  const SizedBox(width: SailStyleValues.padding08),
                  SailButton(
                    label: 'Save & publish reply profile',
                    disabled: busy,
                    onPressed: () async => run(
                      setState,
                      () => model.publishProfile(fee.text),
                      'Reply profile submitted • waiting for a BitNames block',
                    ),
                  ),
                ],
              ),
              if (!model.torOnly && !model.hasTorChainPeer) ...[
                const SizedBox(height: SailStyleValues.padding08),
                SailText.secondary12(
                  'Tor-only chain routing needs a Tor-capable contact or LayerTwo relay. None is configured yet.',
                  color: SailTheme.of(context).colors.warning,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ClaimingStatusBar extends StatelessWidget {
  const _ClaimingStatusBar({required this.status});
  final StatusMessage status;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return _StatusBar(
      color: status.completed ? theme.colors.success : theme.colors.primary,
      title: status.message,
      loading: !status.completed,
      fillAlpha: 0.1,
      borderAlpha: 0.3,
    );
  }
}

class _PrivateStorageBar extends StatelessWidget {
  const _PrivateStorageBar({
    required this.status,
    required this.onBackup,
    required this.onRestore,
    required this.onClear,
  });

  final BitnamesStorageStatus status;
  final Future<void> Function() onBackup;
  final Future<void> Function() onRestore;
  final Future<void> Function() onClear;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final problem = {BitnamesStorageState.locked, BitnamesStorageState.corrupt}.contains(status.state);
    final color = problem ? theme.colors.warning : theme.colors.success;
    final details = [
      if (status.details != null) status.details!,
      if (status.generation != null) 'Authenticated generation ${status.generation}',
    ].join(' • ');
    return _StatusBar(
      color: color,
      icon: problem ? SailSVGAsset.iconWarning : SailSVGAsset.check,
      title: status.summary,
      details: details.isEmpty ? null : details,
      actions: status.writable
          ? [
              SailButton(label: 'Encrypted backup', variant: ButtonVariant.secondary, onPressed: onBackup),
              SailButton(label: 'Restore', variant: ButtonVariant.secondary, onPressed: onRestore),
              SailButton(label: 'Clear chats', variant: ButtonVariant.secondary, onPressed: onClear),
            ]
          : const [],
    );
  }
}

class _ChainHealthBar extends StatelessWidget {
  const _ChainHealthBar({required this.health, required this.onRetry});

  final BitnamesChainSnapshot health;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final attention = health.needsAttention;
    final waiting =
        health.state == BitnamesChainHealthState.waitingForBlock ||
        health.state == BitnamesChainHealthState.recovering ||
        health.state == BitnamesChainHealthState.unknown;
    final color = health.state == BitnamesChainHealthState.synced
        ? theme.colors.success
        : attention
        ? theme.colors.warning
        : theme.colors.primary;
    final retry = health.state == BitnamesChainHealthState.stalled || health.state == BitnamesChainHealthState.error;
    return _StatusBar(
      color: color,
      icon: health.state == BitnamesChainHealthState.synced ? SailSVGAsset.check : SailSVGAsset.iconWarning,
      loading: waiting,
      title: health.summary,
      details: health.details,
      actions: retry
          ? [
              SailButton(
                label: health.state == BitnamesChainHealthState.stalled ? 'Check again' : 'Retry recovery',
                variant: ButtonVariant.secondary,
                onPressed: onRetry,
              ),
            ]
          : const [],
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.color,
    required this.title,
    this.details,
    this.icon = SailSVGAsset.check,
    this.loading = false,
    this.actions = const [],
    this.fillAlpha = 0.08,
    this.borderAlpha = 0.25,
  });

  final Color color;
  final String title;
  final String? details;
  final SailSVGAsset icon;
  final bool loading;
  final List<Widget> actions;
  final double fillAlpha;
  final double borderAlpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding12,
        vertical: SailStyleValues.padding08,
      ),
      margin: const EdgeInsets.only(bottom: SailStyleValues.padding08),
      decoration: BoxDecoration(
        color: color.withValues(alpha: fillAlpha),
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: color.withValues(alpha: borderAlpha)),
      ),
      child: Row(
        children: [
          if (loading)
            SizedBox(
              width: 16,
              height: 16,
              child: LoadingIndicator(color: color),
            )
          else
            SailSVG.fromAsset(icon, color: color, height: 16),
          const SizedBox(width: SailStyleValues.padding12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary13(title, color: color),
                if (details != null) ...[
                  const SizedBox(height: SailStyleValues.padding04),
                  SailText.secondary12(details!),
                ],
              ],
            ),
          ),
          for (final action in actions) ...[
            const SizedBox(width: SailStyleValues.padding12),
            action,
          ],
        ],
      ),
    );
  }
}

class _AddContactDialog extends StatefulWidget {
  final ChatViewModel model;

  const _AddContactDialog({required this.model});

  @override
  State<_AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<_AddContactDialog> {
  final searchController = TextEditingController();
  BitnameEntry? selectedBitName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final match = _findMatchingBitName();
    if (match != null && match.hash != selectedBitName?.hash) {
      // New match found - save the mapping forever!
      final query = searchController.text.trim();
      widget.model.saveNameMapping(query);
    }
    setState(() {
      selectedBitName = match;
    });
  }

  BitnameEntry? _findMatchingBitName() {
    final query = searchController.text.trim();
    if (query.isEmpty) return null;

    // Compute Blake3 hash of the search text
    final searchHash = blake3Hex(utf8.encode(query.toLowerCase()));

    // Find BitName with matching hash
    return widget.model.allBitNames.where((entry) {
      return entry.hash.toLowerCase() == query.toLowerCase() || entry.hash.toLowerCase() == searchHash.toLowerCase();
    }).firstOrNull;
  }

  List<BitnameEntry> get filteredBitNames {
    final query = searchController.text.toLowerCase().trim();
    if (query.isEmpty) return widget.model.allBitNames;

    // Compute Blake3 hash of the search text
    String? searchHash;
    try {
      searchHash = blake3Hex(utf8.encode(query));
    } catch (e) {
      searchHash = null;
    }

    return widget.model.allBitNames.where((entry) {
      // Exact hash match from plaintext search
      if (searchHash != null && entry.hash.toLowerCase() == searchHash.toLowerCase()) {
        return true;
      }
      // Plaintext name match (if already decrypted)
      if (entry.plaintextName?.toLowerCase().contains(query) ?? false) {
        return true;
      }
      // Hash prefix match
      if (entry.hash.toLowerCase().contains(query)) {
        return true;
      }
      return false;
    }).toList();
  }

  Future<void> _addContact(BitnameEntry entry) async {
    // Check if BitName has encryption pubkey (required for chat)
    if (entry.details.encryptionPubkey == null) {
      showSailToast(context, 'This BitName has no encryption key set - cannot chat');
      return;
    }

    setState(() => isLoading = true);

    try {
      // Create contact directly from entry data (no need to lookup again)
      final added = await widget.model.addContactFromEntry(entry);
      if (mounted && added) {
        Navigator.of(context).pop();
      } else if (mounted) {
        showSailToast(context, widget.model.chatError ?? 'Could not add this contact');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final filtered = filteredBitNames;

    return SailDialog(
      title: 'Add Contact',
      actions: [
        SailButton(
          label: 'Cancel',
          variant: ButtonVariant.secondary,
          onPressed: () async => Navigator.of(context).pop(),
        ),
      ],
      child: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.secondary13('Search for a BitName by typing its plaintext name'),
            const SizedBox(height: SailStyleValues.padding12),
            SailTextField(
              controller: searchController,
              hintText: 'Type a name to find its hash...',
            ),
            const SizedBox(height: SailStyleValues.padding12),
            if (selectedBitName != null)
              Container(
                padding: const EdgeInsets.all(SailStyleValues.padding12),
                decoration: BoxDecoration(
                  color: theme.colors.success.withValues(alpha: 0.1),
                  borderRadius: SailStyleValues.borderRadius,
                  border: Border.all(color: theme.colors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    SailSVG.fromAsset(SailSVGAsset.check, color: theme.colors.success, height: 16),
                    const SizedBox(width: SailStyleValues.padding08),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailText.primary13('Match found: "${searchController.text.trim()}"', bold: true),
                          SailText.secondary12('${selectedBitName!.hash.substring(0, 24)}...'),
                        ],
                      ),
                    ),
                    SailButton(
                      label: 'Add',
                      loading: isLoading,
                      onPressed: () async => _addContact(selectedBitName!),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: SailStyleValues.padding12),
            SailText.secondary12('${filtered.length} BitNames'),
            const SizedBox(height: SailStyleValues.padding08),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colors.divider),
                  borderRadius: SailStyleValues.borderRadius,
                ),
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    final isMatch = selectedBitName?.hash == entry.hash;
                    return SailTappable(
                      onTap: () async => _addContact(entry),
                      child: Container(
                        padding: const EdgeInsets.all(SailStyleValues.padding12),
                        decoration: BoxDecoration(
                          color: isMatch ? theme.colors.success.withValues(alpha: 0.1) : null,
                          border: Border(
                            bottom: BorderSide(color: theme.colors.divider, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (entry.plaintextName != null)
                                    SailText.primary13(entry.plaintextName!, bold: true)
                                  else
                                    SailText.secondary13('(encrypted)'),
                                  SailText.secondary12(
                                    '${entry.hash.substring(0, 32)}...',
                                    color: theme.colors.textTertiary,
                                  ),
                                ],
                              ),
                            ),
                            if (isMatch) SailSVG.fromAsset(SailSVGAsset.check, color: theme.colors.success, height: 12),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterBitNameDialog extends StatefulWidget {
  final ChatViewModel model;

  const _RegisterBitNameDialog({required this.model});

  @override
  State<_RegisterBitNameDialog> createState() => _RegisterBitNameDialogState();
}

class _RegisterBitNameDialogState extends State<_RegisterBitNameDialog> {
  final controller = TextEditingController();
  final feeController = TextEditingController(text: '1000');
  late bool useTor;
  bool busy = false;
  bool registered = false;
  String? resultMessage;

  @override
  void initState() {
    super.initState();
    useTor = widget.model.torOnly;
    controller.addListener(_onTextChanged);
    feeController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onTextChanged);
    feeController.removeListener(_onTextChanged);
    controller.dispose();
    feeController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailDialog(
      title: 'Register BitName',
      actions: [
        SailButton(
          label: busy || registered ? 'Close' : 'Cancel',
          variant: ButtonVariant.secondary,
          onPressed: () async => Navigator.of(context).pop(),
        ),
        SailButton(
          label: registered
              ? 'Done'
              : busy
              ? 'Waiting for block...'
              : 'Register',
          disabled: controller.text.trim().isEmpty || (int.tryParse(feeController.text.trim()) ?? -1) < 0 || busy,
          skipLoading: true,
          onPressed: registered
              ? () async => Navigator.of(context).pop()
              : () async {
                  setState(() {
                    busy = true;
                    resultMessage = null;
                  });
                  final ready = await widget.model.prepareRegistration(useTor);
                  if (!ready || !mounted) {
                    if (mounted) {
                      setState(() {
                        busy = false;
                        resultMessage = widget.model.chatError ?? 'Messaging setup failed';
                      });
                    }
                    return;
                  }
                  final name = controller.text.trim();
                  final fee = int.parse(feeController.text.trim());
                  final txid = await widget.model.registerIdentity(name, fee);
                  if (!mounted) return;
                  setState(() {
                    busy = false;
                    registered = txid != null;
                    resultMessage = registered
                        ? widget.model.messagingProfilePending
                              ? '"$name" is registered • its reply profile is waiting for one more BitNames block'
                              : widget.model.messagingReady
                              ? '"$name" is registered and ready to message'
                              : '"$name" is registered • publish its reply profile before chatting'
                        : widget.model.chatError ?? 'Registration failed';
                  });
                },
        ),
      ],
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.secondary13('Enter a name to register as your identity'),
            const SizedBox(height: SailStyleValues.padding12),
            SailText.secondary12(
              'BitWindow handles registration automatically. It normally needs three BitNames blocks: '
              'reservation, registered name, then the reply profile used for paid introductions and replies.',
            ),
            const SizedBox(height: SailStyleValues.padding12),
            SailTextField(
              controller: controller,
              hintText: 'e.g., alice',
              label: 'BitName',
            ),
            const SizedBox(height: SailStyleValues.padding12),
            SailTextField(
              controller: feeController,
              hintText: '1000',
              label: 'Introduction fee (sats)',
              textFieldType: TextFieldType.number,
            ),
            const SizedBox(height: SailStyleValues.padding04),
            SailText.secondary12(
              'People pay this amount to you, plus the 100-sat BitNames chain fee.',
              color: theme.colors.textSecondary,
            ),
            const SizedBox(height: SailStyleValues.padding12),
            SailCheckbox(
              value: useTor,
              onChanged: busy || !widget.model.hasTorChainPeer ? null : (value) => setState(() => useTor = value),
              label: 'Continue through Tor',
            ),
            const SizedBox(height: SailStyleValues.padding08),
            SailText.secondary12(
              !widget.model.hasTorChainPeer
                  ? 'Tor registration needs a Tor-capable BitNames peer or LayerTwo relay; none is configured yet.'
                  : useTor
                  ? 'Requires a reachable BitNames Tor peer; setup fails safely if none is available.'
                  : 'Direct setup shares your detected IP address with contacts.',
              color: theme.colors.textSecondary,
            ),
            if (busy || resultMessage != null) ...[
              const SizedBox(height: SailStyleValues.padding12),
              AnimatedBuilder(
                animation: widget.model,
                builder: (context, _) => SailText.primary13(
                  resultMessage ??
                      widget.model.claimingStatus ??
                      'Registration submitted • waiting for a BitNames block',
                  color: registered ? theme.colors.success : theme.colors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ChatViewModel extends BaseViewModel {
  final ChatProvider _chatProvider = GetIt.I.get<ChatProvider>();
  final BitnamesRPC _bitnamesRPC = GetIt.I.get<BitnamesRPC>();
  final TextEditingController messageController = TextEditingController();

  bool get isConnected => _bitnamesRPC.connected;

  List<BitnameEntry> get myIdentities => _chatProvider.myIdentities;
  List<BitnameEntry> get allBitNames => _chatProvider.allBitNames;
  BitnameEntry? get selectedIdentity => _chatProvider.selectedIdentity;
  bool get hasSufficientBalance => _chatProvider.hasSufficientBalance;

  List<ChatContact> get contacts => _chatProvider.contacts;
  ChatContact? get selectedContact => _chatProvider.selectedContact;

  List<ChatMessage> get currentConversation => _chatProvider.currentConversation;
  bool get hasOlderMessages => _chatProvider.hasOlderMessages;

  bool get isSending => _chatProvider.isSending;
  String? get chatError => _chatProvider.error;
  bool get torOnly => _chatProvider.torOnly;
  bool get torReady => _chatProvider.torStatus.ready;
  String? get ownOnion => _chatProvider.torStatus.onionHost;
  bool get messagingReady => _chatProvider.selectedProfileReady;
  bool get messagingProfilePending => _chatProvider.selectedProfilePending;
  bool get commitmentBlocked => _chatProvider.selectedCommitmentBlocked;
  String get commitmentSummary =>
      _chatProvider.selectedCommitmentAssessment?.summary ?? 'Select a BitName to inspect its application commitment';
  String get commitmentDetails =>
      _chatProvider.selectedCommitmentAssessment?.details ?? 'No commitment state is available.';
  String get commitmentMode => _chatProvider.commitmentMode;
  String get commitmentNetwork => _chatProvider.commitmentNetwork;
  BitnamesChainSnapshot get chainHealth => _chatProvider.chainHealth;
  BitnamesStorageStatus get storageStatus => _chatProvider.storageStatus;
  bool get chainWritesReady => chainHealth.mutationSafe && storageStatus.writable;
  bool get hasTorChainPeer {
    if (torOnly || _chatProvider.hasConfiguredTorPeer) return true;
    try {
      final profile = selectedContact?.replyProfile;
      return profile != null && BitMessageProfile.fromJson(profile).torEndpoints.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool get canSend => switch (selectedContact?.relationshipState) {
    ChatRelationshipState.accepted => true,
    ChatRelationshipState.none => selectedContact?.paymailFeeSats != null,
    _ => false,
  };
  bool get introductionAwaitingBlock => currentConversation.any(
    (message) =>
        message.id == selectedContact?.introductionId &&
        message.isOutgoing &&
        message.kind == ChatMessageKind.introduction &&
        message.deliveryState == ChatDeliveryState.pending,
  );
  String get relationshipStatus => switch (selectedContact!.relationshipState) {
    ChatRelationshipState.accepted => 'Accepted • direct/Tor chat unlocked',
    ChatRelationshipState.incomingIntroduction => 'Introduction received • accept to unlock chat',
    ChatRelationshipState.acceptancePending => 'Acceptance sent • waiting for chain confirmation',
    ChatRelationshipState.outgoingIntroduction when introductionAwaitingBlock =>
      'Introduction submitted • waiting for a BitNames block',
    ChatRelationshipState.outgoingIntroduction => 'Introduction sent • waiting for acceptance',
    ChatRelationshipState.rejected => 'Introduction closed • no further payment will be sent',
    ChatRelationshipState.blocked => 'Blocked',
    _ when selectedContact!.paymailFeeSats != null =>
      'Introduction: ${selectedContact!.paymailFeeSats} sats + 100 sats chain fee',
    _ => 'This BitName is not accepting introductions',
  };
  String get sendHint => switch (selectedContact?.relationshipState) {
    ChatRelationshipState.incomingIntroduction => 'Accept or reject this introduction',
    ChatRelationshipState.acceptancePending => 'Waiting for acceptance confirmation',
    ChatRelationshipState.outgoingIntroduction when introductionAwaitingBlock => 'Waiting for a BitNames block',
    ChatRelationshipState.outgoingIntroduction => 'Waiting for acceptance',
    ChatRelationshipState.rejected => 'Introduction closed',
    ChatRelationshipState.blocked => 'Contact blocked',
    _ => 'Type a message...',
  };

  bool get isClaiming => _chatProvider.isClaiming;
  String? get claimingStatus => _chatProvider.claimingStatus;
  List<StatusMessage> get statusMessages => _chatProvider.statusMessages;

  ChatViewModel() {
    _chatProvider.addListener(_onProviderChanged);
    _bitnamesRPC.addListener(_onConnectionChanged);
    messageController.addListener(notifyListeners);
  }

  void init() {
    if (isConnected) {
      _chatProvider.startPolling();
      unawaited(_chatProvider.refresh());
    }
  }

  void _onProviderChanged() {
    notifyListeners();
  }

  void _onConnectionChanged() {
    if (isConnected) {
      _chatProvider.startPolling();
    }
    notifyListeners();
  }

  void selectIdentity(BitnameEntry identity) {
    _chatProvider.selectIdentity(identity);
  }

  Future<bool> prepareRegistration(bool useTor) async {
    if (useTor && !torReady && !await startTor()) return false;
    return setTorOnly(useTor);
  }

  Future<String?> registerIdentity(String name, int fee) async {
    final txid = await _chatProvider.claimIdentity(name, introductionFeeSats: fee);
    if (txid != null) await publishProfile('$fee');
    return txid;
  }

  Future<void> saveNameMapping(String plaintextName) async {
    await _chatProvider.saveNameMapping(plaintextName);
  }

  Future<bool> addContactFromEntry(BitnameEntry entry) => _chatProvider.addContactFromEntry(entry);

  void selectContact(ChatContact contact) {
    _chatProvider.selectContact(contact);
  }

  Future<void> loadOlderMessages() async => _chatProvider.loadOlderMessages();

  Future<void> sendMessage(BuildContext context) async {
    if (messageController.text.isEmpty) return;
    final contact = selectedContact!;
    if (contact.relationshipState == ChatRelationshipState.none &&
        !await _confirmSpend(
          context,
          'Send introduction?',
          '${contact.paymailFeeSats} sats to the recipient + ${ChatProvider.minerFeeSats} sats chain fee',
        )) {
      return;
    }
    final content = messageController.text;
    messageController.clear();
    final result = await _chatProvider.send(content);
    if (!result.sent && !result.needsChainConfirmation) {
      messageController.text = content;
    }
    if (context.mounted) await _handleFallback(context, result);
  }

  Future<void> accept(BuildContext context) async {
    final result = await _chatProvider.acceptIntroduction();
    if (context.mounted) await _handleFallback(context, result);
  }

  Future<void> reject() => _chatProvider.rejectIntroduction();
  Future<void> cancelIntroduction() => _chatProvider.cancelIntroduction();
  Future<void> block() => _chatProvider.blockContact();
  Future<void> retryChainRecovery() => _chatProvider.retryChainRecovery();
  Future<void> sendViaChain(BuildContext context, String id) => _sendFallback(context, id);
  Future<void> _handleFallback(BuildContext context, ChatSendResult result) async {
    if (result.needsChainConfirmation && result.id != null) {
      await _sendFallback(context, result.id!);
    } else if (!result.sent && context.mounted) {
      showSailToast(context, result.error ?? 'Message failed');
    }
  }

  Future<void> _sendFallback(BuildContext context, String id) async {
    if (!await _confirmSpend(
      context,
      'Send through BitNames?',
      '${ChatProvider.fallbackValueSats} sat + ${ChatProvider.minerFeeSats} sats chain fee',
    )) {
      return;
    }
    final result = await _chatProvider.sendViaChain(id);
    if (!result.sent && context.mounted) showSailToast(context, result.error ?? 'Chain send failed');
  }

  Future<bool> startTor() async => (await _chatProvider.downloadAndStartTor()).ready;
  Future<bool> setTorOnly(bool enabled) {
    final profile = selectedContact?.replyProfile;
    final onion = profile == null ? null : BitMessageProfile.fromJson(profile).torEndpoints.firstOrNull?.host;
    final peer = onion == null || onion.contains(':') ? onion : '$onion:6002';
    return _chatProvider.setTorOnly(enabled, peerOnion: peer);
  }

  Future<bool> publishProfile(String fee) async {
    try {
      final onion = ownOnion;
      final parsedFee = int.tryParse(fee.trim());
      if (fee.trim().isNotEmpty && parsedFee == null) return false;
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      final address = interfaces.expand((interface) => interface.addresses).where((ip) => !ip.isLoopback).firstOrNull;
      return await _chatProvider.publishProfile(
            direct: [if (!torOnly && address != null) Uri.parse('http://${address.address}:37999')],
            tor: [if (onion != null) Uri.parse('http://$onion')],
            paymailFeeSats: parsedFee,
          ) !=
          null;
    } catch (_) {
      return false;
    }
  }

  Future<void> backupPrivateData(BuildContext context) async {
    await _runPrivateAction(
      context,
      success: 'Encrypted chats, reply routes, and pending operations backed up',
      failure: 'Private backup failed',
      action: () async {
        final path = await FilePicker.saveFile(
          dialogTitle: 'Save encrypted BitNames backup',
          fileName: 'bitnames-private-${DateTime.now().toUtc().toIso8601String().replaceAll(':', '-')}.json',
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        if (path == null) return false;
        await File(path).writeAsString(
          await _chatProvider.exportPrivateData(),
          flush: true,
        );
        return true;
      },
    );
  }

  Future<void> restorePrivateData(BuildContext context) async {
    await _runPrivateAction(
      context,
      success: 'Encrypted BitNames data authenticated and restored',
      failure: 'Private restore rejected',
      action: () async {
        final result = await FilePicker.pickFiles(
          dialogTitle: 'Restore encrypted BitNames backup',
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        final path = result?.files.single.path;
        if (path == null) return false;
        final file = File(path);
        if (await file.length() > 64 * 1024 * 1024) {
          throw const BitnamesStorageException('Backup is larger than the 64 MiB safety limit');
        }
        await _chatProvider.restorePrivateData(await file.readAsString());
        return true;
      },
    );
  }

  Future<void> clearPrivateData(BuildContext context) async {
    final confirmed = await showThemedDialog<bool>(
      context: context,
      builder: (dialogContext) => SailAlertCard(
        title: 'Clear private chat history?',
        subtitle:
            'Contacts, messages, and queued encrypted deliveries will be removed. '
            'Registered BitNames and confirmed reply profiles stay available.',
        confirmText: 'Clear chats',
        onConfirm: () async => Navigator.pop(dialogContext, true),
        onCancel: () async => Navigator.pop(dialogContext, false),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _runPrivateAction(
      context,
      success: 'Private BitNames chat history cleared',
      failure: 'Could not clear chats',
      action: () async {
        await _chatProvider.clearChatHistory();
        return true;
      },
    );
  }

  Future<void> _runPrivateAction(
    BuildContext context, {
    required Future<bool> Function() action,
    required String success,
    required String failure,
  }) async {
    try {
      final completed = await action();
      if (completed && context.mounted) showSailToast(context, success, variant: SailToastVariant.success);
    } catch (e) {
      if (context.mounted) showSailToast(context, '$failure: $e');
    }
  }

  @override
  void dispose() {
    _chatProvider.removeListener(_onProviderChanged);
    _bitnamesRPC.removeListener(_onConnectionChanged);
    messageController.dispose();
    super.dispose();
  }
}

Future<bool> _confirmSpend(BuildContext context, String title, String subtitle) async =>
    await showThemedDialog<bool>(
      context: context,
      builder: (dialogContext) => SailAlertCard(
        title: title,
        subtitle: subtitle,
        confirmText: 'Confirm spend',
        onConfirm: () async => Navigator.pop(dialogContext, true),
        onCancel: () async => Navigator.pop(dialogContext, false),
      ),
    ) ==
    true;

/// Searchable dropdown for selecting a BitName identity.
/// Supports searching by plaintext name (uses Blake3 hash matching)
/// or by hash prefix.
class _SearchableIdentityDropdown extends StatelessWidget {
  final List<BitnameEntry> identities;
  final BitnameEntry? selectedIdentity;
  final ValueChanged<BitnameEntry> onIdentitySelected;

  const _SearchableIdentityDropdown({
    required this.identities,
    required this.selectedIdentity,
    required this.onIdentitySelected,
  });

  String _displayName(BitnameEntry entry) {
    return entry.plaintextName ?? '${entry.hash.substring(0, 8)}...';
  }

  @override
  Widget build(BuildContext context) {
    return SailCombobox<BitnameEntry>(
      items: [
        for (final entry in identities)
          SailComboboxItem(
            value: entry,
            label: _displayName(entry),
            subtitle: '${entry.hash.substring(0, 16)}...',
          ),
      ],
      value: selectedIdentity,
      placeholder: 'Select identity',
      searchPlaceholder: 'Search by name or hash...',
      noResultsText: 'No matching identities found',
      filter: (item, query) {
        // Plaintext queries also match their Blake3 hash.
        String? searchHash;
        try {
          searchHash = blake3Hex(utf8.encode(query));
        } catch (_) {
          searchHash = null;
        }
        final entry = item.value;
        if (searchHash != null && entry.hash.toLowerCase() == searchHash.toLowerCase()) {
          return true;
        }
        if (entry.plaintextName?.toLowerCase().contains(query) ?? false) {
          return true;
        }
        return entry.hash.toLowerCase().contains(query);
      },
      onChanged: onIdentitySelected,
    );
  }
}
