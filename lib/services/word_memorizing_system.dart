import 'package:flutter/material.dart';
import 'package:miao_ji/models/user_plan.dart';
import 'package:miao_ji/services/dictionary.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miao_ji/models/memorizing_data.dart';
import 'package:miao_ji/models/word_book.dart';

class WordMemorizingSystem with ChangeNotifier{
  WordMemorizingSystem._();
  static final WordMemorizingSystem _singleton = WordMemorizingSystem._();
  factory WordMemorizingSystem() => _singleton;

  late MemorizingData memorizingData;
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  WordBook? currentWordBook;
  UserPlan? userPlan;
  String currentWord = '';
  String currentMethod = MemorizingMethodName.englishToChineseSelection;


  Future<void> initialize() async {
    memorizingData = await MemorizingData.getInstance();
    String currentWordBookName = await _prefs.getString('currentWordBookName')?? WordBookManager.defaultWordBookName;
    currentWordBook = WordBook(currentWordBookName);
    await currentWordBook!.initialize();
    userPlan = await UserPlan.getInstance();
    memorizeNextWord();
  }

  void memorizeNextWord(){
    currentWord = currentWordBook!.userProcess!.getNextWordToLearn();
    if(currentWord == '') {
      currentWord = currentWordBook!.userProcess!.getNextWordToReview();
    } else {
      currentMethod = MemorizingMethodName.newWordLearning;
      notifyListeners();
      return;
    }
    if(currentWord == '') {
      notifyListeners();
      return;
    }
    currentMethod = userPlan!.getMethod();
    notifyListeners();
  }

  void changeWordBook(String wordBookName) async {
    _prefs.setString('currentWordBookName', wordBookName);
    currentWordBook = WordBook(wordBookName);
    await currentWordBook!.initialize();
    memorizeNextWord();
  }

  int get remainingNewWordsCount {
    return currentWordBook!.userProcess!.wordsToLearn.length;
  }

  int get remainingReviewWordsCount {
    return currentWordBook!.userProcess!.wordsToReview.length;
  }
}