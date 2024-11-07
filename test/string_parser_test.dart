import 'package:flutter_test/flutter_test.dart';
import 'package:miao_ji/utils/string_utils.dart';

void main() {
  group('StringParser', () {
    test('parseEnglishSentence should split sentence correctly', () {
      String sentence = "This is a test sentence. With some punctuation!";
      List<String?> parsedWords = StringUtils.parseEnglishSentence(sentence);
      expect(parsedWords, ['This', 'is', 'a', 'test', 'sentence', '.', 'With', 'some', 'punctuation', '!']);
      sentence = '''
        "Every one loves dogs", said Tom, "I love dogs too."
      ''';
      parsedWords = StringUtils.parseEnglishSentence(sentence);
      expect(parsedWords, ['"','Every', 'one', 'loves', 'dogs', '"',',','said', 'Tom', ',','"', 'I', 'love', 'dogs', 'too', '.','"']);
    });
  });
}