// خدمة إدارة الذاكرة المؤقتة - Cache Management Service
// إدارة ذكية للذاكرة المؤقتة مع LRU و TTL
// Smart cache management with LRU and TTL

import 'dart:async';
import 'dart:collection';
import 'package:logger/logger.dart';
import '../models/suggestion_model.dart';

/// خدمة إدارة الذاكرة المؤقتة - Cache Management Service
/// توفر نظام تخزين مؤقت ذكي مع LRU و TTL
/// Provides smart caching system with LRU and TTL
class CacheManagementService {
  // السنغلتون - Singleton
  static final CacheManagementService _instance =
      CacheManagementService._internal();
  factory CacheManagementService() => _instance;
  CacheManagementService._internal();

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

  /// الذاكرة المؤقتة الرئيسية - Main cache
  final LinkedHashMap<String, CacheEntry> _cache = LinkedHashMap();

  /// الحد الأقصى لحجم الذاكرة المؤقتة - Max cache size
  int _maxSize = 100;

  /// TTL الافتراضي (بالثواني) - Default TTL (in seconds)
  int _defaultTtl = 300; // 5 دقائق - 5 minutes

  /// مؤقت التنظيف التلقائي - Auto-cleanup timer
  Timer? _cleanupTimer;

  /// الإحصائيات - Statistics
  final Map<String, int> _stats = {
    'hits': 0, // عدد الإصابات - Number of hits
    'misses': 0, // عدد الإخفاقات - Number of misses
    'evictions': 0, // عدد الطرد - Number of evictions
    'expirations': 0, // عدد الانتهاءات - Number of expirations
  };

  /// هل تم التهيئة - Is initialized
  bool _isInitialized = false;

  /// تهيئة الخدمة - Initialize service
  void initialize({
    int maxSize = 100,
    int defaultTtl = 300,
    bool enableAutoCleanup = true,
  }) {
    if (_isInitialized) {
      _logger.d('ℹ️ خدمة الذاكرة المؤقتة مهيأة مسبقاً - Cache already initialized');
      return;
    }

    _maxSize = maxSize;
    _defaultTtl = defaultTtl;

    // بدء التنظيف التلقائي كل دقيقة - Start auto-cleanup every minute
    if (enableAutoCleanup) {
      _cleanupTimer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => _performCleanup(),
      );
    }

