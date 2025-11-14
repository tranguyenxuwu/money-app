# Firebase Sync Flow Diagram

## App Startup Flow
```
┌─────────────┐
│   App Start │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ Firebase Auth   │
│ Check User      │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌───────┐  ┌────────────┐
│ No    │  │ Yes        │
│ User  │  │ Logged In  │
└───┬───┘  └──────┬─────┘
    │             │
    ▼             ▼
┌─────────┐  ┌──────────────────────┐
│ Login   │  │ Download Firebase    │
│ Screen  │  │ Data to Local DB     │
└─────────┘  └──────────┬───────────┘
                        │
                        ▼
              ┌───────────────────┐
              │ Show Home Screen  │
              └───────────────────┘
```

## Transaction Operations Flow

### Add Transaction
```
┌─────────────────────┐
│ User Adds           │
│ Transaction in UI   │
└──────────┬──────────┘
           │
           ▼
┌────────────────────────┐
│ DBHelper.insert        │
│ Transaction()          │
│                        │
│ 1. Save to SQLite     │
│ 2. Get transaction    │
│    by ID              │
└──────────┬─────────────┘
           │
           ▼
┌────────────────────────┐
│ SyncService.sync       │
│ SingleTransaction      │
│ ToFirebase()           │
│                        │
│ - Convert to          │
│   Firestore format    │
│ - Upload to Cloud     │
└────────────────────────┘
```

### Update Transaction
```
┌─────────────────────┐
│ User Updates        │
│ Transaction in UI   │
└──────────┬──────────┘
           │
           ▼
┌────────────────────────┐
│ DBHelper.update        │
│ Transaction()          │
│                        │
│ 1. Update SQLite      │
│ 2. Get transaction    │
│    by ID              │
└──────────┬─────────────┘
           │
           ▼
┌────────────────────────┐
│ SyncService.sync       │
│ SingleTransaction      │
│ ToFirebase()           │
│                        │
│ - Upload changes      │
│   to Cloud            │
└────────────────────────┘
```

### Delete Transaction
```
┌─────────────────────┐
│ User Deletes        │
│ Transaction         │
└──────────┬──────────┘
           │
           ▼
┌────────────────────────┐
│ DBHelper.delete        │
│ Transaction()          │
│                        │
│ 1. Delete from SQLite │
└──────────┬─────────────┘
           │
           ▼
┌────────────────────────┐
│ SyncService.delete     │
│ TransactionFrom        │
│ Firebase()             │
│                        │
│ - Remove from Cloud   │
└────────────────────────┘
```

## Data Sync Architecture

```
┌──────────────────────────────────────────────────┐
│                  FIREBASE CLOUD                  │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │ Firestore Database                         │ │
│  │                                            │ │
│  │  users/                                    │ │
│  │    {userId}/                               │ │
│  │      ├── transactions/                     │ │
│  │      │   └── {txnId}/                      │ │
│  │      │       ├── id                        │ │
│  │      │       ├── amount                    │ │
│  │      │       ├── note                      │ │
│  │      │       ├── category                  │ │
│  │      │       ├── direction                 │ │
│  │      │       └── created_at (Timestamp)    │ │
│  │      │                                     │ │
│  │      ├── messages/                         │ │
│  │      └── budgets/                          │ │
│  └────────────────────────────────────────────┘ │
└────────────────┬─────────────────────────────────┘
                 │
                 │  ↕ SYNC
                 │
┌────────────────┴─────────────────────────────────┐
│              MOBILE DEVICE                       │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │ Local SQLite Database                      │ │
│  │                                            │ │
│  │  transactions table                        │ │
│  │    ├── id (INTEGER)                        │ │
│  │    ├── amount (INTEGER)                    │ │
│  │    ├── note (TEXT)                         │ │
│  │    ├── category (TEXT)                     │ │
│  │    ├── direction (TEXT)                    │ │
│  │    └── created_at (TEXT ISO8601)           │ │
│  │                                            │ │
│  │  messages table                            │ │
│  │  budgets table                             │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │ App UI                                     │ │
│  │  ├── Home Screen                           │ │
│  │  ├── Transaction List                      │ │
│  │  ├── Add/Edit Transaction                  │ │
│  │  └── Transaction Detail                    │ │
│  └────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────┘
```

## Multi-Device Sync Example

```
Device A                    Firebase Cloud              Device B
────────                    ──────────────              ────────

1. Add Transaction
   └─> Upload ──────────> Store in Firestore
                                  │
                                  │
                                  │
2. Open App <────────────── Download Data <─────── Open App
   └─> Show Data            All Devices Get         └─> Show Data
                           Same Data
```

## Error Handling Flow

```
┌─────────────────┐
│ Sync Operation  │
└────────┬────────┘
         │
    ┌────┴────┐
    │  Try    │
    └────┬────┘
         │
    ┌────┴────────────┐
    │                 │
    ▼                 ▼
┌─────────┐      ┌──────────┐
│ Success │      │  Error   │
└────┬────┘      └─────┬────┘
     │                 │
     ▼                 ▼
┌─────────┐      ┌──────────────┐
│ Return  │      │ Log Error    │
│ true    │      │ Return false │
└─────────┘      └──────┬───────┘
                        │
                        ▼
              ┌───────────────────┐
              │ App Continues     │
              │ With Local Data   │
              └───────────────────┘
```

## Key Features

✅ **Automatic Sync**: No manual intervention needed
✅ **Real-time**: Changes synced immediately
✅ **Multi-device**: Same data across all devices
✅ **Offline Ready**: App works with local data when offline
✅ **Error Tolerant**: App continues working even if sync fails
✅ **Efficient**: Uses batch operations for bulk sync
✅ **Secure**: Data scoped to authenticated user

## Data Format Conversions

### Local → Firebase
```
SQLite (TEXT)              Firestore (Timestamp)
created_at: "2024-01-15"  →  created_at: Timestamp
```

### Firebase → Local
```
Firestore (Timestamp)      SQLite (TEXT)
created_at: Timestamp     →  created_at: "2024-01-15"
```

