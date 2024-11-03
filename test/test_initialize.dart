import 'package:miao_ji/services/word_memorizing_system.dart';
import 'package:miao_ji/models/word_book.dart';

class TestInitializer{
  static Future<void> initialize() async {
    WordBook wordBook = WordMemorizingSystem().currentWordBook!;
    wordBook.addWord('word');
    wordBook.addWord('apple');
    wordBook.addWord('banana');
    wordBook.addWord('orange');
    wordBook.addWord('grape');
    wordBook.addWord('watermelon');
    wordBook.addWord('pear');
    wordBook.addWord('pineapple');
    wordBook.addWord('kiwi');
    wordBook.addWord('mango');
    wordBook.addWord('peach');
    wordBook.addWord('plum');
    wordBook.addWord('cherry');
    wordBook.addWord('strawberry');
    wordBook.addWord('blueberry');
    wordBook.addWord('raspberry');
  }
}