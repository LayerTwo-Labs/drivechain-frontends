enum DeleteItemStatus { pending, inProgress, success, error }

class DeleteItem {
  final String path;
  DeleteItemStatus status;
  String? errorMessage;

  DeleteItem({required this.path, this.status = DeleteItemStatus.pending, this.errorMessage});
}
