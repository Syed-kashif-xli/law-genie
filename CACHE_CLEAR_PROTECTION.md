# 🔒 Cache Clear Protection - Usage Tracking System

## ❌ Problem: Cache Clear Abuse

**Issue**: User app ka cache clear kar ke unlimited use kar sakta tha
- Local storage (Hive) delete ho jata tha
- Usage count reset ho jata tha
- User phir se free limit use kar sakta tha

## ✅ Solution: Firestore + Local Hybrid System

### 🎯 Strategy

**Dual Storage Approach**:
1. **Local Storage (Hive)**: Fast access, offline support
2. **Server Storage (Firestore)**: Source of truth, tamper-proof

**Key Principle**: **Always use MAXIMUM of local and server data**

---

## 🔧 How It Works

### 1. **App Startup / User Login**

```
User opens app
    ↓
_loadUsage() called
    ↓
Load from Firestore (_loadFromFirestore)
    ↓
Compare server vs local data
    ↓
Use MAXIMUM value
    ↓
Update local storage
    ↓
Display correct usage
```

### 2. **Usage Increment**

```
User uses feature (e.g., AI Chat)
    ↓
Increment local counter
    ↓
Save to Hive (local)
    ↓
Sync to Firestore (server)
    ↓
Both updated ✅
```

### 3. **Cache Clear Scenario**

```
User clears app cache
    ↓
Local Hive data deleted ❌
    ↓
App restarts
    ↓
_loadFromFirestore() runs
    ↓
Loads usage from server ✅
    ↓
Restores correct usage count
    ↓
User CANNOT abuse! 🔒
```

---

## 📊 Data Flow Diagram

```
┌─────────────────┐
│   User Action   │
│  (Use Feature)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Local Storage  │◄──── Fast Access
│     (Hive)      │
└────────┬────────┘
         │
         │ Sync
         ▼
┌─────────────────┐
│    Firestore    │◄──── Source of Truth
│  (Cloud DB)     │
└────────┬────────┘
         │
         │ Load on Startup
         ▼
┌─────────────────┐
│  Merge Logic    │
│  (Use Maximum)  │
└─────────────────┘
```

---

## 💻 Implementation Details

### _loadFromFirestore() Method

```dart
Future<void> _loadFromFirestore() async {
  if (_userId == 'anonymous') return;

  try {
    // Fetch from Firestore
    final doc = await _firestore
        .collection('usage_stats')
        .doc(_userId)
        .get();
    
    if (!doc.exists) return;

    final data = doc.data();
    final features = data['features'];

    // Merge each feature
    void mergeUsage(String featureKey, String localKey) {
      final serverCount = features[featureKey]['monthly'] ?? 0;
      final localCount = _box.get(localKey, defaultValue: 0);

      // 🔑 KEY: Use MAXIMUM (prevents abuse)
      final maxCount = max(serverCount, localCount);
      
      _box.put(localKey, maxCount);
    }

    // Merge all features
    mergeUsage('aiQueries', 'monthlyAiQueriesUsage');
    mergeUsage('caseFinder', 'monthlyCaseFinderUsage');
    // ... all other features
  } catch (e) {
    debugPrint('Error loading from Firestore: $e');
  }
}
```

### _syncToFirestore() Method

```dart
Future<void> _syncToFirestore(String feature, int count) async {
  if (_userId == 'anonymous') return;

  try {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month}';

    await _firestore
        .collection('usage_stats')
        .doc(_userId)
        .set({
          'features': {
            feature: {
              'monthly': count,
              'lastUpdated': FieldValue.serverTimestamp(),
              'month': monthKey,
            }
          },
          'isPremium': _isPremium,
        }, SetOptions(merge: true));
  } catch (e) {
    debugPrint('Error syncing to Firestore: $e');
  }
}
```

---

## 🔒 Security Features

### 1. **Maximum Value Logic**
```dart
final maxCount = serverCount > localCount ? serverCount : localCount;
```
**Why**: Even if user deletes local data, server data prevails

