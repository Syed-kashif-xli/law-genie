# 🔧 Firestore Debugging Guide

## 🎯 Problem: Kuch bhi show nahi ho raha

### Possible Issues:
1. ❌ Firestore mein data save nahi ho raha
2. ❌ Data save ho raha hai lekin load nahi ho raha
3. ❌ Data load ho raha hai lekin UI update nahi ho raha
4. ❌ User anonymous hai (no Firestore sync)

---

## 📊 Enhanced Logging

### New Debug Logs Added

#### 1. Sync to Firestore
```
🔄 Syncing to Firestore: chatHistory = 5 (month: 2025-12)
✅ Synced to Firestore: chatHistory = 5
✅ Verified: chatHistory = 5 (matches)
```

#### 2. Load from Firestore
```
✅ Usage loaded from Firestore for user: abc123
✅ Merged chatHistory: server=5, local=0, using=5
📊 Usage loaded - ChatHistory: 5/100
```

#### 3. Real-Time Updates
```
🔄 Real-time update: chatHistory 📈 Increased from 4 to 5
```

---

## 🧪 Debugging Steps

### Step 1: Check User ID
```dart
// Look for this log
⚠️ Cannot sync to Firestore: User is anonymous

// If you see this:
// - User is not logged in
// - No Firestore sync will happen
// - Only local storage works
```

**Fix**: Ensure user is logged in with Firebase Auth

---

### Step 2: Check Firestore Write
```dart
// Look for these logs
🔄 Syncing to Firestore: chatHistory = 5 (month: 2025-12)
✅ Synced to Firestore: chatHistory = 5
✅ Verified: chatHistory = 5 (matches)

// If you see error:
❌ Error syncing to Firestore: [error message]
❌ Feature: chatHistory, Count: 5, UserId: abc123
```

**Fix**: Check Firestore rules, network connection

---

### Step 3: Check Firestore Read
```dart
// Look for these logs
✅ Usage loaded from Firestore for user: abc123
✅ Merged chatHistory: server=5, local=0, using=5

// If you see:
⚠️ No Firestore data found for user: abc123
⚠️ No features data in Firestore
⚠️ No data for feature: chatHistory
```

**Fix**: Ensure data was written first

---

### Step 4: Check State Update
```dart
// Look for this log
📊 Usage loaded - ChatHistory: 5/100
📊 Usage loaded - CertifiedCopy: 3/20

// This shows final state after all loading
```

**Fix**: If count is wrong here, check Hive data

---

## 🔍 Manual Firestore Check

### Firebase Console
1. Open Firebase Console
2. Go to Firestore Database
3. Navigate to: `usage_stats` collection
4. Find your user document (userId)
5. Check structure:

```json
{
  "userId": "abc123...",
  "isPremium": false,
  "lastSyncedAt": "2025-12-11T21:00:00Z",
  "features": {
    "chatHistory": {
      "monthly": 5,
      "month": "2025-12",
      "lastUpdated": "2025-12-11T21:00:00Z"
    },
    "certifiedCopy": {
      "monthly": 3,
      "month": "2025-12",
      "lastUpdated": "2025-12-11T21:00:00Z"
    }
  }
}
```

---

## 🛠️ Common Issues & Fixes

### Issue 1: Anonymous User
**Symptom**: 
```
⚠️ Cannot sync to Firestore: User is anonymous
```

**Fix**:
```dart
// Check if user is logged in
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  // User needs to login
}
```

---

### Issue 2: Firestore Rules
**Symptom**:
```
❌ Error syncing to Firestore: PERMISSION_DENIED
```

**Fix**:
```javascript
// Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /usage_stats/{userId} {
      allow read, write: if request.auth != null 
                        && request.auth.uid == userId;
    }
  }
}
```

---

### Issue 3: Network Error
**Symptom**:
```
❌ Error syncing to Firestore: UNAVAILABLE
```

**Fix**:
- Check internet connection
- Check Firebase project status
- Retry after some time

