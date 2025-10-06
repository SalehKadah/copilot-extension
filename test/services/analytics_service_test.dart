// اختبارات خدمة الإحصائيات - Analytics Service Tests
// اختبارات شاملة لتتبع الاستخدام والإحصائيات
// Comprehensive tests for usage tracking and analytics

import 'package:flutter_test/flutter_test.dart';
import 'package:copilot_extension/services/analytics_service.dart';
import 'package:copilot_extension/models/copilot_statistics_model.dart';
import 'package:copilot_extension/models/copilot_suggestion_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalyticsService Tests - اختبارات خدمة الإحصائيات', () {
    late AnalyticsService analyticsService;

    setUp(() {
      analyticsService = AnalyticsService();
    });

    tearDown(() async {
      await analyticsService.resetStatistics();
      analyticsService.dispose();
    });

    // ==================== اختبارات تتبع الاقتراحات ====================
    // Suggestion Tracking Tests

    test('تسجيل اقتراح معروض - Track shown suggestion', () {
      final suggestion = CopilotSuggestion(
        id: 'test_1',
        code: 'print("test");',
        language: 'dart',
        type: SuggestionType.singleLine,
        confidence: 0.9,
        timestamp: DateTime.now(),
      );

      analyticsService.trackSuggestionShown(suggestion);

      final stats = analyticsService.getStatistics();
      expect(stats, isNotNull);
      expect(stats!.totalSuggestionsShown, equals(1));
    });

    test('تسجيل اقتراح مقبول - Track accepted suggestion', () {
      final suggestion = CopilotSuggestion(
        id: 'test_1',
        code: 'print("test");',
        language: 'dart',
        type: SuggestionType.singleLine,
        confidence: 0.9,
        timestamp: DateTime.now(),
      );

      analyticsService.trackSuggestionShown(suggestion);
      analyticsService.trackSuggestionAccepted(suggestion);

      final stats = analyticsService.getStatistics();
      expect(stats!.totalSuggestionsAccepted, equals(1));
    });

    test('تسجيل اقتراح مرفوض - Track rejected suggestion', () {
      final suggestion = CopilotSuggestion(
        id: 'test_1',
        code: 'print("test");',
        language: 'dart',
        type: SuggestionType.singleLine,
        confidence: 0.9,
        timestamp: DateTime.now(),
      );

      analyticsService.trackSuggestionShown(suggestion);
      analyticsService.trackSuggestionRejected(suggestion);

      final stats = analyticsService.getStatistics();
      expect(stats!.totalSuggestionsShown, equals(1));
    });

    test(
      'حساب معدل القبول بشكل صحيح - Calculate acceptance rate correctly',
      () {
        final suggestions = List.generate(
          10,
          (i) => CopilotSuggestion(
            id: 'test_$i',
            code: 'code_$i',
            language: 'dart',
            type: SuggestionType.singleLine,
            confidence: 0.8,
            timestamp: DateTime.now(),
          ),
        );

        // عرض 10 اقتراحات - Show 10 suggestions
        for (final suggestion in suggestions) {
          analyticsService.trackSuggestionShown(suggestion);
        }

        // قبول 5 منها - Accept 5 of them
        for (int i = 0; i < 5; i++) {
          analyticsService.trackSuggestionAccepted(suggestions[i]);
        }

        final stats = analyticsService.getStatistics();
        expect(stats!.acceptanceRate, equals(0.5));
      },
    );

    // ==================== اختبارات إحصائيات اللغات ====================
    // Language Statistics Tests

    test('تتبع إحصائيات لغة واحدة - Track single language stats', () {
      final suggestion = CopilotSuggestion(
        id: 'test_1',
        code: 'print("test");',
        language: 'dart',
        type: SuggestionType.singleLine,
        confidence: 0.9,
        timestamp: DateTime.now(),
      );

      analyticsService.trackSuggestionShown(suggestion);
      analyticsService.trackSuggestionAccepted(suggestion);

      final stats = analyticsService.getStatistics();
      expect(stats!.languageStats.containsKey('dart'), isTrue);
      expect(stats.languageStats['dart']!.totalSuggestions, equals(1));
      expect(stats.languageStats['dart']!.acceptedSuggestions, equals(1));
    });

    test('تتبع إحصائيات عدة لغات - Track multiple language stats', () {
      final languages = ['dart', 'javascript', 'python', 'java'];

      for (final lang in languages) {
        final suggestion = CopilotSuggestion(
          id: 'test_$lang',
          code: 'code',
          language: lang,
          type: SuggestionType.singleLine,
          confidence: 0.8,
          timestamp: DateTime.now(),
        );

        analyticsService.trackSuggestionShown(suggestion);
      }

      final stats = analyticsService.getStatistics();
      for (final lang in languages) {
        expect(stats!.languageStats.containsKey(lang), isTrue);
        expect(stats.languageStats[lang]!.totalSuggestions, equals(1));
      }
    });

    test(
      'معدل قبول مختلف لكل لغة - Different acceptance rate per language',
      () {
        // Dart: 2 معروض، 2 مقبول - 100%
        for (int i = 0; i < 2; i++) {
          final s = CopilotSuggestion(
            id: 'dart_$i',
            code: 'code',
            language: 'dart',
            type: SuggestionType.singleLine,
            confidence: 0.9,
            timestamp: DateTime.now(),
          );
          analyticsService.trackSuggestionShown(s);
          analyticsService.trackSuggestionAccepted(s);
        }

        // Python: 4 معروض، 2 مقبول - 50%
        for (int i = 0; i < 4; i++) {
          final s = CopilotSuggestion(
            id: 'python_$i',
            code: 'code',
            language: 'python',
            type: SuggestionType.singleLine,
            confidence: 0.8,
            timestamp: DateTime.now(),
          );
          analyticsService.trackSuggestionShown(s);
          if (i < 2) {
            analyticsService.trackSuggestionAccepted(s);
          }
        }

        final stats = analyticsService.getStatistics();
        expect(stats!.languageStats['dart']!.acceptanceRate, equals(1.0));
        expect(stats.languageStats['python']!.acceptanceRate, equals(0.5));
      },
    );

    // ==================== اختبارات الإحصائيات اليومية ====================
    // Daily Statistics Tests

    test('تسجيل إحصائيات يومية - Record daily statistics', () {
      final suggestion = CopilotSuggestion(
        id: 'test_1',
        code: 'code',
        language: 'dart',
        type: SuggestionType.singleLine,
        confidence: 0.9,
        timestamp: DateTime.now(),
      );

      analyticsService.trackSuggestionShown(suggestion);

      final stats = analyticsService.getStatistics();
      expect(stats!.dailyStats.isNotEmpty, isTrue);
    });

    test('تجميع إحصائيات نفس اليوم - Aggregate same day statistics', () {
      final today = DateTime.now();

      for (int i = 0; i < 5; i++) {
        final suggestion = CopilotSuggestion(
          id: 'test_$i',
          code: 'code',
          language: 'dart',
          type: SuggestionType.singleLine,
          confidence: 0.9,
          timestamp: today,
        );

        analyticsService.trackSuggestionShown(suggestion);
      }

      final stats = analyticsService.getStatistics();
      final todayStats = stats!.dailyStats.first;
      expect(todayStats.suggestionsShown, equals(5));
    });

    // ==================== اختبارات طلبات API ====================
    // API Request Tests

    test('تتبع طلبات API الناجحة - Track successful API requests', () {
      analyticsService.trackApiRequest(success: true, responseTime: 100);

      final stats = analyticsService.getStatistics();
      expect(stats!.totalApiRequests, equals(1));
    });

    test('تتبع طلبات API الفاشلة - Track failed API requests', () {
      analyticsService.trackApiRequest(success: false, responseTime: 5000);

      final stats = analyticsService.getStatistics();
      expect(stats!.totalApiRequests, equals(1));
    });

    test('حساب معدل نجاح API - Calculate API success rate', () {
      // 7 ناجح، 3 فاشل = 70%
      for (int i = 0; i < 7; i++) {
        analyticsService.trackApiRequest(success: true, responseTime: 100);
      }
      for (int i = 0; i < 3; i++) {
        analyticsService.trackApiRequest(success: false, responseTime: 5000);
      }

      final stats = analyticsService.getStatistics();
      expect(stats!.apiSuccessRate, equals(0.7));
    });

    test('حساب متوسط وقت الاستجابة - Calculate average response time', () {
      analyticsService.trackApiRequest(success: true, responseTime: 100);
      analyticsService.trackApiRequest(success: true, responseTime: 200);
      analyticsService.trackApiRequest(success: true, responseTime: 300);

      final stats = analyticsService.getStatistics();
      expect(stats!.averageResponseTime, equals(200));
    });

    // ==================== اختبارات الذاكرة المؤقتة ====================
    // Cache Statistics Tests

    test('تتبع إصابات الذاكرة المؤقتة - Track cache hits', () {
      analyticsService.trackCacheHit();
      analyticsService.trackCacheHit();
      analyticsService.trackCacheHit();

      final stats = analyticsService.getStatistics();
      expect(stats!.cacheHits, equals(3));
    });

    test('تتبع أخطاء الذاكرة المؤقتة - Track cache misses', () {
      analyticsService.trackCacheMiss();
      analyticsService.trackCacheMiss();

      final stats = analyticsService.getStatistics();
      expect(stats!.cacheMisses, equals(2));
    });

    test('حساب معدل إصابة الذاكرة المؤقتة - Calculate cache hit rate', () {
      // 8 إصابات، 2 أخطاء = 80%
      for (int i = 0; i < 8; i++) {
        analyticsService.trackCacheHit();
      }
      for (int i = 0; i < 2; i++) {
        analyticsService.trackCacheMiss();
      }

      final stats = analyticsService.getStatistics();
      expect(stats!.cacheHitRate, equals(0.8));
    });

    test('تحديث حجم الذاكرة المؤقتة - Update cache size', () {
      analyticsService.updateCacheSize(150);

      final stats = analyticsService.getStatistics();
      expect(stats!.cacheSize, equals(150));
    });

    // ==================== اختبارات التصدير ====================
    // Export Tests

    test('تصدير تقرير كامل - Export complete report', () async {
      // إضافة بيانات - Add data
      final suggestion = CopilotSuggestion(
        id: 'test_1',
        code: 'code',
        language: 'dart',
        type: SuggestionType.singleLine,
        confidence: 0.9,
        timestamp: DateTime.now(),
      );

      analyticsService.trackSuggestionShown(suggestion);
      analyticsService.trackSuggestionAccepted(suggestion);
      analyticsService.trackApiRequest(success: true, responseTime: 100);

      final report = await analyticsService.exportReport();

      expect(report, isNotNull);
      expect(report.isNotEmpty, isTrue);
    });

    test('تنسيق التقرير بشكل صحيح - Report is formatted correctly', () async {
      final suggestion = CopilotSuggestion(
        id: 'test_1',
        code: 'code',
        language: 'dart',
        type: SuggestionType.singleLine,
        confidence: 0.9,
        timestamp: DateTime.now(),
      );

      analyticsService.trackSuggestionShown(suggestion);

      final report = await analyticsService.exportReport();

      expect(report.contains('Copilot'), isTrue);
      expect(report.contains('Statistics'), isTrue);
    });

    // ==================== اختبارات إعادة التعيين ====================
    // Reset Tests

    test('إعادة تعيين جميع الإحصائيات - Reset all statistics', () async {
      // إضافة بيانات - Add data
      final suggestion = CopilotSuggestion(
        id: 'test_1',
        code: 'code',
        language: 'dart',
        type: SuggestionType.singleLine,
        confidence: 0.9,
        timestamp: DateTime.now(),
      );

      analyticsService.trackSuggestionShown(suggestion);
      analyticsService.trackSuggestionAccepted(suggestion);
      analyticsService.trackApiRequest(success: true, responseTime: 100);

      // إعادة تعيين - Reset
      await analyticsService.resetStatistics();

      final stats = analyticsService.getStatistics();
      expect(stats, isNull);
    });

    // ==================== اختبارات الأداء ====================
    // Performance Tests

    test('تتبع 1000 اقتراح بسرعة - Track 1000 suggestions quickly', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        final suggestion = CopilotSuggestion(
          id: 'test_$i',
          code: 'code',
          language: 'dart',
          type: SuggestionType.singleLine,
          confidence: 0.9,
          timestamp: DateTime.now(),
        );

        analyticsService.trackSuggestionShown(suggestion);
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('الحصول على الإحصائيات بسرعة - Get statistics quickly', () {
      // إضافة بيانات - Add data
      for (int i = 0; i < 100; i++) {
        final suggestion = CopilotSuggestion(
          id: 'test_$i',
          code: 'code',
          language: 'dart',
          type: SuggestionType.singleLine,
          confidence: 0.9,
          timestamp: DateTime.now(),
        );
        analyticsService.trackSuggestionShown(suggestion);
      }

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        analyticsService.getStatistics();
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    // ==================== اختبارات التكامل ====================
    // Integration Tests

    test('سيناريو استخدام كامل - Complete usage scenario', () {
      // Day 1: عرض وقبول اقتراحات - Show and accept suggestions
      for (int i = 0; i < 10; i++) {
        final suggestion = CopilotSuggestion(
          id: 'day1_$i',
          code: 'code',
          language: 'dart',
          type: SuggestionType.singleLine,
          confidence: 0.9,
          timestamp: DateTime.now(),
        );

        analyticsService.trackSuggestionShown(suggestion);

        if (i % 2 == 0) {
          analyticsService.trackSuggestionAccepted(suggestion);
        }
      }

      // طلبات API - API requests
      for (int i = 0; i < 5; i++) {
        analyticsService.trackApiRequest(
          success: i < 4,
          responseTime: 100 + (i * 50),
        );
      }

      // الذاكرة المؤقتة - Cache
      for (int i = 0; i < 8; i++) {
        analyticsService.trackCacheHit();
      }
      for (int i = 0; i < 2; i++) {
        analyticsService.trackCacheMiss();
      }

      // التحقق - Verify
      final stats = analyticsService.getStatistics();

      expect(stats!.totalSuggestionsShown, equals(10));
      expect(stats.totalSuggestionsAccepted, equals(5));
      expect(stats.acceptanceRate, equals(0.5));
      expect(stats.totalApiRequests, equals(5));
      expect(stats.apiSuccessRate, equals(0.8));
      expect(stats.cacheHits, equals(8));
      expect(stats.cacheMisses, equals(2));
      expect(stats.cacheHitRate, equals(0.8));
    });

    // ==================== اختبارات معالجة الأخطاء ====================
    // Error Handling Tests

    test('التعامل مع قيم null - Handle null values', () {
      expect(() => analyticsService.getStatistics(), returnsNormally);
    });

    test('التعامل مع تواريخ غير صالحة - Handle invalid dates', () {
      final suggestion = CopilotSuggestion(
        id: 'test',
        code: 'code',
        language: 'dart',
        type: SuggestionType.singleLine,
        confidence: 0.9,
        timestamp: DateTime(1900), // تاريخ قديم جداً
      );

      expect(
        () => analyticsService.trackSuggestionShown(suggestion),
        returnsNormally,
      );
    });

    test(
      'التعامل مع قيم سالبة في وقت الاستجابة - Handle negative response times',
      () {
        expect(
          () => analyticsService.trackApiRequest(
            success: true,
            responseTime: -100,
          ),
          returnsNormally,
        );
      },
    );
  });
}
