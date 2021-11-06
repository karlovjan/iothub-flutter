extension DateExt on DateTime {
  bool isBetween(DateTime from, DateTime to) {
    return isAtSameMomentAs(from) || (isAfter(from) && isBefore(to));
  }

  int get secondsSinceEpochInt => secondsSinceEpoch.toInt();

  double get secondsSinceEpoch => millisecondsSinceEpoch * 0.001;
}
