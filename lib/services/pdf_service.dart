import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:myapp/models/judgment_model.dart';
import 'package:myapp/models/chat_model.dart' as chat_models;
import 'package:myapp/features/case_finder/models/legal_case.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PdfService {
  /// Generate and download a PDF for a legal judgment
  static Future<void> generateAndDownloadPdf(Judgment judgment) async {
    try {
      // Load logo bytes in main isolate
      final ByteData logoData = await rootBundle.load('assets/images/logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();

      // Use compute to run PDF generation in a background isolate
      final Uint8List bytes = await compute(_generateJudgmentPdfBytes, {
        'judgment': judgment,
        'logoBytes': logoBytes,
      });

      // Use Printing.layoutPdf for immediate preview/print/save
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'LawGenie_Judgment_${judgment.id}.pdf',
      );

      // Save to file for notification
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/LawGenie_Judgment_${judgment.id}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await NotificationService().showDownloadNotification(
        title: 'Judgment Exported',
        body: 'The judgment "${judgment.title}" has been saved.',
        filePath: file.path,
      );
    } catch (e) {
      debugPrint('PdfService Error: $e');
      rethrow;
    }
  }

  /// Improved: Generate and download a PDF for a chat session
  static Future<void> generateChatPdf(chat_models.ChatSession session) async {
    try {
      final ByteData logoData = await rootBundle.load('assets/images/logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();

      final Uint8List bytes = await compute(_generateChatPdfBytes, {
        'session': session,
        'logoBytes': logoBytes,
      });

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'LawGenie_Chat_${session.sessionId}.pdf',
      );

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/LawGenie_Chat_${session.sessionId}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await NotificationService().showDownloadNotification(
        title: 'Chat Exported',
        body: 'Your chat session "${session.title}" has been saved.',
        filePath: file.path,
      );
    } catch (e) {
      debugPrint('PdfService Chat Error: $e');
      rethrow;
    }
  }

  /// New: Generate and download a PDF for a Case Status result
  static Future<void> generateCaseStatusPdf(LegalCase caseResult) async {
    try {
      final ByteData logoData = await rootBundle.load('assets/images/logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();

      final Uint8List bytes = await compute(_generateCaseStatusPdfBytes, {
        'caseResult': caseResult,
        'logoBytes': logoBytes,
      });

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name:
            'LawGenie_CaseStatus_${caseResult.cnrNumber ?? caseResult.id}.pdf',
      );

      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/LawGenie_CaseStatus_${caseResult.cnrNumber ?? caseResult.id}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await NotificationService().showDownloadNotification(
        title: 'Case Status Exported',
        body:
            'The case status report for CNR ${caseResult.cnrNumber ?? "Report"} is ready.',
        filePath: file.path,
      );
    } catch (e) {
      debugPrint('PdfService CaseStatus Error: $e');
      rethrow;
    }
  }
}

/// Top-level function for compute to generate judgment PDF
Future<Uint8List> _generateJudgmentPdfBytes(Map<String, dynamic> data) async {
  final Judgment judgment = data['judgment'];
  final Uint8List logoBytes = data['logoBytes'];

  final pdf = pw.Document();
  final logo = pw.MemoryImage(logoBytes);

  // Split content into paragraphs to avoid massive layout overhead for a single widget
  final List<String> paragraphs = (judgment.content ?? 'No content available.')
      .split('\n')
      .where((p) => p.trim().isNotEmpty)
      .toList();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Image(logo, width: 40, height: 40),
                    pw.SizedBox(width: 10),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('LawGenie',
                            style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900)),
                        pw.Text('Legal Research Platform',
                            style: const pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                  ],
                ),
                pw.Text('OFFICIAL CASE REPORT',
                    style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey)),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1, color: PdfColors.blue900),
            pw.SizedBox(height: 20),
          ],
        );
      },
      footer: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Divider(thickness: 0.5, color: PdfColors.grey400),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Generated by LawGenie - Your Legal AI Assistant',
                    style:
                        const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                    style:
                        const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
              ],
            ),
          ],
        );
      },
      build: (pw.Context context) {
        return [
          pw.Center(
            child: pw.Text(
              judgment.title.toUpperCase(),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black),
            ),
          ),
          pw.SizedBox(height: 15),

          // Metadata Box
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (judgment.date != null)
                  _buildMetaRow('Date of Judgment', judgment.date!),
                if (judgment.bench != null)
                  _buildMetaRow('Bench', judgment.bench!),
                if (judgment.author != null)
                  _buildMetaRow('Author', judgment.author!),
              ],
            ),
          ),

          pw.SizedBox(height: 30),

          // Efficiently add paragraphs
          ...paragraphs.map((text) => pw.Paragraph(
                text: text,
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(
                  fontSize: 11,
                  lineSpacing: 2,
                  color: PdfColors.black,
                ),
                margin: const pw.EdgeInsets.only(bottom: 12),
              )),

          pw.SizedBox(height: 40),
          pw.Center(
            child: pw.Text(
              '--- END OF DOCUMENT ---',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ),
        ];
      },
    ),
  );

  return pdf.save();
}

pw.Widget _buildMetaRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 110,
          child: pw.Text('$label:',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        ),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    ),
  );
}