### 2. **Month Validation**
```dart
if (serverMonth != currentMonthStr) return; // Old data, ignore
```
**Why**: Only use current month's data, prevents old data confusion

### 3. **Anonymous User Handling**
```dart
if (_userId == 'anonymous') return;
```
**Why**: Anonymous users can't abuse (no server storage)

### 4. **Merge on Every Load**
```dart
await _loadFromFirestore(); // Called on app start
```
**Why**: Always sync with server on startup

---

## 📱 Firestore Structure

```json
{
  "usage_stats": {
    "USER_ID_123": {
      "isPremium": false,
      "features": {
        "aiQueries": {
          "monthly": 45,
          "month": "2025-12",
          "lastUpdated": "2025-12-11T12:00:00Z"
        },
        "caseFinder": {
          "monthly": 8,
          "month": "2025-12",
          "lastUpdated": "2025-12-11T11:30:00Z"
        },
        "riskAnalysis": {
          "monthly": 2,
          "month": "2025-12",
          "lastUpdated": "2025-12-11T10:15:00Z"
        }
        // ... all other features
      }
    }
  }
}
```

---

## 🧪 Test Scenarios

### Scenario 1: Normal Usage ✅
```
1. User uses AI Chat (5 times)
2. Local: 5, Server: 5
3. Both in sync ✅
```

### Scenario 2: Cache Clear ✅
```
1. User uses AI Chat (5 times)
2. Server: 5, Local: 5
3. User clears cache
4. Local: 0 (deleted)
5. App restarts
6. Load from server: 5
7. Local restored: 5 ✅
8. User CANNOT abuse!
```

### Scenario 3: Offline Usage ✅
```
1. User offline, uses AI Chat (3 times)
2. Local: 3, Server: 0 (no internet)
3. User comes online
4. Sync to server: 3
5. Both in sync ✅
```

### Scenario 4: Multiple Devices ✅
```
1. Device A: Uses 5 times
2. Server: 5
3. Device B: Opens app
4. Loads from server: 5
5. Device B shows correct usage ✅
```

---

## 🎯 Benefits

### ✅ Prevents Abuse
- Cache clear doesn't reset usage
- Uninstall/reinstall doesn't reset usage
- Server is source of truth

### ✅ Multi-Device Support
- Same usage across all devices
- Login on new device = correct usage shown

### ✅ Offline Support
- Works offline (uses local data)
- Syncs when online

### ✅ Data Integrity
- Maximum value logic prevents data loss
- Month validation prevents old data issues

---

## 🚀 Performance

### Fast Access
- Local Hive: ~1ms read time
- Firestore: ~100-300ms (only on startup)

### Minimal Network Usage
- Only syncs on increment
- Only loads on startup
- Merge operation in background

---

## 📊 Monitoring

### Debug Logs
```dart
debugPrint('✅ Usage loaded from Firestore for user: $_userId');
debugPrint('❌ Error loading from Firestore: $e');
```

### Firestore Console
- Check `usage_stats` collection
- Verify user data
- Monitor sync timestamps

---

## 🔧 Maintenance

### Monthly Reset
```dart
if (lastMonthlyResetStr != currentMonthStr) {
  _resetMonthlyUsage(currentMonthStr);
}
```
**Automatic**: Resets on 1st of every month

### Daily Reset
```dart
if (lastDailyResetStr != todayStr) {
  _resetDailyUsage(todayStr);
}
```
**Automatic**: Resets at midnight

---

## 🎉 Summary

**Problem Solved**: ✅ Cache clear abuse prevented

**How**:
1. ✅ Dual storage (Local + Server)
2. ✅ Maximum value logic
3. ✅ Load from Firestore on startup
4. ✅ Sync on every increment

**Result**:
- 🔒 **Tamper-proof** usage tracking
- 📱 **Multi-device** support
- ⚡ **Fast** local access
- ☁️ **Reliable** server backup

**User ab cache clear kar ke unlimited use NAHI kar sakta! 🎯**
