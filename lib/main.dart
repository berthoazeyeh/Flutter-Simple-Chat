import 'package:chatappf/api/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:chatappf/firebase_options.dart';
import 'package:chatappf/services/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chatappf/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseApi().initNotification();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (content) => AuthService(),
      )
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
