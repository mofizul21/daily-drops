# Streak Notification Setup

## What Was Fixed

### 1. Android Permissions (`android/app/src/main/AndroidManifest.xml`)
Added required notification permissions:
- `POST_NOTIFICATIONS`
- `RECEIVE_BOOT_COMPLETED`
- `VIBRATE`
- `INTERNET`

### 2. Streak Notification Service (`lib/services/streak_notification_service.dart`)
- Added detailed debug logging to track FCM token generation and saving
- Added foreground message listener
- Improved FCM token saving with user validation

### 3. Firebase Cloud Functions (`functions/src/index.ts`)
- Added `android.notification.channelId` to all notifications
- Added `apns` payload for iOS notifications
- Added `testStreakNotification` function for testing
- Improved logging for debugging

## Deployed Functions

| Function | Schedule | Description |
|----------|----------|-------------|
| `checkStreaksAndSendReminders` | 9:00 PM UTC daily | Sends streak reminder to users at risk |
| `finalStreakWarning` | 11:59 PM UTC daily | Final warning before streak resets |
| `testStreakNotification` | On-demand | Test function for debugging |

## How to Test Notifications

### Step 1: Rebuild and Reinstall the App
```bash
flutter clean
flutter pub get
flutter run
```

### Step 2: Check FCM Token in Firestore
1. Open the app and login
2. Check the console logs for: `🔔 StreakNotification: FCM Token: ...`
3. Go to Firebase Console → Firestore
4. Find your user document in `users` collection
5. Verify `fcmToken` field exists

### Step 3: Test with Test Function

Get your FCM token from the logs or Firestore, then run:

```bash
curl "https://us-central1-wired-analogy-444415-i9.cloudfunctions.net/testStreakNotification?token=YOUR_FCM_TOKEN_HERE"
```

Replace `YOUR_FCM_TOKEN_HERE` with your actual FCM token.

### Step 4: Check Notification
- If the app is in foreground: You'll see a log message
- If the app is in background: You should receive a push notification

## Scheduled Notifications

The streak reminders will automatically run:
- **9:00 PM UTC** - Reminder for users who haven't posted since yesterday
- **11:59 PM UTC** - Final warning before streak resets

## Troubleshooting

### No FCM Token in Logs
- Ensure you granted notification permission when prompted
- Check `FirebaseMessaging.instance.getToken()` returns a value

### Token Not Saved to Firestore
- Ensure user is logged in when the token is generated
- Check Firestore security rules allow writes to user documents

### Test Function Returns Error
- Verify the FCM token is valid
- Check Firebase Console → Functions → Logs for errors

### Notification Not Showing
- Check Android notification settings for the app
- Ensure "Streak Notifications" channel is enabled (Settings → Apps → Daily Drop → Notifications)
- Check `adb logcat` for FCM-related errors

## Manual FCM Token Check

To manually verify your FCM token is saved:

```bash
# In Firebase Console
1. Go to Firestore Database
2. Find your user document: users/{YOUR_USER_ID}
3. Check for fields: fcmToken, fcmTokenUpdatedAt, platform
```

## Important Notes

- Notifications only work for users with active streaks (streak > 0)
- The app must be installed and logged in at least once to save the FCM token
- Android 13+ requires runtime permission request for notifications (already implemented)
