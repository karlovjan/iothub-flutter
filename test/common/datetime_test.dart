import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

//class MockitoCFSClient extends Mock implements Firestore {}

void main() {
  group('from cloude firestore string date time', () {
    test('from string date time of field', () {
      ///iothubs/1/devices/1/data/rzPdNK04X76uvWsEii5r

      final sDateTime = 'Wed Jul 29 2020 23:55:34 GMT+0300';
      // final sDateTime = 'Wed Jul 29 2020 23:55:34 GMT+0200 (Central European Summer Time)';
      var createdAtDT = DateFormat('EEE MMM d yyyy HH:mm:ss').parse(sDateTime);

      final sResultDT = Timestamp.fromDate(createdAtDT);

      expect(sResultDT.seconds * 1000, equals(createdAtDT.millisecondsSinceEpoch));
    });
  });
}
