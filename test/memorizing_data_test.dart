import 'package:flutter_test/flutter_test.dart';  
import 'package:miao_ji/services/database.dart';  
  
// 引入待测试的类  
import 'package:miao_ji/models/memorizing_data.dart';  
  
void main() {  
  TestWidgetsFlutterBinding.ensureInitialized();  
  
  // 设置和清理数据库连接  
  setUpAll(() async {  
    
  });  
  
  tearDownAll(() async {  
    await DBProvider.closeDataBase();  
  });  
  
  group('MemorizingData tests', () {  
    test('Initialization', () async {  
      MemorizingData md = await MemorizingData.getInstance();  
      expect(md, isNotNull);  
    });  
  
    test('Update and Query Score', () async {  
      MemorizingData md = await MemorizingData.getInstance();  
      String testWord = 'testWord';  
      int initialScore = await md.queryScore(testWord);  
      expect(initialScore, equals(0));  
      await md.update(testWord, 10);  
      int updatedScore = await md.queryScore(testWord);  
      expect(updatedScore, equals(10));  
      await md.updateBy(testWord, 20);
      updatedScore = await md.queryScore(testWord);  
      expect(updatedScore, equals(30));
      await md.updateBy(testWord, -5);
      updatedScore = await md.queryScore(testWord);  
      expect(updatedScore, equals(25));  
    });  
  
    test('Clear Data', () async {  
      MemorizingData md = await MemorizingData.getInstance();  
      String testWord = 'clearTest';  
      md.update(testWord, 5);  
      await md.clear();  
  
      int scoreAfterClear = await md.queryScore(testWord);  
      expect(scoreAfterClear, equals(0));  
    });  
  
    test('Query All', () async {  
      MemorizingData md = await MemorizingData.getInstance();  
      String word1 = 'word1';  
      String word2 = 'word2';  
      await md.update(word1, 1);  
      await md.update(word2, 2);  
  
      List<Map<String, dynamic>> allData = await md.queryAll();  
      await md.update(word1, 2);
      allData = await md.queryAll();
      //String dataTimeString = allData[0]['last_memorizing_time'];
      //print(dataTimeString);
      //DateTime dataTime = DateTime.parse(dataTimeString);
      //print(dataTime);
      expect(allData.length, greaterThanOrEqualTo(2));  
      expect(allData.any((map) => map['word'] == word1 && map['score'] == 2), isTrue);  
      expect(allData.any((map) => map['word'] == word2 && map['score'] == 2), isTrue);  
    });  
  });  
}