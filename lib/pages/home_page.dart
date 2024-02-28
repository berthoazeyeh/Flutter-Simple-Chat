// ignore_for_file: must_be_immutable
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:chatappf/pages/groupe_sreen.dart';
import 'package:chatappf/pages/profils_screen.dart';
import 'package:chatappf/pages/user_list.dart';
import 'package:chatappf/services/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chatappf/pages/chat_page.dart';
import 'package:chatappf/services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

//les couleurs que nous allons utiliser dans notre code
const degreen = Color(0xFF00BFA5);
const dewhite = Colors.white;
const deblack = Colors.black;
const deblue = Color(0xFF01579B);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  int currentPage = 0;
  bool reffrech = false;
  List<String> selectedUserG = [];
  //sign user out
  void signOut() {
    // get auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    authService.signOut();
  }

  void requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      if (kDebugMode) {
        print('Permission accordée');
      }
    } else {
      if (kDebugMode) {
        print('Permission refusée');
      }
    }
  }

  @override
  void initState() {
    final authService = Provider.of<AuthService>(context, listen: false);
    AuthService().fetchUserData();
    super.initState();
    authService.fetchUserData();
    if (authService.user != null && authService.user!.status == false) {
      AuthService().fetchUserData();
      currentPage = 3;
      try {
        pageController.jumpToPage(3);
      } catch (e) {
        print(e);
      }
    }
  }

  PageController pageController = PageController(initialPage: 0);
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final List<String> pages = ['Message', 'Onligne', 'Groupe', 'Awaiting'];
  void changeIndexPage(int index) {
    setState(() {
      currentPage = index;
    });
  }

  void _scrollToItem(int index) {
    // Calculez la position de l'élément cible dans le Row.
    TextStyle textStyle = const TextStyle(
      color: Colors.white70,
      fontSize: 23,
    );

    // Création d'un TextPainter
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: pages[index], style: textStyle),
      maxLines:
          1, // Assurez-vous de définir maxLines sur 1 pour mesurer correctement la largeur
      textDirection: ui.TextDirection.ltr,
    );

    // Configurer la taille du textePainter en fonction de la largeur maximale souhaitée
    textPainter.layout(maxWidth: double.infinity);

    // Récupérer la largeur mesurée
    double textWidth = textPainter.width;
    double targetPosition =
        index * textWidth; // Ajustez la taille de l'élément en conséquence

    // Faites défiler vers la position de l'élément cible.
    _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    Future.delayed(const Duration(seconds: 3), () {
      if (authService.user != null &&
          authService.user!.status == false &&
          (currentPage != pages.length - 1)) {
        setState(() {
          currentPage = pages.length - 1;
        });
        // pageController.animateToPage(pages.length - 1,
        //     duration: const Duration(milliseconds: 100), curve: Curves.linear);
        currentPage = pages.length - 1;
        try {
          pageController.jumpToPage(pages.length - 1);
        } catch (e) {
          print(e);
        }
      }
    });
    if (authService.user == null) {
      authService.fetchUserData();
    }
    if (authService.user != null &&
        authService.user!.status == false &&
        (currentPage != pages.length - 1)) {
      setState(() {
        currentPage = pages.length - 1;
      });
      // pageController.animateToPage(pages.length - 1,
      //     duration: const Duration(milliseconds: 100), curve: Curves.linear);
      currentPage = pages.length - 1;
      try {
        pageController.jumpToPage(pages.length - 1);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    final List<Widget> coll = [
      SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [const FavoriteSection(), _buildUserList()],
        ),
      ),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('loading..');
          }
          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return _buildUserListItems(doc);
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                thickness: 3,
              );
            },
            // children: snapshot.data!.docs
            //     .map<Widget>((doc) => _buildUserListItem(doc))
            //     .toList(),
          );
        },
      ),
      const GroupScreen(),
      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: const Text(
                "Votre compte est en cours de vérification. Veuillez patienter pendant que les administrateurs vérifient vos informations.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            if (!reffrech)
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    reffrech = true;
                  });
                  await authService.fetchUserData();
                  setState(() {
                    reffrech = false;
                  });
                  if (authService.user!.status == true) {
                    pageController.jumpToPage(0);
                  }
                  // Action à effectuer lors du clic sur le bouton
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Couleur du texte blanc
                ),
                child: const Text('Rafraîchir'),
              ),
            const SizedBox(
              height: 10,
            ),
            if (reffrech) const CircularProgressIndicator(),
          ]),
    ];

    if (kDebugMode) {
      print(authService.user);
    }
    return Scaffold(
      drawer: MyDrawer(authService: authService, sign: signOut),

      appBar: AppBar(
        backgroundColor: deblack,
        actions: [
          // sign out button
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
            color: dewhite,
          ),
        ],
      ),
      body: Column(
        children: [
          //Pour creer les differents section
          // if (authService.user != null && authService.user!.isAdmin)
          MenuSection(
            pageController: pageController,
            changeIndexPage: changeIndexPage,
            curentpageindex: currentPage,
            scrollController: _scrollController,
          ),
          Expanded(
            child: PageView.builder(
              onPageChanged: (value) {
                _scrollToItem(value);
                setState(() {
                  currentPage = value;
                });
              },
              controller: pageController,
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return pageItemWidget(index, authService, coll[index]);
              },
            ),
          ),
        ],
      ),
      // button float
      floatingActionButton: FloatingActionButton(
        backgroundColor: deblue, //coleur du creon(floattannt)
        onPressed: () {
          _showEditDialog(authService);
        },
        child: const Icon(
          Icons.edit,
          size: 32,
        ),
      ),
    );
  }

  Container pageItemWidget(int index, AuthService authService, Widget c) {
    return Container(
        color: index == 0 || index == 3 || index == 1
            ? null
            : index % 2 == 0
                ? Colors.blue
                : Colors.green,
        child: c);
  }

  Future<void> _showEditDialog(AuthService authService) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nouveau groupe'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Nom du groupe'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('error');
                        }
                        // if (snapshot.connectionState ==
                        //     ConnectionState.waiting) {
                        //   return const Text('loading..');
                        // }
                        return ListView.separated(
                          shrinkWrap: false,
                          itemCount: snapshot.data != null
                              ? snapshot.data!.docs.length
                              : 0,
                          itemBuilder: (context, index) {
                            var doc = snapshot.data!.docs[index];
                            return _buildUserListItemsGroupe(doc, setState);
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider(
                              thickness: 3,
                            );
                          },
                          // children: snapshot.data!.docs
                          //     .map<Widget>((doc) => _buildUserListItem(doc))
                          //     .toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.length >= 2 &&
                      selectedUserG.isNotEmpty) {
                    selectedUserG.add(authService.user!.uid);
                    final FirebaseFirestore firestore =
                        FirebaseFirestore.instance;
                    var data0 = firestore.collection("groupes").doc();
                    await firestore.collection("groupes").doc(data0.id).set({
                      "groupName": _nameController.text,
                      "lastMessageTimes": Timestamp.now(),
                      "lastMessage": "",
                      "memberCount": selectedUserG.length,
                      'uid': data0.id,
                      'membres': selectedUserG,
                    });
                    for (int i = 0; i < selectedUserG.length; i++) {
                      await firestore
                          .collection("groupes")
                          .doc(data0.id)
                          .collection("menbre")
                          .add({"uid": selectedUserG[i]});
                    }
                    Navigator.of(context).pop();
                    setState(
                      () {
                        selectedUserG = [];
                        _nameController.clear();
                        currentPage = 2;
                        pageController.jumpToPage(2);
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Le groupe doit avoir un Nom et au moins un participant"),
                      ),
                    );
                  }
                  // Fire
                },
                child: const Text('Enregistrer'),
              ),
            ],
          );
        });
      },
    );
  }

  // build a list of users execpt for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading..');
        }
        return Column(
          children: snapshot.data!.docs.map((e) {
            var doc = e;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey, width: 2))),
              child: _buildUserListItem(doc),
            );
          }).toList(),
        );
        // return ListView.separated(
        //   shrinkWrap: true,
        //   itemCount: snapshot.data!.docs.length,
        //   itemBuilder: (context, index) {
        //     var doc = snapshot.data!.docs[index];
        //     return _buildUserListItem(doc);
        //   },
        //   separatorBuilder: (BuildContext context, int index) {
        //     return const Divider(
        //       thickness: 3,
        //     );
        //   },
        //   // children: snapshot.data!.docs
        //   //     .map<Widget>((doc) => _buildUserListItem(doc))
        //   //     .toList(),
        // );
      },
    );
  }

  Container horizontalItem() {
    return Container(
      padding: const EdgeInsets.all(4),
      height: 60,
      width: 60,
      decoration: const BoxDecoration(
        color: dewhite,
        shape: BoxShape.circle,
      ),
      child: const CircleAvatar(
          radius: 15,
          backgroundImage: NetworkImage(
              "https://api-private.atlassian.com/users/7831f16b18333c732e152c74f1863d18/avatar") /*AssetImage(favorite['profil'])*/),
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    Users u = Users.fromMap(data);
    if (kDebugMode) {
      print(_auth.currentUser!);
    }
    //display all user except current user
    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        trailing: ClipOval(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: const BoxDecoration(color: Colors.blue),
                child: const Text("20"))),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(data['profilUrl']),
        ),
        title: Text(data['nom']),
        onTap: () {
          // afficher l'uid de tous les utilisateurs cliques sur la page de discution
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(users: u),
            ),
          );
        },
      );
    } else {
      //return empty container
      return Container();
    }
  }

  Widget _buildUserListItems(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    Users u = Users.fromMap(data);
    if (kDebugMode) {
      print(_auth.currentUser!);
    }
    //display all user except current user
    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        trailing: ClipOval(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ))),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(data['profilUrl']),
        ),
        title: Text(data['nom']),
        onTap: () {
          // afficher l'uid de tous les utilisateurs cliques sur la page de discution
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(users: u),
            ),
          );
        },
      );
    } else {
      //return empty container
      return Container();
    }
  }

  Widget _buildUserListItemsGroupe(
      DocumentSnapshot document, StateSetter setState) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    Users u = Users.fromMap(data);
    if (kDebugMode) {
      print(_auth.currentUser!);
    }
    //display all user except current user
    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        trailing:
            selectedUserG.contains(u.uid) ? const Icon(Icons.check) : null,
        leading: const CircleAvatar(
          backgroundImage: NetworkImage(
              "https://api-private.atlassian.com/users/7831f16b18333c732e152c74f1863d18/avatar"),
        ),
        title: Text(data['nom']),
        onTap: () {
          // afficher l'uid de tous les utilisateurs cliques sur la page de discution
          if (selectedUserG.contains(u.uid)) {
            setState(
              () {
                selectedUserG.removeAt(selectedUserG.indexOf(u.uid));
              },
            );
          } else {
            setState(
              () {
                selectedUserG.add(u.uid);
              },
            );
          }
        },
      );
    } else {
      //return empty container
      return Container();
    }
  }
}

