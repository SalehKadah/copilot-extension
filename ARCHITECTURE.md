# 🏗️ وثيقة المعمارية التفصيلية - Detailed Architecture Document
# إضافة وكيل الذكاء الاصطناعي GitHub Copilot Agent Extension

<div dir="rtl">

## 📐 نظرة معمارية شاملة - Comprehensive Architecture Overview

### الهدف من الوثيقة - Document Purpose
توضيح المعمارية التفصيلية للإضافة، شرح تدفق البيانات، العلاقات بين المكونات، وأنماط التصميم المستخدمة.

Explain the detailed architecture of the extension, data flow, component relationships, and design patterns used.

---

## 🎯 مبادئ المعمارية - Architecture Principles

### 1. Clean Architecture
**المبدأ - Principle:**
فصل واضح بين الطبقات مع اعتماد أحادي الاتجاه

Clear separation between layers with unidirectional dependency

**التطبيق - Implementation:**
```
Presentation → Business Logic → Data → External
```

**الفوائد - Benefits:**
- ✅ قابلية الاختبار العالية
- ✅ سهولة الصيانة
- ✅ قابلية التوسع
- ✅ استقلالية المكونات

---

### 2. SOLID Principles

#### S - Single Responsibility Principle
**التطبيق - Implementation:**
كل كلاس له مسؤولية واحدة فقط

Each class has only one responsibility

```dart
// ✅ صحيح - Correct
class GitHubCopilotService {
  // مسؤول فقط عن الاتصال بـ API
  // Responsible only for API connection
}

class SuggestionsManager {
  // مسؤول فقط عن إدارة الاقتراحات
  // Responsible only for managing suggestions
}

// ❌ خطأ - Wrong
class CopilotService {
  // يفعل كل شيء - Does everything
  void connectToAPI() {}
  void manageSuggestions() {}
  void renderUI() {}
}
```

---

#### O - Open/Closed Principle
**التطبيق - Implementation:**
المكونات مفتوحة للتوسع، مغلقة للتعديل

Components are open for extension, closed for modification

```dart
// Base interface للاقتراحات - Base interface for suggestions
abstract class SuggestionProvider {
  Future<List<SuggestionModel>> getSuggestions(String context);
}

// يمكن إضافة مزودين جدد دون تعديل الكود الأساسي
// Can add new providers without modifying base code
class GitHubCopilotProvider implements SuggestionProvider {
  @override
  Future<List<SuggestionModel>> getSuggestions(String context) {
    // Implementation
  }
}

class LocalAIProvider implements SuggestionProvider {
  @override
  Future<List<SuggestionModel>> getSuggestions(String context) {
    // Implementation
  }
}
```

---

#### L - Liskov Substitution Principle
**التطبيق - Implementation:**
الكلاسات الفرعية قابلة للاستبدال بالكلاس الأب

Subclasses can substitute the parent class

```dart
void processSuggestions(SuggestionProvider provider) {
  // يعمل مع أي مزود دون مشاكل
  // Works with any provider without issues
  final suggestions = await provider.getSuggestions(context);
}
```

---

#### I - Interface Segregation Principle
**التطبيق - Implementation:**
واجهات صغيرة ومتخصصة بدلاً من واجهات كبيرة

Small, specialized interfaces instead of large ones

```dart
// ✅ صحيح - Correct
abstract class Cacheable {
  Future<void> cache();
}

abstract class Loggable {
  void log(String message);
}

// ❌ خطأ - Wrong
abstract class ServiceOperations {
  Future<void> cache();
  void log(String message);
  void render();
  void validate();
}
```

---

#### D - Dependency Inversion Principle
**التطبيق - Implementation:**
الاعتماد على Abstractions وليس Concrete classes

Depend on abstractions, not concrete classes

```dart
// ✅ صحيح - Correct
class SuggestionsManager {
  final SuggestionProvider _provider; // Abstract
  
  SuggestionsManager(this._provider);
}

// ❌ خطأ - Wrong
class SuggestionsManager {
  final GitHubCopilotService _service; // Concrete
  
  SuggestionsManager() : _service = GitHubCopilotService();
}
```

---

## 📦 الطبقات المعمارية - Architecture Layers

### Layer 1: Presentation Layer (UI)

#### المسؤولية - Responsibility
عرض المعلومات والتفاعل مع المستخدم

