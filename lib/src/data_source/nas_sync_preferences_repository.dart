import 'package:hive_flutter/hive_flutter.dart';
import 'package:iothub/src/domain/value_objects/sync_form_data.dart';

class NasSyncPreferencesRepository {
  static const boxName = 'nas_sync';
  late final Box _box;

  Future<void> init() async {
    // await Hive.initFlutter(); initializet in global_preferences
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox(boxName);
    }
  }

  int get itemsCount => _box.length;

  String readAt(int index) {
    return _box.getAt(index);
  }

  Future<int> add(String value) {
    return _box.add(value);
  }

  Future<void> deleteAt(int index) async {
    return _box.deleteAt(index);
  }

  Future<void> update(int index, String syncData) {
    return _box.putAt(index, syncData);
  }
}
