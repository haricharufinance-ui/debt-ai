import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/app_data.dart';

/// Local-file persistence for now. Per the brief: "details should currently
/// be stored in a file in phone local storage; later we can move to a DB."
///
/// SWAP-TO-DB-LATER PLAN:
/// This class is the *only* place that knows data lives in a file. To move
/// to SQLite (sqflite) or a remote API, implement the same two methods
/// (`load()` / `save(AppData)`) against the new backend and nothing in
/// AppState or the UI needs to change.
abstract class StorageService {
  Future<AppData> load();
  Future<void> save(AppData data);
}

class LocalFileStorageService implements StorageService {
  static const _fileName = 'debtzero_data.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  @override
  Future<AppData> load() async {
    try {
      final f = await _file();
      if (!await f.exists()) return AppData();
      final raw = await f.readAsString();
      if (raw.trim().isEmpty) return AppData();
      return AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupt or unreadable file - start fresh rather than crash the app.
      return AppData();
    }
  }

  @override
  Future<void> save(AppData data) async {
    final f = await _file();
    await f.writeAsString(jsonEncode(data.toJson()));
  }
}
