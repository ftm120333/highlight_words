import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// path to the database that will be set by loadDatabaseFromAssets function
// and it can be used throughout the app.
late final String databasePath;



// Simply, this will set the database path by checking if the database exists
// in the file system of the app:
//    - if it doesn't exist, we copy it from the assets and then add it to the file system
//    - if it exists, do nothing.
// This was copied from here: https://github.com/tekartik/sqflite/blob/master/sqflite/doc/opening_asset_db.md
Future<void> setDatabasePath() async {
  var databasesPath = await getDatabasesPath();
  databasePath = join(databasesPath, "tryHafs.db");

// Check if the database exists
  var exists = await databaseExists(databasePath);

  if (exists) {
    // do nothing
    print('database is here');
    print('path ==> $databasesPath');
    return;
  } else {
    print('database is  not here');
    // Make sure the parent directory exists
    try {

      await Directory(dirname(databasePath)).create(recursive: true);
    } catch (_) {}

    // Copy from asset
    ByteData data = await rootBundle.load(join("assets", "tryHafs.db"));
    List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await File(databasePath).writeAsBytes(bytes, flush: true);
  }
}
  Database? _database;
  Future<Database> getDatabase() async {
    return _database ??= await openDatabase(databasePath);
  }
