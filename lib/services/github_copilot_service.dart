// خدمة GitHub Copilot - GitHub Copilot Service
// التواصل مع GitHub Copilot API للحصول على اقتراحات الكود
// Communication with GitHub Copilot API to get code suggestions

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/suggestion_model.dart';
import '../models/copilot_settings_model.dart';

/// خدمة GitHub Copilot - GitHub Copilot Service
/// تدير الاتصال والتواصل مع GitHub Copilot API
/// Manages connection and communication with GitHub Copilot API
class GitHubCopilotService {
  // السنغلتون - Singleton
  static final GitHubCopilotService _instance =
      GitHubCopilotService._internal();
  factory GitHubCopilotService() => _instance;
  GitHubCopilotService._internal();

  /// عميل HTTP - HTTP client
  late Dio _dio;

  /// المسجل - Logger
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// الإعدادات الحالية - Current settings
  CopilotSettingsModel? _settings;

  /// حالة الاتصال - Connection status
  bool _isConnected = false;

  /// طلبات قيد الانتظار - Pending requests
  final Map<String, CancelToken> _pendingRequests = {};

  /// عنوان API الافتراضي - Default API URL
  static const String _defaultApiUrl =
      'https://api.github.com/copilot/completions';

  /// المهلة الافتراضية للطلبات (ميلي ثانية) - Default request timeout (ms)
  static const int _defaultTimeout = 5000;

  /// تهيئة الخدمة - Initialize service
  /// يجب استدعاؤها قبل استخدام الخدمة
  /// Must be called before using the service
  Future<void> initialize(CopilotSettingsModel settings) async {
    _settings = settings;

    _dio = Dio(
      BaseOptions(
        baseUrl: _defaultApiUrl,
        connectTimeout: Duration(milliseconds: _defaultTimeout),
        receiveTimeout: Duration(milliseconds: _defaultTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${settings.apiKey}',
          'User-Agent': 'SA-IDE-Copilot-Extension/1.0.0',
        },
      ),
    );

    // إضافة interceptors للتسجيل - Add interceptors for logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d(
            '📤 طلب API - API Request: ${options.method} ${options.path}',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('📥 استجابة API - API Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('❌ خطأ API - API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );

    // التحقق من الاتصال - Verify connection
    await _verifyConnection();
  }

  /// التحقق من الاتصال - Verify connection
  Future<bool> _verifyConnection() async {
    try {
      // محاولة طلب بسيط للتحقق من الاتصال
      // Try a simple request to verify connection
      final response = await _dio.get(
        '/health',
        options: Options(receiveTimeout: const Duration(milliseconds: 3000)),
      );

      _isConnected = response.statusCode == 200;
      _logger.i('🔌 حالة الاتصال - Connection status: $_isConnected');
      return _isConnected;
    } catch (e) {
      _logger.w(
        '⚠️ فشل التحقق من الاتصال - Connection verification failed: $e',
      );
      _isConnected = false;
      return false;
    }
  }

