import 'package:miao_ji/services/database.dart';
import 'package:miao_ji/models/user_process.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


class WordBookManager{
  
}

class WordBook {
  late String name;
  UserProcess? userProcess;
  Database? database;
  WordBook(this.name);

  Future<void> initialize() async{
    database ??= await DBProvider.database;
    userProcess??= UserProcess();
    userProcess!.initialize(name);
    await database!.execute('''CREATE TABLE IF NOT EXISTS ${TableNames.wordBookPrefix + name} (
      word TEXT PRIMARY KEY
    )''');
  }

  Future<void> addWord(String word) async {
    final result = await database!.query(TableNames.wordBookPrefix + name, where: 'word =?', whereArgs: [word]);
    if(result.isNotEmpty) return;
    await database!.insert(TableNames.wordBookPrefix + name, {'word': word});
  }

  Future<void> deleteWord(String word) async {
    await database!.delete(TableNames.wordBookPrefix + name, where: 'word =?', whereArgs: [word]);
  }

  Future<List<String>> getWords() async {
    final List<Map<String, dynamic>> maps = await database!.query(TableNames.wordBookPrefix + name);
    List<String> words = [];
    for (Map<String, dynamic> map in maps) {
      words.add(map['word']);
    }
    return words;
  }

  Future<int> getNewWordNum() async{
    List<Map<String, dynamic>> maps = await database!.rawQuery('''SELECT wb.word FROM ${TableNames.wordBookPrefix + name} AS wb
      WHERE NOT EXISTS(
        SELECT 1
        FROM ${TableNames.memorizingData} AS md
        WHERE md.word = wb.word
      )
    ''');
    return maps.length;
  }

  Future<int> getLearnedWordNum() async{
    List<Map<String, dynamic>> maps = await database!.rawQuery('''SELECT md.word FROM ${TableNames.memorizingData} AS md
      WHERE EXISTS(
        SELECT 1
        FROM ${TableNames.wordBookPrefix + name} AS wb
        WHERE md.word = wb.word AND md.score <= 120
      )
    ''');
    return maps.length;
  }

  Future<int> getFamiliarWordNum() async{
    List<Map<String, dynamic>> maps = await database!.rawQuery('''SELECT md.word FROM ${TableNames.memorizingData} AS md
      WHERE EXISTS(
        SELECT 1
        FROM ${TableNames.wordBookPrefix + name} AS wb
        WHERE md.word = wb.word AND md.score > 120
      )
    ''');
    return maps.length;
  }

}