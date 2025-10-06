// مدير الاقتراحات - Suggestions Manager
// إدارة دورة حياة الاقتراحات والتخزين المؤقت
// Manages suggestion lifecycle and caching

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/suggestion_model.dart';
import '../models/copilot_settings_model.dart';
import 'github_copilot_service.dart';

/// مدير الاقتراحات - Suggestions Manager
/// يدير الحصول على الاقتراحات، التخزين المؤقت، والتصفية
/// Manages getting suggestions, caching, and filtering
class SuggestionsManager extends ChangeNotifier {
  // السنغلتون - Singleton
  static final SuggestionsManager _instance = SuggestionsManager._internal();
  factory SuggestionsManager() => _instance;
  SuggestionsManager._internal();

  /// خدمة GitHub Copilot - GitHub Copilot Service
  final GitHubCopilotService _copilotService = GitHubCopilotService();

  /// المسجل - Logger
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// الاقتراحات الحالية - Current suggestions
  List<SuggestionModel> _currentSuggestions = [];

  /// مؤشر الاقتراح المحدد - Selected suggestion index
  int _selectedIndex = 0;

  /// الذاكرة المؤقتة للاقتراحات - Suggestions cache
  final Map<String, List<SuggestionModel>> _suggestionsCache = {};

  /// مفتاح الطلب الأخير - Last request key
  String? _lastRequestKey;

  /// مؤقت التأخير - Delay timer
  Timer? _delayTimer;

  /// الإعدادات - Settings
  CopilotSettingsModel? _settings;

  /// هل يتم الحصول على اقتراحات - Is fetching suggestions
  bool _isFetching = false;

  /// آخر خطأ - Last error
  String? _lastError;

  // Getters

  /// الاقتراحات الحالية - Current suggestions
  List<SuggestionModel> get currentSuggestions => _currentSuggestions;

  /// الاقتراح المحدد - Selected suggestion
  SuggestionModel? get selectedSuggestion {
    if (_currentSuggestions.isEmpty ||
        _selectedIndex >= _currentSuggestions.length) {
      return null;
    }
    return _currentSuggestions[_selectedIndex];
  }

  /// مؤشر الاقتراح المحدد - Selected suggestion index
  int get selectedIndex => _selectedIndex;

  /// عدد الاقتراحات - Number of suggestions
  int get suggestionsCount => _currentSuggestions.length;

  /// هل توجد اقتراحات - Has suggestions
  bool get hasSuggestions => _currentSuggestions.isNotEmpty;

  /// هل يتم الحصول على اقتراحات - Is fetching
  bool get isFetching => _isFetching;

  /// آخر خطأ - Last error
  String? get lastError => _lastError;

  /// تهيئة المدير - Initialize manager
  Future<void> initialize(CopilotSettingsModel settings) async {
    _settings = settings;
    await _copilotService.initialize(settings);
    _logger.i('✅ تم تهيئة مدير الاقتراحات - Suggestions manager initialized');
  }

