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
  MemorizingData? memorizingData;
  NewWordLearning(this.word);

  @override
  Future<void> checkInput(String input) async{
    memorizingData ??= await MemorizingData.getInstance();
    if(input == recognized){
      memorizingData!.updateBy(word, increment);
    }
    else{
      memorizingData!.updateBy(word, penalty);
      WordMemorizingSystem().currentWordBook!.userProcess!.appendWordToReview(word);
    }
    WordMemorizingSystem().currentWordBook!.userProcess!.updateTodayLearnCount();
  }  
}

class WordRecognitionCheck extends MemorizingMethod {
  static const String recognized = 'recognized';
  static const String notRecognized = 'notRecognized';
  static const String ambiguous = 'ambiguous';

  String word;
  MemorizingData? memorizingData;
  WordRecognitionCheck(this.word);

  @override
  Future<void> checkInput(String input) async{
    memorizingData ??= await MemorizingData.getInstance();
    if(input == recognized){
      memorizingData!.updateBy(word, increment);
      WordMemorizingSystem().currentWordBook!.userProcess!.updateTodayReviewCount(true);
    }
    else{
      if(input == notRecognized){
        memorizingData!.updateBy(word, penalty);
      }
      WordMemorizingSystem().currentWordBook!.userProcess!.appendWordToReview(word);
      WordMemorizingSystem().currentWordBook!.userProcess!.updateTodayReviewCount(false);
    }
  }
}