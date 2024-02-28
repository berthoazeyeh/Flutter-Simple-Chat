import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  String senderName;
  final Timestamp timestamp;

  Message(
      {required this.senderId,
      required this.receiverId,
      required this.senderEmail,
      required this.message,
      required this.timestamp,
      required this.senderName});

  // convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'senderName': senderName,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
