import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';
import 'dart:math';

abstract class MemorizingOrder{
  static const String random = 'random';
  static const String sequential ='sequential';
  static const String reverse ='reverse';
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
  static String _memorizingOrder = 'random';
  static List<String> _usingMethods = [MemorizingMethodName.wordRecognitionCheck];
  static final UserPlan _singleton = UserPlan._();

  static Future<UserPlan> getInstance() async{
    _dailyLearnNum = await _prefs.getInt('dailyLearnNum')?? 10;
    _dailyReviewNum = await _prefs.getInt('dailyReviewNum')?? 10;
    _memorizingOrder = await _prefs.getString('memorizingOrder')?? 'random';
    _usingMethods = await _prefs.getStringList('usingMethods')?? [MemorizingMethodName.wordRecognitionCheck];
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
    _usingMethods.remove(value);
    await _prefs.setStringList('usingMethods', _usingMethods);
  }

  String getMethod(){
    if(_usingMethods.isEmpty) return MemorizingMethodName.wordRecognitionCheck;
    int index = Random().nextInt(_usingMethods.length);
    return _usingMethods[index];
  }
}