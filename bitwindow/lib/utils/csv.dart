/// Encodes [rows] as RFC 4180 CSV: comma fields, CRLF between rows, no CRLF at the end.
String encodeCsv(List<List<String>> rows) => rows.map((row) => row.map(_encodeField).join(',')).join('\r\n');

String _encodeField(String field) {
  final quote =
      field.contains(',') ||
      field.contains('\n') ||
      field.contains('\r') ||
      field.contains('"') ||
      field.startsWith(' ') ||
      field.endsWith(' ');
  return quote ? '"${field.replaceAll('"', '""')}"' : field;
}
