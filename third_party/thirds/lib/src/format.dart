String asHexString(List<int> bytes) {
  final sb = StringBuffer();

  for (int b in bytes) {
    sb.write(b.toRadixString(16).padLeft(2, '0'));
  }

  return sb.toString();
}
