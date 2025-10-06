# 🚀 دليل البدء السريع - Quick Start Guide
# GitHub Copilot Agent Extension

<div dir="rtl">

## ⚡ البدء السريع - Quick Start

### التثبيت في 3 خطوات

#### 1️⃣ تثبيت الإضافة

```bash
# نسخ المجلد إلى مجلد الإضافات
cp -r copilot_extension ~/.sa_ide/extensions/

# أو استخدام أمر SA IDE
sa-ide extensions install copilot_extension
```

#### 2️⃣ إعداد مفتاح API

```dart
// في ملف main.dart للبيئة
import 'package:copilot_extension/main.dart';

final settings = CopilotSettingsModel(
  apiKey: 'YOUR_GITHUB_COPILOT_API_KEY',
  enabled: true,
);

await CopilotExtension.activate(settings: settings);
```

#### 3️⃣ الاستخدام في المحرر

```dart
// في ملف sa_ide_view.dart
import 'package:copilot_extension/main.dart';

// لف المحرر بـ Provider
CopilotExtension.createProvider(
  child: YourEditorWidget(),
)

// إضافة Widget الإضافة
CopilotExtension.createWidget(
  textController: _textController,
  language: 'dart',
  filePath: currentFile.path,
)
```

---

## 🎮 الاستخدام الأساسي

### الحصول على اقتراحات

```dart
// تلقائياً أثناء الكتابة
// اكتب الكود وانتظر 500ms

// أو يدوياً
// اضغط Ctrl+Space
```

### قبول الاقتراح

```dart
// اضغط Tab
// أو اضغط على زر القبول
```

### رفض الاقتراح

```dart
// اضغط Escape
// أو اضغط على زر الرفض
```

### التنقل بين الاقتراحات

```dart
// Alt+] للتالي
// Alt+[ للسابق
```

---

## ⚙️ الإعدادات السريعة

### تخصيص الإعدادات

```dart
final settings = CopilotSettingsModel(
  // تفعيل/إيقاف
  enabled: true,
  
  // التشغيل التلقائي
  autoTrigger: true,
  
  // التأخير (ميلي ثانية)
  suggestionDelay: 500,
  
  // عدد الاقتراحات
  maxSuggestions: 5,
  
  // اللغات المدعومة
  enableForLanguages: ['sa', 'dart', 'javascript'],
  
  // عرض التعليقات
  showInlineComments: true,
  
  // مفتاح API
  apiKey: 'your_api_key_here',
);
```

### حفظ الإعدادات

```dart
final extension = CopilotExtension();
await extension.saveSettings(settings);
```

---

## 📊 مثال كامل

### التكامل في SA IDE

```dart
// في ملف sa_ide_view.dart

import 'package:flutter/material.dart';
import 'package:copilot_extension/main.dart';

class SaIdeView extends StatefulWidget {
  @override
  State<SaIdeView> createState() => _SaIdeViewState();
}

class _SaIdeViewState extends State<SaIdeView> {
  late TextEditingController _textController;
  CopilotExtension? _copilotExtension;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _initializeCopilot();
  }

  Future<void> _initializeCopilot() async {
    // تفعيل الإضافة
    _copilotExtension = await CopilotExtension.activate(
      settings: CopilotSettingsModel(
        apiKey: 'YOUR_API_KEY',
        enabled: true,
        autoTrigger: true,
      ),
    );
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_copilotExtension == null) {
      return CircularProgressIndicator();
    }

    return CopilotExtension.createProvider(
      extension: _copilotExtension,
      child: Scaffold(
        body: Column(
          children: [
            // المحرر مع Copilot
            Expanded(
              child: Stack(
                children: [
                  // محرر الكود
                  TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                  ),
                  
                  // واجهة Copilot
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: CopilotExtension.createWidget(
                      textController: _textController,
                      language: 'dart',
                      filePath: '/path/to/file.dart',
                      isDarkTheme: true,
                      onSuggestionAccepted: (text) {
                        print('تم قبول: $text');
                      },
                      onSuggestionRejected: () {
                        print('تم الرفض');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _copilotExtension?.deactivate();
    super.dispose();
  }
}
```

---

## 🔧 استكشاف الأخطاء السريع

### المشكلة: لا توجد اقتراحات

```dart
// 1. تحقق من التفعيل
print(_copilotExtension?.isInitialized); // يجب أن يكون true

// 2. تحقق من الإعدادات
final settings = _copilotExtension?.extensionModel?.settings;
print('Enabled: ${settings?.enabled}');
print('Has API Key: ${settings?.apiKey.isNotEmpty}');

// 3. تحقق من الاتصال
final service = GitHubCopilotService();
print('Connected: ${service.isConnected}');
```

### المشكلة: الأداء بطيء

```dart
// قلل التأخير
settings.suggestionDelay = 300; // بدلاً من 500

// فعّل الذاكرة المؤقتة
settings.useCache = true;

// قلل عدد الاقتراحات
settings.maxSuggestions = 3;
```

### المشكلة: خطأ في API

```dart
// تحقق من المفتاح
if (settings.apiKey.isEmpty) {
  print('❌ مفتاح API مفقود');
}

// أعد الاتصال
final service = GitHubCopilotService();
await service.reconnect();
```

---

## 📚 موارد إضافية

### الوثائق الكاملة
- [DOCUMENTATION.md](DOCUMENTATION.md) - دليل المطور الشامل
- [README.md](README.md) - معلومات عامة عن الإضافة
- [API Reference](DOCUMENTATION.md#مرجع-api) - مرجع API الكامل

### أمثلة
- [examples/basic_usage.dart](examples/basic_usage.dart) - استخدام أساسي
- [examples/advanced_usage.dart](examples/advanced_usage.dart) - استخدام متقدم
- [examples/custom_settings.dart](examples/custom_settings.dart) - إعدادات مخصصة

### الدعم
- **Issues**: https://github.com/SalehKadah/copilot-extension/issues
- **Email**: saleh@kadahtech.com
- **Discord**: https://discord.gg/saide

---

## 🎯 النصائح السريعة

### 💡 نصيحة 1: استخدم الاختصارات
```
Ctrl+Space    → طلب اقتراحات
Tab           → قبول
Escape        → رفض
Alt+]         → التالي
Alt+[         → السابق
```

### 💡 نصيحة 2: خصص الإعدادات
```dart
// للحصول على أداء أفضل
settings.useCache = true;
settings.suggestionDelay = 300;
```

### 💡 نصيحة 3: راقب الإحصائيات
```dart
final stats = _copilotExtension?.getStatistics();
print('نسبة القبول: ${stats['acceptance_rate']}%');
```

---

## 🚀 الخطوات التالية

1. ✅ قم بتثبيت الإضافة
2. ✅ اضبط مفتاح API
3. ✅ جرب الاقتراحات
4. ✅ خصص الإعدادات
5. ✅ استكشف الميزات المتقدمة

---

<div align="center">

**جاهز للبدء؟ ابدأ الآن! 🎉**

Ready to start? Begin now! 🎉

[📖 الوثائق الكاملة](DOCUMENTATION.md) | [🐛 الإبلاغ عن خطأ](https://github.com/SalehKadah/copilot-extension/issues) | [💬 الدعم](mailto:saleh@kadahtech.com)

</div>

</div>
