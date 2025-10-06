# GitHub Copilot Agent - API Documentation | توثيق API

<div align="center">

![API Documentation](https://img.shields.io/badge/Documentation-API%20Reference-FF6B35?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge)
![Language](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=for-the-badge)

**🔌 Complete API Reference for GitHub Copilot Agent Extension**

**🔌 مرجع API شامل لإضافة وكيل GitHub Copilot**

[English](#english) | [العربية](#arabic)

</div>

---

<a name="english"></a>
## 📖 English API Documentation

### Table of Contents
- [Services](#services-en)
  - [GitHubCopilotService](#githubcopilotservice)
  - [SuggestionsManager](#suggestionsmanager)
  - [AnalyticsService](#analyticsservice)
  - [CacheService](#cacheservice)
  - [StorageService](#storageservice)
- [Models](#models-en)
  - [CopilotSuggestion](#copilotsuggestion)
  - [CopilotSettings](#copilotsettings)
  - [CopilotStatistics](#copilotstatistics)
- [Core](#core-en)
  - [EventManager](#eventmanager)
  - [KeyboardShortcutsManager](#keyboardshortcutsmanager)
- [Enums](#enums-en)
- [Code Examples](#code-examples-en)

---

<a name="services-en"></a>
## 🔧 Services

<a name="githubcopilotservice"></a>
### GitHubCopilotService

**Purpose:** Manages communication with GitHub Copilot API.

**Singleton Pattern:** 
```dart
final service = GitHubCopilotService.instance;
```

#### Methods

##### `initialize(String apiKey)`

Initialize the service with API key.

**Parameters:**
- `apiKey` (String) - Your GitHub Copilot API key

**Returns:** `Future<void>`

**Throws:** `ServiceException` if initialization fails

**Example:**
```dart
try {
  await GitHubCopilotService.instance.initialize('your_api_key');
  print('Service initialized successfully');
} catch (e) {
  print('Initialization failed: $e');
}
```

**Arabic Example:**
```dart
// مثال: تهيئة الخدمة
// Example: Initialize service
try {
  await GitHubCopilotService.instance.initialize('مفتاح_API_الخاص_بك');
  print('تم تهيئة الخدمة بنجاح');
} catch (e) {
  print('فشلت التهيئة: $e');
}
```

##### `getSuggestions(String code, String language, {int maxSuggestions = 5})`

Get code suggestions from Copilot API.

**Parameters:**
- `code` (String, required) - Current code context
- `language` (String, required) - Programming language (sa, dart, javascript, etc.)
- `maxSuggestions` (int, optional) - Maximum suggestions to return (default: 5)

**Returns:** `Future<List<CopilotSuggestion>>`

**Throws:** `ApiException` on API errors

**Example:**
```dart
final suggestions = await GitHubCopilotService.instance.getSuggestions(
  'function calculate',
  'javascript',
  maxSuggestions: 3,
);

for (var suggestion in suggestions) {
  print('${suggestion.type}: ${suggestion.code}');
  print('Confidence: ${suggestion.confidence}');
}
```

**Arabic Example:**
```dart
// مثال: الحصول على اقتراحات
// Example: Get suggestions
final اقتراحات = await GitHubCopilotService.instance.getSuggestions(
  'دالة حساب',
  'sa',
  maxSuggestions: 3,
);

for (var اقتراح in اقتراحات) {
  print('النوع: ${اقتراح.type}');
  print('الثقة: ${اقتراح.confidence}');
}
```

##### `dispose()`

Clean up resources and close connections.

**Returns:** `void`

**Example:**
```dart
GitHubCopilotService.instance.dispose();
```

#### Properties

##### `isInitialized`

Check if service is initialized.

**Type:** `bool` (read-only)

**Example:**
```dart
if (GitHubCopilotService.instance.isInitialized) {
  // Service is ready
  print('Service is ready');
} else {
  // Need to initialize
  print('Please initialize service');
}
```

##### `apiEndpoint`

Current API endpoint URL.

**Type:** `String` (read-only)

**Example:**
```dart
print('API Endpoint: ${GitHubCopilotService.instance.apiEndpoint}');
```

---

<a name="suggestionsmanager"></a>
### SuggestionsManager

**Purpose:** Manages suggestion filtering, ranking, and presentation.

**Singleton Pattern:**
```dart
final manager = SuggestionsManager.instance;
```

#### Methods

##### `filterSuggestions(List<CopilotSuggestion> suggestions, {double minConfidence = 0.7})`

Filter suggestions by confidence score.

**Parameters:**
- `suggestions` (List<CopilotSuggestion>, required) - List of suggestions
- `minConfidence` (double, optional) - Minimum confidence threshold (0.0-1.0)

**Returns:** `List<CopilotSuggestion>`

**Example:**
```dart
final allSuggestions = await GitHubCopilotService.instance.getSuggestions('code', 'dart');
final filtered = SuggestionsManager.instance.filterSuggestions(
  allSuggestions,
  minConfidence: 0.8,
);
print('${filtered.length} high-confidence suggestions');
```

**Arabic Example:**
```dart
// مثال: تصفية الاقتراحات
// Example: Filter suggestions
final كل_الاقتراحات = await GitHubCopilotService.instance.getSuggestions('كود', 'sa');
final المصفاة = SuggestionsManager.instance.filterSuggestions(
  كل_الاقتراحات,
  minConfidence: 0.8,
);
print('${المصفاة.length} اقتراح عالي الثقة');
```

##### `rankSuggestions(List<CopilotSuggestion> suggestions)`

Rank suggestions by quality score.

**Parameters:**
- `suggestions` (List<CopilotSuggestion>, required) - List to rank

**Returns:** `List<CopilotSuggestion>` (sorted by rank)

**Example:**
```dart
final ranked = SuggestionsManager.instance.rankSuggestions(suggestions);
// ranked[0] is the best suggestion
print('Best suggestion: ${ranked.first.code}');
```

##### `groupByType(List<CopilotSuggestion> suggestions)`

Group suggestions by type.

**Parameters:**
- `suggestions` (List<CopilotSuggestion>, required) - Suggestions to group

**Returns:** `Map<SuggestionType, List<CopilotSuggestion>>`

**Example:**
```dart
final grouped = SuggestionsManager.instance.groupByType(suggestions);
print('Function suggestions: ${grouped[SuggestionType.function]?.length ?? 0}');
print('Class suggestions: ${grouped[SuggestionType.classDeclaration]?.length ?? 0}');
```

---

<a name="analyticsservice"></a>
### AnalyticsService

**Purpose:** Tracks usage statistics and performance metrics.

**Singleton Pattern:**
```dart
final analytics = AnalyticsService.instance;
```

#### Methods

##### `trackSuggestionShown(CopilotSuggestion suggestion)`

Record that a suggestion was shown to user.

**Parameters:**
- `suggestion` (CopilotSuggestion, required) - The shown suggestion

**Returns:** `Future<void>`

**Example:**
```dart
await AnalyticsService.instance.trackSuggestionShown(suggestion);
```

##### `trackSuggestionAccepted(CopilotSuggestion suggestion)`

Record that a suggestion was accepted.

**Parameters:**
- `suggestion` (CopilotSuggestion, required) - The accepted suggestion

**Returns:** `Future<void>`

**Example:**
```dart
await AnalyticsService.instance.trackSuggestionAccepted(suggestion);
```

##### `trackSuggestionRejected(CopilotSuggestion suggestion)`

Record that a suggestion was rejected.

**Parameters:**
- `suggestion` (CopilotSuggestion, required) - The rejected suggestion

**Returns:** `Future<void>`

**Example:**
```dart
await AnalyticsService.instance.trackSuggestionRejected(suggestion);
```

##### `getStatistics({int days = 7})`

Get aggregated statistics.

**Parameters:**
- `days` (int, optional) - Number of days to include (default: 7)

**Returns:** `Future<CopilotStatistics>`

**Example:**
```dart
final stats = await AnalyticsService.instance.getStatistics(days: 30);
print('Total suggestions: ${stats.totalSuggestions}');
print('Acceptance rate: ${stats.acceptanceRate}%');
print('Most used language: ${stats.topLanguage}');
```

**Arabic Example:**
```dart
// مثال: الحصول على الإحصائيات
// Example: Get statistics
final إحصائيات = await AnalyticsService.instance.getStatistics(days: 30);
print('إجمالي الاقتراحات: ${إحصائيات.totalSuggestions}');
print('معدل القبول: ${إحصائيات.acceptanceRate}%');
print('اللغة الأكثر استخداماً: ${إحصائيات.topLanguage}');
```

##### `exportStatistics(String format)`

Export statistics to file.

**Parameters:**
- `format` (String, required) - Export format: 'json', 'csv', or 'pdf'

**Returns:** `Future<String>` (file path)

**Throws:** `ExportException` on export errors

**Example:**
```dart
try {
  final path = await AnalyticsService.instance.exportStatistics('json');
  print('Statistics exported to: $path');
} catch (e) {
  print('Export failed: $e');
}
```

---

<a name="cacheservice"></a>
### CacheService

**Purpose:** Manages caching of suggestions for performance.

**Singleton Pattern:**
```dart
final cache = CacheService.instance;
```

#### Methods

##### `get(String key)`

Retrieve cached value.

**Parameters:**
- `key` (String, required) - Cache key

**Returns:** `dynamic` (null if not found)

**Example:**
```dart
final cached = CacheService.instance.get('suggestions_dart_function');
if (cached != null) {
  print('Cache hit!');
  return cached as List<CopilotSuggestion>;
} else {
  print('Cache miss');
  // Fetch from API
}
```

##### `set(String key, dynamic value, {Duration? expiration})`

Store value in cache.

**Parameters:**
- `key` (String, required) - Cache key
- `value` (dynamic, required) - Value to cache
- `expiration` (Duration, optional) - Time until expiration

**Returns:** `void`

**Example:**
```dart
CacheService.instance.set(
  'suggestions_dart_function',
  suggestions,
  expiration: Duration(hours: 24),
);
```

##### `clear()`

Clear all cached data.

**Returns:** `Future<void>`

**Example:**
```dart
await CacheService.instance.clear();
print('Cache cleared');
```

##### `getStats()`

Get cache performance statistics.

**Returns:** `CacheStats`

**Example:**
```dart
final stats = CacheService.instance.getStats();
print('Hit rate: ${stats.hitRate}%');
print('Miss rate: ${stats.missRate}%');
print('Total size: ${stats.totalSizeInMB}MB');
```

---

<a name="storageservice"></a>
### StorageService

**Purpose:** Manages persistent storage of settings and data.

**Singleton Pattern:**
```dart
final storage = StorageService.instance;
```

#### Methods

##### `initialize()`

Initialize storage service.

**Returns:** `Future<void>`

**Example:**
```dart
await StorageService.instance.initialize();
```

##### `saveSettings(CopilotSettings settings)`

Save user settings.

**Parameters:**
- `settings` (CopilotSettings, required) - Settings object

**Returns:** `Future<void>`

**Example:**
```dart
final settings = CopilotSettings(
  enabled: true,
  apiKey: 'your_key',
  autoTrigger: true,
);
await StorageService.instance.saveSettings(settings);
```

**Arabic Example:**
```dart
// مثال: حفظ الإعدادات
// Example: Save settings
final إعدادات = CopilotSettings(
  enabled: true,
  apiKey: 'مفتاحك',
  autoTrigger: true,
);
await StorageService.instance.saveSettings(إعدادات);
```

##### `loadSettings()`

Load saved settings.

**Returns:** `Future<CopilotSettings?>`

**Example:**
```dart
final settings = await StorageService.instance.loadSettings();
if (settings != null) {
  print('Loaded settings: ${settings.toJson()}');
} else {
  print('No saved settings found');
}
```

##### `saveStatistics(CopilotStatistics stats)`

Save statistics data.

**Parameters:**
- `stats` (CopilotStatistics, required) - Statistics object

**Returns:** `Future<void>`

**Example:**
```dart
await StorageService.instance.saveStatistics(stats);
```

##### `loadStatistics()`

Load saved statistics.

**Returns:** `Future<CopilotStatistics?>`

**Example:**
```dart
final stats = await StorageService.instance.loadStatistics();
if (stats != null) {
  print('Total suggestions: ${stats.totalSuggestions}');
}
```

---

<a name="models-en"></a>
## 📦 Models

<a name="copilotsuggestion"></a>
### CopilotSuggestion

Represents a code suggestion from Copilot.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | Unique identifier |
| `code` | String | Suggested code |
| `type` | SuggestionType | Type of suggestion |
| `language` | String | Programming language |
| `confidence` | double | Confidence score (0.0-1.0) |
| `timestamp` | DateTime | When generated |
| `metadata` | Map<String, dynamic> | Additional data |

#### Constructors

##### `CopilotSuggestion({required ...})`

**Example:**
```dart
final suggestion = CopilotSuggestion(
  id: 'sug_123',
  code: 'function add(a, b) { return a + b; }',
  type: SuggestionType.function,
  language: 'javascript',
  confidence: 0.92,
  timestamp: DateTime.now(),
);
```

**Arabic Example:**
```dart
// مثال: إنشاء اقتراح
// Example: Create suggestion
final اقتراح = CopilotSuggestion(
  id: 'اقتراح_123',
  code: 'دالة جمع(أ، ب) { رجع أ + ب؛ }',
  type: SuggestionType.function,
  language: 'sa',
  confidence: 0.92,
  timestamp: DateTime.now(),
);
```

##### `CopilotSuggestion.fromJson(Map<String, dynamic> json)`

Create from JSON.

**Example:**
```dart
final suggestion = CopilotSuggestion.fromJson({
  'id': 'sug_123',
  'code': 'function test() {}',
  'type': 'function',
  'language': 'javascript',
  'confidence': 0.85,
});
```

#### Methods

##### `toJson()`

Convert to JSON.

**Returns:** `Map<String, dynamic>`

**Example:**
```dart
final json = suggestion.toJson();
print(json);
// Output: {id: sug_123, code: ..., type: function, ...}
```

##### `copyWith({...})`

Create a copy with updated fields.

**Example:**
```dart
final updated = suggestion.copyWith(
  confidence: 0.95,
  metadata: {'edited': true},
);
```

---

<a name="copilotsettings"></a>
### CopilotSettings

Stores user configuration.

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `enabled` | bool | true | Enable Copilot |
| `apiKey` | String | '' | API key |
| `autoTrigger` | bool | true | Auto-trigger suggestions |
| `suggestionDelay` | int | 300 | Delay in ms |
| `maxSuggestions` | int | 5 | Max suggestions |
| `minimumConfidence` | double | 0.7 | Min confidence |
| `enabledLanguages` | List<String> | ['sa', 'dart', ...] | Enabled languages |
| `showInlineComments` | bool | true | Show comments |
| `showConfidenceScore` | bool | true | Show scores |
| `fontSize` | int | 14 | Font size |
| `highlightColor` | String | '#007ACC' | Highlight color |
| `enableCache` | bool | true | Enable caching |
| `cacheSizeInMB` | int | 100 | Cache size |
| `enableStatistics` | bool | true | Track statistics |
| `sendAnonymousData` | bool | false | Anonymous telemetry |

#### Constructors

##### `CopilotSettings({...})`

**Example:**
```dart
final settings = CopilotSettings(
  enabled: true,
  apiKey: 'your_api_key',
  autoTrigger: true,
  suggestionDelay: 250,
  maxSuggestions: 3,
  minimumConfidence: 0.8,
  enabledLanguages: ['dart', 'javascript'],
);
```

**Arabic Example:**
```dart
// مثال: إنشاء إعدادات
// Example: Create settings
final إعدادات = CopilotSettings(
  enabled: true,
  apiKey: 'مفتاح_API',
  autoTrigger: true,
  suggestionDelay: 250,
  maxSuggestions: 3,
  minimumConfidence: 0.8,
  enabledLanguages: ['sa', 'dart'],
);
```

##### `CopilotSettings.fromJson(Map<String, dynamic> json)`

**Example:**
```dart
final settings = CopilotSettings.fromJson(jsonData);
```

#### Methods

##### `toJson()`

**Returns:** `Map<String, dynamic>`

##### `copyWith({...})`

**Example:**
```dart
final updated = settings.copyWith(
  maxSuggestions: 10,
  minimumConfidence: 0.9,
);
```

##### `isValid()`

Validate settings.

**Returns:** `bool`

**Example:**
```dart
if (settings.isValid()) {
  print('Settings are valid');
} else {
  print('Invalid settings');
}
```

---

<a name="copilotstatistics"></a>
### CopilotStatistics

Stores usage statistics.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `totalSuggestions` | int | Total shown |
| `acceptedSuggestions` | int | Total accepted |
| `rejectedSuggestions` | int | Total rejected |
| `acceptanceRate` | double | Acceptance % |
| `averageConfidence` | double | Avg confidence |
| `totalApiRequests` | int | API calls made |
| `averageResponseTime` | int | Avg response (ms) |
| `cacheHitRate` | double | Cache hit % |
| `languageStats` | Map<String, LanguageStats> | Per-language stats |
| `dailyStats` | List<DailyStats> | Daily breakdown |
| `topSuggestions` | List<CopilotSuggestion> | Most used |

#### Constructors

##### `CopilotStatistics({...})`

**Example:**
```dart
final stats = CopilotStatistics(
  totalSuggestions: 1000,
  acceptedSuggestions: 750,
  rejectedSuggestions: 250,
  acceptanceRate: 75.0,
  averageConfidence: 0.82,
  totalApiRequests: 500,
  averageResponseTime: 1200,
  cacheHitRate: 85.0,
);
```

**Arabic Example:**
```dart
// مثال: إنشاء إحصائيات
// Example: Create statistics
final إحصائيات = CopilotStatistics(
  totalSuggestions: 1000,
  acceptedSuggestions: 750,
  rejectedSuggestions: 250,
  acceptanceRate: 75.0,
  averageConfidence: 0.82,
);
```

#### Methods

##### `toJson()`

##### `fromJson(Map<String, dynamic> json)`

##### `getLanguageStats(String language)`

Get statistics for specific language.

**Returns:** `LanguageStats?`

**Example:**
```dart
final dartStats = stats.getLanguageStats('dart');
if (dartStats != null) {
  print('Dart acceptance rate: ${dartStats.acceptanceRate}%');
}
```

##### `getDailyStats(DateTime date)`

Get statistics for specific day.

**Returns:** `DailyStats?`

**Example:**
```dart
final todayStats = stats.getDailyStats(DateTime.now());
if (todayStats != null) {
  print('Today: ${todayStats.totalSuggestions} suggestions');
}
```

---

<a name="core-en"></a>
## 🎯 Core

<a name="eventmanager"></a>
### EventManager

**Purpose:** Manages event subscriptions and emissions.

**Singleton Pattern:**
```dart
final events = EventManager.instance;
```

#### Event Types

```dart
enum CopilotEventType {
  // Text editing events / أحداث تحرير النص
  textChanged,
  textSelected,
  cursorMoved,
  
  // Suggestion events / أحداث الاقتراحات
  suggestionRequested,
  suggestionReceived,
  suggestionAccepted,
  suggestionRejected,
  suggestionShown,
  suggestionHidden,
  
  // Error events / أحداث الأخطاء
  apiError,
  cacheError,
  networkError,
  
  // Settings events / أحداث الإعدادات
  settingsChanged,
  languageChanged,
  extensionEnabled,
  extensionDisabled,
}
```

#### Methods

##### `subscribe(CopilotEventType type, EventCallback callback)`

Subscribe to event.

**Parameters:**
- `type` (CopilotEventType, required) - Event type
- `callback` (Function, required) - Callback function: `void Function(CopilotEvent event)`

**Returns:** `Function` (unsubscribe function)

**Example:**
```dart
// Subscribe to suggestion accepted event
final unsubscribe = EventManager.instance.subscribe(
  CopilotEventType.suggestionAccepted,
  (event) {
    print('Suggestion accepted: ${event.data}');
  },
);

// Later, unsubscribe
unsubscribe();
```

**Arabic Example:**
```dart
// مثال: الاشتراك في حدث
// Example: Subscribe to event
final إلغاء_الاشتراك = EventManager.instance.subscribe(
  CopilotEventType.suggestionAccepted,
  (حدث) {
    print('تم قبول الاقتراح: ${حدث.data}');
  },
);

// لاحقاً، إلغاء الاشتراك
إلغاء_الاشتراك();
```

##### `emit(CopilotEvent event)`

Emit an event.

**Parameters:**
- `event` (CopilotEvent, required) - Event to emit

**Returns:** `void`

**Example:**
```dart
EventManager.instance.emit(CopilotEvent(
  type: CopilotEventType.suggestionAccepted,
  data: {'suggestion': suggestion, 'timestamp': DateTime.now()},
  source: 'user_action',
));
```

##### `emitSimple(CopilotEventType type, dynamic data)`

Emit event with minimal parameters.

**Parameters:**
- `type` (CopilotEventType, required) - Event type
- `data` (dynamic, optional) - Event data

**Returns:** `void`

**Example:**
```dart
EventManager.instance.emitSimple(
  CopilotEventType.textChanged,
  {'text': 'new code', 'position': 42},
);
```

##### `unsubscribeAll(CopilotEventType type)`

Remove all subscriptions for event type.

**Returns:** `void`

**Example:**
```dart
EventManager.instance.unsubscribeAll(CopilotEventType.suggestionAccepted);
```

##### `clear()`

Remove all event subscriptions.

**Returns:** `void`

**Example:**
```dart
EventManager.instance.clear();
```

---

<a name="keyboardshortcutsmanager"></a>
### KeyboardShortcutsManager

**Purpose:** Manages keyboard shortcut registration and handling.

**Singleton Pattern:**
```dart
final shortcuts = KeyboardShortcutsManager.instance;
```

#### Methods

##### `register(String action, KeyboardShortcut shortcut)`

Register keyboard shortcut.

**Parameters:**
- `action` (String, required) - Action identifier
- `shortcut` (KeyboardShortcut, required) - Shortcut configuration

**Returns:** `void`

**Throws:** `ConflictException` if shortcut conflicts with existing

**Example:**
```dart
shortcuts.register(
  'triggerSuggestion',
  KeyboardShortcut(
    key: 'Space',
    modifiers: [ModifierKey.ctrl],
    action: () {
      // Trigger suggestion logic
      print('Ctrl+Space pressed');
    },
  ),
);
```

**Arabic Example:**
```dart
// مثال: تسجيل اختصار لوحة مفاتيح
// Example: Register keyboard shortcut
shortcuts.register(
  'إطلاق_الاقتراح',
  KeyboardShortcut(
    key: 'Space',
    modifiers: [ModifierKey.ctrl],
    action: () {
      print('تم الضغط على Ctrl+Space');
    },
  ),
);
```

##### `unregister(String action)`

Remove keyboard shortcut.

**Parameters:**
- `action` (String, required) - Action identifier

**Returns:** `void`

**Example:**
```dart
shortcuts.unregister('triggerSuggestion');
```

##### `getShortcut(String action)`

Get registered shortcut.

**Returns:** `KeyboardShortcut?`

**Example:**
```dart
final shortcut = shortcuts.getShortcut('triggerSuggestion');
if (shortcut != null) {
  print('Shortcut: ${shortcut.toString()}');
}
```

##### `hasConflict(KeyboardShortcut shortcut)`

Check for shortcut conflicts.

**Returns:** `bool`

**Example:**
```dart
final newShortcut = KeyboardShortcut(
  key: 'Space',
  modifiers: [ModifierKey.ctrl],
);

if (shortcuts.hasConflict(newShortcut)) {
  print('Shortcut conflicts with existing');
} else {
  print('Shortcut is available');
}
```

##### `getAllShortcuts()`

Get all registered shortcuts.

**Returns:** `Map<String, KeyboardShortcut>`

**Example:**
```dart
final all = shortcuts.getAllShortcuts();
for (var entry in all.entries) {
  print('${entry.key}: ${entry.value.toString()}');
}
```

---

<a name="enums-en"></a>
## 📋 Enums

### SuggestionType

```dart
enum SuggestionType {
  singleLine,        // Single line completion
  multiLine,         // Multiple lines
  function,          // Function declaration
  classDeclaration,  // Class declaration
  import,            // Import statement
  comment,           // Comment suggestion
  refactor,          // Refactoring suggestion
  snippet,           // Code snippet
}
```

### ModifierKey

```dart
enum ModifierKey {
  ctrl,   // Control key
  shift,  // Shift key
  alt,    // Alt key
  meta,   // Meta/Command key
}
```

---

<a name="code-examples-en"></a>
## 💻 Code Examples

### Complete Usage Example

```dart
import 'package:copilot_extension/copilot_extension.dart';

void main() async {
  // 1. Initialize services
  await StorageService.instance.initialize();
  await GitHubCopilotService.instance.initialize('your_api_key');
  
  // 2. Load settings
  final settings = await StorageService.instance.loadSettings();
  if (settings != null) {
    print('Settings loaded: ${settings.enabled}');
  }
  
  // 3. Subscribe to events
  final unsubscribe = EventManager.instance.subscribe(
    CopilotEventType.suggestionAccepted,
    (event) async {
      final suggestion = event.data['suggestion'] as CopilotSuggestion;
      await AnalyticsService.instance.trackSuggestionAccepted(suggestion);
      print('Tracked acceptance');
    },
  );
  
  // 4. Get suggestions
  final suggestions = await GitHubCopilotService.instance.getSuggestions(
    'function calculate',
    'javascript',
    maxSuggestions: 5,
  );
  
  // 5. Filter and rank
  final filtered = SuggestionsManager.instance.filterSuggestions(
    suggestions,
    minConfidence: 0.8,
  );
  final ranked = SuggestionsManager.instance.rankSuggestions(filtered);
  
  // 6. Show best suggestion
  if (ranked.isNotEmpty) {
    final best = ranked.first;
    print('Best suggestion (${best.confidence}): ${best.code}');
    
    // Track showing
    await AnalyticsService.instance.trackSuggestionShown(best);
    
    // Emit event
    EventManager.instance.emitSimple(
      CopilotEventType.suggestionShown,
      {'suggestion': best},
    );
  }
  
  // 7. Get statistics
  final stats = await AnalyticsService.instance.getStatistics(days: 7);
  print('Weekly stats:');
  print('- Total suggestions: ${stats.totalSuggestions}');
  print('- Acceptance rate: ${stats.acceptanceRate}%');
  print('- Top language: ${stats.topLanguage}');
  
  // 8. Clean up
  unsubscribe();
  GitHubCopilotService.instance.dispose();
}
```

### Arabic Complete Example

```dart
// مثال شامل باللغة العربية
// Complete example in Arabic

import 'package:copilot_extension/copilot_extension.dart';

void main() async {
  // 1. تهيئة الخدمات
  await StorageService.instance.initialize();
  await GitHubCopilotService.instance.initialize('مفتاح_API');
  
  // 2. تحميل الإعدادات
  final إعدادات = await StorageService.instance.loadSettings();
  if (إعدادات != null) {
    print('تم تحميل الإعدادات: ${إعدادات.enabled}');
  }
  
  // 3. الاشتراك في الأحداث
  final إلغاء_الاشتراك = EventManager.instance.subscribe(
    CopilotEventType.suggestionAccepted,
    (حدث) async {
      final اقتراح = حدث.data['suggestion'] as CopilotSuggestion;
      await AnalyticsService.instance.trackSuggestionAccepted(اقتراح);
      print('تم تتبع القبول');
    },
  );
  
  // 4. الحصول على اقتراحات
  final اقتراحات = await GitHubCopilotService.instance.getSuggestions(
    'دالة حساب',
    'sa',
    maxSuggestions: 5,
  );
  
  // 5. التصفية والترتيب
  final مصفى = SuggestionsManager.instance.filterSuggestions(
    اقتراحات,
    minConfidence: 0.8,
  );
  final مرتب = SuggestionsManager.instance.rankSuggestions(مصفى);
  
  // 6. عرض أفضل اقتراح
  if (مرتب.isNotEmpty) {
    final الأفضل = مرتب.first;
    print('أفضل اقتراح (${الأفضل.confidence}): ${الأفضل.code}');
  }
  
  // 7. الحصول على الإحصائيات
  final إحصائيات = await AnalyticsService.instance.getStatistics(days: 7);
  print('إحصائيات أسبوعية:');
  print('- إجمالي الاقتراحات: ${إحصائيات.totalSuggestions}');
  print('- معدل القبول: ${إحصائيات.acceptanceRate}%');
  
  // 8. التنظيف
  إلغاء_الاشتراك();
  GitHubCopilotService.instance.dispose();
}
```

---

<a name="arabic"></a>
<div dir="rtl">

## 📖 التوثيق العربي لـ API

### جدول المحتويات
- [نظرة عامة](#نظرة-عامة-api)
- [أفضل الممارسات](#أفضل-الممارسات-api)
- [معالجة الأخطاء](#معالجة-الأخطاء)
- [الأداء](#الأداء-api)

---

<a name="نظرة-عامة-api"></a>
### 📚 نظرة عامة

API إضافة GitHub Copilot يوفر مجموعة شاملة من الخدمات والنماذج للتكامل مع GitHub Copilot في بيئة SA IDE.

#### المكونات الرئيسية:

1. **الخدمات (Services):** 5 خدمات رئيسية
   - GitHubCopilotService: التواصل مع API
   - SuggestionsManager: إدارة الاقتراحات
   - AnalyticsService: تتبع الإحصائيات
   - CacheService: التخزين المؤقت
   - StorageService: التخزين الدائم

2. **النماذج (Models):** 3 نماذج بيانات
   - CopilotSuggestion: نموذج الاقتراح
   - CopilotSettings: نموذج الإعدادات
   - CopilotStatistics: نموذج الإحصائيات

3. **المحررات الأساسية (Core):** 2 محرر
   - EventManager: إدارة الأحداث
   - KeyboardShortcutsManager: إدارة الاختصارات

---

<a name="أفضل-الممارسات-api"></a>
### ✅ أفضل الممارسات

#### 1. تهيئة الخدمات

**دائماً قم بـ:**
```dart
// تهيئة StorageService أولاً
await StorageService.instance.initialize();

// ثم GitHubCopilotService
await GitHubCopilotService.instance.initialize(apiKey);

// تحميل الإعدادات
final settings = await StorageService.instance.loadSettings();
```

#### 2. معالجة الأخطاء

**استخدم try-catch:**
```dart
try {
  final suggestions = await GitHubCopilotService.instance.getSuggestions(
    code,
    language,
  );
} on ApiException catch (e) {
  print('خطأ في API: ${e.message}');
  // معالجة خطأ API
} on NetworkException catch (e) {
  print('خطأ في الشبكة: ${e.message}');
  // معالجة خطأ الشبكة
} catch (e) {
  print('خطأ عام: $e');
  // معالجة أخطاء أخرى
}
```

#### 3. استخدام الذاكرة المؤقتة

**تحقق من الذاكرة المؤقتة أولاً:**
```dart
final cacheKey = 'suggestions_${language}_${code.hashCode}';
var suggestions = CacheService.instance.get(cacheKey);

if (suggestions == null) {
  // جلب من API
  suggestions = await GitHubCopilotService.instance.getSuggestions(
    code,
    language,
  );
  
  // حفظ في الذاكرة المؤقتة
  CacheService.instance.set(
    cacheKey,
    suggestions,
    expiration: Duration(hours: 1),
  );
}
```

#### 4. تتبع الأحداث

**دائماً تتبع الأحداث المهمة:**
```dart
// تتبع عرض الاقتراح
await AnalyticsService.instance.trackSuggestionShown(suggestion);

// تتبع قبول الاقتراح
await AnalyticsService.instance.trackSuggestionAccepted(suggestion);

// إصدار الحدث
EventManager.instance.emitSimple(
  CopilotEventType.suggestionAccepted,
  {'suggestion': suggestion},
);
```

#### 5. التنظيف

**لا تنسى التنظيف:**
```dart
// إلغاء الاشتراكات
unsubscribe();

// تنظيف الخدمات
GitHubCopilotService.instance.dispose();

// مسح الذاكرة المؤقتة إذا لزم الأمر
await CacheService.instance.clear();
```

---

<a name="معالجة-الأخطاء"></a>
### ⚠️ معالجة الأخطاء

#### أنواع الأخطاء

1. **ApiException:** أخطاء API
   ```dart
   try {
     await service.getSuggestions(code, lang);
   } on ApiException catch (e) {
     print('كود الخطأ: ${e.code}');
     print('الرسالة: ${e.message}');
   }
   ```

2. **NetworkException:** أخطاء الشبكة
   ```dart
   try {
     await service.getSuggestions(code, lang);
   } on NetworkException catch (e) {
     print('خطأ اتصال: ${e.message}');
     // إعادة المحاولة أو استخدام الذاكرة المؤقتة
   }
   ```

3. **CacheException:** أخطاء الذاكرة المؤقتة
   ```dart
   try {
     await CacheService.instance.clear();
   } on CacheException catch (e) {
     print('خطأ في الذاكرة المؤقتة: ${e.message}');
   }
   ```

4. **StorageException:** أخطاء التخزين
   ```dart
   try {
     await storage.saveSettings(settings);
   } on StorageException catch (e) {
     print('خطأ في التخزين: ${e.message}');
   }
   ```

---

<a name="الأداء-api"></a>
### ⚡ نصائح الأداء

#### 1. استخدام الذاكرة المؤقتة بفعالية

```dart
// ✅ جيد: استخدام الذاكرة المؤقتة
final cached = CacheService.instance.get(key);
if (cached != null) return cached;

// ❌ سيء: تجاهل الذاكرة المؤقتة
final fresh = await api.getSuggestions(...);
```

#### 2. تصفية الاقتراحات محلياً

```dart
// ✅ جيد: تصفية على الجهاز
final filtered = manager.filterSuggestions(all, minConfidence: 0.8);

// ❌ سيء: طلب API متعددة
for (var threshold in [0.7, 0.8, 0.9]) {
  await api.getSuggestions(..., minConfidence: threshold);
}
```

#### 3. دمج الأحداث

```dart
// ✅ جيد: حدث واحد للدفعة
EventManager.instance.emitSimple(
  CopilotEventType.suggestionsBatch,
  {'suggestions': allSuggestions},
);

// ❌ سيء: حدث لكل اقتراح
for (var s in suggestions) {
  EventManager.instance.emitSimple(...);
}
```

#### 4. تحميل الإعدادات مرة واحدة

```dart
// ✅ جيد: تحميل مرة واحدة
class MyService {
  late final CopilotSettings settings;
  
  Future<void> init() async {
    settings = await StorageService.instance.loadSettings();
  }
}

// ❌ سيء: تحميل كل مرة
Future<void> doSomething() async {
  final settings = await StorageService.instance.loadSettings();
  // ...
}
```

</div>

---

<div align="center">

### 📞 API Support

**📧 Email:** saleh@kadahtech.com  
**🐛 Issues:** [GitHub Issues](https://github.com/SalehKadah/copilot-extension/issues)  
**💬 Discussions:** [GitHub Discussions](https://github.com/SalehKadah/copilot-extension/discussions)  
**📚 More Docs:** [Full Documentation](https://github.com/SalehKadah/copilot-extension/docs)

---

**API Version: 1.0.0**

**Made with ❤️ by Saleh Kadah | صُنع بـ ❤️ بواسطة صالح كداح**

**© 2025 Kadah Tech. All rights reserved.**

</div>
