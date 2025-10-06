// نقطة الدخول الرئيسية لإضافة Copilot - Copilot Extension Main Entry Point
// تهيئة وتفعيل إضافة GitHub Copilot
// Initialize and activate GitHub Copilot extension

library copilot_extension;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// النماذج - Models
import 'models/copilot_extension_model.dart';
import 'models/copilot_settings_model.dart';

// الخدمات - Services
import 'services/github_copilot_service.dart';
import 'services/suggestions_manager.dart';

// الواجهات - Widgets
import 'widgets/copilot_widget.dart';

// المعالجات - Handlers
import 'handlers/keyboard_shortcuts_handler.dart';

export 'models/copilot_extension_model.dart';
export 'models/copilot_settings_model.dart';
export 'models/suggestion_model.dart';
export 'services/github_copilot_service.dart';
export 'services/suggestions_manager.dart';
export 'widgets/copilot_widget.dart';
export 'widgets/suggestion_popup.dart';
export 'handlers/keyboard_shortcuts_handler.dart';

/// الفئة الرئيسية لإضافة Copilot - Main Copilot Extension Class
/// نقطة الدخول والتحكم الرئيسية بالإضافة
/// Main entry point and control for the extension
class CopilotExtension {
  // السنغلتون - Singleton
  static final CopilotExtension _instance = CopilotExtension._internal();
  factory CopilotExtension() => _instance;
  CopilotExtension._internal();

  /// نموذج الإضافة - Extension model
  CopilotExtensionModel? _extensionModel;

  /// مدير الاقتراحات - Suggestions manager
  final SuggestionsManager _suggestionsManager = SuggestionsManager();

  /// خدمة GitHub Copilot - GitHub Copilot service
  final GitHubCopilotService _copilotService = GitHubCopilotService();

  /// الإعدادات المشتركة - Shared preferences
  SharedPreferences? _prefs;

  /// هل تم التهيئة - Is initialized
  bool _isInitialized = false;

  /// نموذج الإضافة - Extension model
  CopilotExtensionModel? get extensionModel => _extensionModel;

  /// مدير الاقتراحات - Suggestions manager
  SuggestionsManager get suggestionsManager => _suggestionsManager;

  /// هل تم التهيئة - Is initialized
  bool get isInitialized => _isInitialized;

  /// تفعيل الإضافة - Activate extension
  /// يجب استدعاؤها عند بدء تشغيل البيئة
  /// Must be called when IDE starts
  static Future<CopilotExtension> activate({
    CopilotSettingsModel? settings,
  }) async {
    final instance = CopilotExtension();
    await instance._initialize(settings);
    return instance;
  }

