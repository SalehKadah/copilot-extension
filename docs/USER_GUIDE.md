# GitHub Copilot Agent - User Guide | دليل المستخدم

<div align="center">

![User Guide](https://img.shields.io/badge/Documentation-User%20Guide-4CAF50?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge)
![Language](https://img.shields.io/badge/Language-Bilingual-orange?style=for-the-badge)

**📖 Complete Guide to Using GitHub Copilot Agent in SA IDE**

**📖 دليل شامل لاستخدام وكيل GitHub Copilot في بيئة SA IDE**

[English](#english) | [العربية](#arabic)

</div>

---

<a name="english"></a>
## 📖 English Guide

### Table of Contents
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Configuration](#configuration)
- [Basic Usage](#basic-usage)
- [Advanced Features](#advanced-features)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Best Practices](#best-practices)
- [Productivity Tips](#productivity-tips)
- [Frequently Asked Questions](#faq-english)

---

<a name="getting-started"></a>
### 🚀 Getting Started

#### Prerequisites

Before installing GitHub Copilot Agent, ensure you have:

1. **SA IDE** version 2.0.0 or higher
2. **Flutter SDK** version 3.0.0 or higher
3. **GitHub Copilot API Key** (obtain from GitHub)
4. **Stable Internet Connection** for API requests

#### First-Time Setup

1. **Launch SA IDE**
   ```bash
   # Open your SA IDE application
   ```

2. **Access Extensions**
   - Click on `Extensions` in the menu bar
   - Select `Browse` to view available extensions

3. **Find Copilot Agent**
   - Search for "GitHub Copilot Agent"
   - Click on the extension to view details

4. **Install**
   - Click the `Install` button
   - Wait for the installation to complete
   - Restart SA IDE when prompted

---

<a name="installation"></a>
### 📦 Installation

#### Method 1: Extensions Marketplace (Recommended)

```bash
1. Open SA IDE
2. Navigate to: Extensions → Browse
3. Search: "GitHub Copilot Agent"
4. Click: Install
5. Restart SA IDE
```

**Advantages:**
- ✅ Automatic updates
- ✅ Easy installation
- ✅ Version management
- ✅ One-click uninstall

#### Method 2: Manual Installation

```bash
# 1. Download the extension package
wget https://example.com/copilot-agent-v1.0.0.zip

# 2. Extract to extensions directory
unzip copilot-agent-v1.0.0.zip -d ~/.sa_ide/extensions/

# 3. Restart SA IDE
```

**Advantages:**
- ✅ Offline installation
- ✅ Version control
- ✅ Corporate environments

#### Method 3: Build from Source

```bash
# 1. Clone repository
git clone https://github.com/SalehKadah/copilot-extension.git
cd copilot-extension

# 2. Install dependencies
flutter pub get

# 3. Build extension
flutter build

# 4. Copy to extensions directory
cp -r build/outputs ~/.sa_ide/extensions/copilot_agent

# 5. Restart SA IDE
```

**Advantages:**
- ✅ Latest features
- ✅ Custom modifications
- ✅ Development environment

#### Verifying Installation

After installation, verify by:

1. **Check Extensions List**
   - Go to: `Extensions → Installed`
   - Verify "GitHub Copilot Agent" appears

2. **Check Status Bar**
   - Look for Copilot icon in the status bar
   - Should show "Copilot Ready" or "Not Configured"

3. **Open Settings**
   - Press `Ctrl + Shift + P`
   - Settings page should open successfully

---

<a name="configuration"></a>
### ⚙️ Configuration

#### Accessing Settings

**Method 1: Keyboard Shortcut**
```
Press: Ctrl + Shift + P
```

**Method 2: Menu**
```
Menu → Extensions → Copilot Settings
```

**Method 3: Status Bar**
```
Click: Copilot icon in status bar → Settings
```

#### General Settings Tab

##### API Configuration

```json
{
  "apiKey": "your_github_copilot_api_key_here",
  "apiEndpoint": "https://api.github.com/copilot",
  "timeout": 5000
}
```

**How to get API Key:**
1. Visit: https://github.com/settings/copilot
2. Generate new API key
3. Copy the key
4. Paste in settings

##### Enable/Disable Copilot

```json
{
  "enabled": true
}
```

**Toggle Options:**
- ✅ `true` - Copilot is active
- ❌ `false` - Copilot is disabled
- 🔄 Use `Ctrl + Shift + C` to toggle quickly

##### Auto-Trigger Settings

```json
{
  "autoTrigger": true,
  "suggestionDelay": 300,
  "triggerOnEnter": false,
  "triggerOnTab": true
}
```

**Parameters:**
- `autoTrigger`: Enable automatic suggestions while typing
- `suggestionDelay`: Delay in milliseconds before showing suggestions (100-1000)
- `triggerOnEnter`: Show suggestions when pressing Enter
- `triggerOnTab`: Show suggestions when pressing Tab

##### Suggestion Limits

```json
{
  "maxSuggestions": 5,
  "minimumConfidence": 0.7,
  "maxCompletionLength": 1000
}
```

**Parameters:**
- `maxSuggestions`: Maximum number of suggestions to show (1-10)
- `minimumConfidence`: Minimum confidence score (0.0-1.0)
- `maxCompletionLength`: Maximum characters in suggestion

##### Language Support

```json
{
  "enabledLanguages": [
    "sa",
    "dart",
    "javascript",
    "python",
    "java",
    "cpp",
    "csharp",
    "go",
    "rust"
  ]
}
```

**Supported Languages:**
- ✅ SA (SA Language)
- ✅ Dart
- ✅ JavaScript/TypeScript
- ✅ Python
- ✅ Java
- ✅ C++
- ✅ C#
- ✅ Go
- ✅ Rust

#### Editor Settings Tab

##### Display Options

```json
{
  "showInlineComments": true,
  "showConfidenceScore": true,
  "showSuggestionIndex": true,
  "highlightActiveSuggestion": true
}
```

**Options:**
- `showInlineComments`: Display helpful comments with suggestions
- `showConfidenceScore`: Show confidence percentage (0-100%)
- `showSuggestionIndex`: Show "1/5" style index
- `highlightActiveSuggestion`: Highlight the selected suggestion

##### Appearance

```json
{
  "fontSize": 14,
  "fontFamily": "Consolas, monospace",
  "fontStyle": "normal",
  "highlightColor": "#007ACC",
  "backgroundColor": "#1E1E1E",
  "opacity": 0.9
}
```

**Customization:**
- `fontSize`: Font size in pixels (10-24)
- `fontFamily`: Font family for suggestions
- `fontStyle`: normal, italic, bold
- `highlightColor`: Hex color for highlights
- `backgroundColor`: Hex color for popup background
- `opacity`: Transparency level (0.0-1.0)

##### Notifications

```json
{
  "enableNotifications": true,
  "notificationDuration": 3000,
  "enableSound": false,
  "soundVolume": 0.5
}
```

**Settings:**
- `enableNotifications`: Show notifications for events
- `notificationDuration`: Duration in milliseconds
- `enableSound`: Play sound on suggestion acceptance
- `soundVolume`: Volume level (0.0-1.0)

#### Statistics Settings Tab

##### Tracking Options

```json
{
  "enableStatistics": true,
  "trackUsage": true,
  "trackAcceptance": true,
  "trackPerformance": true
}
```

**Tracking:**
- `enableStatistics`: Enable statistics collection
- `trackUsage`: Track suggestion usage patterns
- `trackAcceptance`: Track acceptance/rejection rates
- `trackPerformance`: Track API response times

##### Data Retention

```json
{
  "retentionDays": 30,
  "maxDailyRecords": 1000,
  "aggregateDaily": true
}
```

**Settings:**
- `retentionDays`: Days to keep statistics data
- `maxDailyRecords`: Maximum records per day
- `aggregateDaily`: Combine daily statistics

##### Export Options

```json
{
  "autoExport": false,
  "exportInterval": "weekly",
  "exportFormat": "json",
  "exportPath": "~/copilot_reports/"
}
```

**Export:**
- `autoExport`: Automatically export reports
- `exportInterval`: daily, weekly, monthly
- `exportFormat`: json, csv, pdf
- `exportPath`: Directory for exported reports

#### Advanced Settings Tab

##### Cache Configuration

```json
{
  "enableCache": true,
  "cacheSizeInMB": 100,
  "cacheExpirationHours": 24,
  "usePersistentCache": true
}
```

**Cache:**
- `enableCache`: Enable caching system
- `cacheSizeInMB`: Maximum cache size (10-500 MB)
- `cacheExpirationHours`: Hours before expiration (1-168)
- `usePersistentCache`: Save cache to disk

##### Performance Tuning

```json
{
  "maxConcurrentRequests": 3,
  "requestThrottleMs": 100,
  "enableCompression": true,
  "prioritizeQuality": true
}
```

**Performance:**
- `maxConcurrentRequests`: Concurrent API requests (1-5)
- `requestThrottleMs`: Throttle delay (50-500ms)
- `enableCompression`: Compress API requests
- `prioritizeQuality`: Quality over speed

##### Privacy Settings

```json
{
  "sendAnonymousData": false,
  "sendErrorReports": true,
  "shareStatistics": false
}
```

**Privacy:**
- `sendAnonymousData`: Send anonymous usage data
- `sendErrorReports`: Send crash reports
- `shareStatistics`: Share aggregated statistics

##### Debug Options

```json
{
  "enableDebugMode": false,
  "logLevel": "info",
  "logToFile": false,
  "logFilePath": "~/copilot_logs/"
}
```

**Debug:**
- `enableDebugMode`: Enable debug logging
- `logLevel`: error, warn, info, debug, trace
- `logToFile`: Save logs to file
- `logFilePath`: Log file directory

---

<a name="basic-usage"></a>
### 💡 Basic Usage

#### Starting Copilot

**Automatic Start:**
- Copilot starts automatically when SA IDE launches
- Check status bar for "Copilot Ready" indicator

**Manual Start:**
```
Press: Ctrl + Shift + C
Or: Status Bar → Copilot Icon → Enable
```

#### Triggering Suggestions

##### Method 1: Auto-Trigger (Default)

```dart
// Simply start typing
function calculate

// Copilot suggests:
// → function calculateTotal(items) { ... }
// → function calculateAverage(numbers) { ... }
// → function calculateDiscount(price) { ... }
```

**Advantages:**
- ⚡ Fastest method
- 🎯 Context-aware
- 🔄 Real-time suggestions

##### Method 2: Manual Trigger

```
Press: Ctrl + Space
```

**Use When:**
- Auto-trigger is disabled
- Need suggestions at specific point
- Want to refresh suggestions

##### Method 3: Tab Completion

```dart
// Type partial code and press Tab
class User|  // | = cursor, press Tab

// Copilot completes:
class User {
  final String id;
  final String name;
  // ...
}
```

#### Accepting Suggestions

##### Accept Current Suggestion

```
Press: Tab
Or: Enter
Or: Click on suggestion
```

**Result:** Selected suggestion is inserted at cursor position

##### Accept Partial Suggestion

```
Press: Ctrl + →  (Right Arrow)
```

**Result:** Accept word-by-word from suggestion

##### Accept Line

```
Press: Ctrl + Shift + →
```

**Result:** Accept current line only

#### Rejecting Suggestions

##### Reject All

```
Press: Escape
Or: Click outside popup
Or: Continue typing
```

##### Reject and Request New

```
Press: Ctrl + Space (after rejecting)
```

#### Navigating Suggestions

##### Next Suggestion

```
Press: Alt + ]
Or: ↓ (Down Arrow)
Or: Click Next button
```

##### Previous Suggestion

```
Press: Alt + [
Or: ↑ (Up Arrow)
Or: Click Previous button
```

##### Jump to First/Last

```
First: Home
Last: End
```

#### Common Scenarios

##### Scenario 1: Writing a Function

```dart
// 1. Type function signature
function fibonacci(n) {

// 2. Copilot suggests implementation
// Press Tab to accept

// 3. Result:
function fibonacci(n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}
```

##### Scenario 2: Creating a Class

```dart
// 1. Type class name
class UserProfile {

// 2. Copilot suggests properties
// Navigate with ↓ to see options
// Press Tab to accept

// 3. Continue with methods
  getUserInfo() {
  
// 4. Copilot suggests method implementation
```

##### Scenario 3: Import Statements

```dart
// 1. Type import
import 'package:

// 2. Copilot suggests packages
// → package:flutter/material.dart
// → package:flutter/widgets.dart
// Navigate with ↓, accept with Tab
```

---

<a name="advanced-features"></a>
### 🎯 Advanced Features

#### Multi-Line Completions

**Enable:**
```json
{
  "enableMultiLineCompletion": true,
  "maxLines": 10
}
```

**Usage:**
```dart
// Type opening of a complex function
function processUserData(users) {
  // Press Ctrl + Space

// Copilot suggests entire implementation:
function processUserData(users) {
  return users
    .filter(user => user.active)
    .map(user => ({
      id: user.id,
      name: user.name,
      email: user.email
    }))
    .sort((a, b) => a.name.localeCompare(b.name));
}
```

#### Context-Aware Suggestions

Copilot analyzes:
- **Current file** content
- **Surrounding code** (±50 lines)
- **Function signatures** in scope
- **Import statements**
- **Comments** and documentation

**Example:**
```dart
// Comment guides suggestion
// Function to validate email format
function validate

// Copilot suggests:
function validateEmail(email) {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
}
```

#### Suggestion Filtering

**By Confidence:**
```json
{
  "minimumConfidence": 0.8  // Only show high-quality suggestions
}
```

**By Type:**
```json
{
  "suggestionTypes": [
    "function",
    "class",
    "multiline"
  ]
}
```

**By Language:**
```json
{
  "currentFileLanguage": "dart",
  "enableCrossLanguageSuggestions": false
}
```

#### Code Refactoring Suggestions

**Trigger Refactoring:**
```
1. Select code to refactor
2. Press: Ctrl + Shift + R
3. View refactoring suggestions
4. Accept or reject
```

**Example:**
```dart
// Before (selected code):
let total = 0;
for (let i = 0; i < items.length; i++) {
  total += items[i].price;
}

// After (Copilot suggests):
const total = items.reduce((sum, item) => sum + item.price, 0);
```

#### Snippet Expansion

**Built-in Snippets:**
- `forr` → for loop with range
- `ifelse` → if-else statement
- `trycatch` → try-catch block
- `class` → class template

**Usage:**
```dart
// Type snippet prefix
trycatch

// Press Tab, Copilot expands:
try {
  // code here
} catch (error) {
  console.error(error);
}
```

#### Comment-Based Generation

**Usage:**
```dart
// TODO: Create a function that calculates the factorial of a number

// Copilot generates:
function factorial(n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}
```

**Supported Comment Formats:**
- `// TODO:`
- `// FIXME:`
- `/* ... */`
- `/** ... */` (JSDoc)

---

<a name="keyboard-shortcuts"></a>
### ⌨️ Keyboard Shortcuts

#### Default Shortcuts Table

| Shortcut | Action | Category |
|----------|--------|----------|
| **Ctrl + Space** | Trigger Suggestions | Suggestions |
| **Tab** | Accept Suggestion | Suggestions |
| **Enter** | Accept Suggestion (Alt) | Suggestions |
| **Escape** | Reject Suggestion | Suggestions |
| **Alt + ]** | Next Suggestion | Navigation |
| **Alt + [** | Previous Suggestion | Navigation |
| **Ctrl + →** | Accept Word | Partial Accept |
| **Ctrl + Shift + →** | Accept Line | Partial Accept |
| **Home** | First Suggestion | Navigation |
| **End** | Last Suggestion | Navigation |
| **Ctrl + Shift + P** | Open Settings | Settings |
| **Ctrl + Shift + S** | Show Statistics | Statistics |
| **Ctrl + Shift + C** | Toggle Copilot | General |
| **Ctrl + Shift + R** | Trigger Refactoring | Refactoring |
| **F1** | Show Help | Help |

#### Customizing Shortcuts

**Access Shortcut Settings:**
```
Settings → Keyboard Shortcuts Tab
```

**Modify a Shortcut:**
```
1. Find the action in the list
2. Click the current shortcut
3. Press new key combination
4. Click "Save"
```

**Conflict Detection:**
- Automatic detection of conflicts with SA IDE shortcuts
- Warning displayed if conflict exists
- Suggestion for alternative shortcuts

**Reset to Default:**
```
Settings → Keyboard Shortcuts → Reset All
```

---

<a name="best-practices"></a>
### ✅ Best Practices

#### 1. Write Descriptive Comments

**Good:**
```dart
// Calculate the total price including tax and discount
function calculateFinalPrice
```

**Better:**
```dart
/**
 * Calculate the final price for an order
 * @param subtotal - Order subtotal before tax
 * @param taxRate - Tax rate as decimal (e.g., 0.08 for 8%)
 * @param discountPercent - Discount percentage (0-100)
 * @returns Final price after tax and discount
 */
function calculateFinalPrice
```

**Result:** More accurate and detailed suggestions

#### 2. Use Consistent Naming Conventions

**Consistent:**
```dart
function getUserById(id)
function getUserByEmail(email)
function getUserByName(name)
```

**Result:** Copilot learns your patterns and suggests consistently

#### 3. Provide Context with Imports

**Example:**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Copilot now knows you're building a Flutter app
// Suggestions will be Flutter-specific
class MyWidget
```

#### 4. Review Suggestions Carefully

**Always:**
- ✅ Read the suggested code
- ✅ Verify it matches your intent
- ✅ Check for potential bugs
- ✅ Ensure it follows your code style
- ✅ Test the functionality

**Never:**
- ❌ Accept blindly
- ❌ Ignore security implications
- ❌ Skip code review

#### 5. Use Appropriate Confidence Threshold

**For Critical Code:**
```json
{
  "minimumConfidence": 0.9  // High confidence only
}
```

**For Exploratory Code:**
```json
{
  "minimumConfidence": 0.6  // Lower threshold, more ideas
}
```

#### 6. Leverage Statistics

**Review Regularly:**
```
Ctrl + Shift + S → Statistics Dashboard
```

**Analyze:**
- Acceptance rates by language
- Most useful suggestion types
- Peak productivity times
- Areas for improvement

#### 7. Configure Language-Specific Settings

**Example for Python:**
```json
{
  "python": {
    "style": "pep8",
    "maxLineLength": 79,
    "preferType": "typing"
  }
}
```

#### 8. Balance Speed and Quality

**For Fast Development:**
```json
{
  "prioritizeSpeed": true,
  "minimumConfidence": 0.6
}
```

**For Production Code:**
```json
{
  "prioritizeQuality": true,
  "minimumConfidence": 0.85
}
```

---

<a name="productivity-tips"></a>
### 🚀 Productivity Tips

#### Tip 1: Use Keyboard Shortcuts

**Memorize:**
- `Ctrl + Space` - Trigger
- `Tab` - Accept
- `Alt + ]` - Next

**Result:** 50% faster coding

#### Tip 2: Write Code Comments First

**Workflow:**
```dart
// 1. Write comment describing what you need
// Function to fetch user data from API and cache it

// 2. Press Ctrl + Space
// 3. Review and accept suggestion
```

**Benefit:** Clear intent leads to better suggestions

#### Tip 3: Use Multi-Line Mode for Complex Logic

**Enable:**
```json
{
  "enableMultiLineCompletion": true,
  "maxLines": 15
}
```

**Use Case:** Complete algorithms, data transformations

#### Tip 4: Create Personal Snippet Library

**Method:**
```
1. Write commonly used patterns
2. Copilot learns your style
3. Suggestions match your patterns
```

**Example:** If you always write error handling in a specific way, Copilot will suggest it

#### Tip 5: Utilize Statistics for Learning

**Review:**
- Which suggestions you accept most
- Which languages you're most productive in
- Times of day with highest acceptance

**Optimize:** Adjust settings based on insights

#### Tip 6: Combine with Existing IDE Features

**Workflow:**
```
1. Use IDE autocomplete for simple completions
2. Use Copilot for complex logic
3. Use IDE refactoring tools after acceptance
```

#### Tip 7: Set Up Project-Specific Configurations

**Create:** `.copilot-config.json` in project root

```json
{
  "language": "dart",
  "framework": "flutter",
  "customRules": [
    "always use const constructors",
    "prefer final over var"
  ]
}
```

#### Tip 8: Use During Code Review

**Method:**
```
1. Review suggested refactorings
2. Compare with current implementation
3. Discuss alternatives with team
```

---

<a name="faq-english"></a>
### ❓ Frequently Asked Questions

#### Q1: Why aren't suggestions appearing?

**A:** Check these common issues:
1. ✅ Copilot is enabled (`Ctrl + Shift + C`)
2. ✅ API key is configured correctly
3. ✅ Current language is enabled in settings
4. ✅ Auto-trigger is enabled or use `Ctrl + Space`
5. ✅ Internet connection is active
6. ✅ Minimum confidence threshold isn't too high

#### Q2: Suggestions are too slow. How can I improve performance?

**A:** Try these optimizations:
```json
{
  "enableCache": true,
  "cacheSizeInMB": 200,
  "maxConcurrentRequests": 5,
  "prioritizeSpeed": true,
  "suggestionDelay": 200
}
```

#### Q3: How do I disable Copilot temporarily?

**A:** Three methods:
1. Press `Ctrl + Shift + C`
2. Click Copilot icon in status bar → Disable
3. Settings → General → Set `enabled: false`

#### Q4: Can I use Copilot offline?

**A:** Partially:
- ✅ Cached suggestions work offline
- ❌ New suggestions require internet
- 💡 Increase cache size for better offline experience

#### Q5: How much data does Copilot use?

**A:** Typical usage:
- API request: ~2-5 KB
- Response: ~5-10 KB
- Per hour: ~10-50 MB (depending on activity)
- Per day: ~100-500 MB

**Tip:** Enable compression to reduce data usage

#### Q6: Is my code sent to GitHub?

**A:** Yes, but:
- ✅ Encrypted transmission
- ✅ Used only for suggestions
- ✅ Not stored permanently
- ✅ Respects privacy settings
- ❌ You can disable with `sendAnonymousData: false`

#### Q7: Can I customize suggestion format?

**A:** Yes:
```json
{
  "suggestionFormat": {
    "showComments": true,
    "includeTypeHints": true,
    "verbosity": "medium"
  }
}
```

#### Q8: How do I report bugs or request features?

**A:** 
- **Bugs:** GitHub Issues: https://github.com/SalehKadah/copilot-extension/issues
- **Features:** GitHub Discussions: https://github.com/SalehKadah/copilot-extension/discussions
- **Email:** saleh@kadahtech.com

#### Q9: Can I use Copilot for commercial projects?

**A:** Yes, according to GitHub Copilot license terms. Check GitHub's terms of service for details.

#### Q10: How do I update the extension?

**A:**
- **Automatic:** Enable auto-update in SA IDE settings
- **Manual:** Extensions → Copilot Agent → Update
- **Check for updates:** Extensions → Check for Updates

---

<a name="arabic"></a>
<div dir="rtl">

## 📖 الدليل العربي

### جدول المحتويات
- [البدء](#البدء)
- [التثبيت](#التثبيت-عربي)
- [التكوين](#التكوين-عربي)
- [الاستخدام الأساسي](#الاستخدام-الأساسي)
- [الميزات المتقدمة](#الميزات-المتقدمة)
- [اختصارات لوحة المفاتيح](#اختصارات-لوحة-المفاتيح-عربي)
- [أفضل الممارسات](#أفضل-الممارسات)
- [نصائح الإنتاجية](#نصائح-الإنتاجية)
- [الأسئلة الشائعة](#الأسئلة-الشائعة-عربي)

---

<a name="البدء"></a>
### 🚀 البدء

#### المتطلبات الأساسية

قبل تثبيت وكيل GitHub Copilot، تأكد من توفر:

1. **SA IDE** إصدار 2.0.0 أو أحدث
2. **Flutter SDK** إصدار 3.0.0 أو أحدث
3. **مفتاح GitHub Copilot API** (احصل عليه من GitHub)
4. **اتصال إنترنت مستقر** لطلبات API

#### الإعداد الأولي

1. **تشغيل SA IDE**
   ```bash
   # افتح تطبيق SA IDE
   ```

2. **الوصول للإضافات**
   - انقر على `الإضافات` في شريط القوائم
   - اختر `تصفح` لعرض الإضافات المتاحة

3. **العثور على Copilot Agent**
   - ابحث عن "GitHub Copilot Agent"
   - انقر على الإضافة لعرض التفاصيل

4. **التثبيت**
   - انقر على زر `تثبيت`
   - انتظر اكتمال التثبيت
   - أعد تشغيل SA IDE عند المطالبة

---

<a name="التثبيت-عربي"></a>
### 📦 التثبيت

#### الطريقة 1: سوق الإضافات (موصى بها)

```bash
1. افتح SA IDE
2. انتقل إلى: الإضافات ← تصفح
3. ابحث: "GitHub Copilot Agent"
4. انقر: تثبيت
5. أعد تشغيل SA IDE
```

**المزايا:**
- ✅ تحديثات تلقائية
- ✅ تثبيت سهل
- ✅ إدارة الإصدارات
- ✅ إلغاء التثبيت بنقرة واحدة

#### الطريقة 2: التثبيت اليدوي

```bash
# 1. تنزيل حزمة الإضافة
wget https://example.com/copilot-agent-v1.0.0.zip

# 2. استخراج إلى مجلد الإضافات
unzip copilot-agent-v1.0.0.zip -d ~/.sa_ide/extensions/

# 3. إعادة تشغيل SA IDE
```

**المزايا:**
- ✅ تثبيت دون اتصال بالإنترنت
- ✅ التحكم في الإصدار
- ✅ البيئات المؤسسية

#### الطريقة 3: البناء من المصدر

```bash
# 1. استنساخ المستودع
git clone https://github.com/SalehKadah/copilot-extension.git
cd copilot-extension

# 2. تثبيت الاعتماديات
flutter pub get

# 3. بناء الإضافة
flutter build

# 4. النسخ إلى مجلد الإضافات
cp -r build/outputs ~/.sa_ide/extensions/copilot_agent

# 5. إعادة تشغيل SA IDE
```

**المزايا:**
- ✅ أحدث الميزات
- ✅ التعديلات المخصصة
- ✅ بيئة التطوير

#### التحقق من التثبيت

بعد التثبيت، تحقق من خلال:

1. **التحقق من قائمة الإضافات**
   - انتقل إلى: `الإضافات ← المثبتة`
   - تأكد من ظهور "GitHub Copilot Agent"

2. **التحقق من شريط الحالة**
   - ابحث عن أيقونة Copilot في شريط الحالة
   - يجب أن تظهر "Copilot جاهز" أو "غير مكون"

3. **فتح الإعدادات**
   - اضغط `Ctrl + Shift + P`
   - يجب أن تفتح صفحة الإعدادات بنجاح

---

<a name="التكوين-عربي"></a>
### ⚙️ التكوين

#### الوصول للإعدادات

**الطريقة 1: اختصار لوحة المفاتيح**
```
اضغط: Ctrl + Shift + P
```

**الطريقة 2: القائمة**
```
القائمة ← الإضافات ← إعدادات Copilot
```

**الطريقة 3: شريط الحالة**
```
انقر: أيقونة Copilot في شريط الحالة ← الإعدادات
```

#### تبويب الإعدادات العامة

##### تكوين API

```json
{
  "apiKey": "your_github_copilot_api_key_here",
  "apiEndpoint": "https://api.github.com/copilot",
  "timeout": 5000
}
```

**كيفية الحصول على مفتاح API:**
1. زيارة: https://github.com/settings/copilot
2. توليد مفتاح API جديد
3. نسخ المفتاح
4. لصق في الإعدادات

##### تفعيل/تعطيل Copilot

```json
{
  "enabled": true
}
```

**خيارات التبديل:**
- ✅ `true` - Copilot نشط
- ❌ `false` - Copilot معطل
- 🔄 استخدم `Ctrl + Shift + C` للتبديل السريع

##### إعدادات التشغيل التلقائي

```json
{
  "autoTrigger": true,
  "suggestionDelay": 300,
  "triggerOnEnter": false,
  "triggerOnTab": true
}
```

**المعاملات:**
- `autoTrigger`: تفعيل الاقتراحات التلقائية أثناء الكتابة
- `suggestionDelay`: التأخير بالمللي ثانية قبل عرض الاقتراحات (100-1000)
- `triggerOnEnter`: عرض الاقتراحات عند الضغط على Enter
- `triggerOnTab`: عرض الاقتراحات عند الضغط على Tab

##### حدود الاقتراحات

```json
{
  "maxSuggestions": 5,
  "minimumConfidence": 0.7,
  "maxCompletionLength": 1000
}
```

**المعاملات:**
- `maxSuggestions`: الحد الأقصى لعدد الاقتراحات المعروضة (1-10)
- `minimumConfidence`: الحد الأدنى لدرجة الثقة (0.0-1.0)
- `maxCompletionLength`: الحد الأقصى للأحرف في الاقتراح

##### دعم اللغات

```json
{
  "enabledLanguages": [
    "sa",
    "dart",
    "javascript",
    "python",
    "java",
    "cpp",
    "csharp",
    "go",
    "rust"
  ]
}
```

**اللغات المدعومة:**
- ✅ ص (لغة صاد)
- ✅ Dart
- ✅ JavaScript/TypeScript
- ✅ Python
- ✅ Java
- ✅ C++
- ✅ C#
- ✅ Go
- ✅ Rust

---

<a name="الاستخدام-الأساسي"></a>
### 💡 الاستخدام الأساسي

#### بدء Copilot

**البدء التلقائي:**
- يبدأ Copilot تلقائياً عند تشغيل SA IDE
- تحقق من شريط الحالة لمؤشر "Copilot جاهز"

**البدء اليدوي:**
```
اضغط: Ctrl + Shift + C
أو: شريط الحالة ← أيقونة Copilot ← تفعيل
```

#### إطلاق الاقتراحات

##### الطريقة 1: التشغيل التلقائي (افتراضي)

```dart
// ببساطة ابدأ الكتابة
function calculate

// يقترح Copilot:
// → function calculateTotal(items) { ... }
// → function calculateAverage(numbers) { ... }
// → function calculateDiscount(price) { ... }
```

**المزايا:**
- ⚡ أسرع طريقة
- 🎯 واعي بالسياق
- 🔄 اقتراحات فورية

##### الطريقة 2: التشغيل اليدوي

```
اضغط: Ctrl + Space
```

**استخدم عندما:**
- التشغيل التلقائي معطل
- تحتاج اقتراحات في نقطة محددة
- تريد تحديث الاقتراحات

##### الطريقة 3: إكمال Tab

```dart
// اكتب كود جزئي واضغط Tab
class User|  // | = المؤشر، اضغط Tab

// يكمل Copilot:
class User {
  final String id;
  final String name;
  // ...
}
```

#### قبول الاقتراحات

##### قبول الاقتراح الحالي

```
اضغط: Tab
أو: Enter
أو: انقر على الاقتراح
```

**النتيجة:** يتم إدراج الاقتراح المحدد عند موضع المؤشر

##### قبول اقتراح جزئي

```
اضغط: Ctrl + ←  (سهم يمين)
```

**النتيجة:** قبول كلمة بكلمة من الاقتراح

##### قبول سطر

```
اضغط: Ctrl + Shift + ←
```

**النتيجة:** قبول السطر الحالي فقط

#### رفض الاقتراحات

##### رفض الكل

```
اضغط: Escape
أو: انقر خارج النافذة المنبثقة
أو: استمر في الكتابة
```

##### رفض وطلب جديد

```
اضغط: Ctrl + Space (بعد الرفض)
```

#### التنقل بين الاقتراحات

##### الاقتراح التالي

```
اضغط: Alt + ]
أو: ↓ (سهم أسفل)
أو: انقر زر التالي
```

##### الاقتراح السابق

```
اضغط: Alt + [
أو: ↑ (سهم أعلى)
أو: انقر زر السابق
```

##### الانتقال للأول/الأخير

```
الأول: Home
الأخير: End
```

---

<a name="الميزات-المتقدمة"></a>
### 🎯 الميزات المتقدمة

#### الإكمالات متعددة الأسطر

**التفعيل:**
```json
{
  "enableMultiLineCompletion": true,
  "maxLines": 10
}
```

**الاستخدام:**
```dart
// اكتب بداية دالة معقدة
function processUserData(users) {
  // اضغط Ctrl + Space

// يقترح Copilot التنفيذ الكامل:
function processUserData(users) {
  return users
    .filter(user => user.active)
    .map(user => ({
      id: user.id,
      name: user.name,
      email: user.email
    }))
    .sort((a, b) => a.name.localeCompare(b.name));
}
```

#### اقتراحات واعية بالسياق

يحلل Copilot:
- **محتوى الملف الحالي**
- **الكود المحيط** (±50 سطر)
- **توقيعات الدوال** في النطاق
- **عبارات الاستيراد**
- **التعليقات** والتوثيق

**مثال:**
```dart
// التعليق يوجه الاقتراح
// دالة للتحقق من صحة تنسيق البريد الإلكتروني
function validate

// يقترح Copilot:
function validateEmail(email) {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
}
```

---

<a name="أفضل-الممارسات"></a>
### ✅ أفضل الممارسات

#### 1. اكتب تعليقات وصفية

**جيد:**
```dart
// حساب السعر الإجمالي شاملاً الضريبة والخصم
function calculateFinalPrice
```

**أفضل:**
```dart
/**
 * حساب السعر النهائي للطلب
 * @param subtotal - الإجمالي الفرعي للطلب قبل الضريبة
 * @param taxRate - معدل الضريبة كرقم عشري (مثال: 0.08 لـ 8%)
 * @param discountPercent - نسبة الخصم (0-100)
 * @returns السعر النهائي بعد الضريبة والخصم
 */
function calculateFinalPrice
```

**النتيجة:** اقتراحات أكثر دقة وتفصيلاً

#### 2. استخدم اصطلاحات تسمية متسقة

**متسق:**
```dart
function getUserById(id)
function getUserByEmail(email)
function getUserByName(name)
```

**النتيجة:** يتعلم Copilot أنماطك ويقترح بشكل متسق

#### 3. راجع الاقتراحات بعناية

**دائماً:**
- ✅ اقرأ الكود المقترح
- ✅ تحقق من مطابقته لنيتك
- ✅ تحقق من الأخطاء المحتملة
- ✅ تأكد من اتباعه لأسلوب الكود الخاص بك
- ✅ اختبر الوظيفة

**أبداً:**
- ❌ القبول دون قراءة
- ❌ تجاهل الآثار الأمنية
- ❌ تخطي مراجعة الكود

---

<a name="نصائح-الإنتاجية"></a>
### 🚀 نصائح الإنتاجية

#### نصيحة 1: استخدم اختصارات لوحة المفاتيح

**احفظ:**
- `Ctrl + Space` - إطلاق
- `Tab` - قبول
- `Alt + ]` - التالي

**النتيجة:** كتابة كود أسرع بنسبة 50%

#### نصيحة 2: اكتب تعليقات الكود أولاً

**سير العمل:**
```dart
// 1. اكتب تعليق يصف ما تحتاجه
// دالة لجلب بيانات المستخدم من API وتخزينها مؤقتاً

// 2. اضغط Ctrl + Space
// 3. راجع واقبل الاقتراح
```

**الفائدة:** النية الواضحة تؤدي لاقتراحات أفضل

#### نصيحة 3: استخدم الوضع متعدد الأسطر للمنطق المعقد

**التفعيل:**
```json
{
  "enableMultiLineCompletion": true,
  "maxLines": 15
}
```

**حالة الاستخدام:** إكمال الخوارزميات، تحويلات البيانات

#### نصيحة 4: استخدم الإحصائيات للتعلم

**راجع:**
- الاقتراحات التي تقبلها أكثر
- اللغات الأكثر إنتاجية بالنسبة لك
- الأوقات ذات أعلى معدل قبول

**الأمثل:** اضبط الإعدادات بناءً على الرؤى

---

<a name="الأسئلة-الشائعة-عربي"></a>
### ❓ الأسئلة الشائعة

#### س1: لماذا لا تظهر الاقتراحات؟

**ج:** تحقق من هذه المشاكل الشائعة:
1. ✅ Copilot مفعل (`Ctrl + Shift + C`)
2. ✅ مفتاح API مكون بشكل صحيح
3. ✅ اللغة الحالية مفعلة في الإعدادات
4. ✅ التشغيل التلقائي مفعل أو استخدم `Ctrl + Space`
5. ✅ اتصال الإنترنت نشط
6. ✅ عتبة الثقة الدنيا ليست عالية جداً

#### س2: الاقتراحات بطيئة. كيف يمكنني تحسين الأداء؟

**ج:** جرب هذه التحسينات:
```json
{
  "enableCache": true,
  "cacheSizeInMB": 200,
  "maxConcurrentRequests": 5,
  "prioritizeSpeed": true,
  "suggestionDelay": 200
}
```

#### س3: كيف أعطل Copilot مؤقتاً؟

**ج:** ثلاث طرق:
1. اضغط `Ctrl + Shift + C`
2. انقر أيقونة Copilot في شريط الحالة ← تعطيل
3. الإعدادات ← عام ← اضبط `enabled: false`

#### س4: هل يمكنني استخدام Copilot دون اتصال بالإنترنت؟

**ج:** جزئياً:
- ✅ الاقتراحات المخزنة مؤقتاً تعمل دون اتصال
- ❌ الاقتراحات الجديدة تتطلب إنترنت
- 💡 زد حجم الذاكرة المؤقتة لتجربة أفضل دون اتصال

#### س5: كم من البيانات يستخدم Copilot؟

**ج:** الاستخدام النموذجي:
- طلب API: ~2-5 كيلوبايت
- الاستجابة: ~5-10 كيلوبايت
- في الساعة: ~10-50 ميجابايت (حسب النشاط)
- في اليوم: ~100-500 ميجابايت

**نصيحة:** فعّل الضغط لتقليل استخدام البيانات

#### س6: هل يُرسل كودي إلى GitHub؟

**ج:** نعم، لكن:
- ✅ نقل مشفر
- ✅ يُستخدم فقط للاقتراحات
- ✅ لا يُخزن بشكل دائم
- ✅ يحترم إعدادات الخصوصية
- ❌ يمكنك التعطيل بـ `sendAnonymousData: false`

#### س7: كيف أبلغ عن الأخطاء أو أطلب ميزات؟

**ج:**
- **الأخطاء:** GitHub Issues: https://github.com/SalehKadah/copilot-extension/issues
- **الميزات:** GitHub Discussions: https://github.com/SalehKadah/copilot-extension/discussions
- **البريد الإلكتروني:** saleh@kadahtech.com

#### س8: هل يمكنني استخدام Copilot للمشاريع التجارية؟

**ج:** نعم، وفقاً لشروط ترخيص GitHub Copilot. تحقق من شروط خدمة GitHub للتفاصيل.

#### س9: كيف أحدث الإضافة؟

**ج:**
- **تلقائي:** فعّل التحديث التلقائي في إعدادات SA IDE
- **يدوي:** الإضافات ← Copilot Agent ← تحديث
- **التحقق من التحديثات:** الإضافات ← التحقق من التحديثات

#### س10: كيف أحذف الذاكرة المؤقتة؟

**ج:**
```
الإعدادات ← متقدم ← مسح الذاكرة المؤقتة ← تأكيد
```

</div>

---

<div align="center">

### 📞 Support & Resources

**📧 Email:** saleh@kadahtech.com  
**🐛 Issues:** [GitHub Issues](https://github.com/SalehKadah/copilot-extension/issues)  
**💬 Discussions:** [GitHub Discussions](https://github.com/SalehKadah/copilot-extension/discussions)  
**📚 Documentation:** [Full Docs](https://github.com/SalehKadah/copilot-extension/docs)

---

**Made with ❤️ by Saleh Kadah | صُنع بـ ❤️ بواسطة صالح كداح**

**© 2025 Kadah Tech. All rights reserved.**

</div>
