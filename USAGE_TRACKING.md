# Usage Tracking & Limits System

## Overview
Law Genie app mein comprehensive usage tracking system hai jo har user ki API calls ko track karta hai aur limits enforce karta hai. Yeh system **daily** aur **monthly** dono limits support karta hai.

## Features
✅ **Daily Limits** - Har din reset hote hain  
✅ **Monthly Limits** - Har mahine reset hote hain  
✅ **Per-User Tracking** - Har user ka alag usage count  
✅ **Firestore Sync** - Server-side tracking for analytics  
✅ **Premium Support** - Premium users ko unlimited access  
✅ **User-Friendly Messages** - Clear error messages with upgrade options  

## Configuration

### Limits ko Change Karna

Limits ko change karne ke liye `lib/features/home/providers/usage_provider.dart` file mein `UsageLimits` class ko edit karein:

```dart
class UsageLimits {
  // Daily Limits (Free Users)
  static const int dailyAiQueries = 10;        // AI Chat queries per day
  static const int dailyCaseFinder = 5;        // Case searches per day
  static const int dailyRiskAnalysis = 3;      // Risk analyses per day
  static const int dailyTranslator = 20;       // Translations per day
  static const int dailyCourtOrders = 10;      // Court order reads per day
  static const int dailyScanToPdf = 10;        // PDF scans per day
  static const int dailyDocuments = 5;         // Document generations per day
  
  // Monthly Limits (Free Users)
  static const int monthlyAiQueries = 100;     // AI Chat queries per month
  static const int monthlyCaseFinder = 50;     // Case searches per month
  static const int monthlyRiskAnalysis = 30;   // Risk analyses per month
  static const int monthlyTranslator = 200;    // Translations per month
  static const int monthlyCourtOrders = 100;   // Court order reads per month
  static const int monthlyScanToPdf = 100;     // PDF scans per month
  static const int monthlyDocuments = 50;      // Document generations per month
  
  // Premium Users (Unlimited)
  static const int premiumLimit = 999999;      // Effectively unlimited
}
```

### Example: Limits Change Karna

**Scenario**: Case Finder ki daily limit 5 se 10 karna hai

```dart
// BEFORE
static const int dailyCaseFinder = 5;

// AFTER
static const int dailyCaseFinder = 10;
```

## Usage in Code

### 1. Limit Check Karna (Recommended Method)

```dart
import 'package:myapp/utils/usage_limit_helper.dart';

// Feature use karne se pehle check karein
final canProceed = await UsageLimitHelper.checkAndShowLimit(
  context,
  'caseFinder',  // Feature name
  customTitle: 'Case Finder Limit Reached',  // Optional custom title
);

if (canProceed) {
  // User can proceed
  final usageProvider = Provider.of<UsageProvider>(context, listen: false);
  await usageProvider.incrementCaseFinder();
  
  // Optional: Show usage info
  UsageLimitHelper.showUsageSnackbar(
    context,
    'Case Finder',
    usageProvider.dailyCaseFinderUsage,
    usageProvider.dailyCaseFinderLimit,
  );
} else {
  // User hit limit, dialog already shown
  // Handle accordingly (e.g., reload page, go back)
}
```

### 2. Manual Limit Check

```dart
final usageProvider = Provider.of<UsageProvider>(context, listen: false);
final errorMessage = usageProvider.canUseFeature('aiQueries');

if (errorMessage != null) {
  // Show error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMessage)),
  );
} else {
  // Proceed with feature
  await usageProvider.incrementAiQueries();
}
```

### 3. Display Usage Stats

```dart
final usageProvider = Provider.of<UsageProvider>(context);

// Daily stats
Text('${usageProvider.dailyAiQueriesUsage} / ${usageProvider.dailyAiQueriesLimit}');

// Monthly stats
Text('${usageProvider.aiQueriesUsage} / ${usageProvider.aiQueriesLimit}');
```

## Available Features

| Feature Name | Description | Daily Limit | Monthly Limit |
|-------------|-------------|-------------|---------------|
| `aiQueries` | AI Chat queries | 10 | 100 |
| `caseFinder` | Case searches | 5 | 50 |
| `riskAnalysis` | Risk analyses | 3 | 30 |
| `translator` | Translations | 20 | 200 |
| `courtOrders` | Court order reads | 10 | 100 |
| `scanToPdf` | PDF scans | 10 | 100 |
| `documents` | Document generations | 5 | 50 |
| `cases` | Case management | - | 50 |
| `aiVoice` | AI Voice queries | - | 100 |
| `bareActs` | Bare Acts access | - | 1000 |
| `chatHistory` | Chat sessions | - | 100 |
| `certifiedCopy` | Certified copy requests | - | 10 |

**Note**: Features with "-" in daily limit only have monthly limits.

## Increment Methods

```dart
final usageProvider = Provider.of<UsageProvider>(context, listen: false);

// Increment usage (automatically checks limits)
await usageProvider.incrementAiQueries();
await usageProvider.incrementCaseFinder();
await usageProvider.incrementRiskAnalysis();
await usageProvider.incrementTranslator();
await usageProvider.incrementCourtOrders();
await usageProvider.incrementScanToPdf();
await usageProvider.incrementDocuments();
await usageProvider.incrementCases();
await usageProvider.incrementAiVoice();
await usageProvider.incrementBareActs();
await usageProvider.incrementChatHistory();
await usageProvider.incrementCertifiedCopy();
```

## Premium Users

Premium users ko unlimited access hai:

```dart
// Upgrade to premium
await usageProvider.upgradeToPremium();

// Check premium status
if (usageProvider.isPremium) {
  // Premium user
}
```

## Reset Logic

- **Daily Reset**: Har din midnight (00:00) ko automatically reset hota hai
- **Monthly Reset**: Har mahine ki 1st date ko automatically reset hota hai
- Reset local (Hive) aur server (Firestore) dono mein sync hota hai

## Firestore Structure

```
users/{userId}
  - isPremium: boolean
  - premiumUpgradedAt: timestamp

usage_stats/{userId}
  - monthlyReset: string (YYYY-MM)
  - resetAt: timestamp
  - features: {
      aiQueries: {
        monthly: number
        lastUpdated: timestamp
        month: string
      },
      caseFinder: { ... },
      ...
    }
```

## Testing

### Test Daily Limits
1. App ko use karein aur feature ko daily limit tak use karein
2. Limit hit hone par error dialog dikhega
3. Next day app open karne par usage reset ho jayega

### Test Monthly Limits
1. Monthly limit tak feature use karein
2. Limit hit hone par error dialog dikhega
3. Next month usage reset ho jayega

### Test Premium
1. Premium upgrade karein: `usageProvider.upgradeToPremium()`
2. Verify unlimited access

## Troubleshooting

### Usage reset nahi ho raha
- Check `lastDailyResetDate` aur `lastMonthlyResetDate` in Hive
- Clear app data aur re-login karein

### Firestore sync nahi ho raha
- Check internet connection
- Check Firebase console for errors
- Verify user is authenticated (not anonymous)

### Limits change nahi ho rahe
- `UsageLimits` class mein changes save karein
- Hot restart karein (not hot reload)
- Clear app data if needed

## Future Enhancements

- [ ] Admin panel for dynamic limit configuration
- [ ] Usage analytics dashboard
- [ ] Reward system (watch ad for extra usage)
- [ ] Weekly limits
- [ ] Feature-specific premium tiers
