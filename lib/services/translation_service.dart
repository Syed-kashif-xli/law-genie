import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

class TranslationService {
  final GenerativeModel _model;

  TranslationService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );

  Future<String> translateText(String text, String from, String to) async {
    if (text.isEmpty) return '';

    final prompt =
        'Translate the following text from $from to $to. Only provide the translated text, no explanations.\n\nText: $text';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Translation failed';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> extractTextFromPdf(String path) async {
    try {
      // Load the existing PDF document.
      final PdfDocument document =
          PdfDocument(inputBytes: File(path).readAsBytesSync());

      // Extract the text from all the pages.
      String text = PdfTextExtractor(document).extractText();

      // Dispose the document.
      document.dispose();

      return text;
    } catch (e) {
      return 'Error extracting text: $e';
    }
  }
}
