import 'package:miao_ji/services/database.dart';
import 'package:miao_ji/models/user_process.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';


class WordBookManager{
  static const String defaultWordBookName = 'default';

  static List<String>? wordBooks;
  WordBookManager._();
  static final WordBookManager _singleton = WordBookManager._();
  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static Future<WordBookManager> getInstance() async{
    wordBooks ??= await _prefs.getStringList('wordBooks') ?? [defaultWordBookName];
    if(!wordBooks!.contains(defaultWordBookName)) wordBooks!.add(defaultWordBookName);
    await _prefs.setStringList('wordBooks', wordBooks!);
    return _singleton;
  }

  Future<WordBook> getWordBook(String name) async{
    if(wordBooks!.contains(name)){
      WordBook wordBook = WordBook(name);
      await wordBook.initialize();
      return wordBook;
    }
    throw Exception('Word book $name not found.');
  }

  Future<WordBook> createWordBook(String name) async{
    if(wordBooks!.contains(name)) return await getWordBook(name);
    wordBooks!.add(name);
    await _prefs.setStringList('wordBooks', wordBooks!);
    WordBook wordBook = WordBook(name);
    await wordBook.initialize();
    return wordBook;
  }

  Future<void> deleteWordBook(String name) async{
    if(wordBooks!.contains(name)){
      wordBooks!.remove(name);
      await _prefs.setStringList('wordBooks', wordBooks!);
      WordBook wordBook = WordBook(name);
      await wordBook.initialize();
      await wordBook.deleteTable();
    } 
  }
}

class WordBook {
  late String name;
  UserProcess? userProcess;
  Database? database;
  WordBook(this.name);

  Future<void> initialize() async{
    database ??= await DBProvider.database;
    await database!.execute('''CREATE TABLE IF NOT EXISTS ${TableNames.wordBookPrefix + name} (
      word TEXT PRIMARY KEY
    )''');
    userProcess??= UserProcess();
    await userProcess!.initialize(name);
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

  Future<void> clear() async {
    await database!.delete(TableNames.wordBookPrefix + name);
  }

  Future<void> deleteTable() async {
    database ??= await DBProvider.database;
    await database!.execute('''DROP TABLE IF EXISTS ${TableNames.wordBookPrefix + name}''');
  }
}