// خدمة إدارة الذاكرة المؤقتة المتقدمة - Advanced Cache Service
// نظام ذكي للتخزين المؤقت مع LRU وإدارة التخزين
// Smart caching system with LRU and storage management

import 'dart:async';
import 'dart:collection';
import 'package:logger/logger.dart';
import 'package:hive/hive.dart';
import '../models/suggestion_model.dart';

/// خدمة الذاكرة المؤقتة - Cache Service
/// إدارة ذكية للذاكرة المؤقتة مع Memory و Persistent layers
/// Smart cache management with Memory and Persistent layers
class CacheService {
  // Singleton pattern
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // التبعيات - Dependencies
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  // Memory Cache (LRU) - Layer 1
  final LinkedHashMap<String, CacheEntry> _memoryCache = LinkedHashMap();

  // Persistent Cache (Hive) - Layer 2
  Box<dynamic>? _persistentCache;

  // Configuration
  static const int _maxMemoryEntries = 100;
  static const int _maxMemorySizeMB = 50;
  static const Duration _defaultTTL = Duration(hours: 1);
  static const Duration _persistentTTL = Duration(days: 7);

  // Statistics
  int _memoryHits = 0;
  int _memoryMisses = 0;
  int _persistentHits = 0;
  int _persistentMisses = 0;
  int _evictions = 0;

  // State
  bool _isInitialized = false;
  Timer? _cleanupTimer;

