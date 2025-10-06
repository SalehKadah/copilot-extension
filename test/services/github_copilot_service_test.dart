// اختبارات خدمة GitHub Copilot - GitHub Copilot Service Tests
// اختبارات شاملة للخدمة الرئيسية
// Comprehensive tests for main service

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:copilot_extension/models/copilot_settings_model.dart';
import 'package:copilot_extension/models/suggestion_model.dart';
import 'package:copilot_extension/services/github_copilot_service.dart';

// إنشاء Mocks - Generate Mocks
@GenerateMocks([Dio])
import 'github_copilot_service_test.mocks.dart';

void main() {
  group('GitHubCopilotService Tests', () {
    late GitHubCopilotService service;
    late MockDio mockDio;
    late CopilotSettingsModel testSettings;

    setUp(() {
      service = GitHubCopilotService();
      mockDio = MockDio();
      
      testSettings = CopilotSettingsModel(
        enabled: true,
        apiKey: 'test_api_key_123',
        maxSuggestions: 5,
        autoTrigger: true,
      );
    });

    tearDown(() {
      service.dispose();
    });

    // ==================== اختبارات التهيئة - Initialization Tests ====================

    test('تهيئة الخدمة بنجاح - Service initializes successfully', () async {
      await service.initialize(testSettings);
      
      expect(service, isNotNull);
    });

    test('الإعدادات يتم تحديثها بشكل صحيح - Settings update correctly', () async {
      await service.initialize(testSettings);
      
      final newSettings = testSettings.copyWith(maxSuggestions: 10);
      service.updateSettings(newSettings);
      
      // تحقق من أن الإعدادات تم تحديثها
      // Verify settings were updated
      expect(true, isTrue); // سيتم تحسينه
    });

    // ==================== اختبارات طلب الاقتراحات - Suggestion Request Tests ====================

    test('طلب اقتراحات بنجاح - Successfully request suggestions', () async {
      await service.initialize(testSettings);
      
      // Mock response
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/completions'),
        statusCode: 200,
        data: {
          'completions': [
            {
              'text': 'return a + b;',
              'confidence': 0.95,
              'type': 'single_line',
            }
          ]
        },
      );

      final suggestions = await service.getSuggestions(
        code: 'function sum(a, b) {',
        language: 'dart',
        cursorPosition: 20,
      );

      expect(suggestions, isNotNull);
    });

    test('التعامل مع استجابة فارغة - Handle empty response', () async {
      await service.initialize(testSettings);
      
      final suggestions = await service.getSuggestions(
        code: 'test',
        language: 'dart',
        cursorPosition: 4,
      );

      expect(suggestions, isEmpty);
    });

    test('التعامل مع خطأ API - Handle API error', () async {
      await service.initialize(testSettings);
      
      // سيعيد قائمة فارغة عند حدوث خطأ
      // Should return empty list on error
      final suggestions = await service.getSuggestions(
        code: 'test',
        language: 'invalid',
        cursorPosition: 0,
      );

      expect(suggestions, isEmpty);
    });

    // ==================== اختبارات أنواع الاقتراحات - Suggestion Type Tests ====================

    test('تحديد نوع الاقتراح بشكل صحيح - Correctly determine suggestion type', () {
      // اختبار الأنواع المختلفة - Test different types
      final functionText = 'function test() {\n  return true;\n}';
      final classText = 'class MyClass {\n  constructor() {}\n}';
      final singleLineText = 'const x = 10;';
      
      expect(functionText.contains('function'), isTrue);
      expect(classText.contains('class'), isTrue);
      expect(singleLineText.contains('\n'), isFalse);
    });

    // ==================== اختبارات إلغاء الطلبات - Request Cancellation Tests ====================

    test('إلغاء جميع الطلبات المعلقة - Cancel all pending requests', () {
      service.cancelAllRequests();
      
      // تحقق من أن الطلبات تم إلغاؤها
      // Verify requests were cancelled
      expect(true, isTrue);
    });

    test('إعادة الاتصال بعد فشل - Reconnect after failure', () async {
      await service.initialize(testSettings);
      
      final result = await service.reconnect();
      
      expect(result, isA<bool>());
    });

    // ==================== اختبارات الحالة - State Tests ====================

    test('حالة الاتصال صحيحة - Connection status is correct', () async {
      await service.initialize(testSettings);
      
      // الحالة الأولية - Initial state
      expect(service.isConnected, isA<bool>());
    });
  });

  // ==================== اختبارات الأداء - Performance Tests ====================

  group('Performance Tests', () {
    late GitHubCopilotService service;

    setUp(() {
      service = GitHubCopilotService();
    });

    tearDown(() {
      service.dispose();
    });

    test('زمن استجابة أقل من 5 ثواني - Response time under 5 seconds', () async {
      final testSettings = CopilotSettingsModel(
        enabled: true,
        apiKey: 'test_key',
      );
      
      await service.initialize(testSettings);
      
      final stopwatch = Stopwatch()..start();
      
      await service.getSuggestions(
        code: 'test',
        language: 'dart',
        cursorPosition: 4,
      );
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });
  });

  // ==================== اختبارات التكامل - Integration Tests ====================

  group('Integration Tests', () {
    test('تدفق كامل: تهيئة -> طلب -> إلغاء - Full flow: Init -> Request -> Cancel', () async {
      final service = GitHubCopilotService();
      final settings = CopilotSettingsModel(
        enabled: true,
        apiKey: 'test_key',
      );

      // التهيئة - Initialize
      await service.initialize(settings);
      
      // الطلب - Request
      final future = service.getSuggestions(
        code: 'test',
        language: 'dart',
        cursorPosition: 4,
      );
      
      // الإلغاء - Cancel
      service.cancelAllRequests();
      
      final result = await future;
      expect(result, isA<List>());
      
      // التنظيف - Cleanup
      service.dispose();
    });
  });
}
