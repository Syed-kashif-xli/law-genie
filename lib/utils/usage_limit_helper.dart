import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/home/providers/usage_provider.dart';
import 'package:myapp/features/subscription/subscription_page.dart';

/// Helper class to check usage limits and show appropriate dialogs
class UsageLimitHelper {
  /// Check if user can use a feature, show dialog if limit reached
  /// Returns true if user can proceed, false if blocked
  static Future<bool> checkAndShowLimit(
    BuildContext context,
    String featureName, {
    String? customTitle,
  }) async {
    final usageProvider = Provider.of<UsageProvider>(context, listen: false);
    final errorMessage = usageProvider.canUseFeature(featureName);

    if (errorMessage != null) {
      // Limit reached, show dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.block,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  customTitle ?? 'Limit Reached',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                errorMessage,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Upgrade to Premium for unlimited access to all features!',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionPage(),
                  ),
                );
              },
              icon: const Icon(Icons.upgrade),
              label: const Text('Upgrade to Premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
      return false; // Blocked
    }

    return true; // Can proceed
  }

  /// Show a snackbar with usage info
  static void showUsageSnackbar(
    BuildContext context,
    String featureName,
    int current,
    int limit,
  ) {
    final remaining = limit - current;
    final percentage = (current / limit * 100).toInt();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              percentage >= 80 ? Icons.warning_amber : Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                remaining > 0
                    ? '$remaining $featureName requests remaining today'
                    : 'Limit reached for $featureName',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: percentage >= 80
            ? Colors.orange.shade700
            : Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Get a user-friendly feature name
  static String getFeatureDisplayName(String featureName) {
    switch (featureName) {
      case 'aiQueries':
        return 'AI Chat';
      case 'caseFinder':
        return 'Case Finder';
      case 'riskAnalysis':
        return 'Risk Analysis';
      case 'translator':
        return 'Translator';
      case 'courtOrders':
        return 'Court Order Reader';
      case 'scanToPdf':
        return 'Scan to PDF';
      case 'documents':
        return 'Document Generator';
      case 'cases':
        return 'Case Management';
      case 'aiVoice':
        return 'AI Voice';
      case 'bareActs':
        return 'Bare Acts';
      case 'chatHistory':
        return 'Chat History';
      case 'certifiedCopy':
        return 'Certified Copy';
      default:
        return featureName;
    }
  }
}
