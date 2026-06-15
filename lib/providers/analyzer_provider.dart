import 'package:flutter/material.dart';
import '../models/work.dart';
import '../models/dashboard_data.dart';
import '../services/openalex_service.dart';
import '../services/storage_service.dart';

class AnalyzerProvider with ChangeNotifier {
  final OpenAlexService _apiService = OpenAlexService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String _activeKeyword = '';
  
  List<Work> _works = [];
  Map<int, int> _trendData = {};
  DashboardData _dashboardData = DashboardData.fromWorks([]);
  List<String> _recentSearches = [];
  String _apiKey = '';

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  String get activeKeyword => _activeKeyword;
  List<Work> get works => _works;
  Map<int, int> get trendData => _trendData;
  DashboardData get dashboardData => _dashboardData;
  List<String> get recentSearches => _recentSearches;
  String get apiKey => _apiKey;

  /// Loads initial storage states (API key and recent searches)
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _apiKey = await _storageService.getApiKey() ?? '';
      _recentSearches = await _storageService.getRecentSearches();
    } catch (e) {
      _errorMessage = 'Failed to load local storage: $e';
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Updates the stored OpenAlex API Key
  Future<void> updateApiKey(String newKey) async {
    _apiKey = newKey.trim();
    await _storageService.saveApiKey(_apiKey);
    notifyListeners();
  }

  /// Clears the stored OpenAlex API Key
  Future<void> clearApiKey() async {
    _apiKey = '';
    await _storageService.clearApiKey();
    notifyListeners();
  }

  /// Triggers a topic search and data analysis
  Future<void> searchTopic(String keyword) async {
    if (keyword.trim().isEmpty) return;
    
    _isLoading = true;
    _errorMessage = null;
    _activeKeyword = keyword.trim();
    notifyListeners();

    try {
      // 1. Save search history
      await _storageService.saveRecentSearch(_activeKeyword);
      _recentSearches = await _storageService.getRecentSearches();

      // 2. Fetch works and aggregate dashboard data
      final fetchedWorks = await _apiService.fetchWorks(_activeKeyword, apiKey: _apiKey.isEmpty ? null : _apiKey);
      _works = fetchedWorks;
      _dashboardData = DashboardData.fromWorks(_works);

      // 3. Fetch full trend year distribution counts
      _trendData = await _apiService.fetchTrendData(_activeKeyword, apiKey: _apiKey.isEmpty ? null : _apiKey);
    } on OpenAlexException catch (e) {
      _errorMessage = e.message;
      // Clear data if search fails to avoid showing stale calculations
      _works = [];
      _trendData = {};
      _dashboardData = DashboardData.fromWorks([]);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _works = [];
      _trendData = {};
      _dashboardData = DashboardData.fromWorks([]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears active search state
  void clearSearch() {
    _activeKeyword = '';
    _works = [];
    _trendData = {};
    _dashboardData = DashboardData.fromWorks([]);
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears search history
  Future<void> clearHistory() async {
    await _storageService.clearRecentSearches();
    _recentSearches = [];
    notifyListeners();
  }
}
