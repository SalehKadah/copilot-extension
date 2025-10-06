// خدمة التحليلات - Analytics Service
// تتبع وتحليل استخدام الإضافة
// Tracks and analyzes extension usage

import 'dart:async';
import 'package:logger/logger.dart';
import '../models/copilot_extension_model.dart';
import '../models/suggestion_model.dart';
import 'storage_service.dart';

/// خدمة التحليلات - Analytics Service
/// تتبع وتحليل استخدام الإضافة والاقتراحات
/// Tracks and analyzes extension and suggestions usage
class AnalyticsService {
  // السنغلتون - Singleton
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

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

  /// خدمة التخزين - Storage service
  final StorageService _storage = StorageService();

  /// الإحصائيات الحالية - Current statistics
  UsageStatistics? _statistics;

  /// إحصائيات الجلسة الحالية - Current session statistics
  final Map<String, dynamic> _sessionStats = {
    'session_start': DateTime.now(),
    'suggestions_shown': 0,
    'suggestions_accepted': 0,
    'suggestions_rejected': 0,
    'api_requests': 0,
    'errors': 0,
    'languages_used': <String>{},
    'response_times': <Duration>[],
  };

  /// مؤقت الحفظ التلقائي - Auto-save timer
  Timer? _autoSaveTimer;

  /// هل تم التهيئة - Is initialized
  bool _isInitialized = false;

