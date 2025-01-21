class Invite {
  final int? id; // Identifiant unique
  final int mariageId; // Référence au mariage
  final String nom;
  final String prenom;
  final String qrCode; // Code QR unique pour identifier l'invité
  final String presence; // Statut de présence (par défaut "absent")
  var heure_arrivee; // Heure d'arrivée de l'invité par défaut null

  Invite({
    this.id,
    required this.mariageId,
    required this.nom,
    required this.prenom,
    required this.qrCode,
    this.presence = 'absent',
    this.heure_arrivee,
  });

  // Convertir un objet Invite en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mariageId': mariageId,
      'nom': nom,
      'prenom': prenom,
      'qrCode': qrCode,
      'presence': presence,
      'heure_arrivee': DateTime.now().toIso8601String(), // Ajout de la date et de l'heure d'arrivée
    };
  }

  // Créer un objet Invite à partir d'un Map
  factory Invite.fromMap(Map<String, dynamic> map) {
    return Invite(
      id: map['id'],
      mariageId: map['mariageId'],
      nom: map['nom'],
      prenom: map['prenom'],
      qrCode: map['qrCode'],
      presence: map['presence'],
      heure_arrivee: map['heure_arrivee'],
    );
  }
}
