import 'package:cloud_firestore/cloud_firestore.dart';

class Drop {
  final String userName;
  final String userIconUrl;
  final String dropText;
  int loveCount;
  int ashLoveCount;
  final String userId;
  final String? id;
  final Timestamp timestamp;
  final Map<String, String> reactions; // {userId: 'love' or 'ash'}

  Drop({
    required this.userName,
    required this.userIconUrl,
    required this.dropText,
    this.loveCount = 0,
    this.ashLoveCount = 0,
    required this.userId,
    this.id,
    required this.timestamp,
    Map<String, String>? reactions,
  }) : reactions = reactions ?? {};

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userIconUrl': userIconUrl,
      'dropText': dropText,
      'loveCount': loveCount,
      'ashLoveCount': ashLoveCount,
      'userId': userId,
      'timestamp': timestamp,
      'reactions': reactions,
    };
  }

  factory Drop.fromMap(Map<String, dynamic> data, String documentId) {
    Map<String, String> reactions = {};
    if (data['reactions'] != null) {
      reactions = Map<String, String>.from(data['reactions']);
    }
    return Drop(
      userName: data['userName'] ?? '',
      userIconUrl: data['userIconUrl'] ?? '',
      dropText: data['dropText'] ?? '',
      loveCount: data['loveCount'] ?? 0,
      ashLoveCount: data['ashLoveCount'] ?? 0,
      userId: data['userId'] ?? '',
      id: documentId,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      reactions: reactions,
    );
  }
}
