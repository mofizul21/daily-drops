import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class StreakNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Debug print helper
  void _debugLog(String message) {
    if (kDebugMode) {
      print('🔔 StreakNotification: $message');
    }
  }

  // Initialize notifications
  Future<void> initializeNotifications() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      _debugLog('Permission status: ${settings.authorizationStatus}');

      // Get FCM token
      final token = await _messaging.getToken();
      _debugLog('FCM Token: ${token ?? "null"}');
      
      if (token != null && _auth.currentUser != null) {
        await _saveFCMToken(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveFCMToken);

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _debugLog('Foreground message received: ${message.notification?.title}');
      });

      _debugLog('Streak notifications initialized with FCM');
    } catch (e) {
      _debugLog('FCM initialization error: $e');
      // Continue without FCM - app still works
    }
  }

  // Save FCM token to Firestore
  Future<void> _saveFCMToken(String token) async {
    if (_auth.currentUser == null) {
      _debugLog('No user logged in, skipping FCM token save');
      return;
    }

    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'platform': 'android', // or 'ios'
      }, SetOptions(merge: true));

      _debugLog('FCM token saved to Firestore for user: ${_auth.currentUser!.uid}');
    } catch (e) {
      _debugLog('Error saving FCM token: $e');
    }
  }

  // Check if user is at risk of losing streak (call this on app open)
  Future<Map<String, dynamic>> checkStreakStatus() async {
    if (_auth.currentUser == null) {
      return {'hasStreak': false, 'streak': 0, 'atRisk': false};
    }

    final userDoc = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();

    final userData = userDoc.data();
    final streak = userData?['streak'] ?? 0;
    final lastPostDate = userData?['lastPostDate'] as Timestamp?;

    if (lastPostDate == null) {
      return {'hasStreak': false, 'streak': 0, 'atRisk': false};
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPost = lastPostDate.toDate();
    final lastPostDay = DateTime(lastPost.year, lastPost.month, lastPost.day);

    final daysSinceLastPost = today.difference(lastPostDay).inDays;

    // At risk if last post was yesterday and it's after 6 PM today
    final atRisk = daysSinceLastPost == 1 && now.hour >= 18;

    return {
      'hasStreak': streak > 0,
      'streak': streak,
      'atRisk': atRisk,
      'daysSinceLastPost': daysSinceLastPost,
    };
  }
}
