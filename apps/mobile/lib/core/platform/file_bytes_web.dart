import 'dart:html' as html;

Future<List<int>> readFileBytes(String path) async {
  // On web, 'path' is actually a blob URL or data URL from the image picker.
  // We handle this by reading the blob.
  try {
    final response = await html.HttpRequest.request(
      path,
      responseType: 'blob',
    );
    final reader = html.FileReader();
    reader.readAsArrayBuffer(response.response as html.Blob);
    await reader.onLoad.first;
    return (reader.result as List<dynamic>).cast<int>();
  } catch (_) {
    // Fallback: if path is a data URL, parse it
    if (path.startsWith('data:')) {
      final commaIdx = path.indexOf(',');
      if (commaIdx != -1) {
        final base64 = path.substring(commaIdx + 1);
        final bytes = _base64Decode(base64);
        return bytes;
      }
    }
    throw UnsupportedError('Cannot read file on web: $path');
  }
}

List<int> _base64Decode(String input) {
  const String base64Chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  String s = input.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
  final bytes = <int>[];
  int i = 0;
  while (i < s.length) {
    final a = base64Chars.indexOf(s[i++]);
    final b = base64Chars.indexOf(s[i++]);
    final c = base64Chars.indexOf(s[i++]);
    final d = base64Chars.indexOf(s[i++]);
    bytes.add((a << 2) | (b >> 4));
    if (c != 64) bytes.add(((b & 15) << 4) | (c >> 2));
    if (d != 64) bytes.add(((c & 3) << 6) | d);
  }
  return bytes;
}