class MyDrawer extends StatelessWidget {
  MyDrawer({
    super.key,
    required this.authService,
    required this.sign,
  });
  void Function() sign;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(5.0),
              bottomRight: Radius.circular(5.0)),
          side: BorderSide(width: 0.0, color: Colors.white)),
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: BoxDecoration(
                  border: Border.all(width: 0.0, color: Colors.white),
                  color: Colors.blue,
                  borderRadius: const BorderRadius.all(Radius.circular(15.0))),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 30.0,
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(authService.user!.profilUrl !=
                            null
                        ? authService.user!.profilUrl!
                        : "https://api-private.atlassian.com/users/7831f16b18333c732e152c74f1863d18/avatar"),
                    // AssetImage('assets/images/background.png'),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    authService.user!.nom,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 7.0,
                  ),
                  Text(
                    authService.user!.email,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Colors.white),
                  )
                ],
              )),
          const Divider(),
          if (authService.user!.isAdmin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_rounded),
              title: const Text('Administrateur'),
              onTap: () {
                // Gérer le tap de l'élément de la liste
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const UserListAdmin())); // Fermer le Drawer
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              // Gérer le tap de l'élément de la liste
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserProfileScreen(
                            users: authService.user!,
                            canUpdate: true,
                          )));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () {
              sign();
              // Gérer le tap de l'élément de la liste
              // Navigator.pop(context); // Fermer le Drawer
            },
          ),
          const Divider(),
          // Ajoutez autant d'éléments de liste que nécessaire
        ],
      ),
    );
  }
}

