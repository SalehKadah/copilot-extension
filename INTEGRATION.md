# 🔌 دليل التكامل مع SA IDE - SA IDE Integration Guide
# GitHub Copilot Agent Extension

<div dir="rtl">

## 📋 نظرة عامة - Overview

دليل شامل لتكامل إضافة GitHub Copilot Agent مع بيئة التطوير SA IDE.

Comprehensive guide for integrating GitHub Copilot Agent extension with SA IDE.

---

## 🚀 التكامل الأساسي - Basic Integration

### الخطوة 1: إضافة المكتبة

في ملف `pubspec.yaml` الخاص بـ SA IDE:

```yaml
dependencies:
  copilot_extension:
    path: ../copilot_extension
    # أو من pub.dev
    # copilot_extension: ^1.0.0
```

### الخطوة 2: الاستيراد

في ملف `lib/views/sa_ide_view.dart`:

```dart
// استيراد الإضافة - Import extension
import 'package:copilot_extension/main.dart';
```

### الخطوة 3: التهيئة

```dart
class _SaIdeViewState extends State<SaIdeView> {
  CopilotExtension? _copilotExtension;
  
  @override
  void initState() {
    super.initState();
    _initializeCopilot();
  }
  
  Future<void> _initializeCopilot() async {
    try {
      _copilotExtension = await CopilotExtension.activate(
        settings: CopilotSettingsModel(
          apiKey: 'YOUR_API_KEY', // من الإعدادات
          enabled: true,
          autoTrigger: true,
          maxSuggestions: 5,
        ),
      );
      
      setState(() {});
      
      debugPrint('✅ تم تفعيل Copilot - Copilot activated');
    } catch (e) {
      debugPrint('❌ خطأ في تفعيل Copilot - Error activating Copilot: $e');
    }
  }
  
  @override
  void dispose() {
    _copilotExtension?.deactivate();
    super.dispose();
  }
}
```

---

## 🎨 التكامل مع الواجهة - UI Integration

### إضافة Provider

لف الـ MaterialApp أو الـ Widget الرئيسي:

```dart
@override
Widget build(BuildContext context) {
  if (_copilotExtension == null) {
    return const CircularProgressIndicator();
  }
  
  return CopilotExtension.createProvider(
    extension: _copilotExtension,
    child: Scaffold(
      // البقية
    ),
  );
}
```

### دمج مع المحرر

في منطقة المحرر (داخل `_buildEditorContent`):

```dart
Widget _buildEditorContent() {
  final activeTab = _getActiveTab();
  if (activeTab == null) return _buildWelcomeContent();
  
  return Stack(
    children: [
      // المحرر الأساسي - Base editor
      SaCodeEditorStack(
        file: activeTab.fileModel!,
        settings: settings,
        onContentChanged: (content) {
          // معالجة التغيير
        },
      ),
      
      // واجهة Copilot - Copilot UI
      if (_copilotExtension != null)
        Positioned(
          right: 16,
          bottom: 16,
          child: CopilotExtension.createWidget(
            textController: _getActiveTextController(),
            language: _getLanguageForFile(activeTab.filePath),
            filePath: activeTab.filePath,
            isDarkTheme: settings.isDarkMode,
            fontSize: settings.editorFontSize,
            onSuggestionAccepted: (suggestion) {
              _handleCopilotSuggestionAccepted(suggestion);
            },
            onSuggestionRejected: () {
              _handleCopilotSuggestionRejected();
            },
          ),
        ),
    ],
  );
}
```

---

## ⌨️ تكامل اختصارات لوحة المفاتيح

### إضافة معالج الاختصارات

```dart
class _SaIdeViewState extends State<SaIdeView> {
  late KeyboardShortcutsHandler _copilotShortcutsHandler;
  
  @override
  void initState() {
    super.initState();
    _initializeCopilot();
    _initializeCopilotShortcuts();
  }
  
  void _initializeCopilotShortcuts() {
    _copilotShortcutsHandler = KeyboardShortcutsHandler(
      suggestionsManager: _copilotExtension!.suggestionsManager,
      onAcceptSuggestion: () {
        // معالجة القبول
        _insertCopilotSuggestion();
      },
      onRejectSuggestion: () {
        // معالجة الرفض
        _clearCopilotSuggestion();
      },
      onNextSuggestion: () {
        // الاقتراح التالي
        setState(() {});
      },
      onPreviousSuggestion: () {
        // الاقتراح السابق
        setState(() {});
      },
      onRequestSuggestions: () {
        // طلب اقتراحات
        _requestCopilotSuggestions();
      },
    );
  }
}
```