  /// تهيئة الخدمة - Initialize service
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.d('Cache service already initialized');
      return;
    }

    try {
      _logger.d('🔄 Initializing cache service');

      // تهيئة Hive للتخزين الدائم - Initialize Hive for persistent storage
      _persistentCache = await Hive.openBox('copilot_cache');

      // بدء التنظيف الدوري (كل ساعة) - Start periodic cleanup (every hour)
      _cleanupTimer = Timer.periodic(
        const Duration(hours: 1),
        (_) => _cleanupExpiredEntries(),
      );

      _isInitialized = true;
      _logger.i('✅ Cache service initialized successfully');
    } catch (e) {
      _logger.e('❌ Error initializing cache service: $e');
      rethrow;
    }
  }

  // ==================== GET Operations ====================

  /// الحصول من الذاكرة المؤقتة - Get from cache
  /// يبحث في Memory Cache أولاً، ثم Persistent Cache
  /// Searches Memory Cache first, then Persistent Cache
  Future<T?> get<T>(String key) async {
    _ensureInitialized();

    try {
      // 1. التحقق من Memory Cache - Check Memory Cache
      final memoryEntry = _memoryCache[key];
      if (memoryEntry != null) {
        if (!memoryEntry.isExpired) {
          _memoryHits++;
          memoryEntry.updateAccessTime(); // LRU tracking
          _logger.d('💚 Memory cache hit: $key');
          return memoryEntry.value as T?;
        } else {
          // حذف المدخل المنتهي - Remove expired entry
          _memoryCache.remove(key);
          _logger.d('⏰ Expired entry removed from memory: $key');
        }
      }

      _memoryMisses++;

      // 2. التحقق من Persistent Cache - Check Persistent Cache
      if (_persistentCache != null && _persistentCache!.containsKey(key)) {
        final persistentEntry = _deserializeCacheEntry(
          _persistentCache!.get(key),
        );

        if (persistentEntry != null && !persistentEntry.isExpired) {
          _persistentHits++;

          // ترقية إلى Memory Cache - Promote to Memory Cache
          await _setInMemory(key, persistentEntry.value, persistentEntry.ttl);

          _logger.d('💙 Persistent cache hit: $key (promoted to memory)');
          return persistentEntry.value as T?;
        } else {
          // حذف المدخل المنتهي - Remove expired entry
          await _persistentCache!.delete(key);
          _logger.d('⏰ Expired entry removed from persistent: $key');
        }
      }

      _persistentMisses++;
      _logger.d('❌ Cache miss: $key');
      return null;
    } catch (e) {
      _logger.e('❌ Error getting from cache: $e');
      return null;
    }
  }

  // ==================== SET Operations ====================

  /// حفظ في الذاكرة المؤقتة - Save to cache
  /// يحفظ في Memory و Persistent Cache
  /// Saves to both Memory and Persistent Cache
  Future<void> set<T>(
    String key,
    T value, {
    Duration? ttl,
    bool persistentOnly = false,
  }) async {
    _ensureInitialized();

    try {
      final effectiveTTL = ttl ?? _defaultTTL;

      // حفظ في Memory Cache - Save to Memory Cache
      if (!persistentOnly) {
        await _setInMemory(key, value, effectiveTTL);
      }

      // حفظ في Persistent Cache - Save to Persistent Cache
      await _setInPersistent(key, value, effectiveTTL);

      _logger.d('✅ Cached: $key (TTL: ${effectiveTTL.inMinutes}min)');
    } catch (e) {
      _logger.e('❌ Error setting cache: $e');
    }
  }

  /// حفظ في Memory Cache - Save to Memory Cache
  Future<void> _setInMemory<T>(String key, T value, Duration ttl) async {
    // التحقق من حد الحجم - Check size limit
    if (_memoryCache.length >= _maxMemoryEntries) {
      _evictLRU();
    }

    final entry = CacheEntry(
      key: key,
      value: value,
      ttl: ttl,
      createdAt: DateTime.now(),
    );

    _memoryCache[key] = entry;
  }

  /// حفظ في Persistent Cache - Save to Persistent Cache
  Future<void> _setInPersistent<T>(String key, T value, Duration ttl) async {
    if (_persistentCache == null) return;

    final entry = CacheEntry(
      key: key,
      value: value,
      ttl: ttl,
      createdAt: DateTime.now(),
    );

    await _persistentCache!.put(key, _serializeCacheEntry(entry));
  }

  // ==================== DELETE Operations ====================

  /// حذف من الذاكرة المؤقتة - Delete from cache
  Future<void> delete(String key) async {
    _ensureInitialized();

    try {
      _memoryCache.remove(key);
      await _persistentCache?.delete(key);
      _logger.d('🗑️ Deleted from cache: $key');
    } catch (e) {
      _logger.e('❌ Error deleting from cache: $e');
    }
  }

  /// مسح كل الذاكرة المؤقتة - Clear all cache
  Future<void> clear() async {
    _ensureInitialized();

    try {
      _memoryCache.clear();
      await _persistentCache?.clear();

      // إعادة تعيين الإحصائيات - Reset statistics
      _memoryHits = 0;
      _memoryMisses = 0;
      _persistentHits = 0;
      _persistentMisses = 0;
      _evictions = 0;

      _logger.i('🧹 Cache cleared');
    } catch (e) {
      _logger.e('❌ Error clearing cache: $e');
    }
  }

  // ==================== LRU Eviction ====================

  /// إزالة أقدم مدخل (LRU) - Evict Least Recently Used
  void _evictLRU() {
    if (_memoryCache.isEmpty) return;

    // أول مدخل في LinkedHashMap هو الأقدم استخداماً
    // First entry in LinkedHashMap is the least recently used
    final oldestKey = _memoryCache.keys.first;
    _memoryCache.remove(oldestKey);
    _evictions++;

    _logger.d('🔄 LRU eviction: $oldestKey');
  }

  // ==================== Cleanup ====================

  /// تنظيف المدخلات المنتهية - Cleanup expired entries
  Future<void> _cleanupExpiredEntries() async {
    _ensureInitialized();

    try {
      var memoryCleanedCount = 0;
      var persistentCleanedCount = 0;

      // تنظيف Memory Cache - Cleanup Memory Cache
      _memoryCache.removeWhere((key, entry) {
        if (entry.isExpired) {
          memoryCleanedCount++;
          return true;
        }
        return false;
      });

      // تنظيف Persistent Cache - Cleanup Persistent Cache
      if (_persistentCache != null) {
        final keysToDelete = <String>[];

        for (final key in _persistentCache!.keys) {
          final entry = _deserializeCacheEntry(_persistentCache!.get(key));
          if (entry != null && entry.isExpired) {
            keysToDelete.add(key.toString());
            persistentCleanedCount++;
          }
        }

        for (final key in keysToDelete) {
          await _persistentCache!.delete(key);
        }
      }

      if (memoryCleanedCount > 0 || persistentCleanedCount > 0) {
        _logger.i(
          '🧹 Cleaned up: $memoryCleanedCount memory, $persistentCleanedCount persistent entries',
        );
      }
    } catch (e) {
      _logger.e('❌ Error during cleanup: $e');
    }
  }

  /// تنظيف يدوي - Manual cleanup
  Future<void> cleanupNow() async {
    await _cleanupExpiredEntries();
  }

  // ==================== Statistics ====================

  /// الحصول على إحصائيات الذاكرة المؤقتة - Get cache statistics
  Map<String, dynamic> getStatistics() {
    _ensureInitialized();

    final totalMemoryRequests = _memoryHits + _memoryMisses;
    final totalPersistentRequests = _persistentHits + _persistentMisses;

    return {
      'memory_cache': {
        'entries': _memoryCache.length,
        'max_entries': _maxMemoryEntries,
        'hits': _memoryHits,
        'misses': _memoryMisses,
        'hit_rate': totalMemoryRequests > 0
            ? (_memoryHits / totalMemoryRequests * 100).toStringAsFixed(1)
            : '0.0',
      },
      'persistent_cache': {
        'entries': _persistentCache?.length ?? 0,
        'hits': _persistentHits,
        'misses': _persistentMisses,
        'hit_rate': totalPersistentRequests > 0
            ? (_persistentHits / totalPersistentRequests * 100).toStringAsFixed(
                1,
              )
            : '0.0',
      },
      'overall': {
        'evictions': _evictions,
        'total_requests': totalMemoryRequests + totalPersistentRequests,
      },
    };
  }

  /// طباعة الإحصائيات - Print statistics
  void printStatistics() {
    final stats = getStatistics();

    _logger.i('📊 Cache Statistics:');
    _logger.i(
      'Memory: ${stats['memory_cache']['entries']} entries, '
      '${stats['memory_cache']['hit_rate']}% hit rate',
    );
    _logger.i(
      'Persistent: ${stats['persistent_cache']['entries']} entries, '
      '${stats['persistent_cache']['hit_rate']}% hit rate',
    );
    _logger.i('Evictions: ${stats['overall']['evictions']}');
  }

  // ==================== Serialization ====================

  /// تحويل CacheEntry إلى Map - Serialize CacheEntry to Map
  Map<String, dynamic> _serializeCacheEntry(CacheEntry entry) {
    return {
      'key': entry.key,
      'value': entry.value,
      'created_at': entry.createdAt.toIso8601String(),
      'ttl_seconds': entry.ttl.inSeconds,
      'last_access': entry.lastAccessTime.toIso8601String(),
    };
  }

  /// تحويل Map إلى CacheEntry - Deserialize Map to CacheEntry
  CacheEntry? _deserializeCacheEntry(dynamic data) {
    try {
      if (data is! Map) return null;

      return CacheEntry(
        key: data['key'] as String,
        value: data['value'],
        createdAt: DateTime.parse(data['created_at'] as String),
        ttl: Duration(seconds: data['ttl_seconds'] as int),
        lastAccessTime: DateTime.parse(data['last_access'] as String),
      );
    } catch (e) {
      _logger.e('❌ Error deserializing cache entry: $e');
      return null;
    }
  }

  // ==================== Maintenance ====================

  /// التحقق من التهيئة - Ensure initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'Cache service not initialized. Call initialize() first.',
      );
    }
  }

  /// تنظيف الموارد - Cleanup resources
  Future<void> dispose() async {
    try {
      _cleanupTimer?.cancel();
      await _cleanupExpiredEntries();
      await _persistentCache?.close();
      _memoryCache.clear();
      _isInitialized = false;
      _logger.i('🧹 Cache service disposed');
    } catch (e) {
      _logger.e('❌ Error disposing cache service: $e');
    }
  }
}

/// مدخل الذاكرة المؤقتة - Cache Entry
/// يمثل عنصر واحد في الذاكرة المؤقتة
/// Represents a single cache item
class CacheEntry {
  final String key;
  final dynamic value;
  final DateTime createdAt;
  final Duration ttl;
  DateTime lastAccessTime;

  CacheEntry({
    required this.key,
    required this.value,
    required this.createdAt,
    required this.ttl,
    DateTime? lastAccessTime,
  }) : lastAccessTime = lastAccessTime ?? DateTime.now();

  /// هل انتهت صلاحية المدخل - Is entry expired
  bool get isExpired {
    final expiryTime = createdAt.add(ttl);
    return DateTime.now().isAfter(expiryTime);
  }

  /// الوقت المتبقي - Remaining time
  Duration get remainingTime {
    final expiryTime = createdAt.add(ttl);
    final remaining = expiryTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// تحديث وقت الوصول (للـ LRU) - Update access time (for LRU)
  void updateAccessTime() {
    lastAccessTime = DateTime.now();
  }

  @override
  String toString() {
    return 'CacheEntry(key: $key, expires_in: ${remainingTime.inMinutes}min)';
  }
}
