import 'package:firebase_ai/firebase_ai.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

class TranslationService {
  final GenerativeModel _model;

  TranslationService()
      : _model = FirebaseAI.googleAI().generativeModel(
          model: 'gemini-2.5-flash',
          systemInstruction: Content.system(
              'You are an expert legal translator specializing in Indian languages (Hindi, Marathi, Tamil, Telugu, etc.). '
              'Translate the provided legal text accurately, preserving the legal meaning and nuance. '
              'Use appropriate legal terminology in the target language. '
              'If a legal term has no direct equivalent, keep the English term in brackets or explain it briefly. '
              'Ensure the tone remains formal and professional.'),
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
