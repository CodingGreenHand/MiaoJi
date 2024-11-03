import 'package:flutter_test/flutter_test.dart';  
import 'package:miao_ji/services/dictionary.dart';  
  
void main() {  
  TestWidgetsFlutterBinding.ensureInitialized();  
  
  
  group('LocalDictionary tests', () {  
    LocalDictionary? dictionary;  
  
    setUpAll(() async {  
      // 在所有测试开始之前初始化字典  
      dictionary = await LocalDictionary.getInstance();  
    });  
  
    test('Initialization should succeed', () async {  
      expect(dictionary, isNotNull);  
    });  
  
    test('Query for existing word should return definition', () async {  
      // 假设'apple'是字典中的一个词，并且其对应的解释是'A fruit'  
      // 这需要根据你实际的字典文件内容进行修改  
      String result = dictionary!.query('zoology');  
      expect(result, equals('n.动物学')); // 请根据实际情况修改期望的解释  
    });  
  
    test('Query for non-existing word should return empty string', () async {  
      String result = dictionary!.query('nonexistingword');  
      expect(result, equals(''));  
    });  
  });  
}