import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:bitwindow/utils/wallet_picture_path.dart';
import 'package:sail_ui/sail_ui.dart';

/// Opens the edit dialog for one wallet: its name, its picture, and the
/// choice to delete it.
Future<void> editWallet(BuildContext context, WalletMetadata wallet) async {
  final result = await showEditWalletDialog(
    context,
    currentName: wallet.name,
    gradient: wallet.gradient,
    onChangePicture: () async => _pickWalletPicture(context),
    onConfirmDelete: () async => _confirmDeleteWallet(context, wallet.name),
  );
  if (result == null) {
    return;
  }

  if (result.delete) {
    try {
      await GetIt.I.get<OrchestratorRPC>().wallet.deleteWallet(wallet.id);
    } catch (e) {
      // The backend refuses to delete the starter wallet while others exist,
      // and the dialog is already gone, so the reason goes to the user here.
      if (context.mounted) {
        showSailToast(context, 'Could not delete ${wallet.name}: $e', variant: SailToastVariant.destructive);
      }
      return;
    }
    await _deleteWalletPicture(wallet.gradient.picturePath);
    return;
  }

  var gradient = wallet.gradient;
  if (result.removePicture) {
    gradient = gradient.withoutPicture();
  }
  final picture = result.picture;
  File? written;
  if (picture != null) {
    written = await _saveWalletPicture(wallet.id, picture);
    gradient = gradient.copyWith(picturePath: written.path);
  }

  try {
    await GetIt.I.get<WalletReaderProvider>().updateWalletMetadata(wallet.id, result.name, gradient);
  } catch (_) {
    // Nothing points at the new file, so it does not stay on the disk.
    await _deleteWalletPicture(written?.path);
    rethrow;
  }

  // The old file goes only once the wallet no longer points at it.
  if (result.removePicture || written != null) {
    await _deleteWalletPicture(wallet.gradient.picturePath);
  }
}

Future<bool> _confirmDeleteWallet(BuildContext context, String name) async {
  final go = await showThemedDialog<bool>(
    context: context,
    builder: (context) => SailAlertCard(
      title: 'Delete $name?',
      subtitle: 'The wallet leaves this computer. Its backup is the only way back.',
      confirmText: 'Delete wallet',
      confirmButtonVariant: ButtonVariant.destructive,
      onConfirm: () async => Navigator.of(context).pop(true),
      onCancel: () async => Navigator.of(context).pop(false),
    ),
  );
  return go ?? false;
}

/// Asks for an image file, then lets the user place it in the round window.
Future<Uint8List?> _pickWalletPicture(BuildContext context) async {
  final picked = await FilePicker.pickFile(
    dialogTitle: 'Choose a wallet picture',
    type: FileType.image,
  );
  final path = picked?.path;
  if (path == null || !context.mounted) {
    return null;
  }
  return showPlacePictureDialog(context, File(path));
}

/// Takes the picture off the disk. A user who removes a picture, or deletes
/// the wallet, does not leave the photo behind.
Future<void> _deleteWalletPicture(String? path) async {
  if (path == null || path.isEmpty) {
    return;
  }
  // A restored wallet carries whatever path its old computer wrote, so only
  // a file this app put in its own folder goes.
  final appDir = GetIt.I.get<WindowProvider>().appDir;
  final owned = Directory([appDir.path, 'wallet_pictures'].join(Platform.pathSeparator));
  final file = File(path);
  if (!isInsideWalletPictures(file.absolute.path, owned.absolute.path)) {
    return;
  }
  if (!await file.exists()) {
    return;
  }
  await file.delete();
  await FileImage(file).evict();
}

/// Writes the placed picture beside the wallet metadata. Each save takes its
/// own name, so a replacement never overwrites the picture it replaces.
Future<File> _saveWalletPicture(String walletId, Uint8List png) async {
  final appDir = GetIt.I.get<WindowProvider>().appDir;
  final dir = Directory([appDir.path, 'wallet_pictures'].join(Platform.pathSeparator));
  await dir.create(recursive: true);
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final file = File([dir.path, '$walletId-$stamp.png'].join(Platform.pathSeparator));
  await file.writeAsBytes(png, flush: true);
  return file;
}
