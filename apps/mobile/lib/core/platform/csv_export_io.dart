import 'dart:io';

Future<void> downloadCsv(String csv, String filename) async {
  final dir = Directory(
    '${Platform.environment['USERPROFILE'] ?? Platform.environment['HOME']}/Downloads',
  );
  final file = File('${dir.path}/$filename');
  await file.writeAsString(csv);
}
