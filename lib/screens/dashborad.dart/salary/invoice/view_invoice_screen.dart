import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoiceGenerator {
  Future<File> generateInvoice({
    required String employeeName,
    required String employeeEmail,
    required DateTime paymentDate,
    required num salary,
    required Duration totalWorkedTime,
    required int workTarget,
    required int absenceDays,
    required int dailyWorkHours,
    required num reward,
    required num punishment,
    required num taskReward,
    required num taskPunishment,
    required String adminEmail,
    required int monthlyPayback,
    required int punishmentPerHour,
    required num givenSalary,
  }) async {
    try {
      final pdf = pw.Document();
      final theme = InvoiceTheme();

      // Load the custom font with better error handling
      pw.Font? ttfFont;
      try {
        final fontData = await rootBundle.load('assets/fonts/arabic.ttf');
        ttfFont = pw.Font.ttf(fontData);
      } catch (e) {
        print('Custom font not found, using default: $e');
        ttfFont = null;
      }

      // Try to load logo, but handle if it doesn't exist
      pw.MemoryImage? logoImage;
      try {
        final logoBytes =
            (await rootBundle.load('assets/img/logo.png')).buffer.asUint8List();
        logoImage = pw.MemoryImage(logoBytes);
      } catch (e) {
        print('Logo not found: $e');
        logoImage = null;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header Section
              buildHeader(logoImage, theme, ttfFont),
              pw.SizedBox(height: 24),

              // Invoice Information Section
              buildInvoiceInfo(theme, ttfFont),
              pw.SizedBox(height: 16),

              // Divider
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 24),

              // Employee & Salary Details - ALL DATA
              buildCompleteDetailsSection(
                employeeName: employeeName,
                employeeEmail: employeeEmail,
                paymentDate: paymentDate,
                salary: salary,
                totalWorkedTime: totalWorkedTime,
                workTarget: workTarget,
                absenceDays: absenceDays,
                dailyWorkHours: dailyWorkHours,
                reward: reward,
                punishment: punishment,
                taskReward: taskReward,
                taskPunishment: taskPunishment,
                adminEmail: adminEmail,
                monthlyPayback: monthlyPayback,
                punishmentPerHour: punishmentPerHour,
                givenSalary: givenSalary,
                theme: theme,
                ttfFont: ttfFont,
              ),
              pw.SizedBox(height: 16),

              // Thank You Section
              buildThankYouSection(theme, true, ttfFont),
            ];
          },
        ),
      );

      // Save the PDF
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File(
        '${directory.path}/salary_invoice_${employeeEmail.replaceAll('@', '_').replaceAll('.', '_')}_$timestamp.pdf',
      );

      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      print('PDF saved to: ${file.path}');
      return file;
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow;
    }
  }

  // Helper method to calculate punishment (same logic as in your screen)
  num _calculatePunishment(int workTarget, Duration totalWorkedTime, int punishmentPerHour) {
    final missedHours = workTarget - totalWorkedTime.inHours;
    if (missedHours <= 0) return 0;
    return missedHours * punishmentPerHour;
  }

  // Helper method to format remaining time (same logic as in your screen)
  String _formatRemainingTime(int workTargetHours, Duration totalWorkedTime) {
    final targetMinutes = workTargetHours * 60;
    final workedMinutes = totalWorkedTime.inMinutes;
    final remainingMinutes = targetMinutes - workedMinutes;

    if (remainingMinutes <= 0) {
      return '0 کاتژمێر و 0 خولەک';
    }

    final hours = remainingMinutes ~/ 60;
    final minutes = remainingMinutes % 60;

    return '$hours کاتژمێر و $minutes خولەک';
  }
}

// Helper Functions
pw.Widget buildHeader(
    pw.MemoryImage? logoImage, InvoiceTheme theme, pw.Font? ttfFont) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        'وەسڵ موچە',
        style: pw.TextStyle(
          font: ttfFont,
          fontSize: theme.headerFontSize,
          fontWeight: pw.FontWeight.bold,
          color: theme.primaryColor,
        ),
        textDirection: pw.TextDirection.rtl,
      ),
      // Only show image if it exists
      if (logoImage != null)
        pw.Image(logoImage, width: 80, height: 80)
      else
        pw.Container(
          width: 80,
          height: 80,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Center(
            child: pw.Text(
              'LOGO',
              style: pw.TextStyle(
                font: ttfFont,
                color: PdfColors.grey500,
                fontSize: 12,
              ),
            ),
          ),
        ),
    ],
  );
}