Display information and interact with user

#### المكونات الرئيسية - Main Components

##### 1. CopilotWidget
```dart
/// الواجهة الرئيسية للإضافة
/// Main extension interface
class CopilotWidget extends StatefulWidget {
  // Properties
  final TextEditingController controller;
  final CopilotSettings settings;
  final SuggestionsManager manager;
  
  // State
  - isActive: bool
  - currentSuggestion: SuggestionModel?
  - statusIndicator: StatusIndicator
  
  // Methods
  + build(BuildContext context): Widget
  + showSuggestion(SuggestionModel): void
  + hideSuggestion(): void
  + updateStatus(Status): void
}
```

**التدفق - Flow:**
```
المستخدم يكتب
User Types
    ↓
Widget يلتقط الحدث
Widget Captures Event
    ↓
يطلب من Manager
Requests from Manager
    ↓
يعرض النتيجة
Displays Result
```

---

##### 2. SuggestionPopup
```dart
/// النافذة المنبثقة لعرض الاقتراحات
/// Popup window for displaying suggestions
class SuggestionPopup extends StatelessWidget {
  // Properties
  final SuggestionModel suggestion;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  
  // UI Components
  - suggestionText: Widget
  - confidenceBadge: Widget
  - typeBadge: Widget
  - controlButtons: Widget
  
  // Methods
  + build(BuildContext context): Widget
  + buildSuggestionCard(): Widget
  + buildControlBar(): Widget
}
```

**التصميم - Design:**
```
┌─────────────────────────────────────┐
│ 🤖 Copilot [Function] ⭐ 95%       │
├─────────────────────────────────────┤
│                                     │
│   function calculateSum(a, b) {    │
│     return a + b;                   │
│   }                                 │
│                                     │
├─────────────────────────────────────┤
│ Shortcuts: Tab↩ Esc✖ Alt+]→       │
│ [◀ Previous] [Next ▶] [✓ Accept]  │
└─────────────────────────────────────┘
```

---

##### 3. SettingsPage
```dart
/// صفحة إعدادات الإضافة
/// Extension settings page
class SettingsPage extends StatefulWidget {
  // Sections
  - generalSettings: Widget
  - apiSettings: Widget
  - displaySettings: Widget
  - shortcutsSettings: Widget
  - advancedSettings: Widget
  
  // Methods
  + build(BuildContext context): Widget
  + saveSettings(): Future<void>
  + loadSettings(): Future<void>
  + resetToDefaults(): void
}
```

---

### Layer 2: Business Logic Layer

#### المسؤولية - Responsibility
تنفيذ المنطق التجاري وإدارة الحالة

Execute business logic and manage state

#### المكونات الرئيسية - Main Components

##### 1. SuggestionsManager
```dart
/// مدير دورة حياة الاقتراحات
/// Suggestions lifecycle manager
class SuggestionsManager extends ChangeNotifier {
  // Dependencies
  final SuggestionProvider _provider;
  final CacheService _cache;
  final AnalyticsService _analytics;
  
  // State
  List<SuggestionModel> _suggestions = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  
  // Public API
  + requestSuggestions(String context): Future<void>
  + acceptSuggestion(): void
  + rejectSuggestion(): void
  + nextSuggestion(): void
  + previousSuggestion(): void
  + clearSuggestions(): void
  
  // Private methods
  - _filterSuggestions(List<SuggestionModel>): List<SuggestionModel>
  - _sortByConfidence(List<SuggestionModel>): List<SuggestionModel>
  - _cacheResult(String key, List<SuggestionModel>): Future<void>
}
```

**حالات الإدارة - State Management:**
```
Idle (خامل)
  ↓ requestSuggestions()
Loading (جاري التحميل)
  ↓ _fetchFromAPI()
Processing (معالجة)
  ↓ _filterAndSort()
Ready (جاهز)
  ↓ user action
Accepted/Rejected (مقبول/مرفوض)
  ↓ clearSuggestions()
Idle (خامل)
```

---

