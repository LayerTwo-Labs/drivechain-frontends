import 'package:bitwindow/utils/wallet_picture_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const dir = '/home/u/app/wallet_pictures';

  test('a file the app wrote goes', () {
    expect(isInsideWalletPictures('$dir/AABB-1750000000000.png', dir), isTrue);
  });

  // A wallet restored from another computer carries that computer's path.
  test('a file outside the folder stays', () {
    expect(isInsideWalletPictures('/home/u/Documents/taxes.pdf', dir), isFalse);
    expect(isInsideWalletPictures('/etc/passwd', dir), isFalse);
    expect(isInsideWalletPictures('/home/u/app/wallet.json', dir), isFalse);
  });

  test('a path that climbs out stays', () {
    expect(isInsideWalletPictures('$dir/../../secret.png', dir), isFalse);
    expect(isInsideWalletPictures('$dir/../wallet.json', dir), isFalse);
  });

  test('a file deeper than the folder stays', () {
    expect(isInsideWalletPictures('$dir/nested/a.png', dir), isFalse);
  });

  test('the folder itself stays', () {
    expect(isInsideWalletPictures(dir, dir), isFalse);
  });
}
