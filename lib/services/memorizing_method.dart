import 'package:miao_ji/services/ai_english_client.dart';
import 'package:miao_ji/services/dictionary.dart';
import 'package:miao_ji/services/word_memorizing_system.dart';
import 'package:miao_ji/utils/list_utils.dart';
import 'package:miao_ji/utils/string_parser.dart';
import 'dart:math';

const int increment = 20;
const int penalty = -5;

class NewWordLearning {
  static const String recognized = 'recognized';
  static const String notRecognized = 'notRecognized';
  static const String ambiguous = 'ambiguous';

  String word;
  NewWordLearning(this.word);

  checkInput(String input) {
    if (input == recognized) {
      WordMemorizingSystem().memorizingData.updateBy(word, increment);
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

class MemorizingMethod {
  String word;
  MemorizingMethod(this.word);

  checkInput(String input) {
    if (input == word) {
      WordMemorizingSystem().memorizingData.updateBy(word, increment);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .updateReviewingProgress(true);
    } else {
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
    if (input == word) {
      WordMemorizingSystem().memorizingData.updateBy(word, increment);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .updateReviewingProgress(true);
      return 'correct';
    }
    bool areSynonyms = await AIEnglishClient.areSynonyms(word, input);
    if (areSynonyms) return 'synonyms';
    WordMemorizingSystem().memorizingData.updateBy(word, penalty);
    WordMemorizingSystem()
        .currentWordBook!
        .userProcess!
        .appendWordToReview(word);
    WordMemorizingSystem()
        .currentWordBook!
        .userProcess!
        .updateReviewingProgress(false);
    return 'incorrect';
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
      _options = ListUtils.getRandomElements(dictionary.words, 3);
      _options!.insert(
          Random(DateTime.now().millisecondsSinceEpoch).nextInt(4), word);
    }
    return _options!;
  }
}

class SentenceGapFilling extends MemorizingMethod {
  late int gapIndex;
  List<String> _sentence = [];
  SentenceGapFilling(super.word);

  Future<String> requestAI() async {
    /*final String requirement =
        '''
        Please generate a sentence with the word "$word" in it.
        You should output the content in the following format:
        In the first line, output the sentence you generated.
        In the second line, output a number indicating the position of the gap. 
        The position means the index if the sentence is separated into elements in which the types are word or mark (e.g. punctuation).
        The index starts from 0. 
        If the sentence you generated has multiple positions of the given word, output the first one.
        
        Example 1:
        Input: 
        apple

        Output:
        I like eating apples.
        3

        Explanation:
        You generated a sentence with the word "apple" in it.
        In this sentence, elements are: "I","like","eating","apples","."
        If index starts from 0, the position of the word "apple" in the sentence is 3.

        Example 2:
        Input:
        fly

        Output:
        Because of the sudden noise, the bird flew away.
        8

        Explanation:
        You generate a sentence with the word "fly" in it. It's OK to use forms different from the original word.
        In this sentence, elements are: "Because","of","the","sudden","noise",",","the","bird","flew","away","." 
        If index starts from 0, the position of the word "fly" in the sentence is 8. Note that "," is considered as a single element.

        Example 3:
        Input:
        dog

        Output:
        "Everyone loves dogs." He said, "I love dogs too."
        3

        Explanation:
        You generated a sentence with the word "dog" in it.
        In this sentence, elements are: "\\"" "Everyone","loves","dogs",".","\\"","He","said",",","\\"","I","love","dogs","too",".","\\""
        If index starts from 0, the first position of the word "dog" in the sentence is 3. Note that ",","\\"" and "." are considered as single elements.
        ''';*/
    final String requirement ='''
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
    return await AIEnglishClient.generate(requirement);
  }

  Future<void> initialize() async {
    final String aiResponse = await requestAI();
    _sentence = StringParser.parseEnglishSentence(aiResponse);
    gapIndex = _sentence.indexOf(word);
    if (gapIndex == -1) {
      throw Exception('init failed: word not found in sentence');
    }
  }

  @override
  Future<String> checkInput(String input) async {
    if (input == word) {
      WordMemorizingSystem().memorizingData.updateBy(word, increment);
      WordMemorizingSystem()
          .currentWordBook!
          .userProcess!
          .updateReviewingProgress(true);
      return 'correct';
    }
    bool areSynonyms = await AIEnglishClient.areSynonyms(word, input);
    if (areSynonyms) return 'synonyms';
    WordMemorizingSystem().memorizingData.updateBy(word, penalty);
    WordMemorizingSystem()
        .currentWordBook!
        .userProcess!
        .appendWordToReview(word);
    WordMemorizingSystem()
        .currentWordBook!
        .userProcess!
        .updateReviewingProgress(false);
    return 'incorrect';
  }
}