##### 2. KeyboardShortcutsHandler
```dart
/// معالج اختصارات لوحة المفاتيح
/// Keyboard shortcuts handler
class KeyboardShortcutsHandler {
  // Shortcuts map
  final Map<LogicalKeySet, VoidCallback> _shortcuts;
  
  // State
  bool _isEnabled = true;
  
  // Methods
  + handleKeyEvent(KeyEvent): KeyEventResult
  + registerShortcut(LogicalKeySet, VoidCallback): void
  + unregisterShortcut(LogicalKeySet): void
  + enableShortcuts(): void
  + disableShortcuts(): void
  
  // Default shortcuts
  - _initializeDefaultShortcuts(): void
}
```

**الاختصارات المدعومة - Supported Shortcuts:**
```dart
// طلب اقتراحات - Request suggestions
Ctrl + Space → requestSuggestions()

// قبول - Accept
Tab → acceptSuggestion()

// رفض - Reject
Escape → rejectSuggestion()

// التنقل - Navigation
Alt + ] → nextSuggestion()
Alt + [ → previousSuggestion()

// الإعدادات - Settings
Ctrl + Shift + A → openSettings()
```

---

##### 3. CacheManager
```dart
/// مدير الذاكرة المؤقتة
/// Cache manager
class CacheManager {
  // Storage layers
  final MemoryCache _memoryCache;
  final PersistentCache _persistentCache;
  
  // Configuration
  final int _maxMemorySize;
  final int _maxDiskSize;
  final Duration _ttl;
  
  // Methods
  + get<T>(String key): Future<T?>
  + set<T>(String key, T value, {Duration? ttl}): Future<void>
  + delete(String key): Future<void>
  + clear(): Future<void>
  + getStats(): CacheStats
  
  // Private methods
  - _evictOldEntries(): void
  - _checkMemoryLimit(): void
  - _checkDiskLimit(): void
}
```

**استراتيجية الـ Cache - Cache Strategy:**
```
طلب → Check Memory Cache
Request   ↓ Miss
          Check Persistent Cache
          ↓ Miss
          Fetch from API
          ↓
          Store in Memory + Persistent
          ↓
          Return result
```

---

### Layer 3: Data Layer

#### المسؤولية - Responsibility
التواصل مع المصادر الخارجية وإدارة البيانات

Communicate with external sources and manage data

#### المكونات الرئيسية - Main Components

##### 1. GitHubCopilotService
```dart
/// خدمة الاتصال بـ GitHub Copilot API
/// GitHub Copilot API connection service
class GitHubCopilotService implements SuggestionProvider {
  // Dependencies
  final Dio _dio;
  final Logger _logger;
  final AuthService _auth;
  
  // Configuration
  final String _baseUrl;
  final int _timeout;
  final int _maxRetries;
  
  // Public API
  @override
  + getSuggestions(String context, {
      String? language,
      int maxSuggestions = 5,
    }): Future<List<SuggestionModel>>
  
  // Private methods
  - _buildRequest(String context): Request
  - _parseResponse(Response): List<SuggestionModel>
  - _handleError(DioException): void
  - _retry<T>(Future<T> Function()): Future<T>
}
```

**تدفق API - API Flow:**
```
1. بناء الطلب - Build Request
   ↓
2. إضافة المصادقة - Add Authentication
   ↓
3. إرسال الطلب - Send Request
   ↓
4. معالجة الاستجابة - Process Response
   ↓
5. تحويل إلى Models - Convert to Models
   ↓
6. معالجة الأخطاء (إن وجدت) - Handle Errors (if any)
   ↓
7. إرجاع النتيجة - Return Result
```

**معالجة الأخطاء - Error Handling:**
```dart
try {
  final response = await _dio.post(endpoint, data: request);
  return _parseResponse(response);
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    // إعادة المحاولة - Retry
    return _retry(() => getSuggestions(context));
  } else if (e.response?.statusCode == 429) {
    // Rate limiting - Handle backoff
    await _handleRateLimiting(e.response!);
  } else {
    _logger.error('API Error: ${e.message}');
    rethrow;
  }
}
```

---

##### 2. StorageService
```dart
/// خدمة التخزين المحلي
/// Local storage service
class StorageService {
  // Storage backends
  final SharedPreferences _prefs;
  final Box _hiveBox;
  
  // Methods for settings
  + saveSetting<T>(String key, T value): Future<void>
  + loadSetting<T>(String key): T?
  + deleteSetting(String key): Future<void>
  
  // Methods for cache
  + cacheData<T>(String key, T data): Future<void>
  + getCachedData<T>(String key): T?
  + clearCache(): Future<void>
  
  // Methods for statistics
  + saveStatistics(UsageStatistics): Future<void>
  + loadStatistics(): UsageStatistics?
}
```

