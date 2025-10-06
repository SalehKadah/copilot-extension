// نافذة الاقتراح المنبثقة - Suggestion Popup
// نافذة منبثقة احترافية لعرض الاقتراحات
// Professional popup window for displaying suggestions

import 'package:flutter/material.dart';
import '../models/suggestion_model.dart';

/// نافذة الاقتراح المنبثقة - Suggestion Popup
/// تعرض الاقتراح مع خيارات القبول والرفض
/// Displays suggestion with accept/reject options
class SuggestionPopup extends StatelessWidget {
  /// الاقتراح المعروض - Displayed suggestion
  final SuggestionModel suggestion;

  /// هل الواجهة مظلمة - Is dark theme
  final bool isDarkTheme;

  /// حجم الخط - Font size
  final double fontSize;

  /// callback عند القبول - Callback on accept
  final VoidCallback onAccept;

  /// callback عند الرفض - Callback on reject
  final VoidCallback onReject;

  /// callback للاقتراح التالي - Callback for next suggestion
  final VoidCallback onNext;

  /// callback للاقتراح السابق - Callback for previous suggestion
  final VoidCallback onPrevious;

  const SuggestionPopup({
    super.key,
    required this.suggestion,
    this.isDarkTheme = true,
    this.fontSize = 14.0,
    required this.onAccept,
    required this.onReject,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      color: isDarkTheme ? const Color(0xFF1E1E1E) : Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 300),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس النافذة - Header
            _buildHeader(),

            const SizedBox(height: 8),

            // محتوى الاقتراح - Suggestion content
            Flexible(child: _buildSuggestionContent()),

            const SizedBox(height: 8),

            // أزرار التحكم - Control buttons
            _buildControls(),
          ],
        ),
      ),
    );
  }

  /// بناء رأس النافذة - Build header
  Widget _buildHeader() {
    return Row(
      children: [
        // أيقونة Copilot - Copilot icon
        Icon(Icons.smart_toy, size: 20, color: const Color(0xFF007ACC)),

        const SizedBox(width: 8),

        // نوع الاقتراح - Suggestion type
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getTypeColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _getTypeColor().withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            _getTypeLabel(),
            style: TextStyle(
              fontSize: 11,
              color: _getTypeColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // مستوى الثقة - Confidence score
        if (suggestion.confidence > 0) ...[
          Icon(Icons.stars, size: 14, color: _getConfidenceColor()),
          const SizedBox(width: 4),
          Text(
            '${(suggestion.confidence * 100).toInt()}%',
            style: TextStyle(
              fontSize: 11,
              color: _getConfidenceColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        const Spacer(),

        // زر الإغلاق - Close button
        IconButton(
          icon: Icon(
            Icons.close,
            size: 16,
            color: isDarkTheme ? Colors.white54 : Colors.black54,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onReject,
        ),
      ],
    );
  }

  /// بناء محتوى الاقتراح - Build suggestion content
  Widget _buildSuggestionContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF252526) : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDarkTheme
              ? const Color(0xFF3C3C3C)
              : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          suggestion.text,
          style: TextStyle(
            fontFamily: 'Consolas',
            fontSize: fontSize,
            color: isDarkTheme ? const Color(0xFFD4D4D4) : Colors.black87,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  /// بناء أزرار التحكم - Build control buttons
  Widget _buildControls() {
    return Row(
      children: [
        // معلومات الاختصارات - Shortcuts info
        Expanded(
          child: Wrap(
            spacing: 12,
            children: [
              _buildShortcutHint('Tab', 'قبول - Accept'),
              _buildShortcutHint('Esc', 'رفض - Reject'),
              _buildShortcutHint('Alt+]', 'التالي - Next'),
              _buildShortcutHint('Alt+[', 'السابق - Previous'),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // أزرار التنقل - Navigation buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildControlButton(
              icon: Icons.arrow_back,
              tooltip: 'الاقتراح السابق - Previous',
              onPressed: onPrevious,
            ),

            const SizedBox(width: 4),

            _buildControlButton(
              icon: Icons.arrow_forward,
              tooltip: 'الاقتراح التالي - Next',
              onPressed: onNext,
            ),

            const SizedBox(width: 12),

            // زر الرفض - Reject button
            _buildControlButton(
              icon: Icons.close,
              tooltip: 'رفض - Reject (Esc)',
              onPressed: onReject,
              color: Colors.red,
            ),

            const SizedBox(width: 4),

            // زر القبول - Accept button
            _buildControlButton(
              icon: Icons.check,
              tooltip: 'قبول - Accept (Tab)',
              onPressed: onAccept,
              color: Colors.green,
              isPrimary: true,
            ),
          ],
        ),
      ],
    );
  }

  /// بناء تلميح اختصار - Build shortcut hint
  Widget _buildShortcutHint(String key, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? const Color(0xFF3C3C3C)
                : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Consolas',
              color: isDarkTheme ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDarkTheme ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }

  /// بناء زر تحكم - Build control button
  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
    bool isPrimary = false,
  }) {
    final buttonColor = color ?? const Color(0xFF007ACC);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isPrimary
            ? buttonColor
            : (isDarkTheme ? const Color(0xFF3C3C3C) : const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 16,
              color: isPrimary
                  ? Colors.white
                  : (isDarkTheme ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  /// الحصول على لون نوع الاقتراح - Get suggestion type color
  Color _getTypeColor() {
    switch (suggestion.type) {
      case SuggestionType.function:
        return Colors.purple;
      case SuggestionType.classCompletion:
        return Colors.blue;
      case SuggestionType.documentation:
        return Colors.green;
      case SuggestionType.import:
        return Colors.orange;
      case SuggestionType.errorFix:
        return Colors.red;
      case SuggestionType.refactoring:
        return Colors.amber;
      default:
        return const Color(0xFF007ACC);
    }
  }

  /// الحصول على تسمية نوع الاقتراح - Get suggestion type label
  String _getTypeLabel() {
    switch (suggestion.type) {
      case SuggestionType.function:
        return 'Function - دالة';
      case SuggestionType.classCompletion:
        return 'Class - فئة';
      case SuggestionType.documentation:
        return 'Doc - توثيق';
      case SuggestionType.import:
        return 'Import - استيراد';
      case SuggestionType.errorFix:
        return 'Fix - إصلاح';
      case SuggestionType.refactoring:
        return 'Refactor - تحسين';
      case SuggestionType.multiLine:
        return 'Multi-line - متعدد';
      default:
        return 'Code - كود';
    }
  }

  /// الحصول على لون مستوى الثقة - Get confidence level color
  Color _getConfidenceColor() {
    if (suggestion.confidence >= 0.8) {
      return Colors.green;
    } else if (suggestion.confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
