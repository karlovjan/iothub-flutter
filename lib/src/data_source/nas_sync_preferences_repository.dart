import 'package:hive_flutter/hive_flutter.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class NasSyncPreferencesRepository implements IPersistStore {
  late final Box _box;
  static const boxName = 'nas_sync';

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(boxName);
  }

  @override
  String? read(String key) {
    return _box.get(key);
  }

  @override
  Future<void> write<T>(String key, T value) async {
    return _box.put(key, value);
  }

  @override
  Future<void> delete(String key) async {
    return _box.delete(key);
  }

  @override
  Future<void> deleteAll() async {
    await _box.clear();
  }

  int get itemsCount => _box.length;

  String readAt(int index) {
    return _box.getAt(index);
  }

  Future<void> deleteAt(int index) async {
    return _box.deleteAt(index);
  }
}
