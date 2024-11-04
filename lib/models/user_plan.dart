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
  static const String englishToChineseSection = 'EnglishToChineseSection';
  static const String chineseToEnglishSection = 'ChineseToEnglishSection';
  static const String chineseToEnglishSpelling = 'ChineseToEnglishSpelling';
  static const String sentenceGapFilling = 'SentenceGapFilling';
  static const String wordRecognitionCheck = 'WordRecognitionCheck';
  static const String newWordLearning = 'NewWordLearning';
  static const List<String> methods = [englishToChineseSection, chineseToEnglishSection, chineseToEnglishSpelling, sentenceGapFilling, wordRecognitionCheck];
}

class UserPlan {
  UserPlan._();

  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static int _dailyLearnNum = 10;
  static int _dailyReviewNum = 10;
  static String _memorizingOrder = MemorizingOrder.random;
  static List<String> _usingMethods = [MemorizingMethodName.wordRecognitionCheck];
  static final UserPlan _singleton = UserPlan._();

  static Future<UserPlan> getInstance() async{
    _dailyLearnNum = await _prefs.getInt('dailyLearnNum')?? 10;
    _dailyReviewNum = await _prefs.getInt('dailyReviewNum')?? 10;
    _memorizingOrder = await _prefs.getString('memorizingOrder')?? MemorizingOrder.random;
    _usingMethods = await _prefs.getStringList('usingMethods')?? [MemorizingMethodName.wordRecognitionCheck];
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

  Future<void> setMemorizingMethods(List<String> value) async{
    _usingMethods = value;
    await _prefs.setStringList('usingMethods', value);
  }

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
    await _prefs.setStringList('usingMethods', _usingMethods);
  }

  String getMethod(){
    if(_usingMethods.isEmpty) return MemorizingMethodName.wordRecognitionCheck;
    int index = Random().nextInt(_usingMethods.length);
    return _usingMethods[index];
  }

  bool isMethodAvailable(String value) => _usingMethods.contains(value);
  
  int methodNum() => _usingMethods.length;
}