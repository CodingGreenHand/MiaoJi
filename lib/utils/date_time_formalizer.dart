class DateTimeFormalizer {
  //将DateTime中只保留到年月日，不保留时分秒
  static DateTime truncateToDate(DateTime dateTime){
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}