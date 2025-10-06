// نموذج إعدادات Copilot - Copilot Settings Model
// يحتوي على جميع الإعدادات القابلة للتخصيص
// Contains all customizable settings

import 'package:json_annotation/json_annotation.dart';

part 'copilot_settings_model.g.dart';

/// نموذج إعدادات Copilot - Copilot Settings Model
@JsonSerializable()
class CopilotSettingsModel {
  /// تفعيل Copilot - Enable Copilot
  bool enabled;

  /// التشغيل التلقائي للاقتراحات - Auto-trigger suggestions
  bool autoTrigger;

  /// التأخير قبل إظهار الاقتراحات (ميلي ثانية) - Delay before showing suggestions (ms)
  int suggestionDelay;

  /// الحد الأقصى لعدد الاقتراحات - Maximum number of suggestions
  int maxSuggestions;

  /// اللغات المفعلة - Enabled languages
  List<String> enableForLanguages;

  /// إظهار التعليقات المباشرة - Show inline comments
  bool showInlineComments;

  /// مفتاح API - API Key
  String apiKey;

  /// استخدام الذاكرة المؤقتة - Use caching
  bool useCache;

  /// حجم الذاكرة المؤقتة (بالميجابايت) - Cache size (in MB)
  int cacheSizeInMB;

  /// تسجيل الإحصائيات - Log statistics
  bool logStatistics;

  /// إرسال البيانات المجهولة - Send anonymous data
  bool sendAnonymousData;

  /// إظهار الثقة في الاقتراح - Show confidence score
  bool showConfidenceScore;

  /// الحد الأدنى للثقة لإظهار الاقتراح (0.0 - 1.0) - Minimum confidence to show (0.0 - 1.0)
  double minimumConfidence;

  /// تفعيل الصوت - Enable sound
  bool enableSound;

  /// تفعيل الإشعارات - Enable notifications
  bool enableNotifications;

  /// لون التمييز للاقتراحات - Highlight color for suggestions
  String highlightColor;

  /// حجم الخط للاقتراحات - Font size for suggestions
  double fontSize;

  /// نمط الخط للاقتراحات - Font style for suggestions
  String fontStyle;

  CopilotSettingsModel({
    this.enabled = true,
    this.autoTrigger = true,
    this.suggestionDelay = 500,
    this.maxSuggestions = 5,
    List<String>? enableForLanguages,
    this.showInlineComments = true,
    this.apiKey = '',
    this.useCache = true,
    this.cacheSizeInMB = 100,
    this.logStatistics = true,
    this.sendAnonymousData = false,
    this.showConfidenceScore = true,
    this.minimumConfidence = 0.5,
    this.enableSound = false,
    this.enableNotifications = true,
    this.highlightColor = '#007ACC',
    this.fontSize = 14.0,
    this.fontStyle = 'normal',
  }) : enableForLanguages =
           enableForLanguages ??
           ['sa', 'dart', 'javascript', 'python', 'java', 'cpp'];

  /// إنشاء من JSON - Create from JSON
  factory CopilotSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$CopilotSettingsModelFromJson(json);

  /// تحويل إلى JSON - Convert to JSON
  Map<String, dynamic> toJson() => _$CopilotSettingsModelToJson(this);

  /// نسخ مع تغييرات - Copy with changes
  CopilotSettingsModel copyWith({
    bool? enabled,
    bool? autoTrigger,
    int? suggestionDelay,
    int? maxSuggestions,
    List<String>? enableForLanguages,
    bool? showInlineComments,
    String? apiKey,
    bool? useCache,
    int? cacheSizeInMB,
    bool? logStatistics,
    bool? sendAnonymousData,
    bool? showConfidenceScore,
    double? minimumConfidence,
    bool? enableSound,
    bool? enableNotifications,
    String? highlightColor,
    double? fontSize,
    String? fontStyle,
  }) {
    return CopilotSettingsModel(
      enabled: enabled ?? this.enabled,
      autoTrigger: autoTrigger ?? this.autoTrigger,
      suggestionDelay: suggestionDelay ?? this.suggestionDelay,
      maxSuggestions: maxSuggestions ?? this.maxSuggestions,
      enableForLanguages: enableForLanguages ?? this.enableForLanguages,
      showInlineComments: showInlineComments ?? this.showInlineComments,
      apiKey: apiKey ?? this.apiKey,
      useCache: useCache ?? this.useCache,
      cacheSizeInMB: cacheSizeInMB ?? this.cacheSizeInMB,
      logStatistics: logStatistics ?? this.logStatistics,
      sendAnonymousData: sendAnonymousData ?? this.sendAnonymousData,
      showConfidenceScore: showConfidenceScore ?? this.showConfidenceScore,
      minimumConfidence: minimumConfidence ?? this.minimumConfidence,
      enableSound: enableSound ?? this.enableSound,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      highlightColor: highlightColor ?? this.highlightColor,
      fontSize: fontSize ?? this.fontSize,
      fontStyle: fontStyle ?? this.fontStyle,
    );
  }

  /// التحقق من صحة الإعدادات - Validate settings
  bool validate() {
    if (apiKey.isEmpty) return false;
    if (suggestionDelay < 0) return false;
    if (maxSuggestions < 1 || maxSuggestions > 20) return false;
    if (minimumConfidence < 0.0 || minimumConfidence > 1.0) return false;
    if (cacheSizeInMB < 10 || cacheSizeInMB > 1000) return false;
    return true;
  }

  /// الإعدادات الافتراضية - Default settings
  static CopilotSettingsModel get defaults => CopilotSettingsModel();

  @override
  String toString() {
    return 'CopilotSettingsModel(enabled: $enabled, autoTrigger: $autoTrigger, maxSuggestions: $maxSuggestions)';
  }
}
