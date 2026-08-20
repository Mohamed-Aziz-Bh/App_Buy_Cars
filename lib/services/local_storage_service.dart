import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static const _recentKey = 'recently_viewed_car_ids';
  static const _compareKey = 'compare_car_ids';
  static const _checklistKey = 'purchase_checklist_done';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<List<String>> getRecentlyViewed() async {
    final p = await _prefs;
    return p.getStringList(_recentKey) ?? [];
  }

  Future<void> addRecentlyViewed(String carId) async {
    final p = await _prefs;
    final list = p.getStringList(_recentKey) ?? [];
    list.remove(carId);
    list.insert(0, carId);
    if (list.length > 20) list.removeRange(20, list.length);
    await p.setStringList(_recentKey, list);
  }

  Future<List<String>> getCompareIds() async {
    final p = await _prefs;
    return p.getStringList(_compareKey) ?? [];
  }

  Future<bool> toggleCompare(String carId) async {
    final p = await _prefs;
    final list = p.getStringList(_compareKey) ?? [];
    if (list.contains(carId)) {
      list.remove(carId);
      await p.setStringList(_compareKey, list);
      return false;
    }
    if (list.length >= 3) return false; // max 3
    list.add(carId);
    await p.setStringList(_compareKey, list);
    return true;
  }

  Future<void> clearCompare() async {
    final p = await _prefs;
    await p.setStringList(_compareKey, []);
  }

  Future<Set<String>> getChecklistDone() async {
    final p = await _prefs;
    return (p.getStringList(_checklistKey) ?? []).toSet();
  }

  Future<void> setChecklistItem(String id, bool done) async {
    final p = await _prefs;
    final set = (p.getStringList(_checklistKey) ?? []).toSet();
    if (done) {
      set.add(id);
    } else {
      set.remove(id);
    }
    await p.setStringList(_checklistKey, set.toList());
  }
}
