import 'package:miao_ji/services/database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:miao_ji/utils/date_time_formalizer.dart';

class MemorizingData {
  MemorizingData._();

  static Database? database;
  static final MemorizingData _instance = MemorizingData._();

  Future<void> init() async {
    database ??= await DBProvider.database;
    await database!.execute('''CREATE TABLE IF NOT EXISTS ${TableNames.memorizingData} (
      word TEXT PRIMARY KEY,
      score INTEGER DEFAULT 0,
      last_memorizing_time DATETIME DEFAULT CURRENT_TIMESTAMP
    )''');
  }

  static Future<MemorizingData> getInstance() async {
    if (database == null) await _instance.init();
    return _instance;
  }
  
  Future<void> update(String word,int score)async {
    List<Map<String, dynamic>> result = await database!.query(TableNames.memorizingData, where: 'word = ?', whereArgs: [word]);
    if(result.isEmpty){
      if(score > 0) await database!.insert(TableNames.memorizingData, {'word': word,'score': score,'last_memorizing_time':DateTimeFormalizer.truncateToDate(DateTime.now()).toIso8601String()});
    }else{
      if(result.first['score'] < score){
        await database!.update(TableNames.memorizingData,{'last_memorizing_time':DateTimeFormalizer.truncateToDate(DateTime.now()).toIso8601String()},where: 'word = ?', whereArgs: [word]);
      }
      await database!.update(TableNames.memorizingData, {'score': score}, where: 'word = ?', whereArgs: [word]);
    }
  }

  Future<void> updateBy(String word,int increment) async{
    int score = await queryScore(word);
    score += increment;
    if(score < 0){
      score = 0; 
    }
    await update(word,score);
  }

  Future<void> updateLastMemorizingTimeToNow(String word) async{
    await database!.update(TableNames.memorizingData,{'last_memorizing_time':DateTimeFormalizer.truncateToDate(DateTime.now()).toIso8601String()},where: 'word = ?', whereArgs: [word]);
  }

  Future<void> updateLastMemorizingTime(String word,DateTime dateTime) async{
    await database!.update(TableNames.memorizingData,{'last_memorizing_time':dateTime.toIso8601String()},where: 'word = ?', whereArgs: [word]);
  }

  Future<void> clear() async{
    database!.delete(TableNames.memorizingData);
  }

  Future<int> queryScore(String word) async{
    List<Map<String, dynamic>> result = await database!.query(TableNames.memorizingData, where: 'word = ?', whereArgs: [word]);
    return result.isEmpty? 0 : result.first['score'];
  }

  Future<List<Map<String, dynamic>>> queryAll() async{
    return await database!.query(TableNames.memorizingData);
  }

}