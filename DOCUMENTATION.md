# 📚 دليل التطوير الشامل - Comprehensive Development Documentation
# GitHub Copilot Agent Extension

<div dir="rtl">

## 📋 جدول المحتويات - Table of Contents

1. [نظرة عامة](#نظرة-عامة)
2. [الهندسة المعمارية](#الهندسة-المعمارية)
3. [دليل التطوير](#دليل-التطوير)
4. [مرجع API](#مرجع-api)
5. [أفضل الممارسات](#أفضل-الممارسات)
6. [استكشاف الأخطاء](#استكشاف-الأخطاء)
7. [التطوير المستقبلي](#التطوير-المستقبلي)

---

## 🎯 نظرة عامة

### الوصف

إضافة احترافية لبيئة التطوير SA IDE توفر اقتراحات كود ذكية باستخدام GitHub Copilot AI. مصممة بمعايير احترافية عالية مع دعم كامل للغتين العربية والإنجليزية.

### المميزات الرئيسية

#### ✨ الوظائف الأساسية
- 🧠 **اقتراحات ذكية**: استخدام AI من GitHub Copilot
- ⚡ **أداء عالي**: معالجة فورية وذاكرة مؤقتة ذكية
- 🎨 **واجهة احترافية**: تصميم نظيف ومتجاوب
- 🌍 **دعم متعدد اللغات**: عربي وإنجليزي بالكامل
- ⌨️ **اختصارات قوية**: تحكم كامل من لوحة المفاتيح

#### 🔧 المميزات التقنية
- **معمارية نظيفة**: فصل واضح للمسؤوليات
- **قابلية التوسع**: سهولة إضافة ميزات جديدة
- **اختبارات شاملة**: تغطية كاملة للكود
- **توثيق كامل**: شرح مفصل لكل جزء
- **إدارة الحالة**: استخدام Provider/Riverpod

---

## 🏗️ الهندسة المعمارية

### هيكل المشروع

```
copilot_extension/
├── lib/
│   ├── main.dart                    # نقطة الدخول الرئيسية
│   ├── models/                      # نماذج البيانات
│   │   ├── copilot_extension_model.dart
│   │   ├── copilot_settings_model.dart
│   │   └── suggestion_model.dart
│   ├── services/                    # طبقة الخدمات
│   │   ├── github_copilot_service.dart
│   │   └── suggestions_manager.dart
│   ├── widgets/                     # واجهات المستخدم
│   │   ├── copilot_widget.dart
│   │   └── suggestion_popup.dart
│   └── handlers/                    # معالجات الأحداث
│       └── keyboard_shortcuts_handler.dart
├── test/                           # الاختبارات
├── assets/                         # الموارد
├── pubspec.yaml                    # التكوين
├── extension.json                  # معلومات الإضافة
└── README.md                       # الوثائق
```

### مخطط المعمارية

```
┌─────────────────────────────────────────────────────┐
│                    SA IDE                           │
│  ┌───────────────────────────────────────────────┐  │
│  │           CopilotExtension (Main)            │  │
│  │  ┌────────────────────────────────────────┐  │  │
│  │  │     SuggestionsManager                 │  │  │
│  │  │  ┌──────────────────────────────────┐  │  │  │
│  │  │  │  GitHubCopilotService           │  │  │  │
│  │  │  │  (API Communication)            │  │  │  │
│  │  │  └──────────────────────────────────┘  │  │  │
│  │  │                                         │  │  │
│  │  │  ┌──────────────────────────────────┐  │  │  │
│  │  │  │  Cache & State Management       │  │  │  │
│  │  │  └──────────────────────────────────┘  │  │  │
│  │  └────────────────────────────────────────┘  │  │
│  │                                               │  │
│  │  ┌────────────────────────────────────────┐  │  │
│  │  │     UI Layer (Widgets)                │  │  │
│  │  │  - CopilotWidget                      │  │  │
│  │  │  - SuggestionPopup                    │  │  │
│  │  └────────────────────────────────────────┘  │  │
│  │                                               │  │
│  │  ┌────────────────────────────────────────┐  │  │
│  │  │  KeyboardShortcutsHandler             │  │  │
│  │  └────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### تدفق البيانات

```
1. المستخدم يكتب كود
   ↓
2. TextController يكتشف التغيير
   ↓
3. SuggestionsManager يُطلب
   ↓
4. GitHubCopilotService يتصل بـ API
   ↓
5. تحليل وتصفية الاقتراحات
   ↓
6. تحديث UI مع الاقتراحات
   ↓
7. المستخدم يقبل/يرفض
   ↓
8. تحديث الإحصائيات
```

---

## 👨‍💻 دليل التطوير

### متطلبات التطوير

```yaml
dependencies:
  - Flutter SDK >= 3.0.0
  - Dart SDK >= 3.0.0
  - SA IDE >= 2.0.0

dev_dependencies:
  - flutter_test
  - mockito
  - build_runner
```

### إعداد بيئة التطوير

#### 1. استنساخ المشروع

```bash
git clone https://github.com/SalehKadah/copilot-extension.git
cd copilot-extension
```

#### 2. تثبيت المكتبات

```bash
flutter pub get
```

#### 3. إنشاء ملفات Code Generation

```bash
flutter pub run build_runner build
```

#### 4. تشغيل الاختبارات

```bash
flutter test
```

### دليل الكود

#### إنشاء نموذج جديد

```dart
// في lib/models/

import 'package:json_annotation/json_annotation.dart';

part 'my_model.g.dart';

@JsonSerializable()
class MyModel {
  final String id;
  final String name;
  
  MyModel({
    required this.id,
    required this.name,
  });
  
  factory MyModel.fromJson(Map<String, dynamic> json) =>
      _$MyModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$MyModelToJson(this);
}
```

#### إنشاء خدمة جديدة

```dart
// في lib/services/

class MyService {
  // السنغلتون
  static final MyService _instance = MyService._internal();
  factory MyService() => _instance;
  MyService._internal();
  
  // الخصائص
  bool _isInitialized = false;
  
  // التهيئة
  Future<void> initialize() async {
    // الكود هنا
    _isInitialized = true;
  }
  
  // التنظيف
  void dispose() {
    // الكود هنا
  }
}
```

#### إنشاء Widget جديد

```dart
// في lib/widgets/

import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
  
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // الكود هنا
    );
  }
}
```

---

## 📖 مرجع API

### CopilotExtension

#### activate()

```dart
static Future<CopilotExtension> activate({
  CopilotSettingsModel? settings,
})
```

**الوصف**: تفعيل الإضافة وتهيئتها

**المعاملات**:
- `settings` (اختياري): إعدادات مخصصة

**الإرجاع**: مثيل الإضافة

**مثال**:
```dart
final extension = await CopilotExtension.activate(
  settings: CopilotSettingsModel(
    apiKey: 'your_api_key',
    enabled: true,
  ),
);
```

#### deactivate()

```dart
Future<void> deactivate()
```

**الوصف**: إيقاف الإضافة وتنظيف الموارد

**مثال**:
```dart
await extension.deactivate();
```

### SuggestionsManager

#### requestSuggestions()

```dart
Future<List<SuggestionModel>> requestSuggestions({
  required String code,
  required String language,
  required int cursorPosition,
  String? filePath,
  bool forceRefresh = false,
})
```

**الوصف**: طلب اقتراحات من GitHub Copilot

**المعاملات**:
- `code`: الكود الحالي
- `language`: اللغة البرمجية
- `cursorPosition`: موضع المؤشر
- `filePath` (اختياري): مسار الملف
- `forceRefresh` (اختياري): تجاهل الذاكرة المؤقتة

**الإرجاع**: قائمة بالاقتراحات

**مثال**:
```dart
final suggestions = await manager.requestSuggestions(
  code: 'function calculate',
  language: 'javascript',
  cursorPosition: 18,
);
```

### GitHubCopilotService

#### getSuggestions()

```dart
Future<List<SuggestionModel>> getSuggestions({
  required String code,
  required String language,
  required int cursorPosition,
  String? filePath,
  int? maxSuggestions,
})
```

**الوصف**: الحصول على اقتراحات من API

**المعاملات**: نفس requestSuggestions

**الإرجاع**: قائمة بالاقتراحات

---

## 💡 أفضل الممارسات

### 1. إدارة الحالة

```dart
// استخدم Provider للحالة العامة
ChangeNotifierProvider<SuggestionsManager>(
  create: (_) => SuggestionsManager(),
  child: MyApp(),
)

// استخدم Consumer للوصول للحالة
Consumer<SuggestionsManager>(
  builder: (context, manager, child) {
    return Text('${manager.suggestionsCount}');
  },
)
```

### 2. معالجة الأخطاء

```dart
try {
  final suggestions = await service.getSuggestions(...);
} on DioException catch (e) {
  // معالجة أخطاء الشبكة
  handleNetworkError(e);
} catch (e) {
  // معالجة أخطاء عامة
  handleGeneralError(e);
}
```

### 3. الذاكرة المؤقتة

```dart
// استخدم الذاكرة المؤقتة للأداء
final cacheKey = _generateCacheKey(code, language, position);
if (_cache.containsKey(cacheKey)) {
  return _cache[cacheKey]!;
}
```

### 4. التسجيل

```dart
// استخدم logger للتسجيل
_logger.d('🔍 طلب اقتراحات');
_logger.i('✅ تم بنجاح');
_logger.w('⚠️ تحذير');
_logger.e('❌ خطأ');
```

---

## 🔧 استكشاف الأخطاء

### مشاكل شائعة وحلولها

#### 1. الإضافة لا تعمل

**المشكلة**: الإضافة غير مفعلة

**الحل**:
```dart
// تأكد من تفعيل الإضافة
final extension = await CopilotExtension.activate();
print(extension.isInitialized); // يجب أن يكون true
```

#### 2. لا توجد اقتراحات

**المشكلة**: API لا تُرجع اقتراحات

**الحل**:
```dart
// تحقق من:
// 1. مفتاح API صحيح
// 2. الاتصال بالإنترنت
// 3. الإعدادات مفعلة

final settings = extension.extensionModel?.settings;
print('Enabled: ${settings?.enabled}');
print('API Key: ${settings?.apiKey.isNotEmpty}');
```

#### 3. الأداء بطيء

**المشكلة**: الاقتراحات تستغرق وقتاً طويلاً

**الحل**:
```dart
// 1. قلل التأخير
settings.suggestionDelay = 300; // من 500

// 2. فعّل الذاكرة المؤقتة
settings.useCache = true;

// 3. قلل عدد الاقتراحات
settings.maxSuggestions = 3; // من 5
```

---

## 🚀 التطوير المستقبلي

### المميزات المخططة

#### المرحلة 1 (الإصدار 1.1)
- [ ] دعم وضع offline
- [ ] تحسين الذاكرة المؤقتة
- [ ] إحصائيات متقدمة
- [ ] تخصيص أكثر للواجهة

#### المرحلة 2 (الإصدار 1.2)
- [ ] دعم أكثر للغات البرمجية
- [ ] تكامل مع Git
- [ ] اقتراحات السياق الكامل للمشروع
- [ ] تعلم من اختيارات المستخدم

#### المرحلة 3 (الإصدار 2.0)
- [ ] نموذج AI محلي
- [ ] دعم فريق العمل
- [ ] مزامنة الإعدادات عبر الأجهزة
- [ ] إضافات فرعية (plugins)

### كيفية المساهمة

1. Fork المشروع
2. إنشاء فرع للميزة: `git checkout -b feature/amazing-feature`
3. Commit التغييرات: `git commit -m 'Add amazing feature'`
4. Push للفرع: `git push origin feature/amazing-feature`
5. فتح Pull Request

### معايير المساهمة

- ✅ كود نظيف ومنظم
- ✅ تعليقات بالعربية والإنجليزية
- ✅ اختبارات للميزات الجديدة
- ✅ توثيق واضح
- ✅ اتباع معايير Dart/Flutter

---

## 📞 الدعم والتواصل

### للمطورين

- **GitHub Issues**: للإبلاغ عن الأخطاء واقتراح الميزات
- **Pull Requests**: للمساهمات الكودية
- **Discord**: للنقاشات والدعم الفوري

### جهات الاتصال

- **Email**: saleh@kadahtech.com
- **Twitter**: @SalehKadah
- **Website**: https://kadahtech.com

---

## 📄 الترخيص

هذا المشروع مرخص تحت رخصة MIT. انظر ملف [LICENSE](LICENSE) للتفاصيل.

---

<div align="center">

**صُنع بـ ❤️ في المملكة العربية السعودية**

Made with ❤️ in Saudi Arabia

</div>

</div>