  /// الحصول على اقتراحات - Get suggestions
  /// [code] - الكود الحالي - Current code
  /// [language] - اللغة البرمجية - Programming language
  /// [cursorPosition] - موضع المؤشر - Cursor position
  /// [filePath] - مسار الملف (اختياري) - File path (optional)
  /// [maxSuggestions] - الحد الأقصى للاقتراحات - Maximum suggestions
  Future<List<SuggestionModel>> getSuggestions({
    required String code,
    required String language,
    required int cursorPosition,
    String? filePath,
    int? maxSuggestions,
  }) async {
    if (_settings == null) {
      throw Exception(
        'الخدمة غير مهيأة - Service not initialized. استدعي initialize() أولاً - Call initialize() first.',
      );
    }

    if (!_settings!.enabled) {
      _logger.w('⚠️ Copilot غير مفعل - Copilot is disabled');
      return [];
    }

    try {
      // إنشاء معرف فريد للطلب - Create unique request ID
      final requestId = DateTime.now().millisecondsSinceEpoch.toString();
      final cancelToken = CancelToken();
      _pendingRequests[requestId] = cancelToken;

      _logger.d('🔍 طلب اقتراحات - Requesting suggestions');
      _logger.d('   اللغة - Language: $language');
      _logger.d('   موضع المؤشر - Cursor: $cursorPosition');
      _logger.d('   طول الكود - Code length: ${code.length}');

      // تحضير البيانات - Prepare data
      final requestData = {
        'prompt': code,
        'language': language,
        'cursor_position': cursorPosition,
        'max_completions': maxSuggestions ?? _settings!.maxSuggestions,
        'temperature': 0.2, // مستوى الإبداع - Creativity level
        'top_p': 0.95,
        'file_path': filePath,
        'context': {
          'before': _getContextBefore(code, cursorPosition),
          'after': _getContextAfter(code, cursorPosition),
        },
      };

      // إرسال الطلب - Send request
      final response = await _dio.post(
        '/completions',
        data: requestData,
        cancelToken: cancelToken,
      );

      // إزالة الطلب من قائمة الانتظار - Remove from pending
      _pendingRequests.remove(requestId);

      // معالجة الاستجابة - Process response
      if (response.statusCode == 200 && response.data != null) {
        final suggestions = _parseSuggestions(
          response.data,
          code,
          cursorPosition,
          language,
        );

        _logger.i(
          '✅ تم الحصول على ${suggestions.length} اقتراح - Got ${suggestions.length} suggestions',
        );
        return suggestions;
      } else {
        _logger.w(
          '⚠️ استجابة غير متوقعة - Unexpected response: ${response.statusCode}',
        );
        return [];
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return [];
    } catch (e) {
      _logger.e(
        '❌ خطأ في الحصول على الاقتراحات - Error getting suggestions: $e',
      );
      return [];
    }
  }

  /// معالجة أخطاء Dio - Handle Dio errors
  void _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        _logger.e('⏱️ انتهت مهلة الاتصال - Connection timeout');
        break;
      case DioExceptionType.sendTimeout:
        _logger.e('⏱️ انتهت مهلة الإرسال - Send timeout');
        break;
      case DioExceptionType.receiveTimeout:
        _logger.e('⏱️ انتهت مهلة الاستقبال - Receive timeout');
        break;
      case DioExceptionType.badResponse:
        _logger.e(
          '📛 استجابة خاطئة - Bad response: ${error.response?.statusCode}',
        );
        if (error.response?.statusCode == 401) {
          _logger.e('🔑 مفتاح API غير صالح - Invalid API key');
        } else if (error.response?.statusCode == 429) {
          _logger.e('🚫 تم تجاوز حد الطلبات - Rate limit exceeded');
        }
        break;
      case DioExceptionType.cancel:
        _logger.w('🛑 تم إلغاء الطلب - Request cancelled');
        break;
      case DioExceptionType.connectionError:
        _logger.e('🌐 خطأ في الاتصال - Connection error');
        _isConnected = false;
        break;
      default:
        _logger.e('❌ خطأ غير معروف - Unknown error: ${error.message}');
    }
  }

  /// معالجة وتحليل الاقتراحات - Parse and process suggestions
  List<SuggestionModel> _parseSuggestions(
    dynamic responseData,
    String originalCode,
    int cursorPosition,
    String language,
  ) {
    final List<SuggestionModel> suggestions = [];

    try {
      // التعامل مع تنسيقات الاستجابة المختلفة
      // Handle different response formats
      List<dynamic> completions;

      if (responseData is Map<String, dynamic>) {
        completions =
            responseData['completions'] ?? responseData['choices'] ?? [];
      } else if (responseData is List) {
        completions = responseData;
      } else {
        _logger.w('⚠️ تنسيق استجابة غير معروف - Unknown response format');
        return suggestions;
      }

      // معالجة كل اقتراح - Process each suggestion
      for (var i = 0; i < completions.length; i++) {
        final completion = completions[i];

        String text;
        double confidence = 0.8; // افتراضياً - Default
        SuggestionType type = SuggestionType.singleLine;

        // استخراج النص - Extract text
        if (completion is String) {
          text = completion;
        } else if (completion is Map<String, dynamic>) {
          text = completion['text'] ?? completion['completion'] ?? '';
          confidence = (completion['confidence'] ?? 0.8).toDouble();

          // تحديد نوع الاقتراح - Determine suggestion type
          type = _determineSuggestionType(text, completion);
        } else {
          continue;
        }

        // تصفية الاقتراحات ذات الثقة المنخفضة
        // Filter low-confidence suggestions
        if (_settings!.showConfidenceScore &&
            confidence < _settings!.minimumConfidence) {
          continue;
        }

        // إنشاء نموذج الاقتراح - Create suggestion model
        final suggestion = SuggestionModel(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i',
          text: text,
          startOffset: cursorPosition,
          endOffset: cursorPosition + text.length,
          language: language,
          confidence: confidence,
          type: type,
          contextBefore: _getContextBefore(originalCode, cursorPosition),
          contextAfter: _getContextAfter(originalCode, cursorPosition),
        );

        suggestions.add(suggestion);
      }
    } catch (e) {
      _logger.e('❌ خطأ في معالجة الاقتراحات - Error parsing suggestions: $e');
    }

    return suggestions;
  }

  /// تحديد نوع الاقتراح - Determine suggestion type
  SuggestionType _determineSuggestionType(
    String text,
    Map<String, dynamic>? metadata,
  ) {
    // من البيانات الوصفية - From metadata
    if (metadata != null && metadata.containsKey('type')) {
      return suggestionTypeFromString(metadata['type']);
    }

    // من محتوى النص - From text content
    if (text.contains('\n')) {
      if (text.contains('function') ||
          text.contains('def ') ||
          text.contains('دالة')) {
        return SuggestionType.function;
      } else if (text.contains('class ') || text.contains('فئة')) {
        return SuggestionType.classCompletion;
      } else {
        return SuggestionType.multiLine;
      }
    } else if (text.startsWith('///') ||
        text.startsWith('/**') ||
        text.startsWith('//')) {
      return SuggestionType.documentation;
    } else if (text.startsWith('import ') || text.startsWith('استيراد')) {
      return SuggestionType.import;
    }

    return SuggestionType.singleLine;
  }

  /// الحصول على السياق قبل المؤشر - Get context before cursor
  String _getContextBefore(String code, int position, {int maxChars = 200}) {
    if (position <= 0) return '';
    final start = (position - maxChars).clamp(0, position);
    return code.substring(start, position);
  }

  /// الحصول على السياق بعد المؤشر - Get context after cursor
  String _getContextAfter(String code, int position, {int maxChars = 200}) {
    if (position >= code.length) return '';
    final end = (position + maxChars).clamp(position, code.length);
    return code.substring(position, end);
  }

  /// إلغاء جميع الطلبات المعلقة - Cancel all pending requests
  void cancelAllRequests() {
    _logger.i(
      '🛑 إلغاء ${_pendingRequests.length} طلب معلق - Cancelling ${_pendingRequests.length} pending requests',
    );

    for (final cancelToken in _pendingRequests.values) {
      cancelToken.cancel('تم إلغاء الطلب - Request cancelled');
    }
    _pendingRequests.clear();
  }

  /// إلغاء طلب محدد - Cancel specific request
  void cancelRequest(String requestId) {
    final cancelToken = _pendingRequests[requestId];
    if (cancelToken != null) {
      cancelToken.cancel('تم إلغاء الطلب - Request cancelled');
      _pendingRequests.remove(requestId);
    }
  }

  /// تحديث الإعدادات - Update settings
  void updateSettings(CopilotSettingsModel settings) {
    _settings = settings;

    // تحديث headers في Dio - Update Dio headers
    _dio.options.headers['Authorization'] = 'Bearer ${settings.apiKey}';

    _logger.i('⚙️ تم تحديث الإعدادات - Settings updated');
  }

  /// التحقق من حالة الاتصال - Check connection status
  bool get isConnected => _isConnected;

  /// إعادة الاتصال - Reconnect
  Future<bool> reconnect() async {
    _logger.i('🔄 إعادة الاتصال - Reconnecting...');
    return await _verifyConnection();
  }

  /// تنظيف الموارد - Cleanup resources
  void dispose() {
    cancelAllRequests();
    _dio.close();
    _logger.i('🧹 تم تنظيف الموارد - Resources cleaned up');
  }
}