/// Top-level function for compute to generate chat PDF
Future<Uint8List> _generateChatPdfBytes(Map<String, dynamic> data) async {
  final chat_models.ChatSession session = data['session'];
  final Uint8List logoBytes = data['logoBytes'];

  final pdf = pw.Document();
  final logo = pw.MemoryImage(logoBytes);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Image(logo, width: 40, height: 40),
                    pw.SizedBox(width: 10),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('LawGenie',
                            style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900)),
                        pw.Text('Legal Chat Export',
                            style: const pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                  ],
                ),
                pw.Text(session.timestamp.toString().split(' ')[0],
                    style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey)),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1, color: PdfColors.blue900),
            pw.SizedBox(height: 20),
          ],
        );
      },
      footer: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Divider(thickness: 0.5, color: PdfColors.grey400),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                    'Exported from LawGenie - Professional AI Legal Researcher',
                    style:
                        const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                    style:
                        const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
              ],
            ),
          ],
        );
      },
      build: (pw.Context context) {
        return [
          pw.Text(session.title,
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 25),
          ...session.messages.map((msg) {
            final userParas =
                msg.userMessage.split('\n').where((p) => p.trim().isNotEmpty);
            final botParas =
                msg.botResponse.split('\n').where((p) => p.trim().isNotEmpty);

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border(
                        left:
                            pw.BorderSide(color: PdfColors.blue800, width: 3)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('USER QUERY:',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                              color: PdfColors.blue900)),
                      pw.SizedBox(height: 5),
                      ...userParas.map((p) =>
                          pw.Text(p, style: const pw.TextStyle(fontSize: 11))),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('LAWGENIE ANALYSIS:',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                              color: PdfColors.blue900)),
                      pw.SizedBox(height: 5),
                      ...botParas.map((p) => pw.Text(p,
                          style: const pw.TextStyle(
                              fontSize: 11, lineSpacing: 1.5))),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(color: PdfColors.grey200),
                pw.SizedBox(height: 15),
              ],
            );
          }),
        ];
      },
    ),
  );

  return pdf.save();
}

/// Top-level function for generateCaseStatusPdf
Future<Uint8List> _generateCaseStatusPdfBytes(Map<String, dynamic> data) async {
  final LegalCase caseResult = data['caseResult'];
  final Uint8List logoBytes = data['logoBytes'];

  final pdf = pw.Document();
  final logo = pw.MemoryImage(logoBytes);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Image(logo, width: 40, height: 40),
                    pw.SizedBox(width: 10),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('LawGenie',
                            style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900)),
                        pw.Text('Case Status Report',
                            style: const pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('CNR: ${caseResult.cnrNumber ?? "N/A"}',
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black)),
                    pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}',
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColors.grey)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1, color: PdfColors.blue900),
            pw.SizedBox(height: 20),
          ],
        );
      },
      build: (pw.Context context) {
        return [
          pw.Center(
            child: pw.Text('CASE STATUS REPORT',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),

          // Case Details
          _buildPdfSectionTitle('CASE DETAILS'),
          _buildPdfDetailRow('Case Type', caseResult.caseType),
          _buildPdfDetailRow('Filing Number', caseResult.filingNumber),
          _buildPdfDetailRow('Filing Date', caseResult.filingDate),
          _buildPdfDetailRow('Registration No', caseResult.registrationNumber),
          _buildPdfDetailRow('Registration Date', caseResult.registrationDate),
          _buildPdfDetailRow('CNR Number', caseResult.cnrNumber),
          pw.SizedBox(height: 15),

          // Case Status
          _buildPdfSectionTitle('CASE STATUS'),
          _buildPdfDetailRow('First Hearing Date', caseResult.firstHearingDate),
          _buildPdfDetailRow('Next Hearing Date', caseResult.nextHearingDate),
          _buildPdfDetailRow('Case Stage', caseResult.caseStage),
          _buildPdfDetailRow('Nature of Disposal', caseResult.natureOfDisposal),
          _buildPdfDetailRow('Court Number', caseResult.courtNumber),
          _buildPdfDetailRow('Judge', caseResult.judgeDesignation),
          _buildPdfDetailRow('Court', caseResult.court),
          pw.SizedBox(height: 15),

          // Parties
          _buildPdfSectionTitle('PETITIONER & RESPONDENT'),
          _buildPdfDetailRow('Petitioner', caseResult.petitioner),
          _buildPdfDetailRow('Advocate', caseResult.petitionerAdvocate),
          pw.SizedBox(height: 5),
          _buildPdfDetailRow('Respondent', caseResult.respondent),
          _buildPdfDetailRow('Advocate', caseResult.respondentAdvocate),

          if (caseResult.acts != null && caseResult.acts!.isNotEmpty) ...[
            pw.SizedBox(height: 15),
            _buildPdfSectionTitle('ACTS'),
            pw.Text(caseResult.acts!, style: const pw.TextStyle(fontSize: 10)),
          ],
        ];
      },
    ),
  );

  return pdf.save();
}

pw.Widget _buildPdfSectionTitle(String title) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    decoration: const pw.BoxDecoration(
      color: PdfColors.grey200,
    ),
    child: pw.Text(title,
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
  );
}

pw.Widget _buildPdfDetailRow(String label, String? value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 8),
    child: pw.Row(
      children: [
        pw.SizedBox(
            width: 120,
            child: pw.Text('$label:',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 10))),
        pw.Expanded(
          child:
              pw.Text(value ?? 'N/A', style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    ),
  );
}
