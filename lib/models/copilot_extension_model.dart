// نموذج إضافة Copilot - Copilot Extension Model
// النموذج الرئيسي للإضافة
// Main extension model

import 'package:json_annotation/json_annotation.dart';
import 'suggestion_model.dart';
import 'copilot_settings_model.dart';

part 'copilot_extension_model.g.dart';

/// نموذج إضافة Copilot - Copilot Extension Model
/// يمثل حالة الإضافة الكاملة
/// Represents the complete extension state
@JsonSerializable()
class CopilotExtensionModel {
  /// معرف الإضافة - Extension ID
  final String id;

  /// اسم الإضافة - Extension name
  final String name;

  /// الإصدار - Version
  final String version;

  /// هل الإضافة مفعلة - Is extension active
  bool isActive;

  /// هل الإضافة متصلة بالخادم - Is connected to server
  bool isConnected;

  /// الإعدادات - Settings
  CopilotSettingsModel settings;

  /// الاقتراحات الحالية - Current suggestions
  List<SuggestionModel> currentSuggestions;

  /// مؤشر الاقتراح المحدد - Selected suggestion index
  int selectedSuggestionIndex;

  /// إحصائيات الاستخدام - Usage statistics
  UsageStatistics statistics;

  /// آخر خطأ - Last error
  String? lastError;

  /// وقت آخر تحديث - Last update time
  DateTime lastUpdated;

  CopilotExtensionModel({
    required this.id,
    required this.name,
    required this.version,
    this.isActive = false,
    this.isConnected = false,
    CopilotSettingsModel? settings,
    List<SuggestionModel>? currentSuggestions,
    this.selectedSuggestionIndex = 0,
    UsageStatistics? statistics,
    this.lastError,
    DateTime? lastUpdated,
  }) : settings = settings ?? CopilotSettingsModel(),
       currentSuggestions = currentSuggestions ?? [],
       statistics = statistics ?? UsageStatistics(),
       lastUpdated = lastUpdated ?? DateTime.now();

  /// إنشاء من JSON - Create from JSON
  factory CopilotExtensionModel.fromJson(Map<String, dynamic> json) =>
      _$CopilotExtensionModelFromJson(json);

  /// تحويل إلى JSON - Convert to JSON
  Map<String, dynamic> toJson() => _$CopilotExtensionModelToJson(this);

  /// نسخ مع تغييرات - Copy with changes
  CopilotExtensionModel copyWith({
    String? id,
    String? name,
    String? version,
    bool? isActive,
    bool? isConnected,
    CopilotSettingsModel? settings,
    List<SuggestionModel>? currentSuggestions,
    int? selectedSuggestionIndex,
    UsageStatistics? statistics,
    String? lastError,
    DateTime? lastUpdated,
  }) {
    return CopilotExtensionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      isConnected: isConnected ?? this.isConnected,
      settings: settings ?? this.settings,
      currentSuggestions: currentSuggestions ?? this.currentSuggestions,
      selectedSuggestionIndex:
          selectedSuggestionIndex ?? this.selectedSuggestionIndex,
      statistics: statistics ?? this.statistics,
      lastError: lastError ?? this.lastError,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// تفعيل الإضافة - Activate extension
  void activate() {
    isActive = true;
    lastUpdated = DateTime.now();
  }

  /// إيقاف الإضافة - Deactivate extension
  void deactivate() {
    isActive = false;
    isConnected = false;
    currentSuggestions.clear();
    lastUpdated = DateTime.now();
  }

  /// تحديث الاقتراحات - Update suggestions
  void updateSuggestions(List<SuggestionModel> suggestions) {
    currentSuggestions = suggestions;
    selectedSuggestionIndex = 0;
    lastUpdated = DateTime.now();
  }

  /// مسح الاقتراحات - Clear suggestions
  void clearSuggestions() {
    currentSuggestions.clear();
    selectedSuggestionIndex = 0;
    lastUpdated = DateTime.now();
  }

  /// الاقتراح المحدد حالياً - Currently selected suggestion
  SuggestionModel? get selectedSuggestion {
    if (currentSuggestions.isEmpty ||
        selectedSuggestionIndex >= currentSuggestions.length) {
      return null;
    }
    return currentSuggestions[selectedSuggestionIndex];
  }

  /// الانتقال للاقتراح التالي - Move to next suggestion
  bool nextSuggestion() {
    if (currentSuggestions.isEmpty) return false;
    if (selectedSuggestionIndex < currentSuggestions.length - 1) {
      selectedSuggestionIndex++;
      return true;
    }
    return false;
  }

  /// الانتقال للاقتراح السابق - Move to previous suggestion
  bool previousSuggestion() {
    if (currentSuggestions.isEmpty) return false;
    if (selectedSuggestionIndex > 0) {
      selectedSuggestionIndex--;
      return true;
    }
    return false;
  }

  /// قبول الاقتراح المحدد - Accept selected suggestion
  void acceptSelectedSuggestion() {
    final suggestion = selectedSuggestion;
    if (suggestion != null) {
      suggestion.accept();
      statistics.incrementAccepted();
      lastUpdated = DateTime.now();
    }
  }

  /// رفض الاقتراح المحدد - Reject selected suggestion
  void rejectSelectedSuggestion() {
    final suggestion = selectedSuggestion;
    if (suggestion != null) {
      suggestion.reject();
      statistics.incrementRejected();
      lastUpdated = DateTime.now();
    }
  }

  /// تسجيل خطأ - Log error
  void logError(String error) {
    lastError = error;
    lastUpdated = DateTime.now();
  }

  /// مسح الخطأ - Clear error
  void clearError() {
    lastError = null;
    lastUpdated = DateTime.now();
  }

  @override
  String toString() {
    return 'CopilotExtensionModel(id: $id, name: $name, version: $version, isActive: $isActive, suggestions: ${currentSuggestions.length})';
  }
}

/// إحصائيات الاستخدام - Usage Statistics
/// تتبع استخدام الإضافة والاقتراحات
/// Tracks extension usage and suggestions
@JsonSerializable()
class UsageStatistics {
  /// عدد الاقتراحات المعروضة - Total suggestions shown
  int totalSuggestionsShown;

