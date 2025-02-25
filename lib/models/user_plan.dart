import 'package:miao_ji/services/dictionary.dart';
import 'package:miao_ji/services/word_memorizing_system.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';
import 'dart:math';

abstract class MemorizingOrder{
  static const String random = 'random';
  static const String sequential ='sequential';
  static const String reverse ='reverse';
  static const List<String> orders = [random, sequential, reverse];
}

abstract class MemorizingMethodName{
  static const String englishToChineseSelection = 'EnglishToChineseSelection';
  static const String chineseToEnglishSelection = 'ChineseToEnglishSelection';
  static const String chineseToEnglishSpelling = 'ChineseToEnglishSpelling';
  static const String sentenceGapFilling = 'SentenceGapFilling';
  static const String wordRecognitionCheck = 'WordRecognitionCheck';
  static const String newWordLearning = 'NewWordLearning';
  static const List<String> methods = [englishToChineseSelection, chineseToEnglishSelection, chineseToEnglishSpelling, sentenceGapFilling, wordRecognitionCheck];
}

class UserPlan {
  UserPlan._();

  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static int _dailyLearnNum = 10;
  static int _dailyReviewNum = 10;
  static String _memorizingOrder = MemorizingOrder.random;
  static List<String> _usingMethods = [MemorizingMethodName.wordRecognitionCheck];
  static final UserPlan _singleton = UserPlan._();
  static  LocalDictionary? _localDictionary;
  static int _scoreAward = 20;
  static int _scorePenalty = 5;

  static Future<UserPlan> getInstance() async{
    _dailyLearnNum = await _prefs.getInt('dailyLearnNum')?? 10;
    _dailyReviewNum = await _prefs.getInt('dailyReviewNum')?? 10;
    _scoreAward = await _prefs.getInt('scoreAward')?? 20;
    _scorePenalty = await _prefs.getInt('scorePenalty')?? 5;
    _memorizingOrder = await _prefs.getString('memorizingOrder')?? MemorizingOrder.random;
    _usingMethods = await _prefs.getStringList('usingMethods')?? [MemorizingMethodName.wordRecognitionCheck];
    _localDictionary ??= await LocalDictionary.getInstance();
    if(_dailyLearnNum < 1) _dailyLearnNum = 1;
    if(_dailyReviewNum < 1) _dailyReviewNum = 1;
    if(!MemorizingOrder.orders.contains(_memorizingOrder)) _memorizingOrder = MemorizingOrder.random;
    List<String> toRemove = [];
    for (String method in _usingMethods) {
      if (!MemorizingMethodName.methods.contains(method)) {
        toRemove.add(method);
      }
    }
    for (String method in toRemove) {
      _usingMethods.remove(method);
    }
    return _singleton;
  }

  Future<void> setDailyLearnNum(int value) async{
    _dailyLearnNum = value;
    await _prefs.setInt('dailyLearnNum', value);
  }

  int get dailyLearnNum => _dailyLearnNum;

  Future<void> setDailyReviewNum(int value) async{
    _dailyReviewNum = value;
    await _prefs.setInt('dailyReviewNum', value);
  }

  int get dailyReviewNum => _dailyReviewNum;
  Future<void> setMemorizingOrder(String value) async{
    if(!MemorizingOrder.orders.contains(value)) return;
    _memorizingOrder = value;
    await _prefs.setString('memorizingOrder', value);
  }

  String get memorizingOrder => _memorizingOrder;

  List<String> get memorizingMethods => _usingMethods;

  Future<void> addMemorizingMethod(String value) async{
    if(_usingMethods.contains(value)) return;
    _usingMethods.add(value);
    await _prefs.setStringList('usingMethods', _usingMethods);
  }

  Future<void> cancelMemorizingMethod(String value) async{
    if(!_usingMethods.contains(value)) return;
    if(_usingMethods.length == 1) return;
    _usingMethods.remove(value);
    if(WordMemorizingSystem().currentMethod == value){
      WordMemorizingSystem().currentMethod = getMethod();
    }
    await _prefs.setStringList('usingMethods', _usingMethods);
  }

  String getMethod(){
    if(_usingMethods.isEmpty) return MemorizingMethodName.wordRecognitionCheck;
    List<String> validMethods = [..._usingMethods];
    if(_localDictionary!.query(WordMemorizingSystem().currentWord) == ''){
      if(validMethods.contains(MemorizingMethodName.chineseToEnglishSelection)) validMethods.remove(MemorizingMethodName.chineseToEnglishSelection);
      if(validMethods.contains(MemorizingMethodName.chineseToEnglishSpelling)) validMethods.remove(MemorizingMethodName.chineseToEnglishSpelling);
      if(validMethods.contains(MemorizingMethodName.englishToChineseSelection)) validMethods.remove(MemorizingMethodName.englishToChineseSelection);
    }
    if(validMethods.isEmpty) return MemorizingMethodName.wordRecognitionCheck;
    int index = Random().nextInt(validMethods.length);
    return validMethods[index];
  }

  bool isMethodAvailable(String value) => _usingMethods.contains(value);
  
  int methodNum() => _usingMethods.length;

  Future<void> setScoreAward(int value) async{
    _scoreAward = value;
    await _prefs.setInt('scoreAward', value);
  }

  int get scoreAward => _scoreAward;

  Future<void> setScorePenalty(int value) async{
    _scorePenalty = value;
    await _prefs.setInt('scorePenalty', value);
  }

  int get scorePenalty => _scorePenalty;
}