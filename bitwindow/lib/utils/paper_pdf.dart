import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/sail_ui.dart';

/// Returns the QR module grid of [data], with the error correction level of the dialog QR codes.
QrMatrix paperQrMatrix(String data) {
  final image = QrImage(QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.L));
  final size = image.moduleCount;
  final modules = Uint8List(size * size);
  for (var row = 0; row < size; row++) {
    for (var col = 0; col < size; col++) {
      modules[row * size + col] = image.isDark(row, col) ? 1 : 0;
    }
  }
  return QrMatrix(size: size, modules: modules);
}

/// Asks the user where to save [pdf], then opens the saved file in the default PDF viewer.
/// Does nothing when the user cancels.
Future<void> savePdfAndOpen(List<int> pdf, String fileName) async {
  final uri = await FilePicker.saveFile(
    fileName: fileName,
    bytes: Uint8List.fromList(pdf),
    mimeType: 'application/pdf',
  );
  if (uri == null) {
    return;
  }
  try {
    await openUrl(uri);
  } on OpenUrlException {
    throw Exception('could not open ${uri.toFilePath()}');
  }
}