---

### Issue 4: Data Mismatch
**Symptom**:
```
⚠️ Mismatch: Expected 5, got 3
```

**Fix**:
- Another device may have different data
- Real-time listener will sync eventually
- Force reload app

---

## 📱 Testing Checklist

### Test 1: Fresh User
```
1. Create new account
2. Use a feature (e.g., save chat)
3. Check logs:
   🔄 Syncing to Firestore: chatHistory = 1
   ✅ Synced to Firestore: chatHistory = 1
   ✅ Verified: chatHistory = 1
4. Check Firebase Console
5. Verify document exists
```

### Test 2: Existing User
```
1. Login with existing account
2. Check logs:
   ✅ Usage loaded from Firestore
   ✅ Merged chatHistory: server=5, local=0, using=5
   📊 Usage loaded - ChatHistory: 5/100
3. Verify UI shows correct count
```

### Test 3: Real-Time Sync
```
1. Open app on Device A
2. Use feature on Device A
3. Check Device B logs:
   🔄 Real-time update: chatHistory 📈 Increased from 4 to 5
4. Verify Device B UI updates
```

---

## 🎯 Quick Debug Commands

### Check Current User
```dart
final user = FirebaseAuth.instance.currentUser;
debugPrint('User ID: ${user?.uid}');
debugPrint('Is Anonymous: ${user == null}');
```

### Force Firestore Sync
```dart
// In UsageProvider
await _syncToFirestore('chatHistory', _monthlyChatHistoryUsage);
```

### Force Firestore Load
```dart
// In UsageProvider
await _loadFromFirestore();
_loadMonthlyUsage();
notifyListeners();
```

### Check Hive Data
```dart
final box = await Hive.openBox('usage_stats');
final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
final key = '${userId}_monthlyChatHistoryUsage';
final count = box.get(key, defaultValue: 0);
debugPrint('Hive count: $count');
```

---

## 🔥 Emergency Fix

### If Nothing Works:

#### 1. Clear All Data
```dart
// Clear Hive
final box = await Hive.openBox('usage_stats');
await box.clear();

// Clear Firestore (from Firebase Console)
// Delete user document in usage_stats collection
```

#### 2. Restart App
```
flutter clean
flutter pub get
flutter run
```

#### 3. Force Fresh Sync
```dart
// Use a feature to trigger sync
// Check all logs carefully
// Verify in Firebase Console
```

---

## 📊 Expected Log Flow

### Complete Flow (Success)
```
1. App Start:
   ✅ Usage loaded from Firestore for user: abc123
   ✅ Merged chatHistory: server=5, local=0, using=5
   📊 Usage loaded - ChatHistory: 5/100

2. User Action (Save Chat):
   🔄 Syncing to Firestore: chatHistory = 6 (month: 2025-12)
   ✅ Synced to Firestore: chatHistory = 6
   ✅ Verified: chatHistory = 6 (matches)

3. Real-Time Update (Other Device):
   🔄 Real-time update: chatHistory 📈 Increased from 5 to 6
```

---

## 🎉 Success Indicators

✅ **Firestore Write Success**:
```
✅ Synced to Firestore: chatHistory = 5
✅ Verified: chatHistory = 5 (matches)
```

✅ **Firestore Read Success**:
```
✅ Usage loaded from Firestore
✅ Merged chatHistory: server=5, local=0, using=5
```

✅ **UI Update Success**:
```
📊 Usage loaded - ChatHistory: 5/100
(UI shows 5/100)
```

✅ **Real-Time Success**:
```
🔄 Real-time update: chatHistory 📈 Increased from 4 to 5
(UI updates instantly)
```

---

## 📞 Support Info

**If still not working, provide these logs**:
1. User ID (from Firebase Auth)
2. All debug logs (from console)
3. Firebase Console screenshot
4. UI screenshot showing wrong count

**Ab detailed logs se pata chal jayega ki problem kahan hai! 🔍**
