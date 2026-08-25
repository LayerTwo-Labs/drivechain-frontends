import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  _dragTests();

  _zoomTests();

  test('a large window gives the window its full side', () {
    expect(pictureSideFor(const Size(1440, 900)), 432);
  });

  // main.dart lets the window go down to 400 by 400.
  test('the smallest window still leaves room for the buttons', () {
    final side = pictureSideFor(const Size(400, 400));

    expect(side, lessThan(432));
    expect(side + 260, lessThanOrEqualTo(400), reason: 'the window and its chrome must fit');
  });

  test('a narrow window takes its width, so the picture stays square', () {
    expect(pictureSideFor(const Size(300, 900)), 300 - 96);
  });

  test('a very small window stops at the smallest useful side', () {
    expect(pictureSideFor(const Size(150, 150)), 120);
  });
}

// The window covers itself with the picture's short side, so a zoom factor of
// 1 is the smallest useful zoom. A photo whose cover scale is far below 1 must
// not jump when the user scrolls out.
void _zoomTests() {
  test('the zoom factor never goes below the cover scale', () {
    expect(zoomFactorAfter(1.0, 1.0), 1.0, reason: 'a scroll out at the cover stays at the cover');
    expect(zoomFactorAfter(1.0, -1.0), greaterThan(1.0));
  });

  test('the zoom factor stops at the top', () {
    var factor = 8.0;
    for (var i = 0; i < 10; i++) {
      factor = zoomFactorAfter(factor, -1.0);
    }
    expect(factor, 8.0);
  });

  test('a scroll out walks back down to the cover', () {
    var factor = 4.0;
    for (var i = 0; i < 100; i++) {
      factor = zoomFactorAfter(factor, 1.0);
    }
    expect(factor, 1.0);
  });
}

// A drag must never pull the picture off the window, or the saved picture
// carries empty space.
void _dragTests() {
  test('a drag stops at the edge of the picture', () {
    const scaled = Size(600, 600);
    const side = 432.0;
    const limit = (600 - 432) / 2;

    expect(clampPictureOffset(const Offset(1000, 0), scaled, side).dx, limit);
    expect(clampPictureOffset(const Offset(-1000, 0), scaled, side).dx, -limit);
    expect(clampPictureOffset(const Offset(0, 1000), scaled, side).dy, limit);
  });

  test('a drag inside the picture stays where the user put it', () {
    expect(clampPictureOffset(const Offset(20, -30), const Size(900, 900), 432), const Offset(20, -30));
  });

  test('a picture no larger than the window cannot move', () {
    expect(clampPictureOffset(const Offset(50, 50), const Size(432, 432), 432), Offset.zero);
  });
}
