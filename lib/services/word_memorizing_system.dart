import 'package:miao_ji/models/user_plan.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miao_ji/models/memorizing_data.dart';
import 'package:miao_ji/models/word_book.dart';

class WordMemorizingSystem {
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
      return;
    }
    if(currentWord == '') return;
    currentMethod = userPlan!.getMethod();
  }

  void changeWordBook(String wordBookName) async {
    _prefs.setString('currentWordBookName', wordBookName);
    currentWordBook = WordBook(wordBookName);
    await currentWordBook!.initialize();
    memorizeNextWord();
  }
}