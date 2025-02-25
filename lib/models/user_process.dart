import 'package:miao_ji/services/database.dart';
import 'package:miao_ji/services/word_memorizing_system.dart';
import 'dart:collection';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:miao_ji/models/user_plan.dart';
import 'dart:math';

class UserProcess {
  int todayLearnCount = 0;
  int todayReviewCount = 0;
  DateTime lastMemorizingTime = DateTime.fromMillisecondsSinceEpoch(0);
  Queue<String> wordsToLearn = Queue();
  Queue<String> wordsToReview = Queue();
  Database? database;
  SharedPreferencesAsync? prefs;

  bool _isOneDayPassed(DateTime lastTime){
    DateTime now = DateTime.now();
    if(now.year != lastTime.year || now.month!= lastTime.month) return true;
    return now.day!= lastTime.day;
  }

  bool _needsToReview(Map<String,dynamic> wordData){
    if(wordData['score'] == null) return true;
    int score = wordData['score'];
    if(score > 120) return false;
    if(score <= 20) return true;
    DateTime lastMemorizingTime = DateTime.parse(wordData['last_memorizing_time']);
    Duration interval = DateTime.now().difference(lastMemorizingTime);
    final List<int> expectedIntervalsInDays = [1,2,4,7,15];
    if(score <= 40){
      return interval.inDays >= expectedIntervalsInDays[0];
    }
    else if(score <= 60){
      return interval.inDays >= expectedIntervalsInDays[1];
    }
    else if(score <= 80){
      return interval.inDays >= expectedIntervalsInDays[2];
    }
    else if(score <= 100){
      return interval.inDays >= expectedIntervalsInDays[3];
    }
    else if(score <= 120){
      return interval.inDays >= expectedIntervalsInDays[4];
    }
    return false;
  }

  Future<void> initialize(String wordBookName) async{
    database ??= await DBProvider.database;
    prefs ??= SharedPreferencesAsync();
    todayLearnCount = await prefs!.getInt('todayLearnCount')?? 0;
    todayReviewCount = await prefs!.getInt('todayReviewCount')?? 0;
    lastMemorizingTime = DateTime.fromMillisecondsSinceEpoch(await prefs!.getInt('lastMemorizingTime')?? 0);
    if(_isOneDayPassed(lastMemorizingTime)){
      todayLearnCount = 0;
      todayReviewCount = 0;
    }
    UserPlan userPlan = await UserPlan.getInstance();
    int neededNewWordCount = (userPlan.dailyLearnNum - todayLearnCount)>0? (userPlan.dailyLearnNum - todayLearnCount) : 0;
    int neededReviewCount = (userPlan.dailyReviewNum +  todayLearnCount - todayReviewCount)>0? (userPlan.dailyReviewNum +  todayLearnCount - todayReviewCount) : 0;
    String orderSql = userPlan.memorizingOrder == MemorizingOrder.sequential? 'ASC' : 'DESC';
    List<Map<String, dynamic>> newWordQueryResult = await database!.rawQuery('''SELECT wb.word FROM ${TableNames.wordBookPrefix + wordBookName} AS wb
    WHERE NOT EXISTS(
      SELECT 1
      FROM ${TableNames.memorizingData} AS md
      WHERE md.word = wb.word
    )
    ORDER BY wb.word $orderSql
    LIMIT $neededNewWordCount
    ''');
    List<Map<String,dynamic>> mutableList = [...newWordQueryResult];
    if (userPlan.memorizingOrder == MemorizingOrder.random){
      mutableList.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
    }
    for(Map<String, dynamic> row in mutableList){
      wordsToLearn.add(row['word']);
    }
    List<Map<String, dynamic>> learnedWordQueryResult = await database!.rawQuery('''SELECT md.word,md.score,md.last_memorizing_time FROM ${TableNames.memorizingData} AS md
    WHERE EXISTS(
      SELECT 1
      FROM ${TableNames.wordBookPrefix + wordBookName} AS wb
      WHERE md.word = wb.word AND md.score <= 120
    )
    ORDER BY md.word $orderSql
    ''');
    mutableList = [...learnedWordQueryResult];
    for(Map<String, dynamic> row in mutableList){
      if(row['score'] <= 20) wordsToReview.add(row['word']);
    }
    for(Map<String, dynamic> row in mutableList){
      if(wordsToReview.length >= neededReviewCount) break;
      if(row['score'] > 20 &&_needsToReview(row)) wordsToReview.add(row['word']);
    }
    if (userPlan.memorizingOrder == MemorizingOrder.random){
      mutableList.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
    }
  }

  String getNextWordToLearn(){
    if(wordsToLearn.isEmpty) return '';
    String word = wordsToLearn.first;
    return word;
  }

  String getNextWordToReview(){
    if(wordsToReview.isEmpty) return '';
    String word = wordsToReview.first;
    return word;
  }

  void updateLearningProgress(bool answeredCorrectly){
    if(answeredCorrectly) todayLearnCount++;
    wordsToLearn.removeFirst();
    updateLocalData();
  }

  void updateReviewingProgress(bool answeredCorrectly){
    if(answeredCorrectly) todayReviewCount++;
    wordsToReview.removeFirst();
    updateLocalData();
  }

  void appendWordToLearn(String word){
    wordsToLearn.add(word);
  }

  void appendWordToReview(String word){
    wordsToReview.add(word);
  }

  Future<void> updateLocalData() async{
    await prefs!.setInt('todayLearnCount', todayLearnCount);
    await prefs!.setInt('todayReviewCount', todayReviewCount);
    await prefs!.setInt('lastMemorizingTime', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> startNewRound() async {
    todayLearnCount = 0;
    todayReviewCount = 0;
    await updateLocalData();
    await WordMemorizingSystem().initialize();
  }
}