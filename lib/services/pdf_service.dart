import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:myapp/models/chat_model.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<void> generateChatPdf(ChatSession session) async {
    final pdf = pw.Document();

    final List<String> messagesToExport = session.messages
        .map((m) {
          return "${m.userMessage.isNotEmpty ? 'You: ${m.userMessage}' : ''}\n${m.botResponse.isNotEmpty ? 'Law Genie: ${m.botResponse}' : ''}";
        })
        .where((item) => item.trim().isNotEmpty)
        .toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Chat History: ${session.title}',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            ...messagesToExport.map((message) {
              return pw.Container(
                padding: const pw.EdgeInsets.all(10),
                margin: const pw.EdgeInsets.symmetric(vertical: 4),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey300)),
                ),
                child: pw.Text(message),
              );
            }),
          ];
        },
      ),
    );

    try {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/chat_history_${session.sessionId}.pdf");
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
    } catch (e) {
      debugPrint("Error generating or opening PDF: $e");
    }
  }
}