### لف الواجهة بمعالج الاختصارات

```dart
@override
Widget build(BuildContext context) {
  if (_copilotExtension == null) {
    return const CircularProgressIndicator();
  }
  
  return CopilotKeyboardListener(
    handler: _copilotShortcutsHandler,
    child: CopilotExtension.createProvider(
      extension: _copilotExtension,
      child: Scaffold(
        // البقية
      ),
    ),
  );
}
```

---

## 📊 تكامل شريط الحالة - Status Bar Integration

### إضافة مؤشر Copilot

في ملف `lib/views/components/status_bar/status_bar.dart`:

```dart
class IdeStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          // العناصر الحالية
          // ...
          
          // مؤشر Copilot - Copilot indicator
          Consumer<SuggestionsManager>(
            builder: (context, manager, child) {
              return _buildCopilotIndicator(manager);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildCopilotIndicator(SuggestionsManager manager) {
    final isActive = manager.hasSuggestions;
    final isFetching = manager.isFetching;
    
    return InkWell(
      onTap: () => _showCopilotMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.smart_toy,
              size: 14,
              color: isActive ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              'Copilot',
              style: TextStyle(fontSize: 11),
            ),
            if (isFetching)
              Container(
                margin: const EdgeInsets.only(left: 4),
                width: 10,
                height: 10,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔧 تكامل الإعدادات - Settings Integration

### إضافة صفحة إعدادات Copilot

```dart
// في lib/settings/copilot_settings_page.dart

class CopilotSettingsPage extends StatefulWidget {
  final CopilotExtension extension;
  
  const CopilotSettingsPage({required this.extension});
  
  @override
  State<CopilotSettingsPage> createState() => _CopilotSettingsPageState();
}

class _CopilotSettingsPageState extends State<CopilotSettingsPage> {
  late CopilotSettingsModel _settings;
  
