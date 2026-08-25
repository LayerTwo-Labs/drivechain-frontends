import 'dart:io';

/// True when [path] names a file directly inside [pictureDir]. A wallet
/// restored from another computer carries that computer's path, and nothing
/// outside this folder is the app's to delete.
bool isInsideWalletPictures(String path, String pictureDir) {
  final file = File(path).absolute.uri.normalizePath();
  final dir = Directory(pictureDir).absolute.uri.normalizePath();

  final fileSegments = file.pathSegments.where((s) => s.isNotEmpty).toList();
  final dirSegments = dir.pathSegments.where((s) => s.isNotEmpty).toList();

  // One file, directly in the folder: every folder segment matches, and one
  // name follows.
  if (fileSegments.length != dirSegments.length + 1) {
    return false;
  }
  for (var i = 0; i < dirSegments.length; i++) {
    if (fileSegments[i] != dirSegments[i]) {
      return false;
    }
  }
  return true;
}
