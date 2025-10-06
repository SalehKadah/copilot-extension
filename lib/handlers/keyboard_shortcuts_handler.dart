// معالج اختصارات لوحة المفاتيح - Keyboard Shortcuts Handler
// إدارة اختصارات لوحة المفاتيح لـ Copilot
// Manages keyboard shortcuts for Copilot

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../services/suggestions_manager.dart';

/// معالج اختصارات لوحة المفاتيح - Keyboard Shortcuts Handler
/// يعترض ويعالج اختصارات لوحة المفاتيح المتعلقة بـ Copilot
/// Intercepts and handles Copilot-related keyboard shortcuts
class KeyboardShortcutsHandler {
  /// مدير الاقتراحات - Suggestions manager
  final SuggestionsManager suggestionsManager;

  /// callbacks للأحداث - Event callbacks
  final VoidCallback? onAcceptSuggestion;
  final VoidCallback? onRejectSuggestion;
  final VoidCallback? onNextSuggestion;
  final VoidCallback? onPreviousSuggestion;
  final VoidCallback? onRequestSuggestions;

  KeyboardShortcutsHandler({
    required this.suggestionsManager,
    this.onAcceptSuggestion,
    this.onRejectSuggestion,
    this.onNextSuggestion,
    this.onPreviousSuggestion,
    this.onRequestSuggestions,
  });

  /// معالجة حدث لوحة المفاتيح - Handle keyboard event
  /// يُستدعى عند الضغط على مفتاح
  /// Called when a key is pressed
  KeyEventResult handleKeyEvent(KeyEvent event) {
    // التعامل فقط مع KeyDownEvent - Only handle KeyDownEvent
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // التحقق من المفاتيح المضغوطة - Check pressed keys
    final isCtrl = HardwareKeyboard.instance.isControlPressed;
    final isAlt = HardwareKeyboard.instance.isAltPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;

    // Tab - قبول الاقتراح - Accept suggestion
    if (event.logicalKey == LogicalKeyboardKey.tab &&
        !isCtrl &&
        !isAlt &&
        suggestionsManager.hasSuggestions) {
      _acceptSuggestion();
      return KeyEventResult.handled;
    }

    // Escape - رفض الاقتراح - Reject suggestion
    if (event.logicalKey == LogicalKeyboardKey.escape &&
        !isCtrl &&
        !isAlt &&
        suggestionsManager.hasSuggestions) {
      _rejectSuggestion();
      return KeyEventResult.handled;
    }

    // Alt+] - الاقتراح التالي - Next suggestion
    if (event.logicalKey == LogicalKeyboardKey.bracketRight &&
        !isCtrl &&
        isAlt &&
        suggestionsManager.hasSuggestions) {
      _nextSuggestion();
      return KeyEventResult.handled;
    }

    // Alt+[ - الاقتراح السابق - Previous suggestion
    if (event.logicalKey == LogicalKeyboardKey.bracketLeft &&
        !isCtrl &&
        isAlt &&
        suggestionsManager.hasSuggestions) {
      _previousSuggestion();
      return KeyEventResult.handled;
    }

    // Ctrl+Space - طلب اقتراحات - Request suggestions
    if (event.logicalKey == LogicalKeyboardKey.space && isCtrl && !isAlt) {
      _requestSuggestions();
      return KeyEventResult.handled;
    }

    // Ctrl+Shift+A - إعدادات Copilot - Copilot settings
    if (event.logicalKey == LogicalKeyboardKey.keyA && isCtrl && isShift) {
      _openSettings();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// قبول الاقتراح المحدد - Accept selected suggestion
  void _acceptSuggestion() {
    final text = suggestionsManager.acceptSelectedSuggestion();
    if (text != null) {
      onAcceptSuggestion?.call();
    }
  }

  /// رفض الاقتراح المحدد - Reject selected suggestion
  void _rejectSuggestion() {
    suggestionsManager.rejectSelectedSuggestion();
    onRejectSuggestion?.call();
  }

  /// الانتقال للاقتراح التالي - Move to next suggestion
  void _nextSuggestion() {
    final moved = suggestionsManager.nextSuggestion();
    if (moved) {
      onNextSuggestion?.call();
    }
  }

  /// الانتقال للاقتراح السابق - Move to previous suggestion
  void _previousSuggestion() {
    final moved = suggestionsManager.previousSuggestion();
    if (moved) {
      onPreviousSuggestion?.call();
    }
  }

  /// طلب اقتراحات - Request suggestions
  void _requestSuggestions() {
    onRequestSuggestions?.call();
  }

  /// فتح الإعدادات - Open settings
  void _openSettings() {
    // TODO: تنفيذ فتح الإعدادات - Implement settings opening
    debugPrint('⚙️ فتح إعدادات Copilot - Opening Copilot settings');
  }
}

/// Widget Wrapper لتفعيل الاختصارات - Widget Wrapper to enable shortcuts
/// يلف أي widget لإضافة معالجة اختصارات Copilot
/// Wraps any widget to add Copilot shortcuts handling
class CopilotKeyboardListener extends StatefulWidget {
  /// Widget الفرعي - Child widget
  final Widget child;

  /// معالج الاختصارات - Shortcuts handler
  final KeyboardShortcutsHandler handler;

  const CopilotKeyboardListener({
    super.key,
    required this.child,
    required this.handler,
  });

  @override
  State<CopilotKeyboardListener> createState() =>
      _CopilotKeyboardListenerState();
}

class _CopilotKeyboardListenerState extends State<CopilotKeyboardListener> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(canRequestFocus: false, skipTraversal: true);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) => widget.handler.handleKeyEvent(event),
      child: widget.child,
    );
  }
}

/// خريطة الاختصارات المتاحة - Available shortcuts map
/// للعرض في واجهة المستخدم
/// For display in user interface
class CopilotShortcuts {
  static const Map<String, String> shortcuts = {
    'Tab': 'قبول الاقتراح - Accept suggestion',
    'Escape': 'رفض الاقتراح - Reject suggestion',
    'Alt+]': 'الاقتراح التالي - Next suggestion',
    'Alt+[': 'الاقتراح السابق - Previous suggestion',
    'Ctrl+Space': 'طلب اقتراحات - Request suggestions',
    'Ctrl+Shift+A': 'إعدادات Copilot - Copilot settings',
  };

  /// الحصول على قائمة الاختصارات - Get shortcuts list
  static List<ShortcutInfo> getShortcutsList() {
    return shortcuts.entries
        .map(
          (entry) =>
              ShortcutInfo(shortcut: entry.key, description: entry.value),
        )
        .toList();
  }
}

/// معلومات الاختصار - Shortcut information
class ShortcutInfo {
  final String shortcut;
  final String description;

  const ShortcutInfo({required this.shortcut, required this.description});
}
