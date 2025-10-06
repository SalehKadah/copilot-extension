// مدير الأحداث - Event Manager
// نظام مركزي لإدارة جميع أحداث Copilot
// Centralized system for managing all Copilot events

import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/copilot_suggestion_model.dart';

/// نوع الحدث - Event type
enum CopilotEventType {
  // أحداث النص - Text events
  textChanged,
  textSelected,
  cursorMoved,

  // أحداث الاقتراحات - Suggestion events
  suggestionRequested,
  suggestionReceived,
  suggestionAccepted,
  suggestionRejected,
  suggestionShown,
  suggestionHidden,

  // أحداث الأخطاء - Error events
  apiError,
  cacheError,
  networkError,

  // أحداث النظام - System events
  settingsChanged,
  languageChanged,
  extensionEnabled,
  extensionDisabled,
}

/// حدث Copilot - Copilot event
class CopilotEvent {
  final CopilotEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  CopilotEvent({
    required this.type,
    this.data = const {},
  }) : timestamp = DateTime.now();

  @override
  String toString() => 'CopilotEvent(type: $type, timestamp: $timestamp, data: $data)';
}

/// مدير الأحداث - Event Manager
/// Singleton pattern لضمان وجود نسخة واحدة فقط
/// Singleton pattern to ensure only one instance exists
class EventManager extends ChangeNotifier {
  static final EventManager _instance = EventManager._internal();
  factory EventManager() => _instance;
  EventManager._internal();

  // المشتركون حسب نوع الحدث - Subscribers by event type
  final Map<CopilotEventType, List<Function(CopilotEvent)>> _subscribers = {};

  // سجل الأحداث - Event history
  final List<CopilotEvent> _eventHistory = [];
  final int _maxHistorySize = 1000;

  // معالجات الأخطاء - Error handlers
  final List<Function(CopilotEvent)> _errorHandlers = [];

  /// الاشتراك في حدث - Subscribe to event
  /// Returns unsubscribe function
  VoidCallback subscribe(
    CopilotEventType eventType,
    Function(CopilotEvent) callback,
  ) {
    if (!_subscribers.containsKey(eventType)) {
      _subscribers[eventType] = [];
    }
    _subscribers[eventType]!.add(callback);

    // إرجاع دالة لإلغاء الاشتراك - Return unsubscribe function
    return () => _unsubscribe(eventType, callback);
  }

  /// إلغاء الاشتراك - Unsubscribe
  void _unsubscribe(
    CopilotEventType eventType,
    Function(CopilotEvent) callback,
  ) {
    _subscribers[eventType]?.remove(callback);
  }

  /// إطلاق حدث - Emit event
  void emit(CopilotEvent event) {
    // إضافة للسجل - Add to history
    _addToHistory(event);

    // إشعار المشتركين - Notify subscribers
    final subscribers = _subscribers[event.type] ?? [];
    for (final callback in subscribers) {
      try {
        callback(event);
      } catch (e) {
        debugPrint('Error in event callback: $e');
        _handleError(event, e);
      }
    }

    // إشعار listeners عامة - Notify general listeners
    notifyListeners();
  }

  /// إطلاق حدث بسيط - Emit simple event
  void emitSimple(CopilotEventType type, [Map<String, dynamic>? data]) {
    emit(CopilotEvent(type: type, data: data ?? {}));
  }

  /// الاشتراك في أحداث متعددة - Subscribe to multiple events
  VoidCallback subscribeMultiple(
    List<CopilotEventType> eventTypes,
    Function(CopilotEvent) callback,
  ) {
    final unsubscribers = eventTypes.map((type) => subscribe(type, callback)).toList();

    return () {
      for (final unsubscribe in unsubscribers) {
        unsubscribe();
      }
    };
  }

  /// تسجيل معالج أخطاء - Register error handler
  VoidCallback registerErrorHandler(Function(CopilotEvent) handler) {
    _errorHandlers.add(handler);
    return () => _errorHandlers.remove(handler);
  }

  /// معالجة الخطأ - Handle error
  void _handleError(CopilotEvent event, dynamic error) {
    final errorEvent = CopilotEvent(
      type: CopilotEventType.apiError,
      data: {
        'originalEvent': event,
        'error': error.toString(),
      },
    );

    for (final handler in _errorHandlers) {
      try {
        handler(errorEvent);
      } catch (e) {
        debugPrint('Error in error handler: $e');
      }
    }
  }

  /// إضافة للسجل - Add to history
  void _addToHistory(CopilotEvent event) {
    _eventHistory.add(event);
    if (_eventHistory.length > _maxHistorySize) {
      _eventHistory.removeAt(0);
    }
  }

  /// الحصول على سجل الأحداث - Get event history
  List<CopilotEvent> getHistory({
    CopilotEventType? type,
    DateTime? since,
    int? limit,
  }) {
    var history = List<CopilotEvent>.from(_eventHistory);

    // تصفية حسب النوع - Filter by type
    if (type != null) {
      history = history.where((e) => e.type == type).toList();
    }

    // تصفية حسب الوقت - Filter by time
    if (since != null) {
      history = history.where((e) => e.timestamp.isAfter(since)).toList();
    }

    // تحديد العدد - Limit count
    if (limit != null && history.length > limit) {
      history = history.sublist(history.length - limit);
    }

    return history;
  }

  /// مسح سجل الأحداث - Clear event history
  void clearHistory() {
    _eventHistory.clear();
  }

  /// الحصول على إحصائيات الأحداث - Get event statistics
  Map<CopilotEventType, int> getEventStats() {
    final stats = <CopilotEventType, int>{};
    for (final event in _eventHistory) {
      stats[event.type] = (stats[event.type] ?? 0) + 1;
    }
    return stats;
  }

  /// انتظار حدث - Wait for event
  Future<CopilotEvent> waitFor(
    CopilotEventType eventType, {
    Duration? timeout,
    bool Function(CopilotEvent)? predicate,
  }) {
    final completer = Completer<CopilotEvent>();
    late VoidCallback unsubscribe;

    unsubscribe = subscribe(eventType, (event) {
      if (predicate == null || predicate(event)) {
        completer.complete(event);
        unsubscribe();
      }
    });

    if (timeout != null) {
      return completer.future.timeout(
        timeout,
        onTimeout: () {
          unsubscribe();
          throw TimeoutException('Event wait timeout: $eventType');
        },
      );
    }

    return completer.future;
  }

  @override
  void dispose() {
    _subscribers.clear();
    _eventHistory.clear();
    _errorHandlers.clear();
    super.dispose();
  }
}

/// امتدادات مساعدة - Helper extensions
extension CopilotEventTypeExtension on CopilotEventType {
  /// هل هذا حدث خطأ؟ - Is this an error event?
  bool get isError =>
      this == CopilotEventType.apiError ||
      this == CopilotEventType.cacheError ||
      this == CopilotEventType.networkError;

  /// هل هذا حدث اقتراح؟ - Is this a suggestion event?
  bool get isSuggestion =>
      this == CopilotEventType.suggestionRequested ||
      this == CopilotEventType.suggestionReceived ||
      this == CopilotEventType.suggestionAccepted ||
      this == CopilotEventType.suggestionRejected ||
      this == CopilotEventType.suggestionShown ||
      this == CopilotEventType.suggestionHidden;
}
