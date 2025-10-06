// اختبارات خدمة التخزين - Storage Service Tests
// اختبارات شاملة لإدارة التخزين والإعدادات
// Comprehensive tests for storage and settings management

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:copilot_extension/services/storage_service.dart';
import 'package:copilot_extension/models/copilot_settings_model.dart';
import 'package:copilot_extension/models/copilot_suggestion_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService Tests - اختبارات خدمة التخزين', () {
    late StorageService storageService;

    setUp(() async {
      // إعداد SharedPreferences للاختبار
      // Setup SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      await storageService.initialize();
    });

    tearDown(() async {
      await storageService.clearAll();
      storageService.dispose();
    });

    // ==================== اختبارات حفظ وتحميل الإعدادات ====================
    // Settings Save & Load Tests

    test('حفظ الإعدادات بنجاح - Save settings successfully', () async {
      final settings = CopilotSettingsModel(
        enabled: true,
        apiKey: 'test_api_key_123',
        maxSuggestions: 10,
        suggestionDelay: 500,
        autoTrigger: true,
        minimumConfidence: 0.7,
      );

      final result = await storageService.saveSettings(settings);

      expect(result, isTrue);
    });

    test('تحميل الإعدادات بنجاح - Load settings successfully', () async {
      final originalSettings = CopilotSettingsModel(
        enabled: true,
        apiKey: 'test_key',
        maxSuggestions: 5,
      );

      await storageService.saveSettings(originalSettings);
      final loadedSettings = await storageService.loadSettings();

      expect(loadedSettings, isNotNull);
      expect(loadedSettings!.enabled, originalSettings.enabled);
      expect(loadedSettings.apiKey, originalSettings.apiKey);
      expect(loadedSettings.maxSuggestions, originalSettings.maxSuggestions);
    });

    test('تحميل إعدادات افتراضية عند عدم وجود بيانات - Load defaults when no data', () async {
      final settings = await storageService.loadSettings();

      // يجب أن يعيد null أو إعدادات افتراضية
      // Should return null or default settings
      expect(settings, isA<CopilotSettingsModel?>());
    });

    test('تحديث إعدادات موجودة - Update existing settings', () async {
      final settings1 = CopilotSettingsModel(
        enabled: true,
        maxSuggestions: 5,
      );

      await storageService.saveSettings(settings1);

      final settings2 = CopilotSettingsModel(
        enabled: false,
        maxSuggestions: 10,
      );

      await storageService.saveSettings(settings2);

      final loaded = await storageService.loadSettings();
      expect(loaded!.enabled, settings2.enabled);
      expect(loaded.maxSuggestions, settings2.maxSuggestions);
    });

    // ==================== اختبارات حفظ الاقتراحات ====================
    // Suggestions Storage Tests

    test('حفظ اقتراح واحد - Save single suggestion', () async {
      final suggestion = CopilotSuggestion(
        id: 'test_1',
        code: 'print("Hello");',
        language: 'dart',
        type: SuggestionType.singleLine,
        confidence: 0.95,
        timestamp: DateTime.now(),
      );

      final result = await storageService.saveSuggestion(suggestion);

      expect(result, isTrue);
    });

    test('حفظ عدة اقتراحات - Save multiple suggestions', () async {
      final suggestions = List.generate(
        5,
        (i) => CopilotSuggestion(
          id: 'test_$i',
          code: 'code_$i',
          language: 'dart',
          type: SuggestionType.singleLine,
          confidence: 0.8 + (i * 0.02),
          timestamp: DateTime.now(),
        ),
      );

      final result = await storageService.saveSuggestions(suggestions);

      expect(result, isTrue);
    });

    test('تحميل الاقتراحات المحفوظة - Load saved suggestions', () async {
      final suggestions = List.generate(
        3,
        (i) => CopilotSuggestion(
          id: 'test_$i',
          code: 'code_$i',
          language: 'dart',
          type: SuggestionType.singleLine,
          confidence: 0.9,
          timestamp: DateTime.now(),
        ),
      );

      await storageService.saveSuggestions(suggestions);
      final loaded = await storageService.loadSuggestions();

      expect(loaded.length, suggestions.length);
    });

    test('حذف اقتراح محدد - Delete specific suggestion', () async {
      final suggestion = CopilotSuggestion(
        id: 'to_delete',
        code: 'test',
        language: 'dart',
        type: SuggestionType.singleLine,
        confidence: 0.8,
        timestamp: DateTime.now(),
      );

      await storageService.saveSuggestion(suggestion);
      final result = await storageService.deleteSuggestion('to_delete');

      expect(result, isTrue);

      final remaining = await storageService.loadSuggestions();
      expect(remaining.where((s) => s.id == 'to_delete').isEmpty, isTrue);
    });

    // ==================== اختبارات القيم المخصصة ====================
    // Custom Values Tests

    test('حفظ واسترجاع قيمة نصية - Save and retrieve string value', () async {
      const key = 'test_string';
      const value = 'Hello, World!';

      await storageService.saveString(key, value);
      final retrieved = await storageService.getString(key);

      expect(retrieved, value);
    });

    test('حفظ واسترجاع قيمة رقمية - Save and retrieve int value', () async {
      const key = 'test_int';
      const value = 42;

      await storageService.saveInt(key, value);
      final retrieved = await storageService.getInt(key);

      expect(retrieved, value);
    });

    test('حفظ واسترجاع قيمة boolean - Save and retrieve bool value', () async {
      const key = 'test_bool';
      const value = true;

      await storageService.saveBool(key, value);
      final retrieved = await storageService.getBool(key);

      expect(retrieved, value);
    });

    test('حفظ واسترجاع قيمة double - Save and retrieve double value', () async {
      const key = 'test_double';
      const value = 3.14159;

      await storageService.saveDouble(key, value);
      final retrieved = await storageService.getDouble(key);

      expect(retrieved, value);
    });

    test('حفظ واسترجاع قائمة نصية - Save and retrieve string list', () async {
      const key = 'test_list';
      const value = ['item1', 'item2', 'item3'];

      await storageService.saveStringList(key, value);
      final retrieved = await storageService.getStringList(key);

      expect(retrieved, value);
    });

    // ==================== اختبارات الحذف والمسح ====================
    // Delete & Clear Tests

    test('حذف مفتاح محدد - Delete specific key', () async {
      const key = 'to_delete';
      await storageService.saveString(key, 'value');

      final deleted = await storageService.delete(key);
      expect(deleted, isTrue);

      final retrieved = await storageService.getString(key);
      expect(retrieved, isNull);
    });

    test('مسح جميع البيانات - Clear all data', () async {
      await storageService.saveString('key1', 'value1');
      await storageService.saveInt('key2', 123);
      await storageService.saveBool('key3', true);

      final cleared = await storageService.clearAll();
      expect(cleared, isTrue);

      expect(await storageService.getString('key1'), isNull);
      expect(await storageService.getInt('key2'), isNull);
      expect(await storageService.getBool('key3'), isNull);
    });

    // ==================== اختبارات التحقق من الوجود ====================
    // Existence Check Tests

    test('التحقق من وجود مفتاح - Check if key exists', () async {
      const key = 'existing_key';
      await storageService.saveString(key, 'value');

      expect(await storageService.containsKey(key), isTrue);
      expect(await storageService.containsKey('non_existing'), isFalse);
    });

    test('الحصول على جميع المفاتيح - Get all keys', () async {
      await storageService.saveString('key1', 'value1');
      await storageService.saveInt('key2', 123);

      final keys = await storageService.getAllKeys();

      expect(keys.contains('key1'), isTrue);
      expect(keys.contains('key2'), isTrue);
    });

    // ==================== اختبارات حجم التخزين ====================
    // Storage Size Tests

    test('حساب حجم التخزين - Calculate storage size', () async {
      await storageService.saveString('key1', 'short');
      await storageService.saveString('key2', 'a' * 1000);

      final size = await storageService.getStorageSize();

      expect(size, greaterThan(0));
    });

    // ==================== اختبارات الأداء ====================
    // Performance Tests

    test('حفظ 100 إعداد بسرعة - Save 100 settings quickly', () async {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        await storageService.saveString('key_$i', 'value_$i');
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('تحميل 100 إعداد بسرعة - Load 100 settings quickly', () async {
      // تحضير البيانات - Prepare data
      for (int i = 0; i < 100; i++) {
        await storageService.saveString('key_$i', 'value_$i');
      }

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        await storageService.getString('key_$i');
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });

    // ==================== اختبارات التكامل ====================
    // Integration Tests

    test('تدفق كامل: حفظ -> تحميل -> تعديل -> حذف', () async {
      // حفظ - Save
      final settings = CopilotSettingsModel(
        enabled: true,
        apiKey: 'test',
      );
      await storageService.saveSettings(settings);

      // تحميل - Load
      var loaded = await storageService.loadSettings();
      expect(loaded!.enabled, isTrue);

      // تعديل - Modify
      final modified = loaded.copyWith(enabled: false);
      await storageService.saveSettings(modified);

      // تحقق من التعديل - Verify modification
      loaded = await storageService.loadSettings();
      expect(loaded!.enabled, isFalse);

      // حذف - Delete
      await storageService.clearAll();
      loaded = await storageService.loadSettings();
      expect(loaded, isNull);
    });

    // ==================== اختبارات معالجة الأخطاء ====================
    // Error Handling Tests

    test('التعامل مع قيم null - Handle null values', () async {
      final nullString = await storageService.getString('non_existent');
      final nullInt = await storageService.getInt('non_existent');
      final nullBool = await storageService.getBool('non_existent');

      expect(nullString, isNull);
      expect(nullInt, isNull);
      expect(nullBool, isNull);
    });

    test('التعامل مع مفاتيح فارغة - Handle empty keys', () async {
      expect(
        () => storageService.saveString('', 'value'),
        returnsNormally,
      );
    });

    // ==================== اختبارات التصدير والاستيراد ====================
    // Export & Import Tests

    test('تصدير جميع البيانات - Export all data', () async {
      await storageService.saveString('key1', 'value1');
      await storageService.saveInt('key2', 123);

      final exported = await storageService.exportData();

      expect(exported, isA<Map<String, dynamic>>());
      expect(exported.isNotEmpty, isTrue);
    });

    test('استيراد البيانات - Import data', () async {
      final data = {
        'key1': 'value1',
        'key2': 123,
        'key3': true,
      };

      await storageService.importData(data);

      expect(await storageService.getString('key1'), 'value1');
      expect(await storageService.getInt('key2'), 123);
      expect(await storageService.getBool('key3'), true);
    });
  });

  // ==================== اختبارات الأداء المتقدمة ====================
  // Advanced Performance Tests

  group('Advanced Performance Tests', () {
    late StorageService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = StorageService();
      await service.initialize();
    });

    tearDown(() async {
      await service.clearAll();
      service.dispose();
    });

    test('عمليات متزامنة - Concurrent operations', () async {
      final futures = <Future>[];

      for (int i = 0; i < 50; i++) {
        futures.add(service.saveString('concurrent_$i', 'value_$i'));
      }

      await Future.wait(futures);

      for (int i = 0; i < 50; i++) {
        final value = await service.getString('concurrent_$i');
        expect(value, 'value_$i');
      }
    });

    test('حجم بيانات كبير - Large data size', () async {
      final largeString = 'x' * 100000; // 100KB

      final stopwatch = Stopwatch()..start();
      await service.saveString('large_data', largeString);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      final retrieved = await service.getString('large_data');
      expect(retrieved, largeString);
    });
  });
}
