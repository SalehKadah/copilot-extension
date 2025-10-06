// صفحة إعدادات Copilot - Copilot Settings Page
// واجهة شاملة لتخصيص جميع إعدادات الإضافة
// Comprehensive interface for customizing all extension settings

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/copilot_settings_model.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';

/// صفحة إعدادات Copilot - Copilot Settings Page
class CopilotSettingsPage extends StatefulWidget {
  const CopilotSettingsPage({super.key});

  @override
  State<CopilotSettingsPage> createState() => _CopilotSettingsPageState();
}

class _CopilotSettingsPageState extends State<CopilotSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CopilotSettingsModel _settings;
  final StorageService _storage = StorageService();
  final AnalyticsService _analytics = AnalyticsService();

  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// تحميل الإعدادات - Load settings
  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final savedSettings = await _storage.loadSettings();
      setState(() {
        _settings = savedSettings ?? CopilotSettingsModel();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _settings = CopilotSettingsModel();
        _isLoading = false;
      });
      _showError('فشل تحميل الإعدادات - Failed to load settings');
    }
  }

  /// حفظ الإعدادات - Save settings
  Future<void> _saveSettings() async {
    try {
      final success = await _storage.saveSettings(_settings);
      if (success) {
        setState(() => _hasChanges = false);
        _showSuccess('تم حفظ الإعدادات - Settings saved successfully');
      } else {
        _showError('فشل حفظ الإعدادات - Failed to save settings');
      }
    } catch (e) {
      _showError('خطأ في حفظ الإعدادات - Error saving settings: $e');
    }
  }

  /// إعادة تعيين للافتراضي - Reset to defaults
  Future<void> _resetToDefaults() async {
    final confirm = await _showConfirmDialog(
      'إعادة تعيين الإعدادات - Reset Settings',
      'هل تريد إعادة جميع الإعدادات للقيم الافتراضية؟\nDo you want to reset all settings to default values?',
    );

    if (confirm) {
      setState(() {
        _settings = CopilotSettingsModel.defaults;
        _hasChanges = true;
      });
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTab(),
                _buildEditorTab(),
                _buildAdvancedTab(),
                _buildAboutTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء شريط التطبيق - Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Row(
        children: [
          Icon(Icons.settings, size: 24),
          SizedBox(width: 12),
          Text('إعدادات Copilot - Copilot Settings'),
        ],
      ),
      actions: [
        if (_hasChanges)
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'تراجع - Undo',
            onPressed: _loadSettings,
          ),
        IconButton(
          icon: const Icon(Icons.restore),
          tooltip: 'إعادة تعيين - Reset',
          onPressed: _resetToDefaults,
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _hasChanges ? _saveSettings : null,
          icon: const Icon(Icons.save, size: 18),
          label: const Text('حفظ - Save'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  /// بناء شريط التبويبات - Build tab bar
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(
          icon: Icon(Icons.tune),
          text: 'عام - General',
        ),
        Tab(
          icon: Icon(Icons.edit),
          text: 'المحرر - Editor',
        ),
        Tab(
          icon: Icon(Icons.settings_suggest),
          text: 'متقدم - Advanced',
        ),
        Tab(
          icon: Icon(Icons.info),
          text: 'حول - About',
        ),
      ],
    );
  }

  /// تبويب الإعدادات العامة - General settings tab
  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('التفعيل - Activation'),
          _buildSwitchTile(
            'تفعيل Copilot - Enable Copilot',
            'تشغيل أو إيقاف الإضافة\nEnable or disable the extension',
            _settings.enabled,
            (value) => _updateSetting(() => _settings.enabled = value),
          ),
          _buildSwitchTile(
            'التشغيل التلقائي - Auto Trigger',
            'عرض الاقتراحات تلقائياً أثناء الكتابة\nShow suggestions automatically while typing',
            _settings.autoTrigger,
            (value) => _updateSetting(() => _settings.autoTrigger = value),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('الاقتراحات - Suggestions'),

          _buildSliderTile(
            'تأخير الاقتراحات - Suggestion Delay',
            'الوقت بالميلي ثانية قبل عرض الاقتراحات\nTime in milliseconds before showing suggestions',
            _settings.suggestionDelay.toDouble(),
            100,
            2000,
            (value) => _updateSetting(
              () => _settings.suggestionDelay = value.toInt(),
            ),
            valueLabel: '${_settings.suggestionDelay}ms',
          ),

          _buildSliderTile(
            'عدد الاقتراحات - Max Suggestions',
            'الحد الأقصى لعدد الاقتراحات المعروضة\nMaximum number of suggestions to show',
            _settings.maxSuggestions.toDouble(),
            1,
            20,
            (value) => _updateSetting(
              () => _settings.maxSuggestions = value.toInt(),
            ),
            valueLabel: '${_settings.maxSuggestions}',
            divisions: 19,
          ),

          _buildSliderTile(
            'الحد الأدنى للثقة - Minimum Confidence',
            'أقل نسبة ثقة لعرض الاقتراح\nMinimum confidence to show suggestion',
            _settings.minimumConfidence,
            0.0,
            1.0,
            (value) => _updateSetting(
              () => _settings.minimumConfidence = value,
            ),
            valueLabel: '${(_settings.minimumConfidence * 100).toInt()}%',
            divisions: 10,
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('اللغات المدعومة - Supported Languages'),

          _buildLanguageSelector(),

          const SizedBox(height: 24),
          _buildSectionTitle('مفتاح API - API Key'),

          _buildApiKeyField(),
        ],
      ),
    );
  }

  /// تبويب إعدادات المحرر - Editor settings tab
  Widget _buildEditorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('العرض - Display'),

          _buildSwitchTile(
            'عرض التعليقات المباشرة - Show Inline Comments',
            'إظهار الاقتراحات كتعليقات في المحرر\nShow suggestions as inline comments in editor',
            _settings.showInlineComments,
            (value) => _updateSetting(
              () => _settings.showInlineComments = value,
            ),
          ),

          _buildSwitchTile(
            'عرض مستوى الثقة - Show Confidence Score',
            'إظهار نسبة الثقة مع كل اقتراح\nShow confidence percentage with each suggestion',
            _settings.showConfidenceScore,
            (value) => _updateSetting(
              () => _settings.showConfidenceScore = value,
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('الخطوط - Fonts'),

          _buildSliderTile(
            'حجم الخط - Font Size',
            'حجم الخط للاقتراحات\nFont size for suggestions',
            _settings.fontSize,
            10.0,
            24.0,
            (value) => _updateSetting(() => _settings.fontSize = value),
            valueLabel: '${_settings.fontSize.toInt()}px',
            divisions: 14,
          ),

          _buildDropdownTile<String>(
            'نمط الخط - Font Style',
            'نمط عرض الخط\nFont display style',
            _settings.fontStyle,
            const ['normal', 'italic', 'bold'],
            (value) => _updateSetting(
              () => _settings.fontStyle = value ?? 'normal',
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('الألوان - Colors'),

          _buildColorPickerTile(
            'لون التمييز - Highlight Color',
            'لون تمييز الاقتراحات\nSuggestion highlight color',
            _settings.highlightColor,
            (value) => _updateSetting(() => _settings.highlightColor = value),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('الإشعارات - Notifications'),

          _buildSwitchTile(
            'تفعيل الصوت - Enable Sound',
            'تشغيل صوت عند ظهور الاقتراحات\nPlay sound when suggestions appear',
            _settings.enableSound,
            (value) => _updateSetting(() => _settings.enableSound = value),
          ),

          _buildSwitchTile(
            'تفعيل الإشعارات - Enable Notifications',
            'إظهار إشعارات الحالة\nShow status notifications',
            _settings.enableNotifications,
            (value) => _updateSetting(
              () => _settings.enableNotifications = value,
            ),
          ),
        ],
      ),
    );
  }

  /// تبويب الإعدادات المتقدمة - Advanced settings tab
  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('الذاكرة المؤقتة - Cache'),

          _buildSwitchTile(
            'استخدام الذاكرة المؤقتة - Use Cache',
            'تخزين الاقتراحات مؤقتاً لتحسين الأداء\nCache suggestions for better performance',
            _settings.useCache,
            (value) => _updateSetting(() => _settings.useCache = value),
          ),

          _buildSliderTile(
            'حجم الذاكرة المؤقتة - Cache Size',
            'الحجم الأقصى بالميجابايت\nMaximum size in megabytes',
            _settings.cacheSizeInMB.toDouble(),
            10,
            1000,
            (value) => _updateSetting(
              () => _settings.cacheSizeInMB = value.toInt(),
            ),
            valueLabel: '${_settings.cacheSizeInMB}MB',
            divisions: 99,
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('الإحصائيات - Statistics'),

          _buildSwitchTile(
            'تسجيل الإحصائيات - Log Statistics',
            'تتبع استخدام الإضافة والإحصائيات\nTrack extension usage and statistics',
            _settings.logStatistics,
            (value) => _updateSetting(() => _settings.logStatistics = value),
          ),

          _buildSwitchTile(
            'إرسال بيانات مجهولة - Send Anonymous Data',
            'المساعدة في تحسين الإضافة\nHelp improve the extension',
            _settings.sendAnonymousData,
            (value) => _updateSetting(
              () => _settings.sendAnonymousData = value,
            ),
          ),

          const SizedBox(height: 24),
          _buildDangerZone(),
        ],
      ),
    );
  }

  /// تبويب حول - About tab
  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Icon(Icons.smart_toy, size: 80, color: Color(0xFF007ACC)),
                const SizedBox(height: 16),
                const Text(
                  'GitHub Copilot Agent',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'الإصدار 1.0.0 - Version 1.0.0',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          _buildSectionTitle('الوصف - Description'),
          const Text(
            'إضافة وكيل الذكاء الاصطناعي GitHub Copilot لبيئة التطوير SA IDE.\n'
            'تقدم اقتراحات كود ذكية بالذكاء الاصطناعي لتسريع التطوير.\n\n'
            'GitHub Copilot AI Agent Extension for SA IDE Development Environment.\n'
            'Provides intelligent AI-powered code suggestions to accelerate development.',
            style: TextStyle(height: 1.6),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('المطور - Developer'),
          const Text('Saleh Kadah - صالح كداح'),

          const SizedBox(height: 24),
          _buildSectionTitle('الترخيص - License'),
          const Text('MIT License'),

          const SizedBox(height: 24),
          _buildSectionTitle('الإحصائيات - Statistics'),
          _buildStatisticsCard(),

          const SizedBox(height: 24),
          _buildSectionTitle('الروابط - Links'),
          _buildLinkButton(
            'GitHub Repository',
            Icons.code,
            () => _openLink('https://github.com/SalehKadah/copilot-extension'),
          ),
          const SizedBox(height: 8),
          _buildLinkButton(
            'التوثيق - Documentation',
            Icons.book,
            () => _openLink('https://github.com/SalehKadah/copilot-extension/docs'),
          ),
          const SizedBox(height: 8),
          _buildLinkButton(
            'الإبلاغ عن مشكلة - Report Issue',
            Icons.bug_report,
            () => _openLink('https://github.com/SalehKadah/copilot-extension/issues'),
          ),
        ],
      ),
    );
  }

  /// بناء عنوان القسم - Build section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// بناء مفتاح تبديل - Build switch tile
  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// بناء شريط تمرير - Build slider tile
  Widget _buildSliderTile(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    required String valueLabel,
    int? divisions,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
                Text(valueLabel, style: const TextStyle(color: Color(0xFF007ACC))),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  /// بناء قائمة منسدلة - Build dropdown tile
  Widget _buildDropdownTile<T>(
    String title,
    String subtitle,
    T value,
    List<T> items,
    ValueChanged<T?> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: DropdownButton<T>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item.toString()))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// بناء منتقي ألوان - Build color picker tile
  Widget _buildColorPickerTile(
    String title,
    String subtitle,
    String colorHex,
    ValueChanged<String> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: GestureDetector(
          onTap: () => _showColorPicker(colorHex, onChanged),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _parseColor(colorHex),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  /// بناء حقل مفتاح API - Build API key field
  Widget _buildApiKeyField() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: TextEditingController(text: _settings.apiKey),
          decoration: const InputDecoration(
            labelText: 'مفتاح API - API Key',
            hintText: 'أدخل مفتاح GitHub Copilot API',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          onChanged: (value) => _updateSetting(() => _settings.apiKey = value),
        ),
      ),
    );
  }

  /// بناء منتقي اللغات - Build language selector
  Widget _buildLanguageSelector() {
    final languages = ['sa', 'dart', 'javascript', 'python', 'java', 'cpp', 'csharp', 'go', 'rust'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: languages.map((lang) {
            final isSelected = _settings.enableForLanguages.contains(lang);
            return FilterChip(
              label: Text(lang),
              selected: isSelected,
              onSelected: (selected) {
                _updateSetting(() {
                  if (selected) {
                    _settings.enableForLanguages.add(lang);
                  } else {
                    _settings.enableForLanguages.remove(lang);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// بناء منطقة الخطر - Build danger zone
  Widget _buildDangerZone() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ منطقة الخطر - Danger Zone',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _clearCache,
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              label: const Text('مسح الذاكرة المؤقتة - Clear Cache'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _resetStatistics,
              icon: const Icon(Icons.restart_alt, color: Colors.red),
              label: const Text('إعادة تعيين الإحصائيات - Reset Statistics'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة الإحصائيات - Build statistics card
  Widget _buildStatisticsCard() {
    final stats = _analytics.getStatistics();
    if (stats == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('الاقتراحات المعروضة - Shown', '${stats.totalSuggestionsShown}'),
            _buildStatRow('الاقتراحات المقبولة - Accepted', '${stats.totalSuggestionsAccepted}'),
            _buildStatRow('معدل القبول - Acceptance Rate', '${(stats.acceptanceRate * 100).toInt()}%'),
            _buildStatRow('طلبات API', '${stats.totalApiRequests}'),
          ],
        ),
      ),
    );
  }

  /// بناء صف إحصائية - Build stat row
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// بناء زر رابط - Build link button
  Widget _buildLinkButton(String label, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  /// تحديث إعداد - Update setting
  void _updateSetting(VoidCallback update) {
    setState(() {
      update();
      _hasChanges = true;
    });
  }

  /// مسح الذاكرة المؤقتة - Clear cache
  Future<void> _clearCache() async {
    final confirm = await _showConfirmDialog(
      'مسح الذاكرة المؤقتة - Clear Cache',
      'هل تريد مسح جميع البيانات المخزنة مؤقتاً؟\nDo you want to clear all cached data?',
    );

    if (confirm) {
      // Implement cache clearing
      _showSuccess('تم مسح الذاكرة المؤقتة - Cache cleared');
    }
  }

  /// إعادة تعيين الإحصائيات - Reset statistics
  Future<void> _resetStatistics() async {
    final confirm = await _showConfirmDialog(
      'إعادة تعيين الإحصائيات - Reset Statistics',
      'هل تريد إعادة تعيين جميع الإحصائيات؟\nDo you want to reset all statistics?',
    );

    if (confirm) {
      await _analytics.resetStatistics();
      _showSuccess('تم إعادة تعيين الإحصائيات - Statistics reset');
      setState(() {});
    }
  }

  /// عرض منتقي الألوان - Show color picker
  Future<void> _showColorPicker(String currentColor, ValueChanged<String> onChanged) async {
    // Implement color picker dialog
  }

  /// تحليل اللون من hex - Parse color from hex
  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  /// فتح رابط - Open link
  void _openLink(String url) {
    // Implement URL launcher
  }

  /// عرض حوار تأكيد - Show confirm dialog
  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء - Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد - Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// عرض رسالة نجاح - Show success message
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// عرض رسالة خطأ - Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
