// خدمة التخزين المحلي - Storage Service
// إدارة حفظ وتحميل البيانات محلياً
// Manages saving and loading data locally

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import '../models/copilot_settings_model.dart';
import '../models/copilot_extension_model.dart';

/// خدمة التخزين المحلي - Storage Service
/// توفر واجهة موحدة للتخزين المحلي
/// Provides unified interface for local storage
class StorageService {
  // السنغلتون - Singleton
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// المسجل - Logger
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// SharedPreferences للإعدادات - SharedPreferences for settings
  SharedPreferences? _prefs;

  /// Hive box للبيانات الثقيلة - Hive box for heavy data
  Box? _cacheBox;
  Box? _statisticsBox;

  /// هل تم التهيئة - Is initialized
  bool _isInitialized = false;

  /// مفاتيح التخزين - Storage keys
  static const String _settingsKey = 'copilot_settings';
  static const String _extensionStateKey = 'extension_state';
  static const String _statisticsKey = 'usage_statistics';
  static const String _cacheBoxName = 'copilot_cache';
  static const String _statisticsBoxName = 'copilot_statistics';

  /// تهيئة الخدمة - Initialize service
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.d('ℹ️ الخدمة مهيأة مسبقاً - Service already initialized');
      return;
    }

    try {
      _logger.d('🔄 تهيئة خدمة التخزين - Initializing storage service');

      // تهيئة SharedPreferences - Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      _logger.d('✅ SharedPreferences جاهز - SharedPreferences ready');

      // تهيئة Hive - Initialize Hive
      if (!Hive.isBoxOpen(_cacheBoxName)) {
        _cacheBox = await Hive.openBox(_cacheBoxName);
        _logger.d('✅ Cache Box جاهز - Cache box ready');
      }

      if (!Hive.isBoxOpen(_statisticsBoxName)) {
        _statisticsBox = await Hive.openBox(_statisticsBoxName);
        _logger.d('✅ Statistics Box جاهز - Statistics box ready');
      }

      _isInitialized = true;
      _logger.i('✅ تم تهيئة خدمة التخزين - Storage service initialized');
    } catch (e) {
      _logger.e('❌ خطأ في تهيئة التخزين - Storage initialization error: $e');
      rethrow;
    }
  }

  // ==================== الإعدادات - Settings ====================

  /// حفظ الإعدادات - Save settings
  Future<bool> saveSettings(CopilotSettingsModel settings) async {
    _ensureInitialized();

    try {
      final jsonString = jsonEncode(settings.toJson());
      final success = await _prefs!.setString(_settingsKey, jsonString);

      if (success) {
        _logger.i('💾 تم حفظ الإعدادات - Settings saved');
      }

      return success;
    } catch (e) {
      _logger.e('❌ خطأ في حفظ الإعدادات - Error saving settings: $e');
      return false;
    }
  }

  /// تحميل الإعدادات - Load settings
  Future<CopilotSettingsModel?> loadSettings() async {
    _ensureInitialized();

    try {
      final jsonString = _prefs!.getString(_settingsKey);

      if (jsonString == null) {
        _logger.d('ℹ️ لا توجد إعدادات محفوظة - No saved settings');
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final settings = CopilotSettingsModel.fromJson(json);

      _logger.i('📂 تم تحميل الإعدادات - Settings loaded');
      return settings;
    } catch (e) {
      _logger.e('❌ خطأ في تحميل الإعدادات - Error loading settings: $e');
      return null;
    }
  }

  /// حذف الإعدادات - Delete settings
  Future<bool> deleteSettings() async {
    _ensureInitialized();

    try {
      final success = await _prefs!.remove(_settingsKey);

      if (success) {
        _logger.i('🗑️ تم حذف الإعدادات - Settings deleted');
      }

      return success;
    } catch (e) {
      _logger.e('❌ خطأ في حذف الإعدادات - Error deleting settings: $e');
      return false;
    }
  }

  // ==================== حالة الإضافة - Extension State ====================

  /// حفظ حالة الإضافة - Save extension state
  Future<bool> saveExtensionState(CopilotExtensionModel state) async {
    _ensureInitialized();

    try {
      final jsonString = jsonEncode(state.toJson());
      final success = await _prefs!.setString(_extensionStateKey, jsonString);

      if (success) {
        _logger.d('💾 تم حفظ حالة الإضافة - Extension state saved');
      }

      return success;
    } catch (e) {
      _logger.e('❌ خطأ في حفظ حالة الإضافة - Error saving state: $e');
      return false;
    }
  }

  /// تحميل حالة الإضافة - Load extension state
  Future<CopilotExtensionModel?> loadExtensionState() async {
    _ensureInitialized();

    try {
      final jsonString = _prefs!.getString(_extensionStateKey);

      if (jsonString == null) {
        _logger.d('ℹ️ لا توجد حالة محفوظة - No saved state');
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final state = CopilotExtensionModel.fromJson(json);

      _logger.d('📂 تم تحميل حالة الإضافة - Extension state loaded');
      return state;
    } catch (e) {
      _logger.e('❌ خطأ في تحميل الحالة - Error loading state: $e');
      return null;
    }
  }

  // ==================== الإحصائيات - Statistics ====================

  /// حفظ الإحصائيات - Save statistics
  Future<bool> saveStatistics(UsageStatistics statistics) async {
    _ensureInitialized();

    try {
      final jsonString = jsonEncode(statistics.toJson());
      await _statisticsBox!.put(_statisticsKey, jsonString);

      _logger.d('💾 تم حفظ الإحصائيات - Statistics saved');
      return true;
    } catch (e) {
      _logger.e('❌ خطأ في حفظ الإحصائيات - Error saving statistics: $e');
      return false;
    }
  }

  /// تحميل الإحصائيات - Load statistics
  Future<UsageStatistics?> loadStatistics() async {
    _ensureInitialized();

    try {
      final jsonString = _statisticsBox!.get(_statisticsKey) as String?;

      if (jsonString == null) {
        _logger.d('ℹ️ لا توجد إحصائيات محفوظة - No saved statistics');
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final statistics = UsageStatistics.fromJson(json);

      _logger.d('📂 تم تحميل الإحصائيات - Statistics loaded');
      return statistics;
    } catch (e) {
      _logger.e('❌ خطأ في تحميل الإحصائيات - Error loading statistics: $e');
      return null;
    }
  }

  // ==================== الذاكرة المؤقتة - Cache ====================

  /// حفظ في الذاكرة المؤقتة - Save to cache
  Future<bool> cacheData(String key, dynamic data,
      {Duration? ttl}) async {
    _ensureInitialized();

    try {
      final cacheEntry = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'ttl': ttl?.inMilliseconds,
      };

      await _cacheBox!.put(key, jsonEncode(cacheEntry));
      _logger.d('💾 تم حفظ البيانات في الذاكرة المؤقتة - Data cached: $key');
      return true;
    } catch (e) {
      _logger.e('❌ خطأ في التخزين المؤقت - Caching error: $e');
      return false;
    }
  }

  /// الحصول من الذاكرة المؤقتة - Get from cache
  Future<dynamic> getCachedData(String key) async {
    _ensureInitialized();

    try {
      final jsonString = _cacheBox!.get(key) as String?;

      if (jsonString == null) {
        return null;
      }

      final cacheEntry = jsonDecode(jsonString) as Map<String, dynamic>;
      final timestamp = cacheEntry['timestamp'] as int;
      final ttl = cacheEntry['ttl'] as int?;

      // التحقق من انتهاء الصلاحية - Check expiration
      if (ttl != null) {
        final expirationTime = timestamp + ttl;
        final now = DateTime.now().millisecondsSinceEpoch;

        if (now > expirationTime) {
          _logger.d('⏰ انتهت صلاحية البيانات - Data expired: $key');
          await _cacheBox!.delete(key);
          return null;
        }
      }

      _logger.d('📂 تم استرجاع البيانات من الذاكرة المؤقتة - Data retrieved: $key');
      return cacheEntry['data'];
    } catch (e) {
      _logger.e('❌ خطأ في استرجاع البيانات المؤقتة - Cache retrieval error: $e');
      return null;
    }
  }

  /// حذف من الذاكرة المؤقتة - Delete from cache
  Future<bool> deleteCachedData(String key) async {
    _ensureInitialized();

    try {
      await _cacheBox!.delete(key);
      _logger.d('🗑️ تم حذف البيانات من الذاكرة المؤقتة - Cache deleted: $key');
      return true;
    } catch (e) {
      _logger.e('❌ خطأ في حذف البيانات المؤقتة - Cache deletion error: $e');
      return false;
    }
  }

  /// مسح كل الذاكرة المؤقتة - Clear all cache
  Future<bool> clearCache() async {
    _ensureInitialized();

    try {
      await _cacheBox!.clear();
      _logger.i('🧹 تم مسح كل الذاكرة المؤقتة - All cache cleared');
      return true;
    } catch (e) {
      _logger.e('❌ خطأ في مسح الذاكرة المؤقتة - Cache clear error: $e');
      return false;
    }
  }

  /// الحصول على حجم الذاكرة المؤقتة - Get cache size
  int getCacheSize() {
    _ensureInitialized();
    return _cacheBox?.length ?? 0;
  }

  // ==================== عمليات عامة - General Operations ====================

  /// حفظ بيانات عامة - Save generic data
  Future<bool> setString(String key, String value) async {
    _ensureInitialized();

    try {
      return await _prefs!.setString(key, value);
    } catch (e) {
      _logger.e('❌ خطأ في حفظ البيانات - Error saving data: $e');
      return false;
    }
  }

  /// قراءة بيانات عامة - Read generic data
  String? getString(String key) {
    _ensureInitialized();
    return _prefs!.getString(key);
  }

  /// حفظ رقم - Save integer
  Future<bool> setInt(String key, int value) async {
    _ensureInitialized();
    return await _prefs!.setInt(key, value);
  }

  /// قراءة رقم - Read integer
  int? getInt(String key) {
    _ensureInitialized();
    return _prefs!.getInt(key);
  }

  /// حفظ قيمة منطقية - Save boolean
  Future<bool> setBool(String key, bool value) async {
    _ensureInitialized();
    return await _prefs!.setBool(key, value);
  }

  /// قراءة قيمة منطقية - Read boolean
  bool? getBool(String key) {
    _ensureInitialized();
    return _prefs!.getBool(key);
  }

  /// حذف مفتاح - Remove key
  Future<bool> remove(String key) async {
    _ensureInitialized();
    return await _prefs!.remove(key);
  }

  /// التحقق من وجود مفتاح - Check if key exists
  bool containsKey(String key) {
    _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  // ==================== الصيانة - Maintenance ====================

  /// تنظيف البيانات القديمة - Cleanup old data
  Future<void> cleanupOldData() async {
    _ensureInitialized();

    try {
      _logger.d('🧹 بدء تنظيف البيانات القديمة - Starting cleanup');

      // تنظيف الذاكرة المؤقتة المنتهية - Clean expired cache
      final now = DateTime.now().millisecondsSinceEpoch;
      final keysToDelete = <String>[];

      for (final key in _cacheBox!.keys) {
        try {
          final jsonString = _cacheBox!.get(key) as String?;
          if (jsonString != null) {
            final cacheEntry = jsonDecode(jsonString) as Map<String, dynamic>;
            final timestamp = cacheEntry['timestamp'] as int;
            final ttl = cacheEntry['ttl'] as int?;

            if (ttl != null && now > timestamp + ttl) {
              keysToDelete.add(key.toString());
            }
          }
        } catch (e) {
          // إذا فشل التحليل، احذف المفتاح
          // If parsing fails, delete the key
          keysToDelete.add(key.toString());
        }
      }

      // حذف المفاتيح المنتهية - Delete expired keys
      for (final key in keysToDelete) {
        await _cacheBox!.delete(key);
      }

      _logger.i('🧹 تم حذف ${keysToDelete.length} عنصر منتهي - Deleted ${keysToDelete.length} expired items');
    } catch (e) {
      _logger.e('❌ خطأ في التنظيف - Cleanup error: $e');
    }
  }

  /// الحصول على معلومات التخزين - Get storage info
  Map<String, dynamic> getStorageInfo() {
    _ensureInitialized();

    return {
      'preferences_keys': _prefs!.getKeys().length,
      'cache_size': _cacheBox?.length ?? 0,
      'statistics_size': _statisticsBox?.length ?? 0,
      'is_initialized': _isInitialized,
    };
  }

  /// التحقق من التهيئة - Ensure initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'خدمة التخزين غير مهيأة - Storage service not initialized. استدعي initialize() أولاً - Call initialize() first.',
      );
    }
  }

  /// تنظيف الموارد - Cleanup resources
  Future<void> dispose() async {
    try {
      await _cacheBox?.close();
      await _statisticsBox?.close();
      _isInitialized = false;
      _logger.i('🧹 تم تنظيف موارد التخزين - Storage resources cleaned up');
    } catch (e) {
      _logger.e('❌ خطأ في التنظيف - Disposal error: $e');
    }
  }
}
