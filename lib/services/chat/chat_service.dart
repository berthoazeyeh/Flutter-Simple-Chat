// ignore_for_file: avoid_print

import 'dart:developer';
import 'package:chatappf/services/auth_service.dart';
import 'package:chatappf/services/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../model/message_page.dart';

class ChatService extends ChangeNotifier {
  // get instance of auth and firebase
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //SEND MESSASE
  Future<void> sendMessage(
      String receiverId, String message, String name) async {
    // get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
        senderId: currentUserId,
        receiverId: receiverId,
        senderEmail: currentUserEmail,
        senderName: name,
        message: message,
        timestamp: timestamp);

    // construct chat room id from current user id receiver id (sorted to insure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); //sort the ids (this ensures the chat room id is always the some for any pair of people )
    String chatRoomId = ids.join(
        "_"); //combine the ids into a single string to use as a chatroomID

    try {
      // add new message to database
      log("message");
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());
    } catch (e) {
      print(e);
    }
    //  try {
    //   await _firestore
    //       .collection('users')
    //       .doc(currentUserId)
    //       .update({"lastmessageTimestamp": timestamp});
    //   await _firestore
    //       .collection('users')
    //       .doc(receiverId)
    //       .update({"lastmessageTimestamp": timestamp});
    // } catch (e) {}
  }

  Future<void> sendGroupeMessage(
      String groupeId, String message, String name) async {
    // get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Map<String, dynamic> newMessage = {
      "senderId": currentUserId,
      "receiverId": groupeId,
      "senderEmail": currentUserEmail,
      "senderName": name,
      "message": message,
      "timestamp": timestamp
    };

    try {
      // add new message to database
      log("message");
      await _firestore
          .collection('groupes')
          .doc(groupeId)
          .collection('messages')
          .add(newMessage);
      await _firestore
          .collection('groupes')
          .doc(groupeId)
          .update({"lastMessage": message, "lastMessageTimes": timestamp});
    } catch (e) {
      log(e.toString());
    }
  }

  // GET MESSAGE
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // construct chat room id from user ids (sorted to ensure it matches the id used when sending message)
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // GET MESSAGE
  Stream<QuerySnapshot> getGroupeMessages(String userId) {
    // construct chat room id from user ids (sorted to ensure it matches the id used when sending message)

    return _firestore
        .collection('groupes')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  void getMessageso() {
    FirebaseFirestore.instance
        .collection('chat')
        .doc("6rADCG0biySq7Mp3eNiJVLhynrv1")
        .collection("messages")
        .snapshots()
        .forEach((a) => print(a.docs));

    //   print("okkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
    //   _firestore
    //       .collection('chat_rooms')
    //       .doc("1R0oamF8MiQxGPkUEcTyIWjLki12_ipOYVoWi6TMyjs23H0jcPdBkv6W2")
    //       .get()
    //       .then((value) => {print(value.data())});
  }

  Future<void> updateProfilUser(
      String userId, String url, Users user, AuthService authService) async {
    Users user1 = user;
    user1.profilUrl = url;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({"profilUrl": url});
      authService.updateUser(user1);
      log(user1.profilUrl!);
    } catch (e) {}
  }

  Future<void> updateStatutsUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({"status": true});
    } catch (e) {}
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {}
  }
}
