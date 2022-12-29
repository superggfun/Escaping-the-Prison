import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';

Future<Database> initializeDB() async {
  var databasePath = await getDatabasesPath();
  var path = join(databasePath, "copys.db");

  var exists = await databaseExists(path);

  if (!exists) {
    print('creating a new copy from asset!');

    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    ByteData data = await rootBundle.load(join("assets", "mysql.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    await File(path).writeAsBytes(bytes, flush: true);
  } else {
    print('opening existing database');
  }

  return await openDatabase(path, version: 1, readOnly: false);
}
