// اختبارات مدير الأحداث - Event Manager Tests
// اختبارات شاملة لنظام الأحداث
// Comprehensive tests for event system

import 'package:flutter_test/flutter_test.dart';
import 'package:copilot_extension/core/event_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EventManager Tests - اختبارات مدير الأحداث', () {
    late EventManager eventManager;

    setUp(() {
      eventManager = EventManager();
    });

    tearDown(() {
      eventManager.clearHistory();
    });

    // ==================== اختبارات الاشتراك والإطلاق ====================
    // Subscribe & Emit Tests

    test('الاشتراك في حدث وإطلاقه - Subscribe and emit event', () {
      var eventReceived = false;
      CopilotEvent? receivedEvent;

      final unsubscribe = eventManager.subscribe(
        CopilotEventType.suggestionRequested,
        (event) {
          eventReceived = true;
          receivedEvent = event;
        },
      );

      eventManager.emitSimple(CopilotEventType.suggestionRequested);

      expect(eventReceived, isTrue);
      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.type, equals(CopilotEventType.suggestionRequested));

      unsubscribe();
    });

    test('إطلاق حدث مع بيانات - Emit event with data', () {
      Map<String, dynamic>? eventData;

      final unsubscribe = eventManager.subscribe(
        CopilotEventType.textChanged,
        (event) {
          eventData = event.data;
        },
      );

      eventManager.emitSimple(
        CopilotEventType.textChanged,
        {'text': 'Hello World', 'position': 5},
      );

      expect(eventData, isNotNull);
      expect(eventData!['text'], equals('Hello World'));
      expect(eventData!['position'], equals(5));

      unsubscribe();
    });

    test('عدة مشتركين لنفس الحدث - Multiple subscribers for same event', () {
      var count1 = 0;
      var count2 = 0;
      var count3 = 0;

      final unsub1 = eventManager.subscribe(
        CopilotEventType.suggestionShown,
        (_) => count1++,
      );

      final unsub2 = eventManager.subscribe(
        CopilotEventType.suggestionShown,
        (_) => count2++,
      );

      final unsub3 = eventManager.subscribe(
        CopilotEventType.suggestionShown,
        (_) => count3++,
      );

      eventManager.emitSimple(CopilotEventType.suggestionShown);

      expect(count1, equals(1));
      expect(count2, equals(1));
      expect(count3, equals(1));

      unsub1();
      unsub2();
      unsub3();
    });

    test('إلغاء الاشتراك يمنع استقبال الأحداث - Unsubscribe prevents receiving events', () {
      var count = 0;

      final unsubscribe = eventManager.subscribe(
        CopilotEventType.suggestionAccepted,
        (_) => count++,
      );

      eventManager.emitSimple(CopilotEventType.suggestionAccepted);
      expect(count, equals(1));

      unsubscribe();

      eventManager.emitSimple(CopilotEventType.suggestionAccepted);
      expect(count, equals(1)); // لم يزد - Didn't increase
    });

    // ==================== اختبارات الاشتراك المتعدد ====================
    // Multiple Subscription Tests

    test('الاشتراك في أحداث متعددة - Subscribe to multiple events', () {
      var suggestionCount = 0;
      var textCount = 0;

      final unsubscribe = eventManager.subscribeMultiple(
        [
          CopilotEventType.suggestionRequested,
          CopilotEventType.textChanged,
        ],
        (event) {
          if (event.type == CopilotEventType.suggestionRequested) {
            suggestionCount++;
          } else if (event.type == CopilotEventType.textChanged) {
            textCount++;
          }
        },
      );

      eventManager.emitSimple(CopilotEventType.suggestionRequested);
      eventManager.emitSimple(CopilotEventType.textChanged);
      eventManager.emitSimple(CopilotEventType.suggestionRequested);

      expect(suggestionCount, equals(2));
      expect(textCount, equals(1));

      unsubscribe();
    });

    // ==================== اختبارات سجل الأحداث ====================
    // Event History Tests

    test('حفظ الأحداث في السجل - Save events to history', () {
      eventManager.emitSimple(CopilotEventType.suggestionShown);
      eventManager.emitSimple(CopilotEventType.suggestionAccepted);
      eventManager.emitSimple(CopilotEventType.apiError);

      final history = eventManager.getHistory();

      expect(history.length, equals(3));
    });

    test('تصفية السجل حسب النوع - Filter history by type', () {
      eventManager.emitSimple(CopilotEventType.suggestionShown);
      eventManager.emitSimple(CopilotEventType.suggestionAccepted);
      eventManager.emitSimple(CopilotEventType.suggestionShown);
      eventManager.emitSimple(CopilotEventType.apiError);

      final filteredHistory = eventManager.getHistory(
        type: CopilotEventType.suggestionShown,
      );

      expect(filteredHistory.length, equals(2));
      expect(
        filteredHistory.every((e) => e.type == CopilotEventType.suggestionShown),
        isTrue,
      );
    });

    test('تحديد عدد الأحداث المسترجعة - Limit history results', () {
      for (int i = 0; i < 10; i++) {
        eventManager.emitSimple(CopilotEventType.suggestionShown);
      }

      final limitedHistory = eventManager.getHistory(limit: 5);

      expect(limitedHistory.length, equals(5));
    });

    test('مسح السجل - Clear history', () {
      for (int i = 0; i < 5; i++) {
        eventManager.emitSimple(CopilotEventType.suggestionShown);
      }

      expect(eventManager.getHistory().length, equals(5));

      eventManager.clearHistory();

      expect(eventManager.getHistory().length, equals(0));
    });

    test('حد أقصى لحجم السجل - Maximum history size', () {
      // إضافة أكثر من الحد الأقصى - Add more than max
      for (int i = 0; i < 1500; i++) {
        eventManager.emitSimple(CopilotEventType.suggestionShown);
      }

      final history = eventManager.getHistory();

      // يجب ألا يتجاوز 1000 - Should not exceed 1000
      expect(history.length, lessThanOrEqualTo(1000));
    });

    // ==================== اختبارات الإحصائيات ====================
    // Statistics Tests

    test('حساب إحصائيات الأحداث - Calculate event statistics', () {
      eventManager.emitSimple(CopilotEventType.suggestionShown);
      eventManager.emitSimple(CopilotEventType.suggestionShown);
      eventManager.emitSimple(CopilotEventType.suggestionAccepted);
      eventManager.emitSimple(CopilotEventType.apiError);

      final stats = eventManager.getEventStats();

      expect(stats[CopilotEventType.suggestionShown], equals(2));
      expect(stats[CopilotEventType.suggestionAccepted], equals(1));
      expect(stats[CopilotEventType.apiError], equals(1));
    });

    // ==================== اختبارات معالجة الأخطاء ====================
    // Error Handling Tests

    test('معالجة أخطاء في callback - Handle errors in callback', () {
      final unsubscribe = eventManager.subscribe(
        CopilotEventType.suggestionShown,
        (_) {
          throw Exception('Test error');
        },
      );

      // لا ينبغي أن يتسبب في crash
      // Should not cause a crash
      expect(
        () => eventManager.emitSimple(CopilotEventType.suggestionShown),
        returnsNormally,
      );

      unsubscribe();
    });

    test('تسجيل معالج أخطاء - Register error handler', () {
      var errorHandled = false;

      final unsubscribeError = eventManager.registerErrorHandler((event) {
        errorHandled = true;
      });

      final unsubscribe = eventManager.subscribe(
        CopilotEventType.suggestionShown,
        (_) {
          throw Exception('Test error');
        },
      );

      eventManager.emitSimple(CopilotEventType.suggestionShown);

      expect(errorHandled, isTrue);

      unsubscribe();
      unsubscribeError();
    });

    // ==================== اختبارات انتظار الأحداث ====================
    // Wait For Event Tests

    test('انتظار حدث معين - Wait for specific event', () async {
      // إطلاق الحدث بعد تأخير - Emit event after delay
      Future.delayed(const Duration(milliseconds: 100), () {
        eventManager.emitSimple(CopilotEventType.suggestionReceived);
      });

      final event = await eventManager.waitFor(
        CopilotEventType.suggestionReceived,
        timeout: const Duration(seconds: 1),
      );

      expect(event, isNotNull);
      expect(event.type, equals(CopilotEventType.suggestionReceived));
    });

    test('انتظار حدث مع شرط - Wait for event with predicate', () async {
      Future.delayed(const Duration(milliseconds: 100), () {
        eventManager.emitSimple(
          CopilotEventType.suggestionReceived,
          {'confidence': 0.5},
        );
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        eventManager.emitSimple(
          CopilotEventType.suggestionReceived,
          {'confidence': 0.9},
        );
      });

      final event = await eventManager.waitFor(
        CopilotEventType.suggestionReceived,
        predicate: (e) => e.data['confidence'] >= 0.8,
        timeout: const Duration(seconds: 1),
      );

      expect(event.data['confidence'], equals(0.9));
    });

    test('timeout عند عدم وصول الحدث - Timeout when event not received', () async {
      expect(
        () => eventManager.waitFor(
          CopilotEventType.suggestionReceived,
          timeout: const Duration(milliseconds: 100),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    // ==================== اختبارات الأداء ====================
    // Performance Tests

    test('إطلاق 1000 حدث بسرعة - Emit 1000 events quickly', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        eventManager.emitSimple(CopilotEventType.suggestionShown);
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('الاشتراك وإلغاء الاشتراك بسرعة - Subscribe/unsubscribe quickly', () {
      final stopwatch = Stopwatch()..start();

      final unsubscribers = <Function>[];

      for (int i = 0; i < 100; i++) {
        final unsub = eventManager.subscribe(
          CopilotEventType.suggestionShown,
          (_) {},
        );
        unsubscribers.add(unsub);
      }

      for (final unsub in unsubscribers) {
        unsub();
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('100 مشترك يستقبلون الأحداث بسرعة - 100 subscribers receive events quickly', () {
      final counts = List<int>.filled(100, 0);

      final unsubscribers = <Function>[];

      for (int i = 0; i < 100; i++) {
        final index = i;
        final unsub = eventManager.subscribe(
          CopilotEventType.suggestionShown,
          (_) => counts[index]++,
        );
        unsubscribers.add(unsub);
      }

      final stopwatch = Stopwatch()..start();

      eventManager.emitSimple(CopilotEventType.suggestionShown);

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      expect(counts.every((c) => c == 1), isTrue);

      for (final unsub in unsubscribers) {
        unsub();
      }
    });

    // ==================== اختبارات التكامل ====================
    // Integration Tests

    test('سيناريو كامل: طلب -> استجابة -> قبول', () async {
      var requestReceived = false;
      var responseReceived = false;
      var acceptedReceived = false;

      final unsub1 = eventManager.subscribe(
        CopilotEventType.suggestionRequested,
        (_) => requestReceived = true,
      );

      final unsub2 = eventManager.subscribe(
        CopilotEventType.suggestionReceived,
        (_) => responseReceived = true,
      );

      final unsub3 = eventManager.subscribe(
        CopilotEventType.suggestionAccepted,
        (_) => acceptedReceived = true,
      );

      // تدفق الأحداث - Event flow
      eventManager.emitSimple(CopilotEventType.suggestionRequested);
      await Future.delayed(const Duration(milliseconds: 10));

      eventManager.emitSimple(CopilotEventType.suggestionReceived);
      await Future.delayed(const Duration(milliseconds: 10));

      eventManager.emitSimple(CopilotEventType.suggestionAccepted);

      expect(requestReceived, isTrue);
      expect(responseReceived, isTrue);
      expect(acceptedReceived, isTrue);

      final history = eventManager.getHistory();
      expect(history.length, equals(3));

      unsub1();
      unsub2();
      unsub3();
    });

    // ==================== اختبارات الامتدادات ====================
    // Extension Tests

    test('التحقق من أنواع الأحداث - Check event type extensions', () {
      expect(CopilotEventType.apiError.isError, isTrue);
      expect(CopilotEventType.cacheError.isError, isTrue);
      expect(CopilotEventType.networkError.isError, isTrue);
      expect(CopilotEventType.suggestionShown.isError, isFalse);

      expect(CopilotEventType.suggestionRequested.isSuggestion, isTrue);
      expect(CopilotEventType.suggestionReceived.isSuggestion, isTrue);
      expect(CopilotEventType.suggestionAccepted.isSuggestion, isTrue);
      expect(CopilotEventType.textChanged.isSuggestion, isFalse);
    });

    // ==================== اختبارات التنظيف ====================
    // Cleanup Tests

    test('dispose ينظف الموارد - dispose cleans up resources', () {
      eventManager.subscribe(
        CopilotEventType.suggestionShown,
        (_) {},
      );

      eventManager.emitSimple(CopilotEventType.suggestionShown);

      expect(eventManager.getHistory().isNotEmpty, isTrue);

      eventManager.dispose();

      // بعد dispose، يجب أن تكون الموارد منظفة
      // After dispose, resources should be cleaned
      expect(eventManager.getHistory().isEmpty, isTrue);
    });
  });

  // ==================== اختبارات الأحداث المعقدة ====================
  // Complex Event Tests

  group('Complex Event Scenarios', () {
    late EventManager manager;

    setUp(() {
      manager = EventManager();
    });

    tearDown() {
      manager.clearHistory();
    });

    test('سلسلة أحداث متتالية - Chain of consecutive events', () {
      final eventOrder = <CopilotEventType>[];

      final unsubscribers = <Function>[];

      for (final type in CopilotEventType.values) {
        final unsub = manager.subscribe(type, (event) {
          eventOrder.add(event.type);
        });
        unsubscribers.add(unsub);
      }

      manager.emitSimple(CopilotEventType.textChanged);
      manager.emitSimple(CopilotEventType.suggestionRequested);
      manager.emitSimple(CopilotEventType.suggestionReceived);

      expect(eventOrder.length, equals(3));
      expect(eventOrder[0], equals(CopilotEventType.textChanged));
      expect(eventOrder[1], equals(CopilotEventType.suggestionRequested));
      expect(eventOrder[2], equals(CopilotEventType.suggestionReceived));

      for (final unsub in unsubscribers) {
        unsub();
      }
    });

    test('أحداث متداخلة - Nested events', () {
      var innerEventFired = false;

      final unsub1 = manager.subscribe(
        CopilotEventType.suggestionRequested,
        (_) {
          manager.emitSimple(CopilotEventType.suggestionReceived);
        },
      );

      final unsub2 = manager.subscribe(
        CopilotEventType.suggestionReceived,
        (_) {
          innerEventFired = true;
        },
      );

      manager.emitSimple(CopilotEventType.suggestionRequested);

      expect(innerEventFired, isTrue);

      unsub1();
      unsub2();
    });
  });
}
