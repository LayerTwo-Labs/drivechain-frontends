enum DeleteItemStatus { pending, inProgress, success, error }

class DeleteItem {
  final String path;
  // Used for wallet rows moved by the orchestrator wallet service.
  final bool skipClientDelete;
  DeleteItemStatus status;
  String? errorMessage;

  DeleteItem({
    required this.path,
    this.skipClientDelete = false,
    this.status = DeleteItemStatus.pending,
    this.errorMessage,
  });
}