pw.Widget buildInvoiceInfo(InvoiceTheme theme, pw.Font? ttfFont) {
  final now = DateTime.now();
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ژمارەی وەسڵ',
            style: pw.TextStyle(
              font: ttfFont,
              fontSize: theme.smallFontSize,
              color: theme.secondaryColor,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Text(
            '#${now.millisecondsSinceEpoch.toString().substring(5)}',
            style: pw.TextStyle(
              font: ttfFont,
              fontSize: theme.bodyFontSize,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'بەروار',
            style: pw.TextStyle(
              font: ttfFont,
              fontSize: theme.smallFontSize,
              color: theme.secondaryColor,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Text(
            DateFormat('dd/MM/yyyy').format(now),
            style: pw.TextStyle(
              font: ttfFont,
              fontSize: theme.bodyFontSize,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    ],
  );
}

pw.Widget buildCompleteDetailsSection({
  required String employeeName,
  required String employeeEmail,
  required DateTime paymentDate,
  required num salary,
  required Duration totalWorkedTime,
  required int workTarget,
  required int absenceDays,
  required int dailyWorkHours,
  required num reward,
  required num punishment,
  required num taskReward,
  required num taskPunishment,
  required String adminEmail,
  required int monthlyPayback,
  required int punishmentPerHour,
  required num givenSalary,
  required InvoiceTheme theme,
  required pw.Font? ttfFont,
}) {
  // Calculate additional values (same as in your screen)
  final missedHours = workTarget - totalWorkedTime.inHours;
  final punishmentForMissedWork = missedHours > 0 ? missedHours * punishmentPerHour : 0;
  final remainingTime = _formatRemainingTime(workTarget, totalWorkedTime);
  final absenceHours = absenceDays * dailyWorkHours;
  
  // Create table with ALL data from your screen
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400, width: 1),
    ),
    child: pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(2.5),
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        // Employee Name
        buildTableRow(
            label: 'ناوی کارمەند',
            value: employeeName,
            theme: theme,
            ttfFont: ttfFont),
        
        // Date (Payment month/year)
        buildTableRow(
            label: 'بەروار',
            value: '${paymentDate.year} / ${paymentDate.month}',
            theme: theme,
            ttfFont: ttfFont),

        // Absence Days (exactly like in your screen)
        buildTableRow(
            label: 'ژمارەی ڕۆژانی مۆڵەت',
            value: '$absenceDays ڕۆژ واتە $absenceHours کاتژمێر',
            theme: theme,
            ttfFont: ttfFont),

        // Task Rewards
        buildTableRow(
            label: 'کۆی پاداشتی ئەرکەکان',
            value: '${formatNumber(taskReward)} دینار',
            theme: theme,
            ttfFont: ttfFont),

        // Task Punishment
        buildTableRow(
            label: 'کۆی سزای ئەرکەکان',
            value: '${formatNumber(taskPunishment)} دینار',
            theme: theme,
            ttfFont: ttfFont),

        // Given Reward
        buildTableRow(
            label: 'کۆی پاداشتی پێدراو',
            value: '${formatNumber(reward)} دینار',
            theme: theme,
            ttfFont: ttfFont),

        // Given Punishment
        buildTableRow(
            label: 'سزا پێدراو',
            value: '${formatNumber(punishment)} دینار',
            theme: theme,
            ttfFont: ttfFont),

        // Total Worked Time
        buildTableRow(
            label: 'کۆی کاتی کارکردن',
            value: '${totalWorkedTime.inHours} کاتژمێر و ${totalWorkedTime.inMinutes.remainder(60)} خولەک',
            theme: theme,
            ttfFont: ttfFont),

        // Remaining Work Time
        buildTableRow(
            label: 'کاتی کارکردنی ماوە',
            value: remainingTime,
            theme: theme,
            ttfFont: ttfFont),

        // Work Target
        buildTableRow(
            label: 'ئامانجی کارکردن',
            value: '$workTarget کاتژمێر (${(workTarget / 8).toStringAsFixed(0)} ڕۆژ)',
            theme: theme,
            ttfFont: ttfFont),

        // Punishment for missing work hours
        buildTableRow(
            label: 'بڕی سزای کەمی کاتی کارکردن',
            value: '${formatNumber(punishmentForMissedWork)} دینار',
            theme: theme,
            ttfFont: ttfFont),

        // Base Salary
        buildTableRow(
            label: 'بڕی موچە',
            value: '${formatNumber(salary)} دینار',
            theme: theme,
            ttfFont: ttfFont),

        // Loan Amount
        buildTableRow(
            label: 'بڕی سولفەی وەرگیراو',
            value: 'دیاری نەکراوە', // Since loan is passed as string, you might want to format it
            theme: theme,
            ttfFont: ttfFont),

        // Monthly Payback
        buildTableRow(
            label: 'بڕی پارەدانەوەی مانگانە',
            value: '${formatNumber(monthlyPayback)} دینار',
            theme: theme,
            ttfFont: ttfFont),

        // Punishment per hour rate
        buildTableRow(
            label: 'بڕی سزا بۆ هەر کاتژمێر',
            value: '${formatNumber(punishmentPerHour)} دینار',
            theme: theme,
            ttfFont: ttfFont),

        // Final Given Salary (highlighted - most important)
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
            ),
          ),
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: pw.Text(
                '${formatNumber(givenSalary)} دینار',
                style: pw.TextStyle(
                  font: ttfFont,
                  fontSize: theme.bodyFontSize,
                  fontWeight: pw.FontWeight.bold,
                  color: theme.primaryColor,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: pw.Text(
                'بڕی موچەی پێدراو',
                style: pw.TextStyle(
                  font: ttfFont,
                  fontSize: theme.bodyFontSize,
                  fontWeight: pw.FontWeight.bold,
                  color: theme.primaryColor,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
          ],
        ),

        // Admin Email
        buildTableRow(
            label: 'پارەدەر',
            value: adminEmail,
            theme: theme,
            ttfFont: ttfFont),
      ],
    ),
  );
}

