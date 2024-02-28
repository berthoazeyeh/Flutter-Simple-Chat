// ignore_for_file: must_be_immutable

import 'package:chatappf/pages/view_groupe.dart';
import 'package:chatappf/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('groupes')
              .orderBy("lastMessageTimes", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('error');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('loading..');
            }
            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                var result = snapshot.data?.docs[index].data() as dynamic;
                List<dynamic> mem = result['membres'];
                if ((mem.contains(authService.user != null
                        ? authService.user!.uid
                        : "null")) ||
                    (authService.user != null && authService.user!.isAdmin)) {
                  return GroupListItem(group: result);
                }
                return null;
              },
            );
          }),
    );
  }

//   Future<Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>>
//       getMessageAndMember(
//           AsyncSnapshot<QuerySnapshot<Object?>> snapshot) async {
//     var message = await FirebaseFirestore.instance
//         .collection('groupes')
//         .doc(snapshot.data!.docs[0].id)
//         .collection("messages")
//         .get();
//     var membre = await FirebaseFirestore.instance
//         .collection('groupes')
//         .doc(snapshot.data!.docs[0].id)
//         .collection("membre")
//         .get();
//     Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> result = {
//       "message": message.docs,
//       "membre": membre.docs
//     };
//     if (kDebugMode) {
//       print("${membre.docs.length} ${message.docs.length}");
//     }
//     return result;
//   }
}

class GroupListItem extends StatelessWidget {
  final dynamic group;

  const GroupListItem({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    String times = "";
    String date = "";

    if (group['lastMessageTimes'] != null) {
      Timestamp temp = group['lastMessageTimes'];
      String jours = temp.toDate().day >= 10
          ? temp.toDate().day.toString()
          : "0${temp.toDate().day}";
      String mois = temp.toDate().month >= 10
          ? temp.toDate().month.toString()
          : "0${temp.toDate().month}";
      String annees = temp.toDate().year.toString();
      String min = temp.toDate().minute >= 10
          ? temp.toDate().minute.toString()
          : "0${temp.toDate().minute}";
      String hour = temp.toDate().hour >= 10
          ? temp.toDate().hour.toString()
          : "0${temp.toDate().hour}";
      times = "$hour:$min";
      date = "$jours-$mois-$annees";
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ViewGroupe(
                    groupe: group,
                  )));
        },
        leading: const CircleAvatar(
          // Vous pouvez personnaliser l'image du groupe ici
          backgroundColor: Colors.blue,
          child: Icon(Icons.group),
        ),
        title: Text(group['groupName']),
        subtitle: Text('${group['memberCount']} membres'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              group['lastMessage'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              times,
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              date,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
