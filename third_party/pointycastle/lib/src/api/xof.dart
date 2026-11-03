part of '../../api.dart';

abstract class Xof extends Digest {

  ///
  int doFinalRange(Uint8List out, int outOff, int outLen);

  int doOutput(Uint8List out, int outOff, int outLen);
}
