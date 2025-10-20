String formatBitcoinAddress(String address) {
  if (address.isEmpty) return address;

  final buffer = StringBuffer();
  for (int i = 0; i < address.length; i++) {
    if (i > 0 && i % 4 == 0) {
      buffer.write(' ');
    }
    buffer.write(address[i]);
  }
  return buffer.toString();
}