// Helper method to format remaining time
String _formatRemainingTime(int workTargetHours, Duration totalWorkedTime) {
  final targetMinutes = workTargetHours * 60;
  final workedMinutes = totalWorkedTime.inMinutes;
  final remainingMinutes = targetMinutes - workedMinutes;

  if (remainingMinutes <= 0) {
    return '0 کاتژمێر و 0 خولەک';
  }

  final hours = remainingMinutes ~/ 60;
  final minutes = remainingMinutes % 60;

  return '$hours کاتژمێر و $minutes خولەک';
}

pw.TableRow buildTableRow({
  required String label,
  required String value,
  required InvoiceTheme theme,
  required pw.Font? ttfFont,
}) {
  return pw.TableRow(
    decoration: pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
      ),
    ),
    children: [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: pw.Text(
          value,
          style: pw.TextStyle(
            font: ttfFont,
            fontSize: theme.bodyFontSize - 2,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
          textDirection: pw.TextDirection.rtl,
        ),
      ),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: pw.Text(
          label,
          style: pw.TextStyle(
            font: ttfFont,
            fontSize: theme.bodyFontSize - 2,
            color: theme.secondaryColor,
          ),
          textDirection: pw.TextDirection.rtl,
        ),
      ),
    ],
  );
}

pw.Widget buildThankYouSection(
    InvoiceTheme theme, bool isRtl, pw.Font? ttfFont) {
  return pw.Column(
    crossAxisAlignment:
        isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
    children: [
      pw.Divider(color: PdfColors.grey300, thickness: 1),
      pw.SizedBox(height: 16),
      pw.Text(
        'سوپاست بۆ کاتی خۆشدەپێدانی موچەکەت',
        style: pw.TextStyle(
          font: ttfFont,
          fontSize: theme.bodyFontSize,
          color: theme.secondaryColor,
          fontStyle: pw.FontStyle.italic,
        ),
        textDirection: pw.TextDirection.rtl,
      ),
      pw.SizedBox(height: 8),
      pw.Text(
        'Generated by @BritishBody',
        style: pw.TextStyle(
          font: ttfFont,
          fontSize: theme.smallFontSize,
          color: theme.secondaryColor,
        ),
        textDirection: pw.TextDirection.ltr,
      ),
    ],
  );
}

String formatNumber(num number) {
  return NumberFormat('#,###').format(number);
}

String formatTimeInKurdish(DateTime date) {
  final format = DateFormat('hh:mm a');
  String formattedTime = format.format(date);
  formattedTime = formattedTime.replaceAll('AM', 'پ.ن').replaceAll('PM', 'د.ن');
  return formattedTime;
}

class InvoiceTheme {
  final PdfColor primaryColor = PdfColors.blue700;
  final PdfColor secondaryColor = PdfColors.grey700;
  final PdfColor accentColor = PdfColors.teal;
  final double headerFontSize = 24;
  final double titleFontSize = 18;
  final double bodyFontSize = 14;
  final double smallFontSize = 12;
}