import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class DBProvider{
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database? _database;

  static Future<Database> get database async {
    if(_database != null){
      return _database!;
    }
    _database = await initDB();
    return _database!;
  }

  static initDB() async{
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'hello_world.db');
    //String path = 'hello_world.db';
    return await openDatabase(path, version: 1, onOpen: (db){});
  }

  static closeDataBase(){
    _database?.close();
    _database = null;
  }

}