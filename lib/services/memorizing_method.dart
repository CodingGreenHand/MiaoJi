import 'package:miao_ji/services/ai_english_client.dart';
import 'package:miao_ji/services/dictionary.dart';
import 'package:miao_ji/services/word_memorizing_system.dart';
import 'package:miao_ji/utils/list_utils.dart';
import 'package:miao_ji/utils/string_utils.dart';
import 'dart:math';

class MemorizingMethod {
  String word;
  int increment = WordMemorizingSystem().userPlan!.scoreAward;
  int penalty = -WordMemorizingSystem().userPlan!.scorePenalty;
  MemorizingMethod(this.word);

  checkInput(String input) {
    if (input.toLowerCase() == word.toLowerCase()) {
      WordMemorizingSystem().memorizingData.updateBy(word, increment);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .updateReviewingProgress(true);
    } else {
      WordMemorizingSystem().memorizingData.updateBy(word, penalty);
      WordMemorizingSystem().memorizingData.updateBy(input, penalty);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .appendWordToReview(word);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .updateReviewingProgress(false);
    }
  }
}

class NewWordLearning extends MemorizingMethod {
  static const String recognized = 'recognized';
  static const String notRecognized = 'notRecognized';
  static const String ambiguous = 'ambiguous';

  NewWordLearning(super.word);

  @override
  checkInput(String input) {
    if (input.toLowerCase() == recognized.toLowerCase()) {
      WordMemorizingSystem().memorizingData.updateBy(word, increment);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .appendWordToReview(word);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .updateLearningProgress(true);
    } else {
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .appendWordToLearn(word);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .updateLearningProgress(false);
    }
  }
}

class WordRecognitionCheck extends MemorizingMethod {
  static const String recognized = 'recognized';
  static const String notRecognized = 'notRecognized';
  static const String ambiguous = 'ambiguous';

  WordRecognitionCheck(super.word);

  @override
  Future<void> checkInput(String input) async {
    if (input == recognized) {
      WordMemorizingSystem().memorizingData.updateBy(word, increment);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .updateReviewingProgress(true);
    } else {
      if (input == notRecognized) {
        WordMemorizingSystem().memorizingData.updateBy(word, penalty);
      }
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .appendWordToReview(word);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .updateReviewingProgress(false);
    }
  }
}

class ChineseToEnglishSpelling extends MemorizingMethod {
  ChineseToEnglishSpelling(super.word);

  /// 返回'correct','synonyms','incorrect'
  @override
  Future<String> checkInput(String input) async {
    if (input.toLowerCase() == word.toLowerCase()) {
      WordMemorizingSystem().memorizingData.updateBy(word, increment);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .updateReviewingProgress(true);
      return 'correct';
    }
    try{
      bool areSynonyms = await AiEnglishClient.areSynonyms(word, input);
      if (areSynonyms) return 'synonyms';
      WordMemorizingSystem().memorizingData.updateBy(word, penalty);
      WordMemorizingSystem().memorizingData.updateBy(input, penalty);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .appendWordToReview(word);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .updateReviewingProgress(false);
      return 'incorrect';
    }catch(e){
      return 'incorrect';
    }
  }
}

class ChineseToEnglishSelection extends MemorizingMethod {
  List<String>? _options;

  ChineseToEnglishSelection(super.word);

  Future<List<String>> getOptions() async {
    if (_options == null) {
      LocalDictionary dictionary = await LocalDictionary.getInstance();
      _options = ListUtils.getRandomElements(dictionary.words, 3);
      _options!.insert(
          Random(DateTime.now().millisecondsSinceEpoch).nextInt(4), word);
    }
    return _options!;
  }
}

class EnglishToChineseSelection extends MemorizingMethod {
  List<String>? _options;

  EnglishToChineseSelection(super.word);

  Future<List<String>> getOptions() async {
    if (_options == null) {
      LocalDictionary dictionary = await LocalDictionary.getInstance();
      bool haveSameElement = false;
      List<String> optionsFromWordBook;
      List<String> optionsFromDictionary;
      do{
        optionsFromWordBook = [];
        List<String> originalOptions = ListUtils.getRandomElements(await WordMemorizingSystem().currentWordBook!.getWords(), 2);
        for(String option in originalOptions){
          if(dictionary.query(option) != '') optionsFromWordBook.add(option);
        }
        optionsFromDictionary = ListUtils.getRandomElements(dictionary.words, 3-optionsFromWordBook.length);
        haveSameElement = ListUtils.hasRepeatedElements(optionsFromWordBook + optionsFromDictionary + [word]);
      }while(haveSameElement);// 保证没有重复选项，且每个选项都能在本地词典查到
      _options = optionsFromWordBook + optionsFromDictionary;
      _options!.insert(
          Random(DateTime.now().millisecondsSinceEpoch).nextInt(_options!.length), word);
    }
    return _options!;
  }
}

class SentenceGapFilling extends MemorizingMethod {
  int gapIndex = -1;
  List<String> _sentenceElements = [];
  String _sentence = '';
  String _translation = '';
  SentenceGapFilling(super.word);

  String get translation => _translation;

  Future<String> requestAi() async {
    String requirement ='''
      Please generate a sentence with the word "$word" in it. Don't change the form of the word (Uppercase is acceptable).
      Don't output anything else.
      Example:

      Input:
      apple

      Expected possible output 1:
      I ate an apple for breakfast.
      Explanation:
      In this sentence, the word "apple" occurs in the original form.

      Expected possible output 2:
      Apple is a well-known company.
      Explanation:
      In this sentence, the word "Apple" occurs in the original form, although it is capitalized.
      
      Unexpected output:
      She ate apples.
      Explanation:
      In this sentence, the word "apples" occurs in the plural form. Please use the original form to generate the sentence.
    ''';
    return await AiEnglishClient.generate(requirement);
  }

  Future<void> initialize() async {
    _sentence = await requestAi();
    _sentenceElements = StringUtils.parseEnglishSentence(_sentence);
    gapIndex = -1;
    for (int i = 0; i < _sentenceElements.length; i++) {
      if (_sentenceElements[i].toLowerCase() == word.toLowerCase()) {
        gapIndex = i;
        break;
      }
    }
    if (gapIndex == -1) {
      throw Exception('init failed: word not found in sentence');
    }
    _translation = await getChineseTranslation();
  }

  String getSentenceWithGap(){
    List<String> gapped = [..._sentenceElements];
    gapped[gapIndex] = '____';
    return StringUtils.joinToSentence(gapped);
  }

  Future<String> getChineseTranslation() async{
    String requirement = '''
    将下面的英语句子翻译成中文。只输出翻译，不要输出任何其他内容。
    $_sentence
    ''';
    return await AiEnglishClient.generate(requirement);
  }

  @override
  Future<String> checkInput(String input) async {
    if (input.toLowerCase() == word.toLowerCase()) {
      WordMemorizingSystem().memorizingData.updateBy(word, increment);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .updateReviewingProgress(true);
      return 'correct';
    }
    try{
      bool areSynonyms = await AiEnglishClient.areSynonyms(word, input);
      if (areSynonyms) return 'synonyms';
      WordMemorizingSystem().memorizingData.updateBy(word, penalty);
      WordMemorizingSystem().memorizingData.updateBy(input, penalty);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .appendWordToReview(word);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .updateReviewingProgress(false);
      return 'incorrect';
    }catch(e){
      return 'incorrect';
    }
  }
}