  /// تهيئة الإضافة - Initialize extension
  Future<void> _initialize(CopilotSettingsModel? settings) async {
    if (_isInitialized) {
      debugPrint('⚠️ الإضافة مهيأة بالفعل - Extension already initialized');
      return;
    }

    debugPrint(
      '🚀 بدء تهيئة إضافة Copilot - Starting Copilot extension initialization',
    );

    try {
      // تحميل الإعدادات المحفوظة - Load saved settings
      _prefs = await SharedPreferences.getInstance();
      final loadedSettings = await _loadSettings(settings);

      // إنشاء نموذج الإضافة - Create extension model
      _extensionModel = CopilotExtensionModel(
        id: 'copilot-agent-extension',
        name: 'GitHub Copilot Agent',
        version: '1.0.0',
        settings: loadedSettings,
      );

      // تهيئة الخدمات - Initialize services
      await _copilotService.initialize(loadedSettings);
      await _suggestionsManager.initialize(loadedSettings);

      // تفعيل الإضافة - Activate extension
      _extensionModel!.activate();
      _isInitialized = true;

      debugPrint(
        '✅ تم تهيئة إضافة Copilot بنجاح - Copilot extension initialized successfully',
      );
      debugPrint('   الإصدار - Version: ${_extensionModel!.version}');
      debugPrint(
        '   الحالة - Status: ${_extensionModel!.isActive ? "مفعل - Active" : "غير مفعل - Inactive"}',
      );
    } catch (e) {
      debugPrint('❌ خطأ في تهيئة الإضافة - Error initializing extension: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// تحميل الإعدادات - Load settings
  Future<CopilotSettingsModel> _loadSettings(
    CopilotSettingsModel? providedSettings,
  ) async {
    if (providedSettings != null) {
      return providedSettings;
    }

    // محاولة تحميل من الذاكرة - Try loading from storage
    final settingsJson = _prefs?.getString('copilot_settings');
    if (settingsJson != null) {
      try {
        // TODO: تنفيذ fromJson عند إنشاء ملفات .g.dart
        // TODO: Implement fromJson when .g.dart files are created
        return CopilotSettingsModel();
      } catch (e) {
        debugPrint('⚠️ خطأ في تحميل الإعدادات - Error loading settings: $e');
      }
    }

    // استخدام الإعدادات الافتراضية - Use default settings
    return CopilotSettingsModel.defaults;
  }

  /// حفظ الإعدادات - Save settings
  Future<void> saveSettings(CopilotSettingsModel settings) async {
    try {
      // TODO: تنفيذ toJson عند إنشاء ملفات .g.dart
      // TODO: Implement toJson when .g.dart files are created
      // await _prefs?.setString('copilot_settings', jsonEncode(settings.toJson()));

      // تحديث الإعدادات - Update settings
      _extensionModel?.settings = settings;
      _suggestionsManager.updateSettings(settings);
      _copilotService.updateSettings(settings);

      debugPrint('💾 تم حفظ الإعدادات - Settings saved');
    } catch (e) {
      debugPrint('❌ خطأ في حفظ الإعدادات - Error saving settings: $e');
    }
  }

  /// إيقاف الإضافة - Deactivate extension
  Future<void> deactivate() async {
    if (!_isInitialized) {
      debugPrint('⚠️ الإضافة غير مهيأة - Extension not initialized');
      return;
    }

    debugPrint('🛑 إيقاف إضافة Copilot - Deactivating Copilot extension');

    try {
      // إيقاف الخدمات - Stop services
      _suggestionsManager.dispose();
      _copilotService.dispose();

      // تحديث حالة الإضافة - Update extension state
      _extensionModel?.deactivate();

      _isInitialized = false;

      debugPrint('✅ تم إيقاف الإضافة - Extension deactivated');
    } catch (e) {
      debugPrint('❌ خطأ في إيقاف الإضافة - Error deactivating extension: $e');
    }
  }

  /// إنشاء Provider للإضافة - Create extension provider
  /// يُستخدم لتوفير الإضافة في شجرة الواجهات
  /// Used to provide extension in widget tree
  static Widget createProvider({
    required Widget child,
    CopilotExtension? extension,
  }) {
    return ChangeNotifierProvider<SuggestionsManager>.value(
      value: (extension ?? CopilotExtension()).suggestionsManager,
      child: child,
    );
  }

  /// إنشاء Widget الإضافة - Create extension widget
  /// يُستخدم لدمج الإضافة في المحرر
  /// Used to integrate extension into editor
  static Widget createWidget({
    required TextEditingController textController,
    required String language,
    String? filePath,
    bool isDarkTheme = true,
    double fontSize = 14.0,
    void Function(String suggestion)? onSuggestionAccepted,
    void Function()? onSuggestionRejected,
  }) {
    return CopilotWidget(
      textController: textController,
      language: language,
      filePath: filePath,
      isDarkTheme: isDarkTheme,
      fontSize: fontSize,
      onSuggestionAccepted: onSuggestionAccepted,
      onSuggestionRejected: onSuggestionRejected,
    );
  }

  /// الحصول على إحصائيات الاستخدام - Get usage statistics
  Map<String, dynamic> getStatistics() {
    if (_extensionModel == null) {
      return {'error': 'Extension not initialized'};
    }

    return {
      'extension': {
        'is_active': _extensionModel!.isActive,
        'is_connected': _extensionModel!.isConnected,
        'version': _extensionModel!.version,
      },
      'statistics': _extensionModel!.statistics.toJson(),
      'suggestions_manager': _suggestionsManager.getStatistics(),
    };
  }

  /// عرض معلومات الإضافة - Show extension info
  void showInfo() {
    if (!_isInitialized || _extensionModel == null) {
      debugPrint('❌ الإضافة غير مهيأة - Extension not initialized');
      return;
    }

    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🤖 GitHub Copilot Agent Extension');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('📦 الإصدار - Version: ${_extensionModel!.version}');
    debugPrint(
      '⚡ الحالة - Status: ${_extensionModel!.isActive ? "✅ مفعل - Active" : "❌ غير مفعل - Inactive"}',
    );
    debugPrint(
      '🔌 الاتصال - Connection: ${_extensionModel!.isConnected ? "✅ متصل - Connected" : "❌ غير متصل - Disconnected"}',
    );
    debugPrint('📊 الإحصائيات - Statistics:');
    debugPrint(
      '   الاقتراحات المعروضة - Shown: ${_extensionModel!.statistics.totalSuggestionsShown}',
    );
    debugPrint(
      '   الاقتراحات المقبولة - Accepted: ${_extensionModel!.statistics.totalSuggestionsAccepted}',
    );
    debugPrint(
      '   نسبة القبول - Acceptance: ${(_extensionModel!.statistics.acceptanceRate * 100).toStringAsFixed(1)}%',
    );
    debugPrint('═══════════════════════════════════════════════════════');
  }
}
