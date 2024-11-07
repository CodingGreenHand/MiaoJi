import 'package:flutter_test/flutter_test.dart';  
import 'package:shared_preferences/shared_preferences.dart';  
  
import 'package:miao_ji/models/user_plan.dart'; // 替换为实际的文件路径  
  
void main() {  
  TestWidgetsFlutterBinding.ensureInitialized();  
  
  SharedPreferences prefs;  
  setUpAll(() async {  
    prefs = await SharedPreferences.getInstance();  
    // 清除所有之前的数据以确保测试环境干净  
    await prefs.clear();  
  });  

  tearDownAll(() async {  
    prefs = await SharedPreferences.getInstance();  
    await prefs.clear();  
  });
  
  group('UserPlan tests', () {  
    test('should correctly set and get dailyLearnNum', () async {  
      UserPlan plan = await UserPlan.getInstance();  
      expect(plan.dailyLearnNum, equals(10)); // 默认值  
  
      await plan.setDailyLearnNum(20);  
      expect(plan.dailyLearnNum, equals(20));  
      plan = await UserPlan.getInstance(); // 重新实例化以从SharedPreferences加载  
      expect(plan.dailyLearnNum, equals(20));  
    });  
  
    test('should correctly set and get dailyReviewNum', () async {  
      UserPlan plan = await UserPlan.getInstance();  
      expect(plan.dailyReviewNum, equals(10)); // 默认值  
  
      await plan.setDailyReviewNum(30);  
      expect(plan.dailyReviewNum, equals(30));  
      plan = await UserPlan.getInstance(); // 重新实例化以从SharedPreferences加载  
      expect(plan.dailyReviewNum, equals(30));  
    });  
  
    test('should correctly set and get memorizingOrder', () async {  
      UserPlan plan = await UserPlan.getInstance();  
      expect(plan.memorizingOrder, equals('random')); // 默认值  
  
      await plan.setMemorizingOrder('sequential');  
      expect(plan.memorizingOrder, equals('sequential'));  
      plan = await UserPlan.getInstance(); // 重新实例化以从SharedPreferences加载  
      expect(plan.memorizingOrder, equals('sequential'));  
    });  
  
    test('should correctly add and remove memorizing methods', () async {  
      UserPlan plan = await UserPlan.getInstance();  
      expect(plan.memorizingMethods, contains('EnglishToChinese')); // 默认值  
      expect(plan.memorizingMethods.length, equals(1));  
  
      await plan.addMemorizingMethod('ChineseToEnglish');  
      expect(plan.memorizingMethods, contains('ChineseToEnglish'));  
      plan = await UserPlan.getInstance(); // 重新实例化以从SharedPreferences加载  
      expect(plan.memorizingMethods, contains('ChineseToEnglish'));  
      expect(plan.memorizingMethods.length, equals(2));  
  
      await plan.cancelMemorizingMethod('EnglishToChinese');  
      expect(plan.memorizingMethods, isNot(contains('EnglishToChinese')));  
      plan = await UserPlan.getInstance(); // 重新实例化以从SharedPreferences加载  
      expect(plan.memorizingMethods, isNot(contains('EnglishToChinese')));  
      expect(plan.memorizingMethods.length, equals(1));  
    });  
  });  

}