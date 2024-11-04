import 'package:flutter_test/flutter_test.dart';
import 'package:miao_ji/utils/date_time_formalizer.dart';

void main() {
  test('DateTimeFormalizer test', () {
    DateTime dateTime = DateTime.now().toUtc();
    print(dateTime);
    DateTime dateTimeTruncated = DateTimeFormalizer.truncateToDate(dateTime);
    print(dateTimeTruncated);
    }
  );
}