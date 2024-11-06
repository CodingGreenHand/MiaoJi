import 'package:miao_ji/models/memorizing_data.dart';
import 'package:miao_ji/services/word_memorizing_system.dart';

const int increment = 20;
const int penalty = -5;

abstract class MemorizingMethod {
  checkInput(String input);
}

class NewWordLearning extends MemorizingMethod {
  static const String recognized = 'recognized';
  static const String notRecognized = 'notRecognized';
  static const String ambiguous = 'ambiguous';

  String word;
  NewWordLearning(this.word);

  @override
  Future<void> checkInput(String input) async{
    if(input == recognized){
      WordMemorizingSystem().memorizingData.updateBy(word, increment);
      WordMemorizingSystem().currentWordBook!.userProcess!.updateTodayLearnCount(true);
    }
    else{
      WordMemorizingSystem().currentWordBook!.userProcess!.appendWordToLearn(word);
      WordMemorizingSystem().currentWordBook!.userProcess!.updateTodayLearnCount(false);
    }
  }  
}

class WordRecognitionCheck extends MemorizingMethod {
  static const String recognized = 'recognized';
  static const String notRecognized = 'notRecognized';
  static const String ambiguous = 'ambiguous';

  String word;
  WordRecognitionCheck(this.word);

  @override
  Future<void> checkInput(String input) async{
    if(input == recognized){
      WordMemorizingSystem().memorizingData.updateBy(word, increment);
      WordMemorizingSystem().currentWordBook!.userProcess!.updateTodayReviewCount(true);
    }
    else{
      if(input == notRecognized){
        WordMemorizingSystem().memorizingData.updateBy(word, penalty);
      }
      WordMemorizingSystem().currentWordBook!.userProcess!.appendWordToReview(word);
      WordMemorizingSystem().currentWordBook!.userProcess!.updateTodayReviewCount(false);
    }
  }
}

class ChineseToEnglishSpelling extends MemorizingMethod {
  @override
  Future<void> checkInput(String input) async{
    // TODO: implement checkInput
  }
}

class ChineseToEnglishSelection extends MemorizingMethod {
  @override
  Future<void> checkInput(String input) async{
    // TODO: implement checkInput
  }
}

class EnglishToChineseSelection extends MemorizingMethod {
  @override
  Future<void> checkInput(String input) async{
    // TODO: implement checkInput
  }
}

class SentenceGapFilling extends MemorizingMethod {
  @override
  Future<void> checkInput(String input) async{
    // TODO: implement checkInput
  }
}