  /// تهيئة الخدمة - Initialize service
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.d(
        'ℹ️ خدمة التحليلات مهيأة مسبقاً - Analytics already initialized',
      );
      return;
    }

    try {
      _logger.d('🔄 تهيئة خدمة التحليلات - Initializing analytics service');

      // تحميل الإحصائيات المحفوظة - Load saved statistics
      _statistics = await _storage.loadStatistics();

      // إنشاء إحصائيات جديدة إذا لم توجد - Create new if none exist
      if (_statistics == null) {
        _statistics = UsageStatistics();
        _logger.d('📊 إنشاء إحصائيات جديدة - Creating new statistics');
      }

      // بدء الحفظ التلقائي كل 5 دقائق - Start auto-save every 5 minutes
      _autoSaveTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => _saveStatistics(),
      );

      _isInitialized = true;
      _logger.i('✅ تم تهيئة خدمة التحليلات - Analytics service initialized');
    } catch (e) {
      _logger.e(
        '❌ خطأ في تهيئة التحليلات - Analytics initialization error: $e',
      );
      rethrow;
    }
  }

  // ==================== تتبع الأحداث - Event Tracking ====================

  /// تسجيل طلب اقتراحات - Track suggestion request
  void trackSuggestionRequest({
    required String language,
    Duration? responseTime,
  }) {
    _ensureInitialized();

    try {
      _statistics!.incrementApiRequests();
      _sessionStats['api_requests'] =
          (_sessionStats['api_requests'] as int) + 1;
      (_sessionStats['languages_used'] as Set<String>).add(language);

      if (responseTime != null) {
        (_sessionStats['response_times'] as List<Duration>).add(responseTime);
      }

      _logger.d('📊 تتبع طلب اقتراح - Tracked suggestion request: $language');
    } catch (e) {
      _logger.e('❌ خطأ في تتبع الطلب - Tracking error: $e');
    }
  }

  /// تسجيل عرض اقتراحات - Track suggestions shown
  void trackSuggestionsShown({required int count, required String language}) {
    _ensureInitialized();

    try {
      for (int i = 0; i < count; i++) {
        _statistics!.incrementShown();
      }

      _sessionStats['suggestions_shown'] =
          (_sessionStats['suggestions_shown'] as int) + count;

      _logger.d('📊 تتبع عرض $count اقتراح - Tracked $count suggestions shown');
    } catch (e) {
      _logger.e('❌ خطأ في تتبع العرض - Tracking error: $e');
    }
  }

  /// تسجيل قبول اقتراح - Track suggestion accepted
  void trackSuggestionAccepted(SuggestionModel suggestion) {
    _ensureInitialized();

    try {
      _statistics!.incrementAccepted();
      _sessionStats['suggestions_accepted'] =
          (_sessionStats['suggestions_accepted'] as int) + 1;

      // حساب الوقت الموفر (تقدير) - Calculate saved time (estimate)
      final savedTime = _estimateSavedTime(suggestion);
      _statistics!.totalUsageTimeInSeconds += savedTime;

      _logger.d(
        '✅ تتبع قبول اقتراح - Tracked suggestion accepted: ${suggestion.type}',
      );
    } catch (e) {
      _logger.e('❌ خطأ في تتبع القبول - Tracking error: $e');
    }
  }

  /// تسجيل رفض اقتراح - Track suggestion rejected
  void trackSuggestionRejected(SuggestionModel suggestion) {
    _ensureInitialized();

    try {
      _statistics!.incrementRejected();
      _sessionStats['suggestions_rejected'] =
          (_sessionStats['suggestions_rejected'] as int) + 1;

      _logger.d(
        '❌ تتبع رفض اقتراح - Tracked suggestion rejected: ${suggestion.type}',
      );
    } catch (e) {
      _logger.e('❌ خطأ في تتبع الرفض - Tracking error: $e');
    }
  }

  /// تسجيل خطأ - Track error
  void trackError(String errorType, String errorMessage) {
    _ensureInitialized();

    try {
      _statistics!.incrementErrors();
      _sessionStats['errors'] = (_sessionStats['errors'] as int) + 1;

      _logger.d('❌ تتبع خطأ - Tracked error: $errorType');
    } catch (e) {
      _logger.e('❌ خطأ في تتبع الخطأ - Error tracking error: $e');
    }
  }

  // ==================== التحليلات - Analytics ====================

  /// الحصول على الإحصائيات - Get statistics
  UsageStatistics? getStatistics() {
    _ensureInitialized();
    return _statistics;
  }

  /// الحصول على إحصائيات الجلسة - Get session statistics
  Map<String, dynamic> getSessionStatistics() {
    _ensureInitialized();

    final sessionDuration = DateTime.now().difference(
      _sessionStats['session_start'] as DateTime,
    );

    return {
      'session_duration': sessionDuration.inMinutes,
      'suggestions_shown': _sessionStats['suggestions_shown'],
      'suggestions_accepted': _sessionStats['suggestions_accepted'],
      'suggestions_rejected': _sessionStats['suggestions_rejected'],
      'api_requests': _sessionStats['api_requests'],
      'errors': _sessionStats['errors'],
      'languages_used': (_sessionStats['languages_used'] as Set<String>)
          .toList(),
      'average_response_time': _calculateAverageResponseTime(),
      'acceptance_rate': _calculateSessionAcceptanceRate(),
    };
  }

  /// حساب متوسط وقت الاستجابة - Calculate average response time
  double _calculateAverageResponseTime() {
    final responseTimes = _sessionStats['response_times'] as List<Duration>;

    if (responseTimes.isEmpty) return 0.0;

    final totalMs = responseTimes.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );

    return totalMs / responseTimes.length;
  }

  /// حساب معدل القبول في الجلسة - Calculate session acceptance rate
  double _calculateSessionAcceptanceRate() {
    final shown = _sessionStats['suggestions_shown'] as int;
    final accepted = _sessionStats['suggestions_accepted'] as int;

    if (shown == 0) return 0.0;

    return (accepted / shown) * 100;
  }

  /// تقدير الوقت الموفر - Estimate saved time
  /// بناءً على نوع وطول الاقتراح
  /// Based on suggestion type and length
  int _estimateSavedTime(SuggestionModel suggestion) {
    // تقدير بسيط: حرف واحد = 0.1 ثانية كتابة
    // Simple estimate: 1 character = 0.1 seconds typing
    final baseTime = (suggestion.text.length * 0.1).round();

    // مضاعفات حسب النوع - Multipliers by type
    switch (suggestion.type) {
      case SuggestionType.function:
        return baseTime * 3; // دالة كاملة توفر وقتاً أكثر
      case SuggestionType.classCompletion:
        return baseTime * 4; // فئة كاملة توفر وقتاً أكثر
      case SuggestionType.multiLine:
        return baseTime * 2;
      case SuggestionType.documentation:
        return baseTime * 2;
      default:
        return baseTime;
    }
  }

  /// الحصول على تحليلات مفصلة - Get detailed analytics
  Map<String, dynamic> getDetailedAnalytics() {
    _ensureInitialized();

    if (_statistics == null) {
      return {};
    }

    return {
      // إحصائيات عامة - General statistics
      'total_suggestions_shown': _statistics!.totalSuggestionsShown,
      'total_suggestions_accepted': _statistics!.totalSuggestionsAccepted,
      'total_suggestions_rejected': _statistics!.totalSuggestionsRejected,
      'total_api_requests': _statistics!.totalApiRequests,
      'total_errors': _statistics!.totalErrors,

      // معدلات - Rates
      'acceptance_rate': (_statistics!.acceptanceRate * 100).toStringAsFixed(1),
      'rejection_rate': (_statistics!.rejectionRate * 100).toStringAsFixed(1),

      // أوقات - Times
      'estimated_time_saved_minutes':
          (_statistics!.totalUsageTimeInSeconds / 60).toStringAsFixed(1),
      'total_usage_time_hours': (_statistics!.totalUsageTimeInSeconds / 3600)
          .toStringAsFixed(1),

      // معلومات الجلسة - Session info
      'start_time': _statistics!.startTime.toIso8601String(),
      'last_usage_time': _statistics!.lastUsageTime.toIso8601String(),

      // إحصائيات الجلسة الحالية - Current session
      'session_statistics': getSessionStatistics(),
    };
  }

  /// توليد تقرير نصي - Generate text report
  String generateReport() {
    _ensureInitialized();

    if (_statistics == null) {
      return 'لا توجد إحصائيات متاحة - No statistics available';
    }

    final analytics = getDetailedAnalytics();
    final buffer = StringBuffer();

    buffer.writeln('📊 تقرير إحصائيات GitHub Copilot');
    buffer.writeln('📊 GitHub Copilot Statistics Report');
    buffer.writeln('=' * 50);
    buffer.writeln();

    buffer.writeln('📈 الإحصائيات العامة - General Statistics');
    buffer.writeln(
      '- الاقتراحات المعروضة - Shown: ${analytics['total_suggestions_shown']}',
    );
    buffer.writeln(
      '- الاقتراحات المقبولة - Accepted: ${analytics['total_suggestions_accepted']}',
    );
    buffer.writeln(
      '- الاقتراحات المرفوضة - Rejected: ${analytics['total_suggestions_rejected']}',
    );
    buffer.writeln('- طلبات API: ${analytics['total_api_requests']}');
    buffer.writeln('- الأخطاء - Errors: ${analytics['total_errors']}');
    buffer.writeln();

    buffer.writeln('📊 المعدلات - Rates');
    buffer.writeln(
      '- معدل القبول - Acceptance Rate: ${analytics['acceptance_rate']}%',
    );
    buffer.writeln(
      '- معدل الرفض - Rejection Rate: ${analytics['rejection_rate']}%',
    );
    buffer.writeln();

    buffer.writeln('⏱️ الأوقات - Times');
    buffer.writeln(
      '- الوقت الموفر - Saved Time: ${analytics['estimated_time_saved_minutes']} دقيقة',
    );
    buffer.writeln(
      '- إجمالي الاستخدام - Total Usage: ${analytics['total_usage_time_hours']} ساعة',
    );
    buffer.writeln();

    final sessionStats =
        analytics['session_statistics'] as Map<String, dynamic>;
    buffer.writeln('🔥 إحصائيات الجلسة الحالية - Current Session');
    buffer.writeln(
      '- مدة الجلسة - Duration: ${sessionStats['session_duration']} دقيقة',
    );
    buffer.writeln(
      '- الاقتراحات المعروضة - Shown: ${sessionStats['suggestions_shown']}',
    );
    buffer.writeln(
      '- معدل القبول - Acceptance: ${sessionStats['acceptance_rate'].toStringAsFixed(1)}%',
    );
    buffer.writeln(
      '- متوسط الاستجابة - Avg Response: ${sessionStats['average_response_time'].toStringAsFixed(0)}ms',
    );
    buffer.writeln();

    buffer.writeln('=' * 50);
    buffer.writeln('تاريخ التقرير - Report Date: ${DateTime.now().toLocal()}');

    return buffer.toString();
  }

  /// تصدير الإحصائيات إلى JSON - Export statistics to JSON
  Map<String, dynamic> exportToJson() {
    _ensureInitialized();

    return {
      'statistics': _statistics?.toJson(),
      'session': getSessionStatistics(),
      'detailed_analytics': getDetailedAnalytics(),
      'export_date': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  // ==================== الصيانة - Maintenance ====================

  /// حفظ الإحصائيات - Save statistics
  Future<bool> _saveStatistics() async {
    _ensureInitialized();

    try {
      if (_statistics != null) {
        final success = await _storage.saveStatistics(_statistics!);

        if (success) {
          _logger.d('💾 تم حفظ الإحصائيات - Statistics saved');
        }

        return success;
      }

      return false;
    } catch (e) {
      _logger.e('❌ خطأ في حفظ الإحصائيات - Save error: $e');
      return false;
    }
  }

  /// حفظ يدوي للإحصائيات - Manual save
  Future<bool> saveNow() async {
    return await _saveStatistics();
  }

  /// إعادة تعيين الإحصائيات - Reset statistics
  Future<void> resetStatistics() async {
    _ensureInitialized();

    try {
      _statistics = UsageStatistics();
      await _storage.saveStatistics(_statistics!);

      // إعادة تعيين إحصائيات الجلسة - Reset session stats
      _sessionStats['session_start'] = DateTime.now();
      _sessionStats['suggestions_shown'] = 0;
      _sessionStats['suggestions_accepted'] = 0;
      _sessionStats['suggestions_rejected'] = 0;
      _sessionStats['api_requests'] = 0;
      _sessionStats['errors'] = 0;
      (_sessionStats['languages_used'] as Set<String>).clear();
      (_sessionStats['response_times'] as List<Duration>).clear();

      _logger.i('🔄 تم إعادة تعيين الإحصائيات - Statistics reset');
    } catch (e) {
      _logger.e('❌ خطأ في إعادة التعيين - Reset error: $e');
    }
  }

  /// التحقق من التهيئة - Ensure initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'خدمة التحليلات غير مهيأة - Analytics service not initialized. استدعي initialize() أولاً - Call initialize() first.',
      );
    }
  }

  /// تنظيف الموارد - Cleanup resources
  void dispose() {
    try {
      _autoSaveTimer?.cancel();
      _saveStatistics();
      _isInitialized = false;
      _logger.i('🧹 تم تنظيف موارد التحليلات - Analytics resources cleaned up');
    } catch (e) {
      _logger.e('❌ خطأ في التنظيف - Disposal error: $e');
    }
  }
}
