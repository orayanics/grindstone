class Date {
  // format Iso8601String to mm/dd/yyyy hh:mm
  static String parseDate(String iso8601String) {
    DateTime dateTime = DateTime.parse(iso8601String);
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
