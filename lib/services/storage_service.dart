import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyApiKey = 'openalex_api_key';
  static const String _keyRecentSearches = 'recent_searches';

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiKey, key);
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyApiKey);
  }

  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyApiKey);
  }

  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyRecentSearches) ?? [];
  }

  Future<void> saveRecentSearch(String search) async {
    if (search.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRecentSearches) ?? [];
    
    // Remove if already exists to put it at the front
    list.removeWhere((item) => item.toLowerCase() == search.trim().toLowerCase());
    list.insert(0, search.trim());
    
    // Limit to top 10 recent searches
    if (list.length > 10) {
      list.removeRange(10, list.length);
    }
    
    await prefs.setStringList(_keyRecentSearches, list);
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRecentSearches);
  }
}
