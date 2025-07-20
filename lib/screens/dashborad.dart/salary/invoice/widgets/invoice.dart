
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:intl/intl.dart';

// String formatNumber(num number) {
//   return NumberFormat('#,###').format(number);
// }

// String formatTimeInKurdish(DateTime date) {
//   final format = DateFormat('hh:mm a');
//   String formattedTime = format.format(date);
//   formattedTime = formattedTime.replaceAll('AM', 'پ.ن').replaceAll('PM', 'د.ن');
//   return formattedTime;
// }

// class InvoiceTheme {
//   final PdfColor primaryColor = PdfColors.blue700;
//   final PdfColor secondaryColor = PdfColors.grey700;
//   final PdfColor accentColor = PdfColors.teal;
//   final double headerFontSize = 24;
//   final double titleFontSize = 18;
//   final double bodyFontSize = 14;
//   final double smallFontSize = 12;
// }

// pw.Widget buildHeader(pw.MemoryImage logoImage, InvoiceTheme theme) {
//   return pw.Row(
//     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//     children: [
//       pw.Text(
//         'وەسڵ موچە',
//         style: pw.TextStyle(
//           fontSize: theme.headerFontSize,
//           fontWeight: pw.FontWeight.bold,
//           color: theme.primaryColor,
//         ),
//         textDirection: pw.TextDirection.rtl,
//       ),
//       pw.Image(logoImage, width: 80, height: 80),
//     ],
//   );
// }

// pw.Widget buildInvoiceInfo(InvoiceTheme theme) {
//   final now = DateTime.now(); // 11:12 PM +03, July 19, 2025
//   return pw.Row(
//     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//     children: [
//       pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Text(
//             'ژمارەی وەسڵ',
//             style: pw.TextStyle(
//               fontSize: theme.smallFontSize,
//               color: theme.secondaryColor,
//             ),
//           ),
//           pw.Text(
//             '#${now.millisecondsSinceEpoch.toString().substring(5)}',
//             style: pw.TextStyle(
//               fontSize: theme.bodyFontSize,
//               fontWeight: pw.FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//       pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Text(
//             'بەروار',
//             style: pw.TextStyle(
//               fontSize: theme.smallFontSize,
//               color: theme.secondaryColor,
//             ),
//           ),
//           pw.Text(
//             DateFormat('dd/MM/yyyy').format(now),
//             style: pw.TextStyle(
//               fontSize: theme.bodyFontSize,
//               fontWeight: pw.FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     ],
//   );
// }

// pw.Widget buildDetailsSection({
//   required String employeeName,
//   required String employeeEmail,
//   required DateTime paymentDate,
//   required int salary,
//   required Duration totalWorkedTime,
//   required int workTarget,
//   required int absenceDays,
//   required int dailyWorkHours,
//   required num reward,
//   required num punishment,
//   required num taskReward,
//   required num taskPunishment,
//   required String adminEmail,
//   required int monthlyPayback,
//   required int punishmentPerHour,
//   required int givenSalary,
//   required InvoiceTheme theme,
// }) {
//   return pw.Table(
//     columnWidths: {
//       0: const pw.FlexColumnWidth(1),
//       1: const pw.FlexColumnWidth(3),
//     },
//     border: pw.TableBorder.all(color: PdfColors.grey200, width: 1),
//     children: [
//       buildTableRow(label: 'ناوی کارمەند', value: employeeName, theme: theme),
//       buildTableRow(label: 'ئیمەیل', value: employeeEmail, theme: theme),
//       buildTableRow(label: 'بەروار پارەدان', value: DateFormat('dd/MM/yyyy').format(paymentDate), theme: theme),
//       buildTableRow(label: 'کاتی کارکردن', value: '${totalWorkedTime.inHours} کاتژمێر و ${totalWorkedTime.inMinutes.remainder(60)} خولەک', theme: theme),
//       buildTableRow(label: 'ئامانجی کار', value: '$workTarget کاتژمێر', theme: theme),
//       buildTableRow(label: 'ڕۆژانی مۆڵەت', value: '$absenceDays ڕۆژ', theme: theme),
//       buildTableRow(label: 'پاداشتی پێدراو', value: '${formatNumber(reward)} دینار', theme: theme),
//       buildTableRow(label: 'سزای پێدراو', value: '${formatNumber(punishment)} دینار', theme: theme),
//       buildTableRow(label: 'پاداشتی ئەرکەکان', value: '${formatNumber(taskReward)} دینار', theme: theme),
//       buildTableRow(label: 'سزای ئەرکەکان', value: '${formatNumber(taskPunishment)} دینار', theme: theme),
//       buildTableRow(label: 'بڕی موچە', value: '${formatNumber(salary)} دینار', theme: theme),
//       buildTableRow(label: 'پارەدانەوەی مانگانە', value: '${formatNumber(monthlyPayback)} دینار', theme: theme),
//       buildTableRow(label: 'سزای کەمی کات', value: '${formatNumber(punishmentPerHour)} دینار/کاتژمێر', theme: theme),
//       buildTableRow(label: 'موچەی پێدراو', value: '${formatNumber(givenSalary)} دینار', theme: theme),
//       buildTableRow(label: 'پارەدەر', value: adminEmail, theme: theme),
//     ],
//   );
// }

// pw.TableRow buildTableRow({
//   required String label,
//   required String value,
//   required InvoiceTheme theme,
// }) {

//   return pw.TableRow(
//     children: [
//       pw.Padding(
//         padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//         child: pw.Text(
//           label,
          
//           style: pw.TextStyle(
//             fontSize: theme.bodyFontSize,
//             color: theme.secondaryColor,
            
//           ),

//           textDirection: pw.TextDirection.rtl,
//         ),
//       ),
//       pw.Padding(
//         padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//         child: pw.Text(
//           value,
//           style: pw.TextStyle(
//             fontSize: theme.bodyFontSize,
//             fontWeight: pw.FontWeight.bold,
//           ),
//           textDirection: pw.TextDirection.rtl,
//         ),
//       ),
//     ],
//   );
// }

// pw.Widget buildThankYouSection(InvoiceTheme theme, bool isRtl, pw.Font ttfFont) {
//   return pw.Column(
//     crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
//     children: [
//       pw.Divider(color: PdfColors.grey300, thickness: 1),
//       pw.SizedBox(height: 16),
//       pw.Text(
//         'سوپاست بۆ کاتی خۆشدەپێدانی موچەکەت',
//         style: pw.TextStyle(
//           fontSize: theme.bodyFontSize,
//           color: theme.secondaryColor,
//           fontStyle: pw.FontStyle.italic,
//          font: ttfFont, // Uncomment if you add a font
//         ),
//         textDirection: pw.TextDirection.rtl,
//       ),
//       pw.SizedBox(height: 8),
//       pw.Text(
//         'Generated by @BritishBody',
//         style: pw.TextStyle(
//           fontSize: theme.smallFontSize,
//           color: theme.secondaryColor,
//            font: ttfFont, // Uncomment if you add a font
//         ),
//         textDirection: pw.TextDirection.ltr,
//       ),
//     ],
//   );
// }