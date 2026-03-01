import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize notifications (placeholder for future FCM)
  Future<void> initializeNotifications() async {
    // For now, just save FCM token placeholder
    // In production, you'd initialize Firebase Messaging here
    print('Streak notifications initialized (FCM not configured)');
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

  // Show in-app notification (placeholder for future push notifications)
  Future<void> showStreakWarning() async {
    // For now, just log it
    // In production, you'd use flutter_local_notifications here
    print('Streak warning: User is at risk of losing their streak!');
  }
}
