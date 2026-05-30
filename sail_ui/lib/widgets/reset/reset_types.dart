enum DeleteItemStatus { pending, inProgress, success, error }

class DeleteItem {
  final String path;
  // Wallet paths are moved to wallet_backups/ by the orchestrator rather than
  // deleted, so the UI can word them as "moved" instead of "deleted".
  final bool isWallet;
  DeleteItemStatus status;
  String? errorMessage;

  DeleteItem({
    required this.path,
    this.isWallet = false,
    this.status = DeleteItemStatus.pending,
    this.errorMessage,
  });
}