---

##### 3. AnalyticsService
```dart
/// خدمة تتبع الاستخدام والتحليلات
/// Usage tracking and analytics service
class AnalyticsService {
  // Storage
  final StorageService _storage;
  
  // State
  UsageStatistics _stats;
  
  // Events tracking
  + trackSuggestionRequested(String language): void
  + trackSuggestionAccepted(SuggestionModel): void
  + trackSuggestionRejected(SuggestionModel): void
  + trackResponseTime(Duration): void
  
  // Statistics
  + getStatistics(): UsageStatistics
  + getDailyStats(DateTime date): DailyStats?
  + getLanguageStats(): Map<String, int>
  + exportReport(): Future<String>
  
  // Private methods
  - _updateAcceptanceRate(): void
  - _calculateTimeSaved(): int
}
```

---

## 🔄 تدفقات البيانات الرئيسية - Main Data Flows

### 1. تدفق طلب الاقتراحات - Suggestion Request Flow

```
┌─────────────────────────────────────────────────────────┐
│                      المستخدم                          │
│                       User                              │
└───────────────────┬─────────────────────────────────────┘
                    │ يكتب كود - Types code
                    ▼
┌─────────────────────────────────────────────────────────┐
│              CopilotWidget (UI Layer)                   │
│  - يلتقط حدث الكتابة - Captures typing event          │
│  - يطبق Debounce (500ms)                               │
└───────────────────┬─────────────────────────────────────┘
                    │ onTextChanged()
                    ▼
┌─────────────────────────────────────────────────────────┐
│      KeyboardShortcutsHandler (Business Logic)          │
│  - يتحقق من الاختصارات - Checks shortcuts             │
│  - يحدد نوع الطلب - Determines request type            │
└───────────────────┬─────────────────────────────────────┘
                    │ requestSuggestions()
                    ▼
┌─────────────────────────────────────────────────────────┐
│      SuggestionsManager (Business Logic)                │
│  1. يفحص الـ Cache أولاً - Checks cache first          │
│  2. إذا وجد، يرجع من Cache - If found, return         │
│  3. إذا لم يجد، يطلب من API - If not, request API    │
└───────────────────┬─────────────────────────────────────┘
                    │ getSuggestions()
                    ▼
┌─────────────────────────────────────────────────────────┐
│          CacheManager (Data Layer)                      │
│  - يبحث في Memory Cache                                │
│  - يبحث في Persistent Cache                            │
└───────────────────┬─────────────────────────────────────┘
                    │ Miss
                    ▼
┌─────────────────────────────────────────────────────────┐
│      GitHubCopilotService (Data Layer)                  │
│  1. يبني الطلب - Builds request                        │
│  2. يضيف المصادقة - Adds authentication                │
│  3. يرسل إلى API - Sends to API                        │
│  4. يستقبل الاستجابة - Receives response               │
│  5. يحول إلى Models - Converts to models               │
└───────────────────┬─────────────────────────────────────┘
                    │ List<SuggestionModel>
                    ▼
┌─────────────────────────────────────────────────────────┐
│      SuggestionsManager (Business Logic)                │
│  1. يخزن في Cache - Stores in cache                    │
│  2. يفلتر النتائج - Filters results                    │
│  3. يرتب حسب الثقة - Sorts by confidence               │
│  4. يسجل في Analytics - Logs to analytics              │
└───────────────────┬─────────────────────────────────────┘
                    │ notifyListeners()
                    ▼
┌─────────────────────────────────────────────────────────┐
│              CopilotWidget (UI Layer)                   │
│  - يعرض SuggestionPopup - Shows popup                  │
│  - يحدث مؤشر الحالة - Updates status                  │
└───────────────────┬─────────────────────────────────────┘
                    │ Shows to user
                    ▼
┌─────────────────────────────────────────────────────────┐
│                      المستخدم                          │
│                       User                              │
│  - يقبل/يرفض - Accepts/Rejects                         │
└─────────────────────────────────────────────────────────┘
```

---

### 2. تدفق قبول الاقتراح - Accept Suggestion Flow

