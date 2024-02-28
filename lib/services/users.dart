class Users {
  late String uid;
  late String nom;
  late String email;
  late bool status;
  String? profilUrl; // Changement ici : profilUrl peut être null
  String? token; // Changement ici : profilUrl peut être null
  late bool isAdmin;

  // Constructeur
  Users({
    required this.uid,
    required this.nom,
    required this.email,
    required this.status,
    this.profilUrl, // Changement ici : profilUrl peut être null
    this.token, // Changement ici : profilUrl peut être null
    required this.isAdmin,
  });

  // Méthode pour convertir l'objet User en un Map JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nom': nom,
      'email': email,
      'status': status,
      'profilUrl': profilUrl,
      'token': token,
      'isAdmin': isAdmin,
    };
  }

  // Méthode pour créer un objet User à partir d'un Map
  static Users fromMap(dynamic map) {
    return Users(
      uid: map['uid'],
      nom: map['nom'],
      email: map['email'],
      status: map['status'],
      profilUrl: map['profilUrl'],
      token: map['token'],
      isAdmin: map['isAdmin'],
    );
  }
}
