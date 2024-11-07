import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miao_ji/utils/list_utils.dart'; 

void main() {
  group('ListUtils.getRandomElements', () {
    test('should return empty list when input list is empty', () {
      final list = <int>[];
      final result = ListUtils.getRandomElements(list, 3);
      expect(result, isEmpty);
    });

    test('should return all elements when num is greater than list length', () {
      final list = <int>[1, 2, 3];
      final result = ListUtils.getRandomElements(list, 5);
      debugPrint(result.toString());
      expect(result.length, equals(list.length));
      expect(result.toSet(), equals(list.toSet()));
    });

    test('should return correct number of unique elements', () {
      final list = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      const num = 5;
      final result = ListUtils.getRandomElements(list, num);
      debugPrint(result.toString());
      expect(result.length, equals(num));
      expect(result.toSet().length, equals(num)); // 确保所有元素都是唯一的
    });

    test('should return elements from the input list', () {
      final list = <int>[1, 2, 3, 4, 5];
      const num = 3;
      final result = ListUtils.getRandomElements(list, num);
      expect(result.every((element) => list.contains(element)), isTrue);
    });

    // 可以添加更多测试用例来覆盖其他边界情况和异常情况
  });
}