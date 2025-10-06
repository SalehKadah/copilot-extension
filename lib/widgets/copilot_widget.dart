// واجهة Copilot - Copilot Widget
// الواجهة الرئيسية لعرض الاقتراحات والتفاعل معها
// Main interface for displaying and interacting with suggestions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/suggestion_model.dart';
import '../services/suggestions_manager.dart';
import 'suggestion_popup.dart';

/// واجهة Copilot الرئيسية - Main Copilot Widget
/// تعرض حالة Copilot والاقتراحات
/// Displays Copilot status and suggestions
class CopilotWidget extends StatefulWidget {
  /// محرر النصوص المرتبط - Associated text editor
  final TextEditingController textController;

  /// اللغة البرمجية الحالية - Current programming language
  final String language;

  /// مسار الملف الحالي - Current file path
  final String? filePath;

  /// هل الواجهة مظلمة - Is dark theme
  final bool isDarkTheme;

  /// حجم الخط - Font size
  final double fontSize;

  /// callback عند قبول اقتراح - Callback when suggestion accepted
  final void Function(String suggestion)? onSuggestionAccepted;

  /// callback عند رفض اقتراح - Callback when suggestion rejected
  final void Function()? onSuggestionRejected;

  const CopilotWidget({
    super.key,
    required this.textController,
    required this.language,
    this.filePath,
    this.isDarkTheme = true,
    this.fontSize = 14.0,
    this.onSuggestionAccepted,
    this.onSuggestionRejected,
  });

  @override
  State<CopilotWidget> createState() => _CopilotWidgetState();
}

class _CopilotWidgetState extends State<CopilotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  OverlayEntry? _overlayEntry;
  bool _isShowingSuggestion = false;

  @override
  void initState() {
    super.initState();

    // تهيئة الأنيميشن - Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // الاستماع لتغييرات النص - Listen to text changes
    widget.textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.textController.removeListener(_onTextChanged);
    _removeOverlay();
    super.dispose();
  }

  /// معالج تغيير النص - Text change handler
  void _onTextChanged() {
    final manager = context.read<SuggestionsManager>();

    // طلب اقتراحات مع تأخير - Request suggestions with delay
    manager.requestSuggestionsWithDelay(
      code: widget.textController.text,
      language: widget.language,
      cursorPosition: widget.textController.selection.baseOffset,
      filePath: widget.filePath,
    );
  }

  /// عرض الاقتراح - Show suggestion
  void _showSuggestion(SuggestionModel suggestion) {
    if (_isShowingSuggestion) {
      _removeOverlay();
    }

    _overlayEntry = _createOverlayEntry(suggestion);
    Overlay.of(context).insert(_overlayEntry!);
    _isShowingSuggestion = true;
    _animationController.forward();
  }

  /// إخفاء الاقتراح - Hide suggestion
  void _removeOverlay() {
    if (_overlayEntry != null) {
      _animationController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _isShowingSuggestion = false;
      });
    }
  }

  /// إنشاء Overlay للاقتراح - Create suggestion overlay
  OverlayEntry _createOverlayEntry(SuggestionModel suggestion) {
    return OverlayEntry(
      builder: (context) => Positioned(
        left: 100, // يمكن حسابه ديناميكياً - Can be calculated dynamically
        top: 200, // يمكن حسابه ديناميكياً - Can be calculated dynamically
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SuggestionPopup(
            suggestion: suggestion,
            isDarkTheme: widget.isDarkTheme,
            fontSize: widget.fontSize,
            onAccept: () {
              _acceptSuggestion(suggestion);
            },
            onReject: () {
              _rejectSuggestion();
            },
            onNext: () {
              context.read<SuggestionsManager>().nextSuggestion();
            },
            onPrevious: () {
              context.read<SuggestionsManager>().previousSuggestion();
            },
          ),
        ),
      ),
    );
  }

  /// قبول الاقتراح - Accept suggestion
  void _acceptSuggestion(SuggestionModel suggestion) {
    final manager = context.read<SuggestionsManager>();
    final text = manager.acceptSelectedSuggestion();

    if (text != null) {
      // إدراج النص في المحرر - Insert text into editor
      final currentText = widget.textController.text;
      final cursorPos = widget.textController.selection.baseOffset;

      final newText =
          currentText.substring(0, cursorPos) +
          text +
          currentText.substring(cursorPos);

      widget.textController.text = newText;
      widget.textController.selection = TextSelection.collapsed(
        offset: cursorPos + text.length,
      );

      widget.onSuggestionAccepted?.call(text);
    }

    _removeOverlay();
  }

  /// رفض الاقتراح - Reject suggestion
  void _rejectSuggestion() {
    context.read<SuggestionsManager>().rejectSelectedSuggestion();
    widget.onSuggestionRejected?.call();
    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SuggestionsManager>(
      builder: (context, manager, child) {
        // عرض الاقتراح عند توفره - Show suggestion when available
        if (manager.hasSuggestions && !_isShowingSuggestion) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final suggestion = manager.selectedSuggestion;
            if (suggestion != null) {
              _showSuggestion(suggestion);
            }
          });
        } else if (!manager.hasSuggestions && _isShowingSuggestion) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _removeOverlay();
          });
        }

        // مؤشر حالة Copilot - Copilot status indicator
        return _buildStatusIndicator(manager);
      },
    );
  }

  /// بناء مؤشر الحالة - Build status indicator
  Widget _buildStatusIndicator(SuggestionsManager manager) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (manager.isFetching) {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
      statusText = 'جاري البحث... - Fetching...';
    } else if (manager.hasSuggestions) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText =
          '${manager.suggestionsCount} اقتراح - ${manager.suggestionsCount} suggestions';
    } else if (manager.lastError != null) {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = 'خطأ - Error';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.smart_toy;
      statusText = 'Copilot';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isDarkTheme
            ? const Color(0xFF2D2D30)
            : const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              color: widget.isDarkTheme ? Colors.white70 : Colors.black87,
            ),
          ),
          if (manager.isFetching) ...[
            const SizedBox(width: 6),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