class MenuSection extends StatelessWidget {
  PageController pageController;
  ScrollController scrollController;

  int curentpageindex;
  void Function(int index) changeIndexPage;
  MenuSection(
      {super.key,
      required this.pageController,
      required this.changeIndexPage,
      required this.curentpageindex,
      required this.scrollController});
  final List menuItems = ['Message', 'Onligne', 'Groupe', 'Awaiting'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: deblack,
      height: 100,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(15),
          //ajoutter les points
          child: Row(
            //appele la fonction final MenuSection
            children: menuItems.map((items) {
              int index = menuItems.indexOf(items);
              return InkWell(
                onTap: () {
                  if (index >= 0) {
                    changeIndexPage(index);

                    pageController.animateToPage(index,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.linear);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                      border: index == curentpageindex
                          ? const Border(
                              bottom: BorderSide(
                                  color: Colors.blueAccent, width: 4))
                          : null),
                  margin: const EdgeInsets.only(right: 55),
                  child: Text(
                    items,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 23,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class FavoriteSection extends StatelessWidget {
  const FavoriteSection({super.key});

  Widget _buildFavoriteUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading..');
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: snapshot.data!.docs.map((favorite) {
            Map<String, dynamic> favorite1 =
                favorite.data() as Map<String, dynamic>;

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatPage(users: Users.fromMap(favorite)),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(left: 15),
                child: Column(
                  children: [
                    horizontalItem(favorite),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      favorite1['nom'] ??
                          "", // appel des nom sur 1 menu des favorite
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );

        // ListView(
        //   children: snapshot.data!.docs
        //       .map<Widget>((doc) => _buildUserListItem(doc))
        //       .toList(),
        // );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: deblack,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 20), // separation du contenu a l'interieur
        decoration: const BoxDecoration(
          color: deblue,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(40), topLeft: Radius.circular(40)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: Text(
                    'Contacts Favorite',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: null,
                ),
              ],
            ),
            // Pour afficher et scroller le menu 2
            Container(
              width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height * 0.1,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildFavoriteUserList()),
            )
          ],
        ),
      ),
    );
  }

  Container horizontalItem(DocumentSnapshot favorites) {
    log(favorites.data().toString());

    Map<String, dynamic> favorite = favorites.data() as Map<String, dynamic>;
    return Container(
      padding: const EdgeInsets.all(4),
      // height: 70,
      // width: 70,
      decoration: const BoxDecoration(
        color: dewhite,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (favorite["profilUrl"] != null)
            CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                    favorite['profilUrl']) /*AssetImage(favorite['profil'])*/),
          Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ))
        ],
      ),
    );
  }
}
