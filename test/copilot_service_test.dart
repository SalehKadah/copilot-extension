// اختبارات خدمة GitHub Copilot - GitHub Copilot Service Tests
// اختبارات شاملة لخدمة GitHub Copilot
// Comprehensive tests for GitHub Copilot service

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:copilot_extension/services/github_copilot_service.dart';
import 'package:copilot_extension/models/copilot_settings_model.dart';
import 'package:copilot_extension/models/suggestion_model.dart';

@GenerateMocks([GitHubCopilotService])
void main() {
  group('GitHubCopilotService Tests', () {
    late GitHubCopilotService service;
    late CopilotSettingsModel settings;

    setUp(() {
      // تهيئة الخدمة والإعدادات - Initialize service and settings
      service = GitHubCopilotService();
      settings = CopilotSettingsModel(
        enabled: true,
        apiKey: 'test_api_key_123',
        autoTrigger: true,
        maxSuggestions: 5,
      );
    });

    test(
      'يجب تهيئة الخدمة بنجاح - Should initialize service successfully',
      () async {
        // التهيئة - Initialize
        await service.initialize(settings);

        // التحقق - Verify
        expect(service.isConnected, isTrue);
      },
    );

    test('يجب الحصول على اقتراحات - Should get suggestions', () async {
      // التهيئة - Initialize
      await service.initialize(settings);

      // الطلب - Request
      final suggestions = await service.getSuggestions(
        code: 'function calculate',
        language: 'javascript',
        cursorPosition: 18,
      );

      // التحقق - Verify
      expect(suggestions, isNotEmpty);
      expect(suggestions.first, isA<SuggestionModel>());
    });

    test(
      'يجب التعامل مع الأخطاء بشكل صحيح - Should handle errors correctly',
      () async {
        // إعدادات غير صالحة - Invalid settings
        final invalidSettings = CopilotSettingsModel(
          enabled: true,
          apiKey: '', // مفتاح فارغ - Empty key
        );

        // محاولة التهيئة - Try to initialize
        expect(() => service.initialize(invalidSettings), throwsException);
      },
    );

    test(
      'يجب إلغاء الطلبات المعلقة - Should cancel pending requests',
      () async {
        // التهيئة - Initialize
        await service.initialize(settings);

        // بدء طلب - Start request
        final future = service.getSuggestions(
          code: 'test code',
          language: 'dart',
          cursorPosition: 0,
        );

        // إلغاء - Cancel
        service.cancelAllRequests();

        // التحقق - Verify
        expect(future, completes);
      },
    );
  });

  group('Suggestion Model Tests', () {
    test(
      'يجب إنشاء نموذج اقتراح صحيح - Should create valid suggestion model',
      () {
        // إنشاء - Create
        final suggestion = SuggestionModel(
          id: 'test_1',
          text: 'function test() {}',
          startOffset: 0,
          endOffset: 18,
          language: 'javascript',
          confidence: 0.9,
          type: SuggestionType.function,
        );

        // التحقق - Verify
        expect(suggestion.id, equals('test_1'));
        expect(suggestion.text, equals('function test() {}'));
        expect(suggestion.confidence, equals(0.9));
        expect(suggestion.type, equals(SuggestionType.function));
        expect(suggestion.isAccepted, isFalse);
        expect(suggestion.isRejected, isFalse);
      },
    );

    test(
      'يجب قبول الاقتراح بشكل صحيح - Should accept suggestion correctly',
      () {
        // إنشاء - Create
        final suggestion = SuggestionModel(
          id: 'test_1',
          text: 'code',
          startOffset: 0,
          endOffset: 4,
          language: 'dart',
          confidence: 0.8,
          type: SuggestionType.singleLine,
        );

        // قبول - Accept
        suggestion.accept();

        // التحقق - Verify
        expect(suggestion.isAccepted, isTrue);
        expect(suggestion.isRejected, isFalse);
        expect(suggestion.interactionAt, isNotNull);
      },
    );

    test('يجب رفض الاقتراح بشكل صحيح - Should reject suggestion correctly', () {
      // إنشاء - Create
      final suggestion = SuggestionModel(
        id: 'test_1',
        text: 'code',
        startOffset: 0,
        endOffset: 4,
        language: 'dart',
        confidence: 0.8,
        type: SuggestionType.singleLine,
      );

      // رفض - Reject
      suggestion.reject();

      // التحقق - Verify
      expect(suggestion.isAccepted, isFalse);
      expect(suggestion.isRejected, isTrue);
      expect(suggestion.interactionAt, isNotNull);
    });
  });

  group('Settings Model Tests', () {
    test('يجب إنشاء إعدادات افتراضية - Should create default settings', () {
      // إنشاء - Create
      final settings = CopilotSettingsModel.defaults;

      // التحقق - Verify
      expect(settings.enabled, isTrue);
      expect(settings.autoTrigger, isTrue);
      expect(settings.maxSuggestions, equals(5));
      expect(settings.suggestionDelay, equals(500));
    });

    test('يجب التحقق من صحة الإعدادات - Should validate settings', () {
      // إعدادات صالحة - Valid settings
      final validSettings = CopilotSettingsModel(
        apiKey: 'valid_key',
        maxSuggestions: 5,
        minimumConfidence: 0.5,
      );

      expect(validSettings.validate(), isTrue);

      // إعدادات غير صالحة - Invalid settings
      final invalidSettings = CopilotSettingsModel(
        apiKey: '', // مفتاح فارغ - Empty key
      );

      expect(invalidSettings.validate(), isFalse);
    });
  });
}
