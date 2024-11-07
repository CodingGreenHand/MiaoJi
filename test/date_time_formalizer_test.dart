import 'package:flutter_test/flutter_test.dart';
import 'package:miao_ji/utils/date_time_formalizer.dart';
import 'package:flutter/foundation.dart';

void main() {
  test('DateTimeFormalizer test', () {
    DateTime dateTime = DateTime.now().toUtc();
    debugPrint(dateTime.toString());
    DateTime dateTimeTruncated = DateTimeFormalizer.truncateToDate(dateTime);
    debugPrint(dateTimeTruncated.toString());
    }
  );
}