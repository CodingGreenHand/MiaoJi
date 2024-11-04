import 'package:miao_ji/services/ai_english_client.dart';
import 'package:flutter_test/flutter_test.dart';  
  
void main() {  
  group('AIPassageGenerator', () {  
    test('should return a non-null string when generating a passage', () async {  
      final generator = AIEnglishClient.getInstance();  
      const prompt = 'apple, banana, orange';  
      final passage = await generator.generatePassage(prompt);  
      print(passage);
      expect(passage, isNotNull);  
      // 根据实际情况，你可能还想检查返回的字符串是否包含某些特定内容  
      // expect(passage, contains('some expected text'));  
    });  
  
    test('should be a singleton', () {
      final instance1 = AIEnglishClient.getInstance();  
      final instance2 = AIEnglishClient.getInstance();  
      expect(instance1, same(instance2));  
    });  
  
  });  
}