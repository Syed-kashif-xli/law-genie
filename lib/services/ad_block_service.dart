import 'package:http/http.dart' as http;

class AdBlockService {
  /// Checks if an ad blocker is likely active.
  /// Returns check result:
  /// 0: No Internet
  /// 1: No Ad Blocker (Clean)
  /// 2: Ad Blocker Detected
  static Future<int> detectAdBlocker() async {
    try {
      // 1. Check General Connectivity
      final googleCheck = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 4));
      if (googleCheck.statusCode != 200) {
        // Technically could be 200OK. If it fails completely it throws.
        // If it returns non-200, internet might be weird, but let's assume active.
      }
    } catch (e) {
      return 0; // No Internet
    }

    try {
      // 2. Check Ad Server
      // doubleclick is the most standard domain blocked by ad blockers
      await http
          .get(Uri.parse('https://googleads.g.doubleclick.net'))
          .timeout(const Duration(seconds: 4));
      return 1; // Success - No Blocker
    } catch (e) {
      // Connection failed to ad server, but google.com worked.
      // Likely an Ad Blocker.
      return 2;
    }
  }
}
