import 'package:hive_flutter/hive_flutter.dart';

/// Persists recent transaction search strings (device-local).
abstract class SearchHistoryStore {
  List<String> read();

  void prepend(String query);

  void remove(String query);

  void clear();
}

const String _searchHistoryBoxName = 'search_history_v1';
const String _queriesKey = 'queries';

class HiveSearchHistoryStore implements SearchHistoryStore {
  HiveSearchHistoryStore(this._box);

  final Box<dynamic> _box;

  static Future<HiveSearchHistoryStore> open() async {
    final box = await Hive.openBox<dynamic>(_searchHistoryBoxName);
    return HiveSearchHistoryStore(box);
  }

  @override
  List<String> read() {
    final v = _box.get(_queriesKey);
    if (v is List) {
      return List<String>.from(v.map((e) => e.toString()));
    }
    return [];
  }

  @override
  void prepend(String raw) {
    final q = raw.trim();
    if (q.isEmpty) return;
    final list = List<String>.from(read());
    list.removeWhere((e) => e.toLowerCase() == q.toLowerCase());
    list.insert(0, q);
    _box.put(_queriesKey, list.take(25).toList());
  }

  @override
  void remove(String query) {
    final list = read().where((e) => e != query).toList();
    _box.put(_queriesKey, list);
  }

  @override
  void clear() {
    _box.delete(_queriesKey);
  }
}

/// In-memory store for tests (no Hive).
class MemorySearchHistoryStore implements SearchHistoryStore {
  final List<String> _items = [];

  @override
  List<String> read() => List<String>.unmodifiable(_items);

  @override
  void prepend(String raw) {
    final q = raw.trim();
    if (q.isEmpty) return;
    _items.removeWhere((e) => e.toLowerCase() == q.toLowerCase());
    _items.insert(0, q);
    while (_items.length > 25) {
      _items.removeLast();
    }
  }

  @override
  void remove(String query) {
    _items.removeWhere((e) => e == query);
  }

  @override
  void clear() => _items.clear();
}
