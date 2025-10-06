# Contributing to SA IDE GitHub Copilot Agent Extension
# المساهمة في إضافة GitHub Copilot Agent لـ SA IDE

<div dir="rtl">

شكراً لاهتمامك بالمساهمة في مشروع GitHub Copilot Agent Extension! نحن نرحب بجميع المساهمات من المجتمع.

</div>

Thank you for your interest in contributing to the GitHub Copilot Agent Extension project! We welcome all contributions from the community.

---

## Table of Contents / جدول المحتويات

- [English Version](#english-version)
  - [Code of Conduct](#code-of-conduct)
  - [How Can I Contribute?](#how-can-i-contribute)
  - [Development Setup](#development-setup)
  - [Pull Request Process](#pull-request-process)
  - [Coding Standards](#coding-standards)
  - [Testing Guidelines](#testing-guidelines)
  - [Documentation](#documentation)
  - [Community](#community)

- [النسخة العربية](#النسخة-العربية)
  - [مدونة السلوك](#مدونة-السلوك)
  - [كيف يمكنني المساهمة؟](#كيف-يمكنني-المساهمة)
  - [إعداد بيئة التطوير](#إعداد-بيئة-التطوير)
  - [عملية طلب السحب](#عملية-طلب-السحب)
  - [معايير الكود](#معايير-الكود)
  - [إرشادات الاختبار](#إرشادات-الاختبار)
  - [التوثيق](#التوثيق)
  - [المجتمع](#المجتمع)

---

# English Version

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [kadahtech@support.com](mailto:kadahtech@support.com).

### Our Pledge

We pledge to make participation in our project and our community a harassment-free experience for everyone, regardless of:
- Age
- Body size
- Disability
- Ethnicity
- Gender identity and expression
- Level of experience
- Nationality
- Personal appearance
- Race
- Religion
- Sexual identity and orientation

### Our Standards

**Positive behavior includes:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Unacceptable behavior includes:**
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information without explicit permission
- Other conduct which could reasonably be considered inappropriate

---

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the [issue tracker](https://github.com/kadahtech/copilot-extension/issues) as you might find that you don't need to create one. When you are creating a bug report, please include as many details as possible:

**Bug Report Template:**
```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**
- OS: [e.g. Windows 11, Ubuntu 22.04, macOS 13]
- SA IDE Version: [e.g. 2.2.0]
- Extension Version: [e.g. 1.0.0]
- Flutter Version: [e.g. 3.16.0]
- Dart Version: [e.g. 3.2.0]

**Additional context**
Add any other context about the problem here.
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

**Enhancement Template:**
```markdown
**Is your feature request related to a problem?**
A clear and concise description of what the problem is. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Additional context**
Add any other context or screenshots about the feature request here.

**Priority**
- [ ] Critical
- [ ] High
- [ ] Medium
- [ ] Low
```

### Your First Code Contribution

Unsure where to begin? You can start by looking through these issues:
- `good-first-issue` - Issues which should only require a few lines of code
- `help-wanted` - Issues which should be a bit more involved than `good-first-issue`
- `documentation` - Documentation improvements
- `bug` - Bug fixes

### Pull Requests

We actively welcome your pull requests:

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code lints
6. Issue that pull request!

---

## Development Setup

### Prerequisites

Before you begin, ensure you have the following installed:

```bash
# Flutter SDK (>= 3.0.0)
flutter --version

# Dart SDK (>= 3.0.0)
dart --version

# Git
git --version

# SA IDE (>= 2.0.0)
# Download from: https://www.kadahtech.com/sa-ide
```

### Getting the Code

```bash
# Clone the repository
git clone https://github.com/kadahtech/copilot-extension.git

# Navigate to the project directory
cd copilot-extension

# Install dependencies
flutter pub get

# Verify setup
flutter doctor
```

### Project Structure

```
copilot_extension/
├── lib/                           # Main source code
│   ├── extensions/               # Extension system
│   │   ├── services/            # Core services
│   │   │   ├── copilot_service.dart
│   │   │   ├── suggestion_service.dart
│   │   │   ├── analytics_service.dart
│   │   │   ├── cache_service.dart
│   │   │   └── event_service.dart
│   │   ├── models/              # Data models
│   │   │   ├── copilot_suggestion.dart
│   │   │   ├── analytics_data.dart
│   │   │   └── event_data.dart
│   │   └── views/               # UI components
│   │       ├── copilot_tab.dart
│   │       ├── suggestions_panel.dart
│   │       ├── analytics_panel.dart
│   │       └── settings_panel.dart
│   └── main.dart
├── test/                          # Test files
│   ├── extensions/
│   │   ├── copilot_service_test.dart
│   │   ├── suggestion_service_test.dart
│   │   ├── analytics_service_test.dart
│   │   ├── cache_service_test.dart
│   │   └── event_service_test.dart
├── docs/                          # Documentation
├── examples/                      # Example code
└── pubspec.yaml                  # Dependencies
```

### Running the Extension

```bash
# Run in development mode
flutter run

# Run with specific device
flutter run -d windows
flutter run -d linux
flutter run -d macos

# Run in release mode
flutter run --release
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/extensions/copilot_service_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
# Open coverage/html/index.html in browser
```

---

## Pull Request Process

### 1. Branch Naming Convention

Use descriptive branch names following this pattern:

```
feature/add-new-suggestion-type
bugfix/fix-cache-invalidation
hotfix/critical-memory-leak
docs/update-api-documentation
refactor/improve-service-architecture
test/add-analytics-tests
```

### 2. Commit Message Guidelines

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that don't affect code meaning (formatting, missing semi-colons, etc.)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `build`: Changes that affect the build system or external dependencies
- `ci`: Changes to CI configuration files and scripts
- `chore`: Other changes that don't modify src or test files

**Examples:**
```bash
feat(suggestions): add support for TypeScript suggestions
fix(cache): resolve cache invalidation issue
docs(api): update CopilotService documentation
test(analytics): add unit tests for AnalyticsService
refactor(events): improve event dispatching logic
perf(cache): optimize cache lookup performance
```

### 3. Pull Request Template

When creating a pull request, use this template:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

## Related Issue
Fixes #(issue number)

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
- [ ] All existing tests pass
- [ ] New tests added for new features
- [ ] Manual testing completed
- [ ] Test coverage maintained/improved

## Screenshots (if applicable)
Add screenshots to demonstrate changes

## Checklist
- [ ] My code follows the project's coding standards
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published

## Additional Notes
Any additional information that reviewers should know
```

### 4. Review Process

1. **Automated Checks**: CI/CD pipeline runs automatically
   - Linting (dart analyze)
   - Tests (flutter test)
   - Code coverage check
   - Build verification

2. **Code Review**: At least one maintainer must approve
   - Code quality
   - Test coverage
   - Documentation updates
   - Breaking changes assessment

3. **Merge**: Once approved and all checks pass
   - Squash and merge for feature branches
   - Rebase and merge for hotfixes
   - Update CHANGELOG.md

---

## Coding Standards

### Dart/Flutter Style Guide

We follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide:

**Naming Conventions:**
```dart
// Classes, enums, typedefs: UpperCamelCase
class CopilotService {}
enum SuggestionType {}
typedef SuggestionCallback = void Function(CopilotSuggestion);

// Libraries, packages, directories: lowercase_with_underscores
library copilot_extension;

// Variables, constants, parameters, named parameters: lowerCamelCase
var currentSuggestion = '';
const maxSuggestions = 10;

// Private members: _leadingUnderscore
class CopilotService {
  String _apiKey;
  void _processInternally() {}
}
```

**Code Formatting:**
```dart
// Use dartfmt to format your code
flutter format .

// Line length: 80 characters (configurable to 120)
// Indentation: 2 spaces
// No tabs

// Good
if (condition) {
  doSomething();
}

// Bad
if(condition){
doSomething();
}
```

**Import Organization:**
```dart
// 1. Dart imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party package imports
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// 4. Local imports
import '../models/copilot_suggestion.dart';
import '../services/cache_service.dart';
```

### Architecture Patterns

We follow **Clean Architecture** principles:

```
Presentation Layer (UI)
    ↓
Business Logic Layer (Services)
    ↓
Data Layer (Models, Repositories)
```

**SOLID Principles:**
- **S**ingle Responsibility Principle
- **O**pen/Closed Principle
- **L**iskov Substitution Principle
- **I**nterface Segregation Principle
- **D**ependency Inversion Principle

**Example:**
```dart
// Good: Single Responsibility
class CopilotService {
  Future<List<CopilotSuggestion>> getSuggestions(String code) async {
    // Only responsible for fetching suggestions
  }
}

class SuggestionFormatter {
  String format(CopilotSuggestion suggestion) {
    // Only responsible for formatting
  }
}

// Bad: Multiple responsibilities
class CopilotService {
  Future<List<CopilotSuggestion>> getSuggestions(String code) async {}
  String formatSuggestion(CopilotSuggestion suggestion) {}
  void logAnalytics(String event) {}
  void cacheResult(String key, dynamic value) {}
}
```

### Documentation

**Class Documentation:**
```dart
/// Service for managing GitHub Copilot AI code completions and suggestions.
///
/// This service handles:
/// - Fetching AI-powered code suggestions from OpenAI API
/// - Managing suggestion lifecycle and state
/// - Coordinating with cache and analytics services
///
/// Example usage:
/// ```dart
/// final service = CopilotService();
/// final suggestions = await service.getSuggestions('def fibonacci(n):');
/// ```
///
/// See also:
/// - [SuggestionService] for suggestion processing
/// - [CacheService] for caching suggestions
class CopilotService {
  // ...
}
```

**Method Documentation:**
```dart
/// Fetches AI-powered code suggestions for the given code context.
///
/// Parameters:
/// - [code]: The code context to get suggestions for
/// - [language]: Programming language (optional)
/// - [maxSuggestions]: Maximum number of suggestions (default: 5)
///
/// Returns a [Future] that completes with a list of [CopilotSuggestion]s.
///
/// Throws:
/// - [ApiException] if API request fails
/// - [CacheException] if cache operations fail
///
/// Example:
/// ```dart
/// final suggestions = await service.getSuggestions(
///   'def fibonacci(n):',
///   language: 'python',
///   maxSuggestions: 3,
/// );
/// ```
Future<List<CopilotSuggestion>> getSuggestions(
  String code, {
  String? language,
  int maxSuggestions = 5,
}) async {
  // ...
}
```

### Error Handling

```dart
// Use try-catch for expected errors
try {
  final suggestions = await copilotService.getSuggestions(code);
  return suggestions;
} on ApiException catch (e) {
  logger.error('API error: ${e.message}');
  return [];
} on CacheException catch (e) {
  logger.warning('Cache error: ${e.message}');
  // Fallback to API without cache
} catch (e, stackTrace) {
  logger.error('Unexpected error', error: e, stackTrace: stackTrace);
  rethrow;
}

// Use Result type for functions that can fail
class Result<T> {
  final T? data;
  final String? error;
  
  Result.success(this.data) : error = null;
  Result.failure(this.error) : data = null;
  
  bool get isSuccess => data != null;
  bool get isFailure => error != null;
}

Future<Result<List<CopilotSuggestion>>> getSuggestions(String code) async {
  try {
    final suggestions = await _fetchFromApi(code);
    return Result.success(suggestions);
  } catch (e) {
    return Result.failure(e.toString());
  }
}
```

---

## Testing Guidelines

### Test Structure

```dart
void main() {
  group('CopilotService', () {
    late CopilotService service;
    late MockHttpClient mockClient;
    late MockCacheService mockCache;
    
    setUp(() {
      mockClient = MockHttpClient();
      mockCache = MockCacheService();
      service = CopilotService(
        httpClient: mockClient,
        cacheService: mockCache,
      );
    });
    
    tearDown(() {
      service.dispose();
    });
    
    group('getSuggestions', () {
      test('should return suggestions for valid code', () async {
        // Arrange
        final code = 'def fibonacci(n):';
        final expectedSuggestions = [
          CopilotSuggestion(text: '    if n <= 1:', type: SuggestionType.line),
        ];
        when(mockClient.post(any)).thenAnswer((_) async => Response(
          jsonEncode({'suggestions': expectedSuggestions}),
          200,
        ));
        
        // Act
        final result = await service.getSuggestions(code);
        
        // Assert
        expect(result, expectedSuggestions);
        verify(mockClient.post(any)).called(1);
      });
      
      test('should use cache when available', () async {
        // Test cache behavior
      });
      
      test('should handle API errors gracefully', () async {
        // Test error handling
      });
    });
  });
}
```

### Test Coverage Requirements

- **Minimum coverage**: 80%
- **Critical paths**: 100%
- **New features**: 90%+
- **Bug fixes**: Must include regression test

### Types of Tests

1. **Unit Tests**: Test individual functions/classes
2. **Widget Tests**: Test UI components
3. **Integration Tests**: Test feature flows
4. **Performance Tests**: Test performance metrics

---

## Documentation

### Code Comments

```dart
// Use // for implementation comments
// Calculate fibonacci sequence iteratively

/// Use /// for API documentation (appears in generated docs)
/// Returns the nth fibonacci number

// TODO: Optimize for large values
// FIXME: Handle negative input
// NOTE: This uses memoization for better performance
```

### README Updates

When adding new features, update:
- Features list
- Installation instructions (if changed)
- Configuration options
- Examples

### API Documentation

Use `dartdoc` to generate API documentation:

```bash
# Generate documentation
dart doc .

# View documentation
# Open doc/api/index.html in browser
```

### Changelog

Follow [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format:

```markdown
## [1.1.0] - 2025-02-01

### Added
- New TypeScript suggestion support
- Configuration option for max suggestions

### Changed
- Improved cache performance by 30%
- Updated UI to Material Design 3

### Fixed
- Cache invalidation bug
- Memory leak in event system

### Deprecated
- Old suggestion format (will be removed in v2.0.0)

### Security
- Updated dependencies to fix vulnerabilities
```

---

## Community

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and discussions
- **Email**: [kadahtech@support.com](mailto:kadahtech@support.com)
- **Website**: [https://www.kadahtech.com](https://www.kadahtech.com)

### Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Awarded contributor badge
- Featured in project documentation

### Getting Help

If you need help:
1. Check existing documentation
2. Search closed issues
3. Ask in GitHub Discussions
4. Contact maintainers

---

# النسخة العربية

<div dir="rtl">

## مدونة السلوك

يخضع هذا المشروع وجميع المشاركين فيه لـ [مدونة السلوك](CODE_OF_CONDUCT.md). من خلال المشاركة، من المتوقع أن تلتزم بهذه المدونة. يرجى الإبلاغ عن السلوك غير المقبول إلى [kadahtech@support.com](mailto:kadahtech@support.com).

### تعهدنا

نتعهد بجعل المشاركة في مشروعنا ومجتمعنا تجربة خالية من التحرش للجميع، بغض النظر عن:
- العمر
- حجم الجسم
- الإعاقة
- العرق
- الهوية والتعبير الجنسي
- مستوى الخبرة
- الجنسية
- المظهر الشخصي
- العرق
- الدين
- الهوية والتوجه الجنسي

### معاييرنا

**السلوك الإيجابي يشمل:**
- استخدام لغة ترحيبية وشاملة
- احترام وجهات النظر والتجارب المختلفة
- قبول النقد البناء بلطف
- التركيز على ما هو أفضل للمجتمع
- إظهار التعاطف تجاه أعضاء المجتمع الآخرين

**السلوك غير المقبول يشمل:**
- التحرش أو التعليقات المسيئة والهجمات الشخصية أو السياسية
- التحرش العام أو الخاص
- نشر معلومات خاصة للآخرين دون إذن صريح
- أي سلوك آخر يمكن اعتباره غير لائق

---

## كيف يمكنني المساهمة؟

### الإبلاغ عن الأخطاء

قبل إنشاء تقارير الأخطاء، يرجى التحقق من [متتبع المشكلات](https://github.com/kadahtech/copilot-extension/issues). عند إنشاء تقرير خطأ، يرجى تضمين أكبر قدر ممكن من التفاصيل:

**نموذج تقرير الخطأ:**
```markdown
**وصف الخطأ**
وصف واضح وموجز للخطأ.

**خطوات إعادة الإنتاج**
خطوات لإعادة إنتاج السلوك:
1. انتقل إلى '...'
2. انقر على '....'
3. مرر لأسفل إلى '....'
4. شاهد الخطأ

**السلوك المتوقع**
وصف واضح وموجز لما توقعت حدوثه.

**لقطات الشاشة**
إذا كان ذلك مناسباً، أضف لقطات شاشة لمساعدة في شرح مشكلتك.

**البيئة:**
- نظام التشغيل: [مثل Windows 11، Ubuntu 22.04، macOS 13]
- إصدار SA IDE: [مثل 2.2.0]
- إصدار الإضافة: [مثل 1.0.0]
- إصدار Flutter: [مثل 3.16.0]
- إصدار Dart: [مثل 3.2.0]

**سياق إضافي**
أضف أي سياق آخر حول المشكلة هنا.
```

### اقتراح تحسينات

يتم تتبع اقتراحات التحسين كمشكلات GitHub. عند إنشاء اقتراح تحسين، يرجى تضمين:

**نموذج التحسين:**
```markdown
**هل طلب الميزة مرتبط بمشكلة؟**
وصف واضح وموجز لما هي المشكلة. مثال: أشعر بالإحباط دائماً عندما [...]

**وصف الحل الذي تريده**
وصف واضح وموجز لما تريد أن يحدث.

**وصف البدائل التي فكرت فيها**
وصف واضح وموجز لأي حلول أو ميزات بديلة فكرت فيها.

**سياق إضافي**
أضف أي سياق آخر أو لقطات شاشة حول طلب الميزة هنا.

**الأولوية**
- [ ] حرجة
- [ ] عالية
- [ ] متوسطة
- [ ] منخفضة
```

### مساهمتك البرمجية الأولى

غير متأكد من أين تبدأ؟ يمكنك البدء بالنظر في هذه المشكلات:
- `good-first-issue` - مشكلات يجب أن تتطلب بضعة أسطر من الكود فقط
- `help-wanted` - مشكلات يجب أن تكون أكثر تعقيداً قليلاً من `good-first-issue`
- `documentation` - تحسينات التوثيق
- `bug` - إصلاحات الأخطاء

### طلبات السحب (Pull Requests)

نرحب بنشاط بطلبات السحب الخاصة بك:

1. افصل المستودع (Fork) وأنشئ فرعك من `main`
2. إذا أضفت كوداً يجب اختباره، أضف اختبارات
3. إذا قمت بتغيير واجهات برمجة التطبيقات (APIs)، قم بتحديث الوثائق
4. تأكد من نجاح مجموعة الاختبار
5. تأكد من أن كودك يتبع معايير الكود
6. أصدر طلب السحب!

---

## إعداد بيئة التطوير

### المتطلبات الأساسية

قبل أن تبدأ، تأكد من تثبيت ما يلي:

```bash
# Flutter SDK (>= 3.0.0)
flutter --version

# Dart SDK (>= 3.0.0)
dart --version

# Git
git --version

# SA IDE (>= 2.0.0)
# التنزيل من: https://www.kadahtech.com/sa-ide
```

### الحصول على الكود

```bash
# استنساخ المستودع
git clone https://github.com/kadahtech/copilot-extension.git

# الانتقال إلى دليل المشروع
cd copilot-extension

# تثبيت التبعيات
flutter pub get

# التحقق من الإعداد
flutter doctor
```

### تشغيل الإضافة

```bash
# التشغيل في وضع التطوير
flutter run

# التشغيل مع جهاز محدد
flutter run -d windows
flutter run -d linux
flutter run -d macos

# التشغيل في وضع الإصدار
flutter run --release
```

### تشغيل الاختبارات

```bash
# تشغيل جميع الاختبارات
flutter test

# تشغيل ملف اختبار محدد
flutter test test/extensions/copilot_service_test.dart

# التشغيل مع التغطية
flutter test --coverage

# عرض تقرير التغطية
genhtml coverage/lcov.info -o coverage/html
# افتح coverage/html/index.html في المتصفح
```

---

## عملية طلب السحب

### 1. اصطلاح تسمية الفروع

استخدم أسماء فروع وصفية تتبع هذا النمط:

```
feature/add-new-suggestion-type
bugfix/fix-cache-invalidation
hotfix/critical-memory-leak
docs/update-api-documentation
refactor/improve-service-architecture
test/add-analytics-tests
```

### 2. إرشادات رسائل الالتزام (Commit)

اتبع مواصفات [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**الأنواع:**
- `feat`: ميزة جديدة
- `fix`: إصلاح خطأ
- `docs`: تغييرات الوثائق فقط
- `style`: تغييرات لا تؤثر على معنى الكود (التنسيق، إلخ)
- `refactor`: تغيير كود لا يصلح خطأ ولا يضيف ميزة
- `perf`: تغيير كود يحسن الأداء
- `test`: إضافة اختبارات مفقودة أو تصحيح اختبارات موجودة
- `build`: تغييرات تؤثر على نظام البناء أو التبعيات الخارجية
- `ci`: تغييرات على ملفات وسكريبتات تكوين CI
- `chore`: تغييرات أخرى لا تعدل ملفات src أو test

**أمثلة:**
```bash
feat(suggestions): add support for TypeScript suggestions
fix(cache): resolve cache invalidation issue
docs(api): update CopilotService documentation
test(analytics): add unit tests for AnalyticsService
refactor(events): improve event dispatching logic
perf(cache): optimize cache lookup performance
```

### 3. نموذج طلب السحب

عند إنشاء طلب سحب، استخدم هذا النموذج:

```markdown
## الوصف
وصف موجز للتغييرات

## نوع التغيير
- [ ] إصلاح خطأ (تغيير غير كاسر يصلح مشكلة)
- [ ] ميزة جديدة (تغيير غير كاسر يضيف وظيفة)
- [ ] تغيير كاسر (إصلاح أو ميزة قد تتسبب في عدم عمل الوظائف الحالية كما هو متوقع)
- [ ] تحديث التوثيق
- [ ] تحسين الأداء
- [ ] إعادة هيكلة الكود

## المشكلة ذات الصلة
يصلح #(رقم المشكلة)

## التغييرات المنجزة
- التغيير 1
- التغيير 2
- التغيير 3

## الاختبار
- [ ] جميع الاختبارات الحالية تمر
- [ ] اختبارات جديدة مضافة للميزات الجديدة
- [ ] الاختبار اليدوي مكتمل
- [ ] تغطية الاختبار محفوظة/محسنة

## لقطات الشاشة (إن وجدت)
أضف لقطات شاشة لتوضيح التغييرات

## قائمة التحقق
- [ ] كودي يتبع معايير الكود للمشروع
- [ ] لقد قمت بمراجعة ذاتية لكودي
- [ ] لقد علقت على كودي، خاصة في المناطق الصعبة الفهم
- [ ] لقد قمت بإجراء تغييرات مقابلة على التوثيق
- [ ] تغييراتي لا تولد تحذيرات جديدة
- [ ] لقد أضفت اختبارات تثبت أن إصلاحي فعال أو أن ميزتي تعمل
- [ ] الاختبارات الجديدة والحالية تمر محلياً مع تغييراتي
- [ ] أي تغييرات تابعة تم دمجها ونشرها

## ملاحظات إضافية
أي معلومات إضافية يجب أن يعرفها المراجعون
```

### 4. عملية المراجعة

1. **الفحوصات التلقائية**: يعمل خط أنابيب CI/CD تلقائياً
   - Linting (dart analyze)
   - الاختبارات (flutter test)
   - فحص تغطية الكود
   - التحقق من البناء

2. **مراجعة الكود**: يجب أن يوافق مشرف واحد على الأقل
   - جودة الكود
   - تغطية الاختبار
   - تحديثات التوثيق
   - تقييم التغييرات الكاسرة

3. **الدمج**: بمجرد الموافقة ونجاح جميع الفحوصات
   - Squash and merge لفروع الميزات
   - Rebase and merge للإصلاحات الساخنة
   - تحديث CHANGELOG.md

---

## معايير الكود

### دليل أسلوب Dart/Flutter

نتبع دليل أسلوب [Effective Dart](https://dart.dev/guides/language/effective-dart):

**اصطلاحات التسمية:**
```dart
// Classes, enums, typedefs: UpperCamelCase
class CopilotService {}
enum SuggestionType {}
typedef SuggestionCallback = void Function(CopilotSuggestion);

// Libraries, packages, directories: lowercase_with_underscores
library copilot_extension;

// Variables, constants, parameters, named parameters: lowerCamelCase
var currentSuggestion = '';
const maxSuggestions = 10;

// Private members: _leadingUnderscore
class CopilotService {
  String _apiKey;
  void _processInternally() {}
}
```

**تنسيق الكود:**
```dart
// استخدم dartfmt لتنسيق كودك
flutter format .

// طول السطر: 80 حرفاً (قابل للتكوين إلى 120)
// المسافة البادئة: مسافتان
// لا توجد علامات تبويب

// جيد
if (condition) {
  doSomething();
}

// سيء
if(condition){
doSomething();
}
```

**تنظيم الاستيراد:**
```dart
// 1. استيرادات Dart
import 'dart:async';
import 'dart:convert';

// 2. استيرادات Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. استيرادات الحزم الخارجية
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// 4. الاستيرادات المحلية
import '../models/copilot_suggestion.dart';
import '../services/cache_service.dart';
```

### أنماط البنية المعمارية

نتبع مبادئ **Clean Architecture**:

```
طبقة العرض (UI)
    ↓
طبقة منطق الأعمال (Services)
    ↓
طبقة البيانات (Models, Repositories)
```

**مبادئ SOLID:**
- **S**ingle Responsibility Principle (مبدأ المسؤولية الواحدة)
- **O**pen/Closed Principle (مبدأ المفتوح/المغلق)
- **L**iskov Substitution Principle (مبدأ استبدال ليسكوف)
- **I**nterface Segregation Principle (مبدأ فصل الواجهة)
- **D**ependency Inversion Principle (مبدأ عكس التبعية)

**مثال:**
```dart
// جيد: مسؤولية واحدة
class CopilotService {
  Future<List<CopilotSuggestion>> getSuggestions(String code) async {
    // مسؤول فقط عن جلب الاقتراحات
  }
}

class SuggestionFormatter {
  String format(CopilotSuggestion suggestion) {
    // مسؤول فقط عن التنسيق
  }
}

// سيء: مسؤوليات متعددة
class CopilotService {
  Future<List<CopilotSuggestion>> getSuggestions(String code) async {}
  String formatSuggestion(CopilotSuggestion suggestion) {}
  void logAnalytics(String event) {}
  void cacheResult(String key, dynamic value) {}
}
```

### التوثيق

**توثيق الفئات:**
```dart
/// خدمة لإدارة إكمالات واقتراحات كود GitHub Copilot AI.
///
/// تتعامل هذه الخدمة مع:
/// - جلب اقتراحات الكود المدعومة بالذكاء الاصطناعي من OpenAI API
/// - إدارة دورة حياة وحالة الاقتراحات
/// - التنسيق مع خدمات التخزين المؤقت والتحليلات
///
/// مثال الاستخدام:
/// ```dart
/// final service = CopilotService();
/// final suggestions = await service.getSuggestions('def fibonacci(n):');
/// ```
///
/// انظر أيضاً:
/// - [SuggestionService] لمعالجة الاقتراحات
/// - [CacheService] للتخزين المؤقت للاقتراحات
class CopilotService {
  // ...
}
```

**توثيق الطرق:**
```dart
/// يجلب اقتراحات الكود المدعومة بالذكاء الاصطناعي لسياق الكود المعطى.
///
/// المعاملات:
/// - [code]: سياق الكود للحصول على اقتراحات له
/// - [language]: لغة البرمجة (اختياري)
/// - [maxSuggestions]: الحد الأقصى لعدد الاقتراحات (افتراضي: 5)
///
/// يعيد [Future] يكتمل بقائمة من [CopilotSuggestion]s.
///
/// يطرح:
/// - [ApiException] إذا فشل طلب API
/// - [CacheException] إذا فشلت عمليات التخزين المؤقت
///
/// مثال:
/// ```dart
/// final suggestions = await service.getSuggestions(
///   'def fibonacci(n):',
///   language: 'python',
///   maxSuggestions: 3,
/// );
/// ```
Future<List<CopilotSuggestion>> getSuggestions(
  String code, {
  String? language,
  int maxSuggestions = 5,
}) async {
  // ...
}
```

### معالجة الأخطاء

```dart
// استخدم try-catch للأخطاء المتوقعة
try {
  final suggestions = await copilotService.getSuggestions(code);
  return suggestions;
} on ApiException catch (e) {
  logger.error('خطأ API: ${e.message}');
  return [];
} on CacheException catch (e) {
  logger.warning('خطأ التخزين المؤقت: ${e.message}');
  // العودة إلى API بدون تخزين مؤقت
} catch (e, stackTrace) {
  logger.error('خطأ غير متوقع', error: e, stackTrace: stackTrace);
  rethrow;
}

// استخدم نوع Result للوظائف التي يمكن أن تفشل
class Result<T> {
  final T? data;
  final String? error;
  
  Result.success(this.data) : error = null;
  Result.failure(this.error) : data = null;
  
  bool get isSuccess => data != null;
  bool get isFailure => error != null;
}

Future<Result<List<CopilotSuggestion>>> getSuggestions(String code) async {
  try {
    final suggestions = await _fetchFromApi(code);
    return Result.success(suggestions);
  } catch (e) {
    return Result.failure(e.toString());
  }
}
```

---

## إرشادات الاختبار

### بنية الاختبار

```dart
void main() {
  group('CopilotService', () {
    late CopilotService service;
    late MockHttpClient mockClient;
    late MockCacheService mockCache;
    
    setUp(() {
      mockClient = MockHttpClient();
      mockCache = MockCacheService();
      service = CopilotService(
        httpClient: mockClient,
        cacheService: mockCache,
      );
    });
    
    tearDown(() {
      service.dispose();
    });
    
    group('getSuggestions', () {
      test('يجب أن يعيد اقتراحات لكود صالح', () async {
        // Arrange
        final code = 'def fibonacci(n):';
        final expectedSuggestions = [
          CopilotSuggestion(text: '    if n <= 1:', type: SuggestionType.line),
        ];
        when(mockClient.post(any)).thenAnswer((_) async => Response(
          jsonEncode({'suggestions': expectedSuggestions}),
          200,
        ));
        
        // Act
        final result = await service.getSuggestions(code);
        
        // Assert
        expect(result, expectedSuggestions);
        verify(mockClient.post(any)).called(1);
      });
      
      test('يجب استخدام التخزين المؤقت عند التوفر', () async {
        // اختبار سلوك التخزين المؤقت
      });
      
      test('يجب معالجة أخطاء API بلطف', () async {
        // اختبار معالجة الأخطاء
      });
    });
  });
}
```

### متطلبات تغطية الاختبار

- **الحد الأدنى للتغطية**: 80%
- **المسارات الحرجة**: 100%
- **الميزات الجديدة**: 90%+
- **إصلاحات الأخطاء**: يجب أن تتضمن اختبار انحدار

### أنواع الاختبارات

1. **اختبارات الوحدة (Unit Tests)**: اختبار الوظائف/الفئات الفردية
2. **اختبارات الويدجت (Widget Tests)**: اختبار مكونات واجهة المستخدم
3. **اختبارات التكامل (Integration Tests)**: اختبار تدفقات الميزات
4. **اختبارات الأداء (Performance Tests)**: اختبار مقاييس الأداء

---

## التوثيق

### تعليقات الكود

```dart
// استخدم // لتعليقات التنفيذ
// حساب تسلسل فيبوناتشي بشكل تكراري

/// استخدم /// لتوثيق API (يظهر في الوثائق المولدة)
/// يعيد رقم فيبوناتشي n-th

// TODO: تحسين للقيم الكبيرة
// FIXME: معالجة الإدخال السالب
// NOTE: يستخدم هذا الحفظ للحصول على أداء أفضل
```

### تحديثات README

عند إضافة ميزات جديدة، قم بتحديث:
- قائمة الميزات
- تعليمات التثبيت (إذا تغيرت)
- خيارات التكوين
- أمثلة

### توثيق API

استخدم `dartdoc` لتوليد وثائق API:

```bash
# توليد الوثائق
dart doc .

# عرض الوثائق
# افتح doc/api/index.html في المتصفح
```

### سجل التغييرات (Changelog)

اتبع تنسيق [Keep a Changelog](https://keepachangelog.com/en/1.0.0/):

```markdown
## [1.1.0] - 2025-02-01

### أضيف
- دعم اقتراحات TypeScript الجديد
- خيار تكوين للحد الأقصى من الاقتراحات

### تغير
- تحسين أداء التخزين المؤقت بنسبة 30%
- تحديث واجهة المستخدم إلى Material Design 3

### أصلح
- خطأ إبطال التخزين المؤقت
- تسرب الذاكرة في نظام الأحداث

### مهمل (Deprecated)
- تنسيق الاقتراح القديم (سيتم إزالته في v2.0.0)

### الأمان
- تحديث التبعيات لإصلاح الثغرات الأمنية
```

---

## المجتمع

### قنوات الاتصال

- **مشكلات GitHub**: تقارير الأخطاء وطلبات الميزات
- **مناقشات GitHub**: الأسئلة والمناقشات العامة
- **البريد الإلكتروني**: [kadahtech@support.com](mailto:kadahtech@support.com)
- **الموقع الإلكتروني**: [https://www.kadahtech.com](https://www.kadahtech.com)

### التقدير

سيحصل المساهمون على:
- قائمة في CONTRIBUTORS.md
- ذكر في ملاحظات الإصدار
- شارة مساهم
- ميزة في وثائق المشروع

### الحصول على المساعدة

إذا كنت بحاجة إلى مساعدة:
1. تحقق من الوثائق الموجودة
2. ابحث في المشكلات المغلقة
3. اسأل في مناقشات GitHub
4. اتصل بالمشرفين

---

</div>

## License / الترخيص

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

<div dir="rtl">

من خلال المساهمة في هذا المشروع، فإنك توافق على أن مساهماتك ستكون مرخصة بموجب ترخيص MIT.

</div>

---

## Thank You / شكراً لك

Thank you for contributing to the SA IDE GitHub Copilot Agent Extension! Your contributions help make this project better for everyone.

<div dir="rtl">

شكراً لك على المساهمة في إضافة GitHub Copilot Agent لـ SA IDE! مساهماتك تساعد في جعل هذا المشروع أفضل للجميع.

</div>

---

**Maintained by / يُصان بواسطة**: Saleh Kadah / Kadah Tech  
**License / الترخيص**: MIT  
**Website / الموقع**: [https://www.kadahtech.com](https://www.kadahtech.com)  
**Email / البريد الإلكتروني**: [kadahtech@support.com](mailto:kadahtech@support.com)  
**Version / الإصدار**: 1.0.0  
**Last Updated / آخر تحديث**: 2025-01-XX

---

**Happy Coding! / برمجة سعيدة! 🚀**
