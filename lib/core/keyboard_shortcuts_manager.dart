// مدير اختصارات لوحة المفاتيح - Keyboard Shortcuts Manager
// إدارة مركزية لجميع اختصارات Copilot
// Centralized management for all Copilot keyboard shortcuts

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/event_manager.dart';

/// اختصار لوحة المفاتيح - Keyboard shortcut
class KeyboardShortcut {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final Set<LogicalKeyboardKey> keys;
  final VoidCallback action;
  final bool enabled;

  KeyboardShortcut({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.keys,
    required this.action,
    this.enabled = true,
  });

  /// التحقق من تطابق المفاتيح - Check if keys match
  bool matches(Set<LogicalKeyboardKey> pressedKeys) {
    if (!enabled) return false;
    return keys.difference(pressedKeys).isEmpty &&
        pressedKeys.difference(keys).isEmpty;
  }

  /// الحصول على نص الاختصار - Get shortcut text
  String get shortcutText {
    final keyNames = keys.map((key) => _getKeyName(key)).toList()..sort();
    return keyNames.join(' + ');
  }

  /// الحصول على اسم المفتاح - Get key name
  String _getKeyName(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.control ||
        key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight) {
      return 'Ctrl';
    }
    if (key == LogicalKeyboardKey.shift ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight) {
      return 'Shift';
    }
    if (key == LogicalKeyboardKey.alt ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight) {
      return 'Alt';
    }
    if (key == LogicalKeyboardKey.meta ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight) {
      return 'Meta';
    }
    return key.keyLabel;
  }

  KeyboardShortcut copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    Set<LogicalKeyboardKey>? keys,
    VoidCallback? action,
    bool? enabled,
  }) {
    return KeyboardShortcut(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      keys: keys ?? this.keys,
      action: action ?? this.action,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// مدير اختصارات لوحة المفاتيح - Keyboard Shortcuts Manager
/// Singleton pattern لضمان وجود نسخة واحدة فقط
class KeyboardShortcutsManager extends ChangeNotifier {
  static final KeyboardShortcutsManager _instance =
      KeyboardShortcutsManager._internal();
  factory KeyboardShortcutsManager() => _instance;
  KeyboardShortcutsManager._internal() {
    _initializeDefaultShortcuts();
  }

  final EventManager _eventManager = EventManager();
  final Map<String, KeyboardShortcut> _shortcuts = {};
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  bool _enabled = true;

  /// تهيئة الاختصارات الافتراضية - Initialize default shortcuts
  void _initializeDefaultShortcuts() {
    // اقتراح التكملة - Trigger suggestion
    registerShortcut(
      KeyboardShortcut(
        id: 'trigger_suggestion',
        name: 'Trigger Suggestion',
        nameAr: 'إظهار الاقتراحات',
        description: 'Show code suggestions',
        descriptionAr: 'عرض اقتراحات الكود',
        keys: {LogicalKeyboardKey.control, LogicalKeyboardKey.space},
        action: () =>
            _eventManager.emitSimple(CopilotEventType.suggestionRequested),
      ),
    );

    // قبول الاقتراح - Accept suggestion
    registerShortcut(
      KeyboardShortcut(
        id: 'accept_suggestion',
        name: 'Accept Suggestion',
        nameAr: 'قبول الاقتراح',
        description: 'Accept the current suggestion',
        descriptionAr: 'قبول الاقتراح الحالي',
        keys: {LogicalKeyboardKey.tab},
        action: () =>
            _eventManager.emitSimple(CopilotEventType.suggestionAccepted),
      ),
    );

    // رفض الاقتراح - Reject suggestion
    registerShortcut(
      KeyboardShortcut(
        id: 'reject_suggestion',
        name: 'Reject Suggestion',
        nameAr: 'رفض الاقتراح',
        description: 'Reject the current suggestion',
        descriptionAr: 'رفض الاقتراح الحالي',
        keys: {LogicalKeyboardKey.escape},
        action: () =>
            _eventManager.emitSimple(CopilotEventType.suggestionRejected),
      ),
    );

    // الاقتراح التالي - Next suggestion
    registerShortcut(
      KeyboardShortcut(
        id: 'next_suggestion',
        name: 'Next Suggestion',
        nameAr: 'الاقتراح التالي',
        description: 'Show next suggestion',
        descriptionAr: 'عرض الاقتراح التالي',
        keys: {LogicalKeyboardKey.alt, LogicalKeyboardKey.bracketRight},
        action: () => _eventManager.emitSimple(
          CopilotEventType.suggestionRequested,
          {'direction': 'next'},
        ),
      ),
    );

    // الاقتراح السابق - Previous suggestion
    registerShortcut(
      KeyboardShortcut(
        id: 'previous_suggestion',
        name: 'Previous Suggestion',
        nameAr: 'الاقتراح السابق',
        description: 'Show previous suggestion',
        descriptionAr: 'عرض الاقتراح السابق',
        keys: {LogicalKeyboardKey.alt, LogicalKeyboardKey.bracketLeft},
        action: () => _eventManager.emitSimple(
          CopilotEventType.suggestionRequested,
          {'direction': 'previous'},
        ),
      ),
    );

    // فتح الإعدادات - Open settings
    registerShortcut(
      KeyboardShortcut(
        id: 'open_settings',
        name: 'Open Settings',
        nameAr: 'فتح الإعدادات',
        description: 'Open Copilot settings',
        descriptionAr: 'فتح إعدادات Copilot',
        keys: {
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyP,
        },
        action: () => _eventManager.emitSimple(
          CopilotEventType.settingsChanged,
          {'action': 'open'},
        ),
      ),
    );

    // عرض الإحصائيات - Show statistics
    registerShortcut(
      KeyboardShortcut(
        id: 'show_statistics',
        name: 'Show Statistics',
        nameAr: 'عرض الإحصائيات',
        description: 'Show usage statistics',
        descriptionAr: 'عرض إحصائيات الاستخدام',
        keys: {
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyS,
        },
        action: () => _eventManager.emitSimple(
          CopilotEventType.settingsChanged,
          {'action': 'statistics'},
        ),
      ),
    );

    // تبديل Copilot - Toggle Copilot
    registerShortcut(
      KeyboardShortcut(
        id: 'toggle_copilot',
        name: 'Toggle Copilot',
        nameAr: 'تبديل Copilot',
        description: 'Enable/disable Copilot',
        descriptionAr: 'تفعيل/تعطيل Copilot',
        keys: {
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyC,
        },
        action: () =>
            _eventManager.emitSimple(CopilotEventType.extensionEnabled),
      ),
    );
  }

  /// تسجيل اختصار - Register shortcut
  void registerShortcut(KeyboardShortcut shortcut) {
    _shortcuts[shortcut.id] = shortcut;
    notifyListeners();
  }

  /// إلغاء تسجيل اختصار - Unregister shortcut
  void unregisterShortcut(String id) {
    _shortcuts.remove(id);
    notifyListeners();
  }

  /// تحديث اختصار - Update shortcut
  void updateShortcut(
    String id, {
    Set<LogicalKeyboardKey>? keys,
    bool? enabled,
  }) {
    final shortcut = _shortcuts[id];
    if (shortcut != null) {
      _shortcuts[id] = shortcut.copyWith(keys: keys, enabled: enabled);
      notifyListeners();
    }
  }

  /// معالجة ضغط المفتاح - Handle key down
  KeyEventResult handleKeyDown(KeyEvent event) {
    if (!_enabled) return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);

      // البحث عن اختصار مطابق - Search for matching shortcut
      for (final shortcut in _shortcuts.values) {
        if (shortcut.matches(_pressedKeys)) {
          shortcut.action();
          return KeyEventResult.handled;
        }
      }
    }

    return KeyEventResult.ignored;
  }

  /// معالجة رفع المفتاح - Handle key up
  void handleKeyUp(KeyEvent event) {
    if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }
  }

  /// إعادة تعيين المفاتيح المضغوطة - Reset pressed keys
  void resetPressedKeys() {
    _pressedKeys.clear();
  }

  /// الحصول على جميع الاختصارات - Get all shortcuts
  List<KeyboardShortcut> getAllShortcuts() {
    return _shortcuts.values.toList();
  }

  /// الحصول على اختصار حسب المعرف - Get shortcut by id
  KeyboardShortcut? getShortcut(String id) {
    return _shortcuts[id];
  }

  /// البحث عن اختصارات - Search shortcuts
  List<KeyboardShortcut> searchShortcuts(String query) {
    final lowerQuery = query.toLowerCase();
    return _shortcuts.values.where((shortcut) {
      return shortcut.name.toLowerCase().contains(lowerQuery) ||
          shortcut.nameAr.contains(query) ||
          shortcut.description.toLowerCase().contains(lowerQuery) ||
          shortcut.descriptionAr.contains(query);
    }).toList();
  }

  /// تفعيل/تعطيل المدير - Enable/disable manager
  void setEnabled(bool enabled) {
    _enabled = enabled;
    notifyListeners();
  }

  /// هل المدير مفعل؟ - Is manager enabled?
  bool get isEnabled => _enabled;

  /// الحصول على الاختصارات حسب الفئة - Get shortcuts by category
  Map<String, List<KeyboardShortcut>> getShortcutsByCategory() {
    final categories = <String, List<KeyboardShortcut>>{
      'suggestions': [],
      'navigation': [],
      'settings': [],
      'general': [],
    };

    for (final shortcut in _shortcuts.values) {
      if (shortcut.id.contains('suggestion')) {
        categories['suggestions']!.add(shortcut);
      } else if (shortcut.id.contains('next') ||
          shortcut.id.contains('previous')) {
        categories['navigation']!.add(shortcut);
      } else if (shortcut.id.contains('settings') ||
          shortcut.id.contains('statistics')) {
        categories['settings']!.add(shortcut);
      } else {
        categories['general']!.add(shortcut);
      }
    }

    return categories;
  }

  /// إعادة تعيين للافتراضي - Reset to defaults
  void resetToDefaults() {
    _shortcuts.clear();
    _initializeDefaultShortcuts();
    notifyListeners();
  }

  /// التحقق من تعارض الاختصارات - Check for shortcut conflicts
  List<KeyboardShortcut> findConflicts(KeyboardShortcut shortcut) {
    return _shortcuts.values
        .where((s) => s.id != shortcut.id && s.enabled)
        .where(
          (s) =>
              s.keys.difference(shortcut.keys).isEmpty &&
              shortcut.keys.difference(s.keys).isEmpty,
        )
        .toList();
  }

  /// حفظ الاختصارات - Save shortcuts
  Map<String, dynamic> exportShortcuts() {
    return _shortcuts.map(
      (id, shortcut) => MapEntry(id, {
        'keys': shortcut.keys.map((k) => k.keyId).toList(),
        'enabled': shortcut.enabled,
      }),
    );
  }

  /// تحميل الاختصارات - Load shortcuts
  void importShortcuts(Map<String, dynamic> data) {
    for (final entry in data.entries) {
      final id = entry.key;
      final config = entry.value as Map<String, dynamic>;
      final keys = (config['keys'] as List)
          .map((keyId) => LogicalKeyboardKey.findKeyByKeyId(keyId as int))
          .whereType<LogicalKeyboardKey>()
          .toSet();
      final enabled = config['enabled'] as bool? ?? true;

      updateShortcut(id, keys: keys, enabled: enabled);
    }
  }

  @override
  void dispose() {
    _shortcuts.clear();
    _pressedKeys.clear();
    super.dispose();
  }
}