```
المستخدم يضغط Tab
User Presses Tab
        ↓
KeyboardShortcutsHandler
يلتقط الحدث
Captures Event
        ↓
SuggestionsManager
acceptSuggestion()
        ↓
1. يحدث حالة الاقتراح
   Updates suggestion state
        ↓
2. يدرج النص في المحرر
   Inserts text in editor
        ↓
3. يسجل في Analytics
   Logs to Analytics
        ↓
4. ينظف الحالة
   Cleans up state
        ↓
5. يخفي Popup
   Hides Popup
        ↓
المستخدم يواصل الكتابة
User Continues Typing
```

---

## 🎨 أنماط التصميم - Design Patterns

### 1. Singleton Pattern

**الاستخدام - Usage:**
للمكونات التي يجب أن يكون لها نسخة واحدة فقط

For components that should have only one instance

```dart
class CopilotExtension {
  // Private constructor
  CopilotExtension._();
  
  // Single instance
  static final CopilotExtension _instance = CopilotExtension._();
  
  // Public accessor
  static CopilotExtension get instance => _instance;
  
  // Properties and methods
  bool _isActivated = false;
  
  Future<void> activate() async {
    if (_isActivated) return;
    // Activation logic
    _isActivated = true;
  }
}
```

---

### 2. Factory Pattern

**الاستخدام - Usage:**
لإنشاء كائنات بناءً على شروط معينة

To create objects based on specific conditions

```dart
abstract class SuggestionProvider {
  factory SuggestionProvider.create(ProviderType type) {
    switch (type) {
      case ProviderType.github:
        return GitHubCopilotProvider();
      case ProviderType.local:
        return LocalAIProvider();
      case ProviderType.custom:
        return CustomProvider();
      default:
        throw UnimplementedError();
    }
  }
  
  Future<List<SuggestionModel>> getSuggestions(String context);
}
```

---

### 3. Observer Pattern (Provider)

**الاستخدام - Usage:**
لإدارة الحالة وإشعار المستمعين بالتغييرات

For state management and notifying listeners of changes

```dart
class SuggestionsManager extends ChangeNotifier {
  List<SuggestionModel> _suggestions = [];
  
  void addSuggestion(SuggestionModel suggestion) {
    _suggestions.add(suggestion);
    notifyListeners(); // إشعار جميع المستمعين - Notify all listeners
  }
}

// في الـ Widget - In Widget
Consumer<SuggestionsManager>(
  builder: (context, manager, child) {
    return SuggestionsList(
      suggestions: manager.suggestions,
    );
  },
)
```

---

### 4. Repository Pattern

**الاستخدام - Usage:**
للفصل بين منطق الأعمال وطبقة الوصول للبيانات

To separate business logic from data access layer

```dart
abstract class SettingsRepository {
  Future<CopilotSettings> loadSettings();
  Future<void> saveSettings(CopilotSettings settings);
  Future<void> deleteSettings();
}

class SettingsRepositoryImpl implements SettingsRepository {
  final StorageService _storage;
  
  SettingsRepositoryImpl(this._storage);
  
  @override
  Future<CopilotSettings> loadSettings() async {
    final json = _storage.loadSetting<Map>('copilot_settings');
    return json != null 
        ? CopilotSettings.fromJson(json) 
        : CopilotSettings.defaultSettings();
  }
  
  @override
  Future<void> saveSettings(CopilotSettings settings) async {
    await _storage.saveSetting('copilot_settings', settings.toJson());
  }
}
```

---

### 5. Strategy Pattern

**الاستخدام - Usage:**
لتحديد خوارزمية في وقت التشغيل

To define an algorithm at runtime

```dart
abstract class CacheEvictionStrategy {
  List<CacheEntry> evict(List<CacheEntry> entries, int targetSize);
}

class LRUEvictionStrategy implements CacheEvictionStrategy {
  @override
  List<CacheEntry> evict(List<CacheEntry> entries, int targetSize) {
    entries.sort((a, b) => a.lastAccessTime.compareTo(b.lastAccessTime));
    return entries.take(targetSize).toList();
  }
}

class FIFOEvictionStrategy implements CacheEvictionStrategy {
  @override
  List<CacheEntry> evict(List<CacheEntry> entries, int targetSize) {
    entries.sort((a, b) => a.createdTime.compareTo(b.createdTime));
    return entries.take(targetSize).toList();
  }
}

class CacheManager {
  CacheEvictionStrategy strategy;
  
  void setEvictionStrategy(CacheEvictionStrategy newStrategy) {
    strategy = newStrategy;
  }
}
```

