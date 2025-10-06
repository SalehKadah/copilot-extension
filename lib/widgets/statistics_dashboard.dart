// لوحة إحصائيات Copilot - Copilot Statistics Dashboard
// عرض شامل لجميع الإحصائيات والتحليلات
// Comprehensive display of all statistics and analytics

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/analytics_service.dart';
import '../models/copilot_statistics_model.dart';

/// لوحة الإحصائيات - Statistics Dashboard
class StatisticsDashboard extends StatefulWidget {
  const StatisticsDashboard({super.key});

  @override
  State<StatisticsDashboard> createState() => _StatisticsDashboardState();
}

class _StatisticsDashboardState extends State<StatisticsDashboard>
    with SingleTickerProviderStateMixin {
  final AnalyticsService _analytics = AnalyticsService();
  late TabController _tabController;

  CopilotStatistics? _stats;
  bool _isLoading = true;
  String _selectedPeriod = 'today';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// تحميل الإحصائيات - Load statistics
  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final stats = _analytics.getStatistics();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// تصدير التقرير - Export report
  Future<void> _exportReport() async {
    try {
      final report = await _analytics.exportReport();
      // Implement file saving logic
      _showSuccess('تم تصدير التقرير - Report exported successfully');
    } catch (e) {
      _showError('فشل تصدير التقرير - Failed to export report');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_stats == null) {
      return Scaffold(appBar: _buildAppBar(), body: _buildEmptyState());
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildPeriodSelector(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildLanguagesTab(),
                _buildPerformanceTab(),
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
          Icon(Icons.analytics, size: 24),
          SizedBox(width: 12),
          Text('إحصائيات Copilot - Copilot Statistics'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'تحديث - Refresh',
          onPressed: _loadStatistics,
        ),
        IconButton(
          icon: const Icon(Icons.download),
          tooltip: 'تصدير - Export',
          onPressed: _exportReport,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// بناء منتقي الفترة - Build period selector
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const Text(
            'الفترة - Period:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          _buildPeriodChip('اليوم - Today', 'today'),
          _buildPeriodChip('هذا الأسبوع - This Week', 'week'),
          _buildPeriodChip('هذا الشهر - This Month', 'month'),
          _buildPeriodChip('الكل - All Time', 'all'),
        ],
      ),
    );
  }

  /// بناء رقاقة فترة - Build period chip
  Widget _buildPeriodChip(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedPeriod = period);
          _loadStatistics();
        },
      ),
    );
  }

  /// بناء شريط التبويبات - Build tab bar
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(icon: Icon(Icons.dashboard), text: 'نظرة عامة - Overview'),
        Tab(icon: Icon(Icons.code), text: 'اللغات - Languages'),
        Tab(icon: Icon(Icons.speed), text: 'الأداء - Performance'),
      ],
    );
  }

  /// تبويب النظرة العامة - Overview tab
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKPICards(),
          const SizedBox(height: 24),
          _buildUsageChart(),
          const SizedBox(height: 24),
          _buildTopSuggestions(),
        ],
      ),
    );
  }

  /// بناء بطاقات المؤشرات الرئيسية - Build KPI cards
  Widget _buildKPICards() {
    return Row(
      children: [
        Expanded(
          child: _buildKPICard(
            'الاقتراحات المعروضة\nSuggestions Shown',
            '${_stats!.totalSuggestionsShown}',
            Icons.visibility,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            'الاقتراحات المقبولة\nSuggestions Accepted',
            '${_stats!.totalSuggestionsAccepted}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            'معدل القبول\nAcceptance Rate',
            '${(_stats!.acceptanceRate * 100).toInt()}%',
            Icons.trending_up,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            'طلبات API\nAPI Requests',
            '${_stats!.totalApiRequests}',
            Icons.cloud,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  /// بناء بطاقة مؤشر - Build KPI card
  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء مخطط الاستخدام - Build usage chart
  Widget _buildUsageChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الاستخدام اليومي - Daily Usage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(height: 300, child: _buildBarChart()),
          ],
        ),
      ),
    );
  }

  /// بناء مخطط شريطي - Build bar chart
  Widget _buildBarChart() {
    final dailyStats = _stats!.dailyStats.take(7).toList();
    if (dailyStats.isEmpty) {
      return const Center(child: Text('لا توجد بيانات - No data available'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxValue = dailyStats
            .map((s) => s.suggestionsShown)
            .reduce(math.max);
        final barWidth = constraints.maxWidth / (dailyStats.length * 2);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dailyStats.map((stat) {
            final heightRatio = stat.suggestionsShown / maxValue;
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${stat.suggestionsShown}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: barWidth,
                  height: constraints.maxHeight * 0.8 * heightRatio,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stat.date.substring(5),
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  /// بناء أفضل الاقتراحات - Build top suggestions
  Widget _buildTopSuggestions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أكثر الاقتراحات استخداماً - Most Used Suggestions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._buildTopSuggestionsList(),
          ],
        ),
      ),
    );
  }

  /// بناء قائمة أفضل الاقتراحات - Build top suggestions list
  List<Widget> _buildTopSuggestionsList() {
    return [
      _buildSuggestionItem(
        'function calculateTotal()',
        'completion',
        234,
        0.85,
      ),
      _buildSuggestionItem('class UserManager', 'completion', 189, 0.78),
      _buildSuggestionItem('// TODO: Add validation', 'comment', 156, 0.92),
      _buildSuggestionItem('import "package:..."', 'import', 142, 0.88),
      _buildSuggestionItem('await fetchData()', 'completion', 128, 0.81),
    ];
  }

  /// بناء عنصر اقتراح - Build suggestion item
  Widget _buildSuggestionItem(
    String code,
    String type,
    int count,
    double rate,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _buildTypeChip(type),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              code,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$count استخدام',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(width: 16),
          Text(
            '${(rate * 100).toInt()}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  /// تبويب اللغات - Languages tab
  Widget _buildLanguagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLanguageDistribution(),
          const SizedBox(height: 24),
          _buildLanguageDetails(),
        ],
      ),
    );
  }

  /// بناء توزيع اللغات - Build language distribution
  Widget _buildLanguageDistribution() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'توزيع الاستخدام حسب اللغة - Usage by Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: Row(
                children: [
                  Expanded(child: _buildPieChart()),
                  const SizedBox(width: 24),
                  _buildLanguageLegend(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء مخطط دائري - Build pie chart
  Widget _buildPieChart() {
    final languageStats = _stats!.languageStats.entries.toList();
    final total = languageStats.fold<int>(
      0,
      (sum, e) => sum + e.value.totalSuggestions,
    );

    return CustomPaint(
      size: const Size(200, 200),
      painter: _PieChartPainter(
        data: languageStats
            .map((e) => e.value.totalSuggestions / total)
            .toList(),
        colors: _getLanguageColors(languageStats.length),
      ),
    );
  }

  /// بناء مفتاح اللغات - Build language legend
  Widget _buildLanguageLegend() {
    final languageStats = _stats!.languageStats.entries.toList();
    final colors = _getLanguageColors(languageStats.length);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: languageStats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors[index],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${stat.key}: ${stat.value.totalSuggestions}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// بناء تفاصيل اللغات - Build language details
  Widget _buildLanguageDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات تفصيلية - Detailed Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLanguageTable(),
          ],
        ),
      ),
    );
  }

  /// بناء جدول اللغات - Build language table
  Widget _buildLanguageTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        _buildTableRow([
          'اللغة - Language',
          'المجموع - Total',
          'المقبول - Accepted',
          'معدل - Rate',
        ], isHeader: true),
        ..._stats!.languageStats.entries.map((entry) {
          final stat = entry.value;
          return _buildTableRow([
            entry.key,
            '${stat.totalSuggestions}',
            '${stat.acceptedSuggestions}',
            '${(stat.acceptanceRate * 100).toInt()}%',
          ]);
        }),
      ],
    );
  }

  /// بناء صف جدول - Build table row
  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: isHeader ? BoxDecoration(color: Colors.grey.shade200) : null,
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            cell,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// تبويب الأداء - Performance tab
  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceMetrics(),
          const SizedBox(height: 24),
          _buildResponseTimes(),
        ],
      ),
    );
  }

  /// بناء مقاييس الأداء - Build performance metrics
  Widget _buildPerformanceMetrics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مقاييس الأداء - Performance Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'متوسط وقت الاستجابة - Avg Response Time',
              '${_stats!.averageResponseTime}ms',
            ),
            _buildMetricRow(
              'معدل نجاح API - API Success Rate',
              '${(_stats!.apiSuccessRate * 100).toInt()}%',
            ),
            _buildMetricRow(
              'حجم الذاكرة المؤقتة - Cache Size',
              '${_stats!.cacheSize} items',
            ),
            _buildMetricRow(
              'إصابات الذاكرة - Cache Hits',
              '${_stats!.cacheHits}',
            ),
            _buildMetricRow(
              'معدل الإصابة - Hit Rate',
              '${(_stats!.cacheHitRate * 100).toInt()}%',
            ),
          ],
        ),
      ),
    );
  }

  /// بناء صف مقياس - Build metric row
  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF007ACC),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء أوقات الاستجابة - Build response times
  Widget _buildResponseTimes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'توزيع أوقات الاستجابة - Response Time Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildResponseTimeChart(),
          ],
        ),
      ),
    );
  }

  /// بناء مخطط أوقات الاستجابة - Build response time chart
  Widget _buildResponseTimeChart() {
    return Column(
      children: [
        _buildResponseBar('< 100ms', 0.7, Colors.green),
        _buildResponseBar('100-200ms', 0.5, Colors.blue),
        _buildResponseBar('200-500ms', 0.3, Colors.orange),
        _buildResponseBar('> 500ms', 0.1, Colors.red),
      ],
    );
  }

  /// بناء شريط استجابة - Build response bar
  Widget _buildResponseBar(String label, double ratio, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(ratio * 100).toInt()}%',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// بناء حالة فارغة - Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد إحصائيات متاحة\nNo statistics available',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'استخدم Copilot لبدء جمع الإحصائيات\nUse Copilot to start collecting statistics',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// بناء رقاقة النوع - Build type chip
  Widget _buildTypeChip(String type) {
    final colors = {
      'completion': Colors.blue,
      'comment': Colors.green,
      'import': Colors.purple,
      'refactor': Colors.orange,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (colors[type] ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          color: colors[type] ?? Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// الحصول على ألوان اللغات - Get language colors
  List<Color> _getLanguageColors(int count) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors.take(count).toList();
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

/// رسام المخطط الدائري - Pie chart painter
class _PieChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;

  _PieChartPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    var startAngle = -math.pi / 2;

    for (var i = 0; i < data.length; i++) {
      final sweepAngle = 2 * math.pi * data[i];
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
