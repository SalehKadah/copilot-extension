# 🤖 GitHub Copilot Agent Extension | إضافة وكيل GitHub Copilot

<div dir="rtl">

## 📖 نظرة عامة | Overview

إضافة احترافية لبيئة التطوير SA IDE توفر اقتراحات الكود الذكية باستخدام تقنية GitHub Copilot AI.

A professional extension for SA IDE that provides intelligent code suggestions using GitHub Copilot AI technology.

</div>

## ✨ Features | المميزات

<div dir="rtl">

### المميزات الرئيسية

- 🧠 **اقتراحات ذكية**: اقتراحات كود دقيقة باستخدام الذكاء الاصطناعي
- ⚡ **سريع وفعال**: استجابة فورية أثناء الكتابة
- 🌍 **دعم متعدد اللغات**: يدعم لغة ص، Dart، JavaScript، Python وغيرها
- 🎨 **واجهة احترافية**: تصميم نظيف ومتوافق مع SA IDE
- ⌨️ **اختصارات لوحة المفاتيح**: تحكم كامل بالاختصارات
- 🔒 **آمن وموثوق**: حماية بيانات المستخدم والكود
- 📊 **إحصائيات الاستخدام**: تتبع أداء الاقتراحات
- 🌙 **دعم الوضع الليلي**: واجهة متوافقة مع السمة الداكنة

</div>

## 📦 Installation | التثبيت

<div dir="rtl">

### التثبيت من السوق

1. افتح SA IDE
2. انتقل إلى Extensions (الإضافات)
3. ابحث عن "GitHub Copilot Agent"
4. اضغط على Install (تثبيت)

### التثبيت اليدوي

```bash
# نسخ الإضافة إلى مجلد الإضافات
cp -r copilot_extension ~/.sa_ide/extensions/

# أو باستخدام الأمر
sa-ide extensions install copilot_extension
```

</div>

## 🚀 Quick Start | البدء السريع

<div dir="rtl">

### 1. التفعيل

```dart
// في ملف sa_ide_view.dart أضف:
import 'package:copilot_extension/main.dart';

// تفعيل الإضافة
CopilotExtension.activate(context);
```

### 2. إعداد المفتاح

1. احصل على مفتاح API من GitHub Copilot
2. افتح الإعدادات: `Ctrl+,`
3. ابحث عن "Copilot"
4. أدخل مفتاح API

### 3. الاستخدام

- اضغط `Ctrl+Space` للحصول على اقتراحات
- اضغط `Tab` لقبول الاقتراح
- اضغط `Alt+]` للاقتراح التالي
- اضغط `Alt+[` للاقتراح السابق
- اضغط `Esc` لإلغاء الاقتراح

</div>

## ⌨️ Keyboard Shortcuts | اختصارات لوحة المفاتيح

| الاختصار | الوصف | Description |
|----------|--------|-------------|
| `Ctrl+Space` | عرض الاقتراحات | Show suggestions |
| `Tab` | قبول الاقتراح | Accept suggestion |
| `Alt+]` | الاقتراح التالي | Next suggestion |
| `Alt+[` | الاقتراح السابق | Previous suggestion |
| `Esc` | إلغاء الاقتراح | Cancel suggestion |
| `Ctrl+Shift+A` | فتح إعدادات Copilot | Open Copilot settings |

## 🎯 Supported Languages | اللغات المدعومة

<div dir="rtl">

- ✅ لغة ص (Sa Language)
- ✅ Dart
- ✅ JavaScript / TypeScript
- ✅ Python
- ✅ Java
- ✅ C++
- ✅ C#
- ✅ Go
- ✅ Rust
- ✅ PHP

</div>

## ⚙️ Configuration | الإعدادات

<div dir="rtl">

يمكن تخصيص الإضافة من خلال ملف `settings.json`:

