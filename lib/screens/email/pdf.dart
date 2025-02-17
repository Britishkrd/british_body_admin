import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PDF {
  static pw.Font? arabicFont;
  static pw.Font? englishFont;

  // Initialize the fonts (Arabic and English fonts)
  static Future<void> init() async {
    arabicFont = pw.Font.times();
    pw.Font.ttf(
        await rootBundle.load('lib/assets/Rabar_029.ttf')); // Arabic font
    englishFont = pw.Font.ttf(await rootBundle.load(
        'lib/assets/Rabar_029.ttf')); // English font (Helvetica or any other default)
  }

  static Future<void> createPDF(
      List<String> to,
      List<String> cc,
      String subject,
      String content,
      List<String> images,
      List<String> files,
      DateTime date,
      String email,
      String from,
      int id) async {
    await init();

    // Create a new PDF document
    final pdf = pw.Document();

    // Create the content for the MultiPage
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildTitle(subject),
            _buildSubtitle(from, from, 'English', id),

            pw.SizedBox(height: 20),

            // Table Section (Room Info) using pw.TableRow
            _buildRoomTableWithTableRow('TO', to),
            _buildRoomTableWithTableRow('CC', cc),

            pw.SizedBox(height: 20),

            // Notes and Total Cost Section
            _buildNotesAndTotalCost(content)
          ];
        },
      ),
    );

    // Save the document
    final output = await getApplicationDocumentsDirectory();
    final file = File(
        "${output.path}/email_${DateTime.now().millisecondsSinceEpoch}.pdf");

    // Write PDF data to file
    await file.writeAsBytes(await pdf.save());

    // Open the PDF (optional, requires additional packages on Android/iOS)
    OpenFile.open(file.path);
  }

  // Build the title for the report in Arabic
  static pw.Widget _buildTitle(String hotelName) {
    return pw.Center(
      child: pw.Text(
        hotelName.toUpperCase(),
       style: pw.TextStyle(
              fontSize: 16,
              font: englishFont!,
            ),
            textDirection: pw.TextDirection.rtl
      ),
    );
  }

  // Build the subtitle showing date range
  static pw.Widget _buildSubtitle(String customername,
      String customerphonenumber, String valueLanguage, int recieptnumber) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("${'ڕۆژ'}: ${_formatDate(DateTime.now())}",
              style: pw.TextStyle(
              fontSize: 12,
              font: englishFont!,
            ),
            textDirection: pw.TextDirection.rtl),
          pw.Text("${'کات'}: ${DateFormat('kk:mm').format(DateTime.now())}",
              style: pw.TextStyle(
              fontSize: 12,
              font: englishFont!,
            ),
            textDirection: pw.TextDirection.rtl),
          pw.Text("${'ناسنامەی ئیمەیڵ'}: $recieptnumber",
              style: pw.TextStyle(
              fontSize: 12,
              font: englishFont!,
            ),
            textDirection: pw.TextDirection.rtl),
        ]),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("${'ئیمەیڵ لەلایەن'}: $customername",
              style: pw.TextStyle(
              fontSize: 12,
              font: englishFont!,
            ),
            textDirection: pw.TextDirection.rtl),
        ]),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  // Build the room table using pw.TableRow
  static pw.Widget _buildRoomTableWithTableRow(
    String title,
    List<String> list,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildCell(title, 'English', isHeader: true),
            // _buildCell('children', valueLanguage, isHeader: true),
            // _buildCell('price', valueLanguage, isHeader: true),
            // _buildCell('checkIn', valueLanguage, isHeader: true),
            // _buildCell('checkOut', valueLanguage, isHeader: true),
            // _buildCell('employee', valueLanguage, isHeader: true),
          ],
        ),
        // Data rows
        for (int i = 0; i < list.length; i++)
          pw.TableRow(
            children: [
              _buildCell(list[i], 'English'),
              // _buildCell(children, valueLanguage),
              // _buildCell(NumberFormat("#,###").format(int.parse(price)),
              //     valueLanguage),
              // _buildCell(
              //     DateFormat("yy-MM-dd").format(starts[i]), valueLanguage),
              // _buildCell(DateFormat("yy-MM-dd").format(ends[i]), valueLanguage),
              // _buildCell(employee, valueLanguage),
            ],
          ),
      ],
    );
  }

  // Build a cell for the table with optional header styling
  static pw.Widget _buildCell(String content, String valueLanguage,
      {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        content,
       style: pw.TextStyle(
              fontSize: 12,
              font: englishFont!,
            ),
            textDirection: pw.TextDirection.rtl,
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // Build the notes and total cost section
  static pw.Widget _buildNotesAndTotalCost(String content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ناوەڕۆکی ئیمەیڵ :',
          style: pw.TextStyle(
              fontSize: 12,
              font: englishFont!,
            ),
            textDirection: pw.TextDirection.rtl
        ),
        pw.SizedBox(height: 10),
        pw.Text(content,
            style: pw.TextStyle(
              fontSize: 12,
              font: englishFont!,
            ),
            textDirection: pw.TextDirection.rtl),
      ],
    );
  }
}
