import 'dart:html' as html;

Future<void> downloadCsv(String csv, String filename) async {
  final bytes = html.Blob([csv], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrl(bytes);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