```json
{
  "copilot.enabled": true,
  "copilot.autoTrigger": true,
  "copilot.suggestionDelay": 500,
  "copilot.maxSuggestions": 5,
  "copilot.enableForLanguages": ["sa", "dart", "javascript"],
  "copilot.showInlineComments": true
}
```

</div>

## 🛠️ Development | التطوير

<div dir="rtl">

### متطلبات التطوير

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- SA IDE >= 2.0.0

### إعداد بيئة التطوير

```bash
# تثبيت المكتبات
flutter pub get

# تشغيل الاختبارات
flutter test

# بناء الإضافة
flutter build
```

### هيكل المشروع

```
copilot_extension/
├── lib/
│   ├── main.dart                    # نقطة الدخول الرئيسية
│   ├── models/                      # نماذج البيانات
│   │   ├── copilot_extension_model.dart
│   │   ├── suggestion_model.dart
│   │   └── settings_model.dart
│   ├── services/                    # الخدمات
│   │   ├── github_copilot_service.dart
│   │   └── suggestions_manager.dart
│   ├── widgets/                     # واجهات المستخدم
│   │   ├── copilot_widget.dart
│   │   └── suggestion_popup.dart
│   └── handlers/                    # المعالجات
│       └── keyboard_shortcuts_handler.dart
├── assets/                          # الأصول
├── test/                           # الاختبارات
├── pubspec.yaml                    # التكوين
├── extension.json                  # معلومات الإضافة
└── README.md                       # الوثائق
```

</div>

## 📝 API Reference | مرجع API

<div dir="rtl">

### CopilotExtension

الفئة الرئيسية للإضافة

```dart
class CopilotExtension {
  // تفعيل الإضافة
  static Future<void> activate(BuildContext context);
  
  // إيقاف الإضافة
  static Future<void> deactivate();
  
  // الحصول على اقتراحات
  static Future<List<Suggestion>> getSuggestions(String code);
}
```

### GitHubCopilotService

خدمة التواصل مع GitHub Copilot

```dart
class GitHubCopilotService {
  // الحصول على اقتراحات من API
  Future<List<Suggestion>> fetchSuggestions({
    required String code,
    required String language,
    required int cursorPosition,
  });
}
```

</div>

## 🧪 Testing | الاختبارات

<div dir="rtl">

```bash
# تشغيل جميع الاختبارات
flutter test

# تشغيل اختبارات محددة
flutter test test/services/github_copilot_service_test.dart

# تشغيل مع التغطية
flutter test --coverage
```

</div>

## 🤝 Contributing | المساهمة

<div dir="rtl">

نرحب بمساهماتكم! يرجى اتباع الخطوات التالية:

1. Fork المشروع
2. إنشاء فرع جديد (`git checkout -b feature/amazing-feature`)
3. Commit التغييرات (`git commit -m 'Add amazing feature'`)
4. Push للفرع (`git push origin feature/amazing-feature`)
5. فتح Pull Request

</div>

## 📄 License | الترخيص

<div dir="rtl">

هذا المشروع مرخص تحت رخصة MIT - انظر ملف [LICENSE](LICENSE) للتفاصيل.

</div>

## 👤 Author | المؤلف

**Saleh Kadah**

- GitHub: [@SalehKadah](https://github.com/SalehKadah)
- Email: saleh@kadahtech.com

## 🙏 Acknowledgments | شكر وتقدير

<div dir="rtl">

- شكراً لفريق GitHub Copilot
- شكراً لمجتمع Flutter
- شكراً لمستخدمي SA IDE

</div>

## 📞 Support | الدعم

<div dir="rtl">

إذا واجهت أي مشاكل أو لديك اقتراحات:

- افتح [Issue](https://github.com/SalehKadah/copilot-extension/issues)
- أرسل بريد إلكتروني: support@kadahtech.com
- انضم إلى [Discord Server](https://discord.gg/saide)

</div>

---

<div align="center" dir="rtl">

صُنع بـ ❤️ في المملكة العربية السعودية

Made with ❤️ in Saudi Arabia

</div>
