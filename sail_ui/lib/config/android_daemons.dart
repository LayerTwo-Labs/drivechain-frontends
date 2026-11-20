import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sidechain_core/utils/android_native.dart';

/// The daemons the Android APK ships as `lib<name>.so`.
const androidDaemons = ['bitwindowd', 'drivechaind'];

/// Links each of [androidDaemons] into [binDir], so the desktop binary paths
/// resolve to the APK's native library folder.
Future<void> linkAndroidDaemons(Directory binDir) async {
  final nativeDir = await androidNative.invokeMethod<String>('nativeLibraryDir');
  if (nativeDir == null || nativeDir.isEmpty) {
    throw StateError('Android returned no native library folder');
  }
  await linkNativeBinaries(binDir, nativeDir, androidDaemons);
}

/// Points `binDir/<name>` at `nativeDir/lib<name>.so` for each name. An APK
/// update moves nativeDir, so a link to another target is made again.
Future<void> linkNativeBinaries(Directory binDir, String nativeDir, List<String> names) async {
  for (final name in names) {
    final target = path.join(nativeDir, 'lib$name.so');
    if (!File(target).existsSync()) {
      throw FileSystemException('the APK has no $name', target);
    }
    final link = Link(path.join(binDir.path, name));
    final type = FileSystemEntity.typeSync(link.path, followLinks: false);
    if (type == FileSystemEntityType.link) {
      if (await link.target() == target) {
        continue;
      }
      await link.delete();
    } else if (type != FileSystemEntityType.notFound) {
      await File(link.path).delete();
    }
    await link.create(target);
  }
}