---

## 🔐 الأمان والخصوصية - Security & Privacy

### 1. تخزين آمن لمفتاح API - Secure API Key Storage

```dart
class SecureStorageService {
  final FlutterSecureStorage _secureStorage;
  
  Future<void> saveApiKey(String apiKey) async {
    // تشفير قبل التخزين - Encrypt before storing
    final encrypted = await _encrypt(apiKey);
    await _secureStorage.write(
      key: 'copilot_api_key',
      value: encrypted,
    );
  }
  
  Future<String?> getApiKey() async {
    final encrypted = await _secureStorage.read(key: 'copilot_api_key');
    if (encrypted == null) return null;
    
    // فك التشفير - Decrypt
    return await _decrypt(encrypted);
  }
  
  Future<String> _encrypt(String plainText) async {
    // استخدام خوارزمية تشفير قوية
    // Use strong encryption algorithm
  }
  
  Future<String> _decrypt(String encrypted) async {
    // فك التشفير
    // Decrypt
  }
}
```

---

### 2. طلبات API آمنة - Secure API Requests

```dart
class GitHubCopilotService {
  Dio _configureDio() {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    // إضافة interceptor للأمان - Add security interceptor
    dio.interceptors.add(SecurityInterceptor());
    
    return dio;
  }
}

class SecurityInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // التحقق من HTTPS - Verify HTTPS
    if (!options.uri.scheme.contains('https')) {
      handler.reject(
        DioException(
          requestOptions: options,
          message: 'Only HTTPS connections allowed',
        ),
      );
      return;
    }
    
    // إضافة Token - Add token
    options.headers['Authorization'] = 'Bearer ${_getToken()}';
    
    handler.next(options);
  }
}
```

---

## 📊 مراقبة الأداء - Performance Monitoring

### 1. تتبع أوقات الاستجابة - Response Time Tracking

```dart
class PerformanceMonitor {
  final Logger _logger;
  final List<Duration> _responseTimes = [];
  
  Future<T> measurePerformance<T>(
    String operation,
    Future<T> Function() function,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await function();
      stopwatch.stop();
      
      _responseTimes.add(stopwatch.elapsed);
      _logger.info('$operation took ${stopwatch.elapsedMilliseconds}ms');
      
      return result;
    } catch (e) {
      stopwatch.stop();
      _logger.error('$operation failed after ${stopwatch.elapsedMilliseconds}ms');
      rethrow;
    }
  }
  
  Duration get averageResponseTime {
    if (_responseTimes.isEmpty) return Duration.zero;
    final total = _responseTimes.reduce((a, b) => a + b);
    return Duration(microseconds: total.inMicroseconds ~/ _responseTimes.length);
  }
}
```

---

### 2. مراقبة استهلاك الذاكرة - Memory Usage Monitoring

```dart
class MemoryMonitor {
  Timer? _monitoringTimer;
  
  void startMonitoring() {
    _monitoringTimer = Timer.periodic(
      Duration(seconds: 10),
      (_) => _checkMemoryUsage(),
    );
  }
  
  void _checkMemoryUsage() {
    final info = ProcessInfo.currentRss;
    final usageMB = info / (1024 * 1024);
    
    _logger.info('Memory usage: ${usageMB.toStringAsFixed(2)} MB');
    
    if (usageMB > 50) {
      _logger.warning('High memory usage detected!');
      _triggerCleanup();
    }
  }
  
  void _triggerCleanup() {
    // تنظيف الذاكرة المؤقتة - Clean cache
    CacheManager.instance.clearOldEntries();
  }
  
  void stopMonitoring() {
    _monitoringTimer?.cancel();
  }
}
```

---

## ✅ الخلاصة - Summary

تم توضيح المعمارية التفصيلية للإضافة بشكل شامل، تغطية جميع الطبقات، المكونات، أنماط التصميم، تدفقات البيانات، والاعتبارات الأمنية والأداء.

A comprehensive detailed architecture has been explained, covering all layers, components, design patterns, data flows, and security and performance considerations.

---

<div align="center">

**© 2025 Kadah Tech**

**جميع الحقوق محفوظة - All Rights Reserved**

</div>

</div>
