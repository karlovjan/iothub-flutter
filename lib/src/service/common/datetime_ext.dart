extension DateExt on DateTime {
  DateTime dateNow() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool isBetween(DateTime from, DateTime to) {
    return isAtSameMomentAs(from) || (isAfter(from) && isBefore(to));
  }
}
