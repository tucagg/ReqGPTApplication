import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class StorageService {
  static const _filename = 'reqgpt_store.json';

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_filename');
  }

  Future<Map<String, dynamic>?> load() async {
    try {
      final file = await _file;
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Map<String, dynamic> data) async {
    try {
      final file = await _file;
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }
}
