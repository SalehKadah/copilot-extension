// نموذج الاقتراح - Suggestion Model
// يمثل اقتراح كود واحد من GitHub Copilot
// Represents a single code suggestion from GitHub Copilot

import 'package:json_annotation/json_annotation.dart';

part 'suggestion_model.g.dart';

/// نموذج الاقتراح - Suggestion Model
/// يحتوي على معلومات الاقتراح والبيانات الوصفية
/// Contains suggestion information and metadata
@JsonSerializable()
class SuggestionModel {
  /// معرف فريد للاقتراح - Unique suggestion identifier
  final String id;

  /// النص المقترح - Suggested text
  final String text;

  /// موضع بداية الاقتراح - Start position of suggestion
  final int startOffset;

  /// موضع نهاية الاقتراح - End position of suggestion
  final int endOffset;

  /// اللغة البرمجية - Programming language
  final String language;

  /// الثقة في الاقتراح (0.0 - 1.0) - Confidence score (0.0 - 1.0)
  final double confidence;

  /// نوع الاقتراح - Suggestion type
  final SuggestionType type;

  /// السياق قبل الاقتراح - Context before suggestion
  final String? contextBefore;

  /// السياق بعد الاقتراح - Context after suggestion
  final String? contextAfter;

  /// هل تم قبول الاقتراح - Whether suggestion was accepted
  bool isAccepted;

  /// هل تم رفض الاقتراح - Whether suggestion was rejected
  bool isRejected;

  /// وقت إنشاء الاقتراح - Creation timestamp
  final DateTime createdAt;

  /// وقت التفاعل (قبول/رفض) - Interaction timestamp (accept/reject)
  DateTime? interactionAt;

  /// البيانات الوصفية الإضافية - Additional metadata
  final Map<String, dynamic>? metadata;

  SuggestionModel({
    required this.id,
    required this.text,
    required this.startOffset,
    required this.endOffset,
    required this.language,
    required this.confidence,
    required this.type,
    this.contextBefore,
    this.contextAfter,
    this.isAccepted = false,
    this.isRejected = false,
    DateTime? createdAt,
    this.interactionAt,
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();

  /// إنشاء من JSON - Create from JSON
  factory SuggestionModel.fromJson(Map<String, dynamic> json) =>
      _$SuggestionModelFromJson(json);

  /// تحويل إلى JSON - Convert to JSON
  Map<String, dynamic> toJson() => _$SuggestionModelToJson(this);

  /// نسخ مع تغييرات - Copy with changes
  SuggestionModel copyWith({
    String? id,
    String? text,
    int? startOffset,
    int? endOffset,
    String? language,
    double? confidence,
    SuggestionType? type,
    String? contextBefore,
    String? contextAfter,
    bool? isAccepted,
    bool? isRejected,
    DateTime? createdAt,
    DateTime? interactionAt,
    Map<String, dynamic>? metadata,
  }) {
    return SuggestionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
      language: language ?? this.language,
      confidence: confidence ?? this.confidence,
      type: type ?? this.type,
      contextBefore: contextBefore ?? this.contextBefore,
      contextAfter: contextAfter ?? this.contextAfter,
      isAccepted: isAccepted ?? this.isAccepted,
      isRejected: isRejected ?? this.isRejected,
      createdAt: createdAt ?? this.createdAt,
      interactionAt: interactionAt ?? this.interactionAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// قبول الاقتراح - Accept suggestion
  void accept() {
    isAccepted = true;
    isRejected = false;
    interactionAt = DateTime.now();
  }

  /// رفض الاقتراح - Reject suggestion
  void reject() {
    isAccepted = false;
    isRejected = true;
    interactionAt = DateTime.now();
  }

  @override
  String toString() {
    return 'SuggestionModel(id: $id, text: "${text.substring(0, text.length > 50 ? 50 : text.length)}...", confidence: $confidence, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SuggestionModel &&
        other.id == id &&
        other.text == text &&
        other.startOffset == startOffset &&
        other.endOffset == endOffset;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        startOffset.hashCode ^
        endOffset.hashCode;
  }
}

/// نوع الاقتراح - Suggestion Type
/// يحدد نوع الاقتراح المقدم
/// Defines the type of suggestion provided
enum SuggestionType {
  /// إكمال سطر واحد - Single line completion
  singleLine,

  /// إكمال متعدد الأسطر - Multi-line completion
  multiLine,

  /// إكمال دالة كاملة - Full function completion
  function,

  /// إكمال فئة - Class completion
  classCompletion,

  /// تعليق توثيقي - Documentation comment
  documentation,

  /// استيراد - Import statement
  import,

  /// إصلاح خطأ - Error fix
  errorFix,

  /// تحسين كود - Code improvement
  refactoring,
}

/// تحويل من نص إلى نوع اقتراح - Convert from string to suggestion type
SuggestionType suggestionTypeFromString(String type) {
  switch (type.toLowerCase()) {
    case 'singleline':
    case 'single_line':
      return SuggestionType.singleLine;
    case 'multiline':
    case 'multi_line':
      return SuggestionType.multiLine;
    case 'function':
      return SuggestionType.function;
    case 'class':
    case 'class_completion':
      return SuggestionType.classCompletion;
    case 'documentation':
    case 'doc':
      return SuggestionType.documentation;
    case 'import':
      return SuggestionType.import;
    case 'errorfix':
    case 'error_fix':
      return SuggestionType.errorFix;
    case 'refactoring':
    case 'improvement':
      return SuggestionType.refactoring;
    default:
      return SuggestionType.singleLine;
  }
}

/// تحويل من نوع اقتراح إلى نص - Convert from suggestion type to string
String suggestionTypeToString(SuggestionType type) {
  switch (type) {
    case SuggestionType.singleLine:
      return 'single_line';
    case SuggestionType.multiLine:
      return 'multi_line';
    case SuggestionType.function:
      return 'function';
    case SuggestionType.classCompletion:
      return 'class_completion';
    case SuggestionType.documentation:
      return 'documentation';
    case SuggestionType.import:
      return 'import';
    case SuggestionType.errorFix:
      return 'error_fix';
    case SuggestionType.refactoring:
      return 'refactoring';
  }
}