/// Widget لمعالجة اختصارات لوحة المفاتيح - Keyboard shortcuts handler widget
class KeyboardShortcutsHandler extends StatefulWidget {
  final Widget child;

  const KeyboardShortcutsHandler({required this.child, super.key});

  @override
  State<KeyboardShortcutsHandler> createState() =>
      _KeyboardShortcutsHandlerState();
}

class _KeyboardShortcutsHandlerState extends State<KeyboardShortcutsHandler> {
  final KeyboardShortcutsManager _manager = KeyboardShortcutsManager();

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          return _manager.handleKeyDown(event);
        } else if (event is KeyUpEvent) {
          _manager.handleKeyUp(event);
        }
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _manager.resetPressedKeys();
    super.dispose();
  }
}

/// Widget لعرض قائمة الاختصارات - Shortcuts list widget
class ShortcutsListWidget extends StatelessWidget {
  final KeyboardShortcutsManager _manager = KeyboardShortcutsManager();

  ShortcutsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = _manager.getShortcutsByCategory();

    return ListView(
      children: [
        _buildCategorySection(
          'الاقتراحات - Suggestions',
          categories['suggestions']!,
          Icons.lightbulb,
        ),
        _buildCategorySection(
          'التنقل - Navigation',
          categories['navigation']!,
          Icons.navigation,
        ),
        _buildCategorySection(
          'الإعدادات - Settings',
          categories['settings']!,
          Icons.settings,
        ),
        _buildCategorySection(
          'عام - General',
          categories['general']!,
          Icons.apps,
        ),
      ],
    );
  }

  Widget _buildCategorySection(
    String title,
    List<KeyboardShortcut> shortcuts,
    IconData icon,
  ) {
    if (shortcuts.isEmpty) return const SizedBox();

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...shortcuts.map(
            (shortcut) => ListTile(
              title: Text('${shortcut.nameAr} - ${shortcut.name}'),
              subtitle: Text(
                '${shortcut.descriptionAr}\n${shortcut.description}',
              ),
              trailing: Chip(
                label: Text(shortcut.shortcutText),
                backgroundColor: Colors.blue.shade100,
              ),
              isThreeLine: true,
            ),
          ),
        ],
      ),
    );
  }
}
