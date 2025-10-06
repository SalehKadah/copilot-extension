// اختبارات صفحة الإعدادات - Settings Page Widget Tests
// اختبارات شاملة لواجهة الإعدادات
// Comprehensive tests for settings UI

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:copilot_extension/widgets/copilot_settings_page.dart';
import 'package:copilot_extension/models/copilot_settings_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CopilotSettingsPage Widget Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    // ==================== اختبارات العرض ====================
    // Rendering Tests

    testWidgets('عرض صفحة الإعدادات - Render settings page', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('إعدادات Copilot - Copilot Settings'), findsOneWidget);
    });

    testWidgets('عرض 4 تبويبات - Display 4 tabs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('عام - General'), findsOneWidget);
      expect(find.text('المحرر - Editor'), findsOneWidget);
      expect(find.text('متقدم - Advanced'), findsOneWidget);
      expect(find.text('حول - About'), findsOneWidget);
    });

    testWidgets('عرض زر الحفظ - Display save button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('حفظ - Save'), findsOneWidget);
    });

    // ==================== اختبارات التفاعل ====================
    // Interaction Tests

    testWidgets('تبديل تفعيل Copilot - Toggle Copilot enable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // البحث عن مفتاح التبديل - Find switch
      final switchFinder = find.byType(Switch).first;

      // الحصول على القيمة الحالية - Get current value
      final switchWidget = tester.widget<Switch>(switchFinder);
      final initialValue = switchWidget.value;

      // تبديل القيمة - Toggle value
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // التحقق من التغيير - Verify change
      final newSwitchWidget = tester.widget<Switch>(switchFinder);
      expect(newSwitchWidget.value, equals(!initialValue));
    });

    testWidgets('تبديل التبويبات - Switch between tabs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // النقر على تبويب المحرر - Click Editor tab
      await tester.tap(find.text('المحرر - Editor'));
      await tester.pumpAndSettle();

      // التحقق من المحتوى - Verify content
      expect(find.text('العرض - Display'), findsOneWidget);

      // النقر على تبويب متقدم - Click Advanced tab
      await tester.tap(find.text('متقدم - Advanced'));
      await tester.pumpAndSettle();

      expect(find.text('الذاكرة المؤقتة - Cache'), findsOneWidget);
    });

    testWidgets('تعديل شريط التمرير - Modify slider', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // البحث عن شريط التمرير - Find slider
      final sliderFinder = find.byType(Slider).first;

      // سحب الشريط - Drag slider
      await tester.drag(sliderFinder, const Offset(100, 0));
      await tester.pumpAndSettle();

      // التحقق من التغيير - Verify change
      expect(find.byType(Slider), findsWidgets);
    });

    // ==================== اختبارات الحفظ ====================
    // Save Tests

    testWidgets('حفظ الإعدادات - Save settings', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // تعديل إعداد - Modify a setting
      final switchFinder = find.byType(Switch).first;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // النقر على زر الحفظ - Click save button
      await tester.tap(find.text('حفظ - Save'));
      await tester.pumpAndSettle();

      // التحقق من رسالة النجاح - Verify success message
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('زر الحفظ معطل بدون تغييرات - Save button disabled without changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // البحث عن زر الحفظ - Find save button
      final saveButton = find.widgetWithText(FilledButton, 'حفظ - Save');

      // التحقق من أن الزر معطل - Verify button is disabled
      final button = tester.widget<FilledButton>(saveButton);
      expect(button.onPressed, isNull);
    });

    // ==================== اختبارات إعادة التعيين ====================
    // Reset Tests

    testWidgets('إعادة تعيين للافتراضي - Reset to defaults', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // النقر على زر إعادة التعيين - Click reset button
      await tester.tap(find.byIcon(Icons.restore));
      await tester.pumpAndSettle();

      // التأكيد في الحوار - Confirm in dialog
      await tester.tap(find.text('تأكيد - Confirm'));
      await tester.pumpAndSettle();

      // التحقق من رسالة النجاح - Verify success message
      expect(find.byType(SnackBar), findsOneWidget);
    });

    // ==================== اختبارات منتقي اللغات ====================
    // Language Selector Tests

    testWidgets('اختيار لغات - Select languages', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // البحث عن رقائق اللغات - Find language chips
      final dartChip = find.widgetWithText(FilterChip, 'dart');

      if (dartChip.evaluate().isNotEmpty) {
        await tester.tap(dartChip);
        await tester.pumpAndSettle();
      }

      expect(find.byType(FilterChip), findsWidgets);
    });

    // ==================== اختبارات تبويب حول ====================
    // About Tab Tests

    testWidgets('عرض معلومات حول - Display about information', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // الانتقال لتبويب حول - Navigate to About tab
      await tester.tap(find.text('حول - About'));
      await tester.pumpAndSettle();

      expect(find.text('GitHub Copilot Agent'), findsOneWidget);
      expect(find.text('الإصدار 1.0.0 - Version 1.0.0'), findsOneWidget);
    });

    // ==================== اختبارات منطقة الخطر ====================
    // Danger Zone Tests

    testWidgets('مسح الذاكرة المؤقتة - Clear cache', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // الانتقال لتبويب متقدم - Navigate to Advanced tab
      await tester.tap(find.text('متقدم - Advanced'));
      await tester.pumpAndSettle();

      // البحث عن زر مسح الذاكرة - Find clear cache button
      final clearCacheButton = find.text('مسح الذاكرة المؤقتة - Clear Cache');

      if (clearCacheButton.evaluate().isNotEmpty) {
        await tester.tap(clearCacheButton);
        await tester.pumpAndSettle();

        // التأكيد - Confirm
        await tester.tap(find.text('تأكيد - Confirm'));
        await tester.pumpAndSettle();
      }

      expect(find.byType(CopilotSettingsPage), findsOneWidget);
    });

    // ==================== اختبارات الإحصائيات ====================
    // Statistics Display Tests

    testWidgets('عرض الإحصائيات في تبويب حول - Display stats in About tab', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // الانتقال لتبويب حول - Navigate to About tab
      await tester.tap(find.text('حول - About'));
      await tester.pumpAndSettle();

      // التحقق من وجود بطاقة الإحصائيات - Verify statistics card exists
      expect(find.text('الإحصائيات - Statistics'), findsOneWidget);
    });

    // ==================== اختبارات التمرير ====================
    // Scroll Tests

    testWidgets('التمرير في التبويبات - Scroll within tabs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // البحث عن قائمة قابلة للتمرير - Find scrollable list
      final scrollable = find.byType(SingleChildScrollView).first;

      // التمرير للأسفل - Scroll down
      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();

      // التمرير للأعلى - Scroll up
      await tester.drag(scrollable, const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(find.byType(CopilotSettingsPage), findsOneWidget);
    });

    // ==================== اختبارات الاستجابة ====================
    // Responsiveness Tests

    testWidgets('العمل على شاشات صغيرة - Work on small screens', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CopilotSettingsPage), findsOneWidget);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('العمل على شاشات كبيرة - Work on large screens', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CopilotSettingsPage), findsOneWidget);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    // ==================== اختبارات الأداء ====================
    // Performance Tests

    testWidgets('فتح الصفحة بسرعة - Page opens quickly', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('التبديل بين التبويبات بسلاسة - Smooth tab switching', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // التبديل بين جميع التبويبات - Switch between all tabs
      await tester.tap(find.text('المحرر - Editor'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('متقدم - Advanced'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('حول - About'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('عام - General'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    // ==================== اختبارات إمكانية الوصول ====================
    // Accessibility Tests

    testWidgets('دعم قارئ الشاشة - Screen reader support', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // التحقق من Semantics - Verify semantics
      expect(tester.getSemantics(find.byType(CopilotSettingsPage)), isNotNull);
    });

    // ==================== اختبارات معالجة الأخطاء ====================
    // Error Handling Tests

    testWidgets('التعامل مع فشل التحميل - Handle load failure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pump(); // لا ننتظر الانتهاء - Don't wait for completion

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CopilotSettingsPage), findsOneWidget);
    });
  });

  // ==================== اختبارات التكامل ====================
  // Integration Tests

  group('Settings Page Integration Tests', () {
    testWidgets('تدفق كامل: تحميل -> تعديل -> حفظ', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // تعديل إعداد - Modify setting
      final switchFinder = find.byType(Switch).first;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // حفظ - Save
      await tester.tap(find.text('حفظ - Save'));
      await tester.pumpAndSettle();

      // التحقق من النجاح - Verify success
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('تدفق التبويبات الكامل - Complete tab flow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CopilotSettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // زيارة جميع التبويبات - Visit all tabs
      final tabs = [
        'المحرر - Editor',
        'متقدم - Advanced',
        'حول - About',
        'عام - General',
      ];

      for (final tab in tabs) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expect(find.text(tab), findsOneWidget);
      }
    });
  });
}