  /// عدد الاقتراحات المقبولة - Total suggestions accepted
  int totalSuggestionsAccepted;

  /// عدد الاقتراحات المرفوضة - Total suggestions rejected
  int totalSuggestionsRejected;

  /// عدد طلبات API - Total API requests
  int totalApiRequests;

  /// عدد الأخطاء - Total errors
  int totalErrors;

  /// وقت البدء - Start time
  final DateTime startTime;

  /// آخر استخدام - Last usage time
  DateTime lastUsageTime;

  /// إجمالي وقت الاستخدام (بالثواني) - Total usage time (in seconds)
  int totalUsageTimeInSeconds;

  UsageStatistics({
    this.totalSuggestionsShown = 0,
    this.totalSuggestionsAccepted = 0,
    this.totalSuggestionsRejected = 0,
    this.totalApiRequests = 0,
    this.totalErrors = 0,
    DateTime? startTime,
    DateTime? lastUsageTime,
    this.totalUsageTimeInSeconds = 0,
  }) : startTime = startTime ?? DateTime.now(),
       lastUsageTime = lastUsageTime ?? DateTime.now();

  /// إنشاء من JSON - Create from JSON
  factory UsageStatistics.fromJson(Map<String, dynamic> json) =>
      _$UsageStatisticsFromJson(json);

  /// تحويل إلى JSON - Convert to JSON
  Map<String, dynamic> toJson() => _$UsageStatisticsToJson(this);

  /// زيادة عدد الاقتراحات المعروضة - Increment shown suggestions
  void incrementShown() {
    totalSuggestionsShown++;
    lastUsageTime = DateTime.now();
  }

  /// زيادة عدد الاقتراحات المقبولة - Increment accepted suggestions
  void incrementAccepted() {
    totalSuggestionsAccepted++;
    lastUsageTime = DateTime.now();
  }

  /// زيادة عدد الاقتراحات المرفوضة - Increment rejected suggestions
  void incrementRejected() {
    totalSuggestionsRejected++;
    lastUsageTime = DateTime.now();
  }

  /// زيادة عدد طلبات API - Increment API requests
  void incrementApiRequests() {
    totalApiRequests++;
    lastUsageTime = DateTime.now();
  }

  /// زيادة عدد الأخطاء - Increment errors
  void incrementErrors() {
    totalErrors++;
    lastUsageTime = DateTime.now();
  }

  /// نسبة القبول - Acceptance rate
  double get acceptanceRate {
    if (totalSuggestionsShown == 0) return 0.0;
    return totalSuggestionsAccepted / totalSuggestionsShown;
  }

  /// نسبة الرفض - Rejection rate
  double get rejectionRate {
    if (totalSuggestionsShown == 0) return 0.0;
    return totalSuggestionsRejected / totalSuggestionsShown;
  }

  /// إعادة التعيين - Reset statistics
  void reset() {
    totalSuggestionsShown = 0;
    totalSuggestionsAccepted = 0;
    totalSuggestionsRejected = 0;
    totalApiRequests = 0;
    totalErrors = 0;
    totalUsageTimeInSeconds = 0;
  }

  @override
  String toString() {
    return 'UsageStatistics(shown: $totalSuggestionsShown, accepted: $totalSuggestionsAccepted, rejected: $totalSuggestionsRejected, acceptanceRate: ${(acceptanceRate * 100).toStringAsFixed(1)}%)';
  }
}