    _isInitialized = true;
    _logger.i('✅ تم تهيئة خدمة الذاكرة المؤقتة - Cache service initialized');
    _logger.d('   الحد الأقصى - Max size: $_maxSize');
    _logger.d('   TTL الافتراضي - Default TTL: $_defaultTtl ثانية');
  }

  // ==================== عمليات الذاكرة المؤقتة - Cache Operations ====================

  /// وضع بيانات في الذاكرة المؤقتة - Put data in cache
  void put<T>(
    String key,
    T value, {
    Duration? ttl,
    int? priority,
  }) {
    _ensureInitialized();

    try {
      // التحقق من الحجم - Check size
      if (_cache.length >= _maxSize && !_cache.containsKey(key)) {
        _evictLRU();
      }

      // إنشاء مدخل جديد - Create new entry
      final entry = CacheEntry<T>(
        key: key,
        value: value,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(
          ttl ?? Duration(seconds: _defaultTtl),
        ),
        priority: priority ?? 0,
        lastAccessedAt: DateTime.now(),
        accessCount: 0,
      );

      _cache[key] = entry;

      _logger.d('💾 تم إضافة إلى الذاكرة المؤقتة - Added to cache: $key');
    } catch (e) {
      _logger.e('❌ خطأ في إضافة البيانات - Put error: $e');
    }
  }

  /// الحصول على بيانات من الذاكرة المؤقتة - Get data from cache
  T? get<T>(String key) {
    _ensureInitialized();

    try {
      final entry = _cache[key];

      // لا يوجد - Not found
      if (entry == null) {
        _stats['misses'] = (_stats['misses'] ?? 0) + 1;
        _logger.d('❌ لم يوجد في الذاكرة المؤقتة - Cache miss: $key');
        return null;
      }

      // التحقق من الانتهاء - Check expiration
      if (entry.isExpired) {
        _cache.remove(key);
        _stats['expirations'] = (_stats['expirations'] ?? 0) + 1;
        _logger.d('⏰ انتهت صلاحية المدخل - Entry expired: $key');
        return null;
      }

      // تحديث معلومات الوصول - Update access info
      entry.lastAccessedAt = DateTime.now();
      entry.accessCount++;

      // نقل إلى النهاية (LRU) - Move to end (LRU)
      _cache.remove(key);
      _cache[key] = entry;

      _stats['hits'] = (_stats['hits'] ?? 0) + 1;
      _logger.d('✅ وجد في الذاكرة المؤقتة - Cache hit: $key');

      return entry.value as T;
    } catch (e) {
      _logger.e('❌ خطأ في الحصول على البيانات - Get error: $e');
      return null;
    }
  }

  /// التحقق من وجود مفتاح - Check if key exists
  bool containsKey(String key) {
    _ensureInitialized();

    final entry = _cache[key];
    if (entry == null) return false;

    // التحقق من الانتهاء - Check expiration
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// حذف مفتاح - Remove key
  bool remove(String key) {
    _ensureInitialized();

    try {
      final removed = _cache.remove(key) != null;

      if (removed) {
        _logger.d('🗑️ تم حذف من الذاكرة المؤقتة - Removed from cache: $key');
      }

      return removed;
    } catch (e) {
      _logger.e('❌ خطأ في الحذف - Remove error: $e');
      return false;
    }
  }

  /// مسح كل الذاكرة المؤقتة - Clear all cache
  void clear() {
    _ensureInitialized();

    try {
      final size = _cache.length;
      _cache.clear();
      _logger.i('🧹 تم مسح الذاكرة المؤقتة - Cache cleared: $size عنصر');
    } catch (e) {
      _logger.e('❌ خطأ في المسح - Clear error: $e');
    }
  }

  // ==================== استراتيجيات الطرد - Eviction Strategies ====================

  /// طرد عنصر باستخدام LRU - Evict item using LRU
  void _evictLRU() {
    try {
      // البحث عن أقل عنصر استخداماً - Find least recently used
      String? keyToEvict;
      DateTime? oldestAccess;

      for (final entry in _cache.entries) {
        final cacheEntry = entry.value;

        if (oldestAccess == null ||
            cacheEntry.lastAccessedAt.isBefore(oldestAccess)) {
          oldestAccess = cacheEntry.lastAccessedAt;
          keyToEvict = entry.key;
        }
      }

      if (keyToEvict != null) {
        _cache.remove(keyToEvict);
        _stats['evictions'] = (_stats['evictions'] ?? 0) + 1;
        _logger.d('🚮 طرد عنصر LRU - Evicted LRU: $keyToEvict');
      }
    } catch (e) {
      _logger.e('❌ خطأ في طرد LRU - LRU eviction error: $e');
    }
  }

  /// طرد حسب الأولوية - Evict by priority
  void _evictByPriority() {
    try {
      // البحث عن أقل أولوية - Find lowest priority
      String? keyToEvict;
      int lowestPriority = 999999;

      for (final entry in _cache.entries) {
        final cacheEntry = entry.value;

        if (cacheEntry.priority < lowestPriority) {
          lowestPriority = cacheEntry.priority;
          keyToEvict = entry.key;
        }
      }

      if (keyToEvict != null) {
        _cache.remove(keyToEvict);
        _stats['evictions'] = (_stats['evictions'] ?? 0) + 1;
        _logger.d('🚮 طرد حسب الأولوية - Evicted by priority: $keyToEvict');
      }
    } catch (e) {
      _logger.e('❌ خطأ في الطرد - Priority eviction error: $e');
    }
  }

  // ==================== التنظيف والصيانة - Cleanup & Maintenance ====================

  /// تنظيف المدخلات المنتهية - Cleanup expired entries
  void _performCleanup() {
    _ensureInitialized();

    try {
      final now = DateTime.now();
      final keysToRemove = <String>[];

      // جمع المفاتيح المنتهية - Collect expired keys
      for (final entry in _cache.entries) {
        if (entry.value.expiresAt.isBefore(now)) {
          keysToRemove.add(entry.key);
        }
      }

      // حذف المفاتيح المنتهية - Remove expired keys
      for (final key in keysToRemove) {
        _cache.remove(key);
        _stats['expirations'] = (_stats['expirations'] ?? 0) + 1;
      }

      if (keysToRemove.isNotEmpty) {
        _logger.d(
          '🧹 تم تنظيف ${keysToRemove.length} مدخل منتهي - Cleaned ${keysToRemove.length} expired entries',
        );
      }
    } catch (e) {
      _logger.e('❌ خطأ في التنظيف - Cleanup error: $e');
    }
  }

  /// تنظيف يدوي - Manual cleanup
  void cleanup() {
    _performCleanup();
  }

  /// تحسين الذاكرة المؤقتة - Optimize cache
  /// حذف العناصر الأقل استخداماً
  /// Remove least used items
  void optimize({double targetFillRatio = 0.8}) {
    _ensureInitialized();

    try {
      final targetSize = (_maxSize * targetFillRatio).round();

      if (_cache.length <= targetSize) {
        _logger.d('ℹ️ لا حاجة للتحسين - No optimization needed');
        return;
      }

      // ترتيب حسب عدد الوصول - Sort by access count
      final entries = _cache.entries.toList()
        ..sort((a, b) => a.value.accessCount.compareTo(b.value.accessCount));

      // حذف العناصر الأقل استخداماً - Remove least used
      final removeCount = _cache.length - targetSize;

      for (int i = 0; i < removeCount && i < entries.length; i++) {
        _cache.remove(entries[i].key);
        _stats['evictions'] = (_stats['evictions'] ?? 0) + 1;
      }

      _logger.i(
        '🔧 تم تحسين الذاكرة المؤقتة - Cache optimized: حذف $removeCount عنصر',
      );
    } catch (e) {
      _logger.e('❌ خطأ في التحسين - Optimization error: $e');
    }
  }

  // ==================== الإحصائيات - Statistics ====================

  /// الحصول على إحصائيات الذاكرة المؤقتة - Get cache statistics
  Map<String, dynamic> getStatistics() {
    _ensureInitialized();

    final totalRequests = (_stats['hits'] ?? 0) + (_stats['misses'] ?? 0);
    final hitRate = totalRequests > 0
        ? ((_stats['hits'] ?? 0) / totalRequests * 100)
        : 0.0;

    return {
      'size': _cache.length,
      'max_size': _maxSize,
      'hits': _stats['hits'] ?? 0,
      'misses': _stats['misses'] ?? 0,
      'hit_rate': hitRate.toStringAsFixed(2) + '%',
      'evictions': _stats['evictions'] ?? 0,
      'expirations': _stats['expirations'] ?? 0,
      'fill_ratio': ((_cache.length / _maxSize) * 100).toStringAsFixed(2) + '%',
    };
  }

  /// طباعة إحصائيات - Print statistics
  void printStatistics() {
    final stats = getStatistics();

    _logger.i('📊 إحصائيات الذاكرة المؤقتة - Cache Statistics');
    _logger.i('   الحجم - Size: ${stats['size']}/${stats['max_size']}');
    _logger.i('   معدل الإصابة - Hit Rate: ${stats['hit_rate']}');
    _logger.i('   الإصابات - Hits: ${stats['hits']}');
    _logger.i('   الإخفاقات - Misses: ${stats['misses']}');
    _logger.i('   الطرد - Evictions: ${stats['evictions']}');
    _logger.i('   الانتهاءات - Expirations: ${stats['expirations']}');
    _logger.i('   نسبة الامتلاء - Fill Ratio: ${stats['fill_ratio']}');
  }

  /// إعادة تعيين الإحصائيات - Reset statistics
  void resetStatistics() {
    _stats['hits'] = 0;
    _stats['misses'] = 0;
    _stats['evictions'] = 0;
    _stats['expirations'] = 0;
    _logger.d('🔄 تم إعادة تعيين الإحصائيات - Statistics reset');
  }

  // ==================== تخصيص الإعدادات - Settings Customization ====================

  /// تعيين الحد الأقصى للحجم - Set max size
  void setMaxSize(int size) {
    _maxSize = size;
    _logger.d('⚙️ تم تغيير الحد الأقصى - Max size changed: $size');

    // تنظيف إذا تجاوز الحد - Cleanup if exceeded
    if (_cache.length > _maxSize) {
      optimize();
    }
  }

  /// تعيين TTL الافتراضي - Set default TTL
  void setDefaultTtl(int seconds) {
    _defaultTtl = seconds;
    _logger.d('⚙️ تم تغيير TTL الافتراضي - Default TTL changed: $seconds ثانية');
  }

  /// الحصول على معلومات المدخل - Get entry info
  Map<String, dynamic>? getEntryInfo(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    return {
      'key': entry.key,
      'created_at': entry.createdAt.toIso8601String(),
      'expires_at': entry.expiresAt.toIso8601String(),
      'last_accessed_at': entry.lastAccessedAt.toIso8601String(),
      'access_count': entry.accessCount,
      'priority': entry.priority,
      'is_expired': entry.isExpired,
      'time_to_live': entry.timeToLive.inSeconds,
    };
  }

  /// سرد جميع المفاتيح - List all keys
  List<String> keys() {
    return _cache.keys.toList();
  }

  /// الحصول على الحجم - Get size
  int get size => _cache.length;

  /// التحقق من الفراغ - Check if empty
  bool get isEmpty => _cache.isEmpty;

  /// التحقق من الامتلاء - Check if full
  bool get isFull => _cache.length >= _maxSize;

  /// التحقق من التهيئة - Ensure initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'خدمة الذاكرة المؤقتة غير مهيأة - Cache service not initialized. استدعي initialize() أولاً - Call initialize() first.',
      );
    }
  }

  /// تنظيف الموارد - Cleanup resources
  void dispose() {
    try {
      _cleanupTimer?.cancel();
      _cache.clear();
      _stats.clear();
      _isInitialized = false;
      _logger.i('🧹 تم تنظيف موارد الذاكرة المؤقتة - Cache resources cleaned up');
    } catch (e) {
      _logger.e('❌ خطأ في التنظيف - Disposal error: $e');
    }
  }
}

// ==================== مدخل الذاكرة المؤقتة - Cache Entry ====================

/// مدخل الذاكرة المؤقتة - Cache Entry
/// يحتوي على البيانات والبيانات الوصفية
/// Contains data and metadata
class CacheEntry<T> {
  /// المفتاح - Key
  final String key;

  /// القيمة - Value
  final T value;

  /// وقت الإنشاء - Creation time
  final DateTime createdAt;

  /// وقت الانتهاء - Expiration time
  final DateTime expiresAt;

  /// الأولوية - Priority
  final int priority;

  /// آخر وقت وصول - Last access time
  DateTime lastAccessedAt;

  /// عدد مرات الوصول - Access count
  int accessCount;

  CacheEntry({
    required this.key,
    required this.value,
    required this.createdAt,
    required this.expiresAt,
    required this.priority,
    required this.lastAccessedAt,
    required this.accessCount,
  });

  /// هل انتهت الصلاحية - Is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// الوقت المتبقي - Time to live
  Duration get timeToLive {
    final now = DateTime.now();
    return expiresAt.isAfter(now)
        ? expiresAt.difference(now)
        : Duration.zero;
  }

  /// عمر المدخل - Age of entry
  Duration get age => DateTime.now().difference(createdAt);
}
