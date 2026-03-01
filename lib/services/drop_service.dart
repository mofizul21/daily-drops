import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/drop.dart';

class DropService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Generate Gravatar URL from email
  String _generateGravatarUrl(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    final emailHash = md5.convert(utf8.encode(normalizedEmail)).toString();
    return 'https://www.gravatar.com/avatar/$emailHash?s=200&d=identicon';
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Save a new drop to Firestore
  Future<String> saveDrop(String dropText) async {
    try {
      if (currentUser == null) {
        return 'No user logged in.';
      }

      // Generate Gravatar URL if no photoURL
      String userIconUrl = currentUser!.photoURL ?? '';
      if (userIconUrl.isEmpty && currentUser!.email != null) {
        userIconUrl = _generateGravatarUrl(currentUser!.email!);
      }

      final now = Timestamp.now();
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      // Check user's last post date from their profile
      final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      final userData = userDoc.data();
      
      if (userData != null && userData['lastPostDate'] != null) {
        final lastPostDate = (userData['lastPostDate'] as Timestamp).toDate();
        final lastPostDay = DateTime(lastPostDate.year, lastPostDate.month, lastPostDate.day);
        
        // If last post was today, prevent duplicate
        if (lastPostDay.year == todayStart.year && 
            lastPostDay.month == todayStart.month && 
            lastPostDay.day == todayStart.day) {
          return 'You already posted a drop today!';
        }
      }

      final drop = Drop(
        userName: currentUser!.displayName ?? 'Anonymous',
        userIconUrl: userIconUrl,
        dropText: dropText,
        userId: currentUser!.uid,
        timestamp: now,
      );

      await _firestore.collection('drops').add(drop.toMap());
      
      // Update user's streak
      await _updateUserStreak();
      
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // Update user's streak
  Future<void> _updateUserStreak() async {
    if (currentUser == null) return;

    final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
    final userData = userDoc.data();
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int currentStreak = 0;
    DateTime? lastPostDate;
    
    if (userData != null && userData['lastPostDate'] != null) {
      lastPostDate = (userData['lastPostDate'] as Timestamp).toDate();
      lastPostDate = DateTime(lastPostDate.year, lastPostDate.month, lastPostDate.day);
      
      final daysDiff = today.difference(lastPostDate).inDays;
      
      if (daysDiff == 0) {
        // Already posted today, keep streak
        currentStreak = userData['streak'] ?? 0;
      } else if (daysDiff == 1) {
        // Posted yesterday, increment streak
        currentStreak = (userData['streak'] ?? 0) + 1;
      } else if (daysDiff > 1) {
        // Missed a day, reset streak
        currentStreak = 1;
      }
    } else {
      // First post ever
      currentStreak = 1;
    }

    // Update user document
    await _firestore.collection('users').doc(currentUser!.uid).set({
      'streak': currentStreak,
      'lastPostDate': Timestamp.fromDate(today),
      'streakUpdatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  // Check and reset broken streaks (call this when user opens app)
  Future<void> checkAndResetStreaks() async {
    if (currentUser == null) return;

    final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
    final userData = userDoc.data();
    
    if (userData == null || userData['lastPostDate'] == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPostDate = (userData['lastPostDate'] as Timestamp).toDate();
    final lastPostDay = DateTime(lastPostDate.year, lastPostDate.month, lastPostDate.day);

    final daysDiff = today.difference(lastPostDay).inDays;

    // If last post was before yesterday, reset streak
    if (daysDiff > 1 && (userData['streak'] ?? 0) > 0) {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'streak': 0,
        'streakResetAt': Timestamp.now(),
      });
    }
  }

  // Get user's current streak
  Future<int> getUserStreak(String userId) async {
    // First check and reset if needed
    await checkAndResetStreaks();
    
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data()?['streak'] ?? 0;
  }

  // Get all drops ordered by timestamp (newest first)
  Stream<List<Drop>> getAllDrops() {
    return _firestore
        .collection('drops')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Drop.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get drops by specific user
  Stream<List<Drop>> getUserDrops(String userId) {
    return _firestore
        .collection('drops')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Drop.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get user's reaction for a drop
  Future<String?> getUserReaction(String dropId) async {
    if (currentUser == null) return null;
    
    try {
      final doc = await _firestore
          .collection('drops')
          .doc(dropId)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        final reactions = data?['reactions'] as Map<String, dynamic>?;
        if (reactions != null) {
          return reactions[currentUser!.uid] as String?;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Toggle love reaction (Facebook-style)
  Future<void> toggleLoveReaction(String dropId, Drop drop) async {
    if (currentUser == null) return;
    
    final currentUserId = currentUser!.uid;
    final userReaction = drop.reactions[currentUserId] ?? 'none';

    Map<String, dynamic> updates = {};
    
    if (userReaction == 'love') {
      // Remove love reaction
      updates['reactions.$currentUserId'] = FieldValue.delete();
    } else if (userReaction == 'ash') {
      // Switch from ash to love
      updates['reactions.$currentUserId'] = 'love';
    } else {
      // Add new love reaction
      updates['reactions.$currentUserId'] = 'love';
    }

    await _firestore.collection('drops').doc(dropId).update(updates);
  }

  // Toggle ash love reaction (Facebook-style)
  Future<void> toggleAshLoveReaction(String dropId, Drop drop) async {
    if (currentUser == null) return;
    
    final currentUserId = currentUser!.uid;
    final userReaction = drop.reactions[currentUserId] ?? 'none';

    Map<String, dynamic> updates = {};
    
    if (userReaction == 'ash') {
      // Remove ash love reaction
      updates['reactions.$currentUserId'] = FieldValue.delete();
    } else if (userReaction == 'love') {
      // Switch from love to ash
      updates['reactions.$currentUserId'] = 'ash';
    } else {
      // Add new ash love reaction
      updates['reactions.$currentUserId'] = 'ash';
    }

    await _firestore.collection('drops').doc(dropId).update(updates);
  }

  // Delete a drop
  Future<String> deleteDrop(String dropId) async {
    try {
      await _firestore.collection('drops').doc(dropId).delete();
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // Update a drop
  Future<String> updateDrop(String dropId, String dropText) async {
    try {
      if (currentUser == null) {
        return 'No user logged in.';
      }

      await _firestore.collection('drops').doc(dropId).update({
        'dropText': dropText,
      });
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }
}