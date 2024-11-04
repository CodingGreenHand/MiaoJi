import 'package:flutter_test/flutter_test.dart';
import 'package:miao_ji/services/database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('database_viewer', () async {
    Database database = await DBProvider.database;
    print(await database.rawQuery(
      '''
      SELECT name   
      FROM sqlite_master   
      WHERE type='table';
      '''
    ));
  });
}