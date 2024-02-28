// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'dart:io';

import 'package:chatappf/services/auth_service.dart';
import 'package:chatappf/services/chat/chat_service.dart';
import 'package:chatappf/services/users.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen({super.key, required this.users, required this.canUpdate});
  Users users;
  bool canUpdate;
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  Future<void> getImageCaptured(
      ImageSource source, AuthService authService) async {
    final ImagePicker _picker = ImagePicker();

    await Permission.photos.status;
    await Permission.camera.status;
    final XFile? image = await _picker.pickImage(source: source);
    if (kDebugMode) {
      print(image);
    }

    if (image != null) {
      try {
        // Récupérez une référence unique pour l'image
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now()}.png');

        // Téléversez l'image sur Firebase Storage
        await storageReference.putFile(File(image.path));

        // Obtenez l'URL de téléchargement de l'image
        String downloadURL = await storageReference.getDownloadURL();
        ChatService().updateProfilUser(
            authService.user!.uid, downloadURL, authService.user!, authService);
        // Utilisez downloadURL comme nécessaire (par exemple, sauvegardez-le dans Firebase Database)
        if (kDebugMode) {
          print(
              'Image téléversée avec succès. URL de téléchargement : $downloadURL');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erreur lors du téléversement de l\'image : $e');
        }
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    print(_nameController.text);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Utilisateur'),
        actions: [
          if (widget.canUpdate)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _nameController.text = authService.user!.nom;
                _emailController.text = authService.user!.email;
                _showEditDialog(setState);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                InkWell(
                  onTap: () {
                    getImageCaptured(ImageSource.gallery, authService);
                  },
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(authService.user!.profilUrl !=
                            null
                        ? authService.user!.profilUrl!
                        : "https://api-private.atlassian.com/users/7831f16b18333c732e152c74f1863d18/avatar"), // Remplacez par le chemin de votre image
                  ),
                ),
                if (widget.canUpdate)
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[300], shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Action à effectuer lorsque l'icône d'édition est cliquée
                        getImageCaptured(ImageSource.camera, authService);

                        if (kDebugMode) {
                          print('Icône d\'édition cliquée');
                        }
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard('Nom', widget.users.nom),
            _buildInfoCard('E-mail', widget.users.email),
            _buildInfoCard(
                'Statut', widget.users.status ? 'Activé' : 'Désactivé'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(StateSetter stateSetter) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier les informations'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nouveau nom'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Nouvel e-mail'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                stateSetter(
                  () {},
                );
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _nameController.clear();
                _emailController.clear();
                stateSetter(
                  () {},
                );
                Navigator.pop(context);
                _showSnackbar('Informations mises à jour avec succès');
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