  /// طلب اقتراحات - Request suggestions
  /// [code] - الكود الحالي - Current code
  /// [language] - اللغة البرمجية - Programming language
  /// [cursorPosition] - موضع المؤشر - Cursor position
  /// [filePath] - مسار الملف (اختياري) - File path (optional)
  /// [forceRefresh] - فرض التحديث (تجاهل الذاكرة المؤقتة) - Force refresh (ignore cache)
  Future<List<SuggestionModel>> requestSuggestions({
    required String code,
    required String language,
    required int cursorPosition,
    String? filePath,
    bool forceRefresh = false,
  }) async {
    if (_settings == null) {
      _logger.e('❌ المدير غير مهيأ - Manager not initialized');
      return [];
    }

    if (!_settings!.enabled) {
      _logger.w('⚠️ Copilot غير مفعل - Copilot is disabled');
      return [];
    }

    // إنشاء مفتاح للذاكرة المؤقتة - Create cache key
    final cacheKey = _generateCacheKey(code, language, cursorPosition);

    // التحقق من الذاكرة المؤقتة - Check cache
    if (!forceRefresh && _suggestionsCache.containsKey(cacheKey)) {
      _logger.d('📦 استخدام الذاكرة المؤقتة - Using cache');
      _currentSuggestions = _suggestionsCache[cacheKey]!;
      _selectedIndex = 0;
      notifyListeners();
      return _currentSuggestions;
    }

    try {
      _isFetching = true;
      _lastError = null;
      notifyListeners();

      _logger.d('🔍 طلب اقتراحات جديدة - Requesting new suggestions');

      // الحصول على الاقتراحات من الخدمة - Get suggestions from service
      final suggestions = await _copilotService.getSuggestions(
        code: code,
        language: language,
        cursorPosition: cursorPosition,
        filePath: filePath,
        maxSuggestions: _settings!.maxSuggestions,
      );

      // تصفية الاقتراحات - Filter suggestions
      final filteredSuggestions = _filterSuggestions(suggestions);

      // ترتيب الاقتراحات حسب الثقة - Sort by confidence
      filteredSuggestions.sort((a, b) => b.confidence.compareTo(a.confidence));

      // تحديث الحالة - Update state
      _currentSuggestions = filteredSuggestions;
      _selectedIndex = 0;
      _lastRequestKey = cacheKey;

      // حفظ في الذاكرة المؤقتة - Save to cache
      if (_settings!.useCache) {
        _addToCache(cacheKey, filteredSuggestions);
      }

      _logger.i(
        '✅ تم الحصول على ${_currentSuggestions.length} اقتراح - Got ${_currentSuggestions.length} suggestions',
      );

      notifyListeners();
      return _currentSuggestions;
    } catch (e) {
      _lastError = e.toString();
      _logger.e('❌ خطأ في طلب الاقتراحات - Error requesting suggestions: $e');
      _currentSuggestions = [];
      notifyListeners();
      return [];
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  /// طلب اقتراحات مع تأخير - Request suggestions with delay
  /// يستخدم للتشغيل التلقائي أثناء الكتابة
  /// Used for auto-trigger while typing
  void requestSuggestionsWithDelay({
    required String code,
    required String language,
    required int cursorPosition,
    String? filePath,
  }) {
    // إلغاء المؤقت السابق - Cancel previous timer
    _delayTimer?.cancel();

    if (!_settings!.autoTrigger) {
      return;
    }

    // إنشاء مؤقت جديد - Create new timer
    _delayTimer = Timer(Duration(milliseconds: _settings!.suggestionDelay), () {
      requestSuggestions(
        code: code,
        language: language,
        cursorPosition: cursorPosition,
        filePath: filePath,
      );
    });
  }

  /// تصفية الاقتراحات - Filter suggestions
  List<SuggestionModel> _filterSuggestions(List<SuggestionModel> suggestions) {
    return suggestions.where((suggestion) {
      // تصفية حسب اللغة - Filter by language
      if (_settings!.enableForLanguages.isNotEmpty &&
          !_settings!.enableForLanguages.contains(suggestion.language)) {
        return false;
      }

      // تصفية حسب الثقة - Filter by confidence
      if (suggestion.confidence < _settings!.minimumConfidence) {
        return false;
      }

      // تصفية الاقتراحات الفارغة - Filter empty suggestions
      if (suggestion.text.trim().isEmpty) {
        return false;
      }

      return true;
    }).toList();
  }

  /// الانتقال للاقتراح التالي - Move to next suggestion
  bool nextSuggestion() {
    if (_currentSuggestions.isEmpty) return false;

    if (_selectedIndex < _currentSuggestions.length - 1) {
      _selectedIndex++;
      notifyListeners();
      _logger.d('➡️ الاقتراح التالي - Next suggestion: $_selectedIndex');
      return true;
    }

    return false;
  }

  /// الانتقال للاقتراح السابق - Move to previous suggestion
  bool previousSuggestion() {
    if (_currentSuggestions.isEmpty) return false;

    if (_selectedIndex > 0) {
      _selectedIndex--;
      notifyListeners();
      _logger.d('⬅️ الاقتراح السابق - Previous suggestion: $_selectedIndex');
      return true;
    }

    return false;
  }

  /// تحديد اقتراح معين - Select specific suggestion
  void selectSuggestion(int index) {
    if (index >= 0 && index < _currentSuggestions.length) {
      _selectedIndex = index;
      notifyListeners();
      _logger.d('👆 تحديد اقتراح - Select suggestion: $index');
    }
  }

  /// قبول الاقتراح المحدد - Accept selected suggestion
  String? acceptSelectedSuggestion() {
    final suggestion = selectedSuggestion;
    if (suggestion == null) return null;

    suggestion.accept();
    _logger.i('✅ تم قبول الاقتراح - Suggestion accepted: ${suggestion.id}');

    // مسح الاقتراحات - Clear suggestions
    clearSuggestions();

    return suggestion.text;
  }

  /// رفض الاقتراح المحدد - Reject selected suggestion
  void rejectSelectedSuggestion() {
    final suggestion = selectedSuggestion;
    if (suggestion == null) return;

    suggestion.reject();
    _logger.i('❌ تم رفض الاقتراح - Suggestion rejected: ${suggestion.id}');

    // إزالة الاقتراح من القائمة - Remove from list
    _currentSuggestions.removeAt(_selectedIndex);

    // تعديل المؤشر - Adjust index
    if (_selectedIndex >= _currentSuggestions.length && _selectedIndex > 0) {
      _selectedIndex--;
    }

    notifyListeners();
  }

  /// مسح الاقتراحات - Clear suggestions
  void clearSuggestions() {
    _currentSuggestions.clear();
    _selectedIndex = 0;
    _lastError = null;
    notifyListeners();
    _logger.d('🧹 تم مسح الاقتراحات - Suggestions cleared');
  }

  /// إلغاء الطلب الحالي - Cancel current request
  void cancelCurrentRequest() {
    _delayTimer?.cancel();
    _copilotService.cancelAllRequests();
    _isFetching = false;
    notifyListeners();
    _logger.d('🛑 تم إلغاء الطلب - Request cancelled');
  }

  /// إنشاء مفتاح للذاكرة المؤقتة - Generate cache key
  String _generateCacheKey(String code, String language, int position) {
    // استخدام hash للكود لتقليل حجم المفتاح
    // Use hash for code to reduce key size
    final codeHash = code.hashCode;
    return '${language}_${position}_$codeHash';
  }

  /// إضافة إلى الذاكرة المؤقتة - Add to cache
  void _addToCache(String key, List<SuggestionModel> suggestions) {
    _suggestionsCache[key] = suggestions;

    // حد أقصى لحجم الذاكرة المؤقتة - Maximum cache size
    const maxCacheSize = 50;

    // حذف أقدم العناصر إذا تجاوز الحد - Remove oldest if exceeded
    if (_suggestionsCache.length > maxCacheSize) {
      final firstKey = _suggestionsCache.keys.first;
      _suggestionsCache.remove(firstKey);
    }
  }

  /// مسح الذاكرة المؤقتة - Clear cache
  void clearCache() {
    _suggestionsCache.clear();
    _logger.d('🧹 تم مسح الذاكرة المؤقتة - Cache cleared');
  }

  /// تحديث الإعدادات - Update settings
  void updateSettings(CopilotSettingsModel settings) {
    _settings = settings;
    _copilotService.updateSettings(settings);
    _logger.i('⚙️ تم تحديث إعدادات المدير - Manager settings updated');
  }

  /// الحصول على إحصائيات الاقتراحات - Get suggestions statistics
  Map<String, dynamic> getStatistics() {
    int totalAccepted = 0;
    int totalRejected = 0;

    for (final suggestions in _suggestionsCache.values) {
      for (final suggestion in suggestions) {
        if (suggestion.isAccepted) totalAccepted++;
        if (suggestion.isRejected) totalRejected++;
      }
    }

    return {
      'cache_size': _suggestionsCache.length,
      'current_suggestions': _currentSuggestions.length,
      'total_accepted': totalAccepted,
      'total_rejected': totalRejected,
      'is_fetching': _isFetching,
    };
  }

  /// تنظيف الموارد - Cleanup resources
  @override
  void dispose() {
    _delayTimer?.cancel();
    _copilotService.dispose();
    _suggestionsCache.clear();
    _currentSuggestions.clear();
    super.dispose();
    _logger.i('🧹 تم تنظيف موارد المدير - Manager resources cleaned up');
  }
}
