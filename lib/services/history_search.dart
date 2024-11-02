import 'package:miao_ji/services/database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class HistorySearchHandler {
  static Database? _db;

  HistorySearchHandler._();

  static final HistorySearchHandler _instance = HistorySearchHandler._();

  static get instance async{
    _db ??= await DBProvider.database;
    _instance.createHistorySearchTable();
    return _instance;
  }

  createHistorySearchTable() async{
    await _db!.execute('''CREATE TABLE IF NOT EXISTS history_search (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      search_text TEXT NOT NULL,
      search_time DATETIME DEFAULT CURRENT_TIMESTAMP
    )''');
  }

  insertHistorySearch(String searchText) async{
    await _db!.insert('history_search', {'search_text': searchText});
  }

  deleteHistorySearch(int id) async{
    await _db!.delete('history_search', where: 'id = ?', whereArgs: [id]);
  }

  deleteAllHistorySearch() async{
    await _db!.delete('history_search');
  }

  Future<List<Map<String, dynamic>>> getHistorySearch() async{
    return await _db!.query('history_search', orderBy: 'search_time DESC',distinct: true);
  }
}