  @override
  void initState() {
    super.initState();
    _settings = widget.extension.extensionModel!.settings;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات Copilot - Copilot Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // تفعيل/إيقاف - Enable/Disable
          SwitchListTile(
            title: Text('تفعيل Copilot - Enable Copilot'),
            value: _settings.enabled,
            onChanged: (value) {
              setState(() => _settings.enabled = value);
              _saveSettings();
            },
          ),
          
          // التشغيل التلقائي - Auto-trigger
          SwitchListTile(
            title: Text('التشغيل التلقائي - Auto-trigger'),
            subtitle: Text('اقتراحات تلقائية أثناء الكتابة'),
            value: _settings.autoTrigger,
            onChanged: (value) {
              setState(() => _settings.autoTrigger = value);
              _saveSettings();
            },
          ),
          
          // التأخير - Delay
          ListTile(
            title: Text('التأخير (ميلي ثانية) - Delay (ms)'),
            subtitle: Slider(
              value: _settings.suggestionDelay.toDouble(),
              min: 100,
              max: 2000,
              divisions: 19,
              label: '${_settings.suggestionDelay}ms',
              onChanged: (value) {
                setState(() => _settings.suggestionDelay = value.toInt());
              },
              onChangeEnd: (value) => _saveSettings(),
            ),
          ),
          
          // عدد الاقتراحات - Max suggestions
          ListTile(
            title: Text('عدد الاقتراحات - Max Suggestions'),
            subtitle: Slider(
              value: _settings.maxSuggestions.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '${_settings.maxSuggestions}',
              onChanged: (value) {
                setState(() => _settings.maxSuggestions = value.toInt());
              },
              onChangeEnd: (value) => _saveSettings(),
            ),
          ),
          
          // مفتاح API - API Key
          TextField(
            decoration: InputDecoration(
              labelText: 'مفتاح API - API Key',
              hintText: 'أدخل مفتاح GitHub Copilot',
            ),
            obscureText: true,
            controller: TextEditingController(text: _settings.apiKey),
            onChanged: (value) {
              _settings.apiKey = value;
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }
  
  Future<void> _saveSettings() async {
    await widget.extension.saveSettings(_settings);
  }
}
```

### إضافة إلى قائمة الإعدادات

في قائمة View أو Settings:

```dart
MenuItem(
  label: 'إعدادات Copilot - Copilot Settings',
  onTap: () => _openCopilotSettings(),
),
```

---

## 📦 التكامل مع نظام الإضافات

### تسجيل الإضافة

في ملف `lib/extensions/extension_registry.dart`:

```dart
// تسجيل الإضافة عند البدء
Future<void> registerCopilotExtension() async {
  final extension = await CopilotExtension.activate();
  
  ExtensionRegistry.register(
    ExtensionInfo(
      id: 'copilot-agent-extension',
      name: 'GitHub Copilot Agent',
      version: '1.0.0',
      description: 'AI-powered code suggestions',
      author: 'Saleh Kadah',
      isActive: true,
      extension: extension,
    ),
  );
}
```

---

## 🔍 التكامل مع نظام البحث

### إضافة بحث في الاقتراحات

```dart
// في search_view.dart
void searchCopilotHistory() {
  final manager = Provider.of<SuggestionsManager>(context, listen: false);
  final stats = manager.getStatistics();
  
  // عرض تاريخ الاقتراحات
  // Display suggestions history
}
```

---

## 📊 التكامل مع الإحصائيات

### عرض إحصائيات Copilot

```dart
Widget _buildCopilotStatistics() {
  final extension = _copilotExtension;
  if (extension == null) return Container();
  
  final stats = extension.getStatistics();
  
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إحصائيات Copilot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          _buildStatRow('الاقتراحات المعروضة', stats['statistics']['totalSuggestionsShown']),
          _buildStatRow('الاقتراحات المقبولة', stats['statistics']['totalSuggestionsAccepted']),
          _buildStatRow('نسبة القبول', '${(stats['statistics']['acceptanceRate'] * 100).toStringAsFixed(1)}%'),
          _buildStatRow('حجم الذاكرة المؤقتة', stats['suggestions_manager']['cache_size']),
        ],
      ),
    ),
  );
}

Widget _buildStatRow(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
```

---

## 🧪 الاختبار - Testing

### اختبار التكامل

```dart
// في test/integration/copilot_integration_test.dart

void main() {
  testWidgets('Copilot integration test', (tester) async {
    // تهيئة الإضافة
    final extension = await CopilotExtension.activate(
      settings: CopilotSettingsModel(
        apiKey: 'test_key',
        enabled: true,
      ),
    );
    
    // بناء الواجهة
    await tester.pumpWidget(
      CopilotExtension.createProvider(
        extension: extension,
        child: MaterialApp(
          home: SaIdeView(),
        ),
      ),
    );
    
    // التحقق من التفعيل
    expect(extension.isInitialized, isTrue);
    
    // محاكاة الكتابة
    // ...
    
    // التحقق من الاقتراحات
    // ...
  });
}
```

---

## 📝 ملاحظات مهمة - Important Notes

### الأداء
- استخدم الذاكرة المؤقتة لتحسين الأداء
- تجنب الطلبات المتكررة غير الضرورية
- راقب استهلاك الذاكرة

### الأمان
- لا تحفظ مفتاح API في الكود
- استخدم متغيرات البيئة
- شفّر البيانات الحساسة

### تجربة المستخدم
- قدم ملاحظات فورية
- اجعل الواجهة سلسة
- احترم تفضيلات المستخدم

---

## 🆘 الدعم - Support

### واجهت مشكلة؟
- راجع [DOCUMENTATION.md](DOCUMENTATION.md)
- راجع [QUICKSTART.md](QUICKSTART.md)
- افتح [Issue](https://github.com/SalehKadah/copilot-extension/issues)

### تحتاج مساعدة؟
- **Email**: saleh@kadahtech.com
- **Discord**: https://discord.gg/saide

---

<div align="center">

**التكامل الناجح يبدأ من هنا! 🚀**

Successful Integration Starts Here! 🚀

</div>

</div>
