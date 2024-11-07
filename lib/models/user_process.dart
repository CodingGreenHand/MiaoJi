import 'package:miao_ji/services/database.dart';
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

  //TODO: detail the logic
  bool _needsToReview(Map<String,dynamic> wordData){
    if(wordData['score'] <= 120) return true;
    return false;
    //if(wordData['score'] <= 20 && wordData['last_memorizing_time'])
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
    int neededReviewCount = (userPlan.dailyReviewNum - todayReviewCount)>0? (userPlan.dailyReviewNum - todayReviewCount) : 0;
    List<Map<String, dynamic>> newWordQueryResult = await database!.rawQuery('''SELECT wb.word FROM ${TableNames.wordBookPrefix + wordBookName} AS wb
    WHERE NOT EXISTS(
      SELECT 1
      FROM ${TableNames.memorizingData} AS md
      WHERE md.word = wb.word
    )
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
    LIMIT $neededReviewCount
    ''');
    mutableList = [...learnedWordQueryResult];
    if (userPlan.memorizingOrder == MemorizingOrder.random){
      mutableList.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
    }
    for(Map<String, dynamic> row in mutableList){
      if(_needsToReview(row)) wordsToReview.add(row['word']);
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
}