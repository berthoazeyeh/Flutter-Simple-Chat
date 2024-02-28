import 'package:chatappf/api/firebase_api.dart';
import 'package:chatappf/components/chat_bubble.dart';
import 'package:chatappf/services/auth_service.dart';
import 'package:chatappf/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ViewGroupe extends StatefulWidget {
  ViewGroupe({super.key, required this.groupe});
  dynamic groupe;

  @override
  State<ViewGroupe> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ViewGroupe> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<String> selectedSMS = [];

  void sendMessage() async {
    // only send message if there is something to send

    final authService = Provider.of<AuthService>(context, listen: false);

    if (_messageController.text.isNotEmpty) {
      await FirebaseApi().sendNotification(
          "fu-R0xIATASiQKvZGo_cqg:APA91bHhjlDl2ciAxIMezVsWJpyUmUpbJU68v6ndgKZLAGZA77ru2PJxgRadSARLMbnKg0EQ1VSzkCOfC5vt_rYMHM-nbFRNtnMTZJ7ELJ7MxSGJnc2fclHtv1b35vgsEFflFJ6zMlkS",
          "${authService.user!.nom}  -  ${authService.user!.email}",
          _messageController.text);
      await _chatService.sendGroupeMessage(
          widget.groupe['uid'], _messageController.text, authService.user!.nom);
      // clear the text controller after sending the message
      _messageController.clear();
      // _scrollToBottom();
    }
  }

  Widget _buildMessageItem(DocumentSnapshot document, AuthService authService) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    Timestamp temp = data['timestamp'];
    String min = temp.toDate().minute >= 10
        ? temp.toDate().minute.toString()
        : "0${temp.toDate().minute}";
    String hour = temp.toDate().hour >= 10
        ? temp.toDate().hour.toString()
        : "0${temp.toDate().hour}";
    String times = "$hour:$min";
    // align the message to the right if the sender is the current user, otherwise to the left
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return InkWell(
      onTap: () {
        if (selectedSMS.isNotEmpty && !selectedSMS.contains(document.id)) {
          setState(() {
            selectedSMS.add((document.id));
          });
        } else if (selectedSMS.contains(document.id)) {
          setState(() {
            selectedSMS.removeAt(selectedSMS.indexOf(document.id));
          });
        }
      },
      onLongPress: () {
        if (!selectedSMS.contains(document.id)) {
          setState(() {
            selectedSMS.add(document.id);
          });
        } else {
          setState(() {
            selectedSMS.removeAt(selectedSMS.indexOf(document.id));
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
            color:
                !selectedSMS.contains(document.id) ? null : Colors.grey[300]),
        padding: const EdgeInsets.only(bottom: 15),
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment:
                (data['senderId'] == _firebaseAuth.currentUser!.uid)
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            mainAxisAlignment:
                (data['senderId'] == _firebaseAuth.currentUser!.uid)
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              Text(data['senderName']),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment:
                    (data['senderId'] == _firebaseAuth.currentUser!.uid)
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.end,
                mainAxisAlignment:
                    (data['senderId'] == _firebaseAuth.currentUser!.uid)
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                children: [
                  data['senderId'] != _firebaseAuth.currentUser!.uid
                      ? const CircleAvatar(
                          radius: 10,
                          backgroundImage: NetworkImage(
                              "https://api-private.atlassian.com/users/7831f16b18333c732e152c74f1863d18/avatar") /*AssetImage(favorite['profil'])*/)
                      : Text(times),
                  const SizedBox(
                    width: 8,
                  ),
                  ChatBubble(
                    message: data['message'],
                    isSender:
                        data['senderId'] == _firebaseAuth.currentUser!.uid,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  data['senderId'] == _firebaseAuth.currentUser!.uid
                      ? CircleAvatar(
                          radius: 10,
                          backgroundImage: NetworkImage(authService
                                      .user!.profilUrl !=
                                  null
                              ? authService.user!.profilUrl!
                              : "https://api-private.atlassian.com/users/7831f16b18333c732e152c74f1863d18/avatar") /*AssetImage(favorite['profil'])*/)
                      : Text(times)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (kDebugMode) {
      print(widget.groupe);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupe['groupName']),
      ),
      body: Column(
        children: [
          // message
          Expanded(
            child: _buildMessageList(authService),
          ),
          // user input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList(AuthService authService) {
    return StreamBuilder(
      stream: _chatService.getGroupeMessages(widget.groupe['uid']),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Text('Loading..');
        // }
        return ListView(
          controller: _scrollController,
          children: snapshot.data != null
              ? snapshot.data!.docs
                  .map((document) => _buildMessageItem(document, authService))
                  .toList()
              : [],
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (e) {
                sendMessage();
              },
              onTap: () {
                // setState(() {
                //   selectedSMS = [];
                // });
              },
              decoration: InputDecoration(
                hintText: 'Tapez votre message...',
                contentPadding: const EdgeInsets.all(18.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.grey[300], shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      sendMessage();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
