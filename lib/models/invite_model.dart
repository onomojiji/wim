class Invite {
  final int? id; // Identifiant unique
  final int mariageId; // Référence au mariage
  final String nomPorteur; // Nom de la personne qui a invité
  final String ville; // Ville de l'invité
  final String nom; // Nom ou nom de groupe (ex: Famille Mvondo)
  final String telephone; // Numéro de téléphone de l'invité
  final int nombrePlaces; // Nombre de personnes couvertes par le billet
  final String qrCode; // QR Code unique du billet
  int nombrePresent; // Nombre de personnes effectivement présentes
  String presence; // Statut de présence : absent, partiel, complet
  DateTime? heureArrivee; // Heure d'arrivée du premier invité (null par défaut)

  Invite({
    this.id,
    required this.mariageId,
    required this.nomPorteur,
    required this.ville,
    required this.nom,
    required this.telephone,
    required this.nombrePlaces,
    required this.qrCode,
    this.nombrePresent = 0,
    this.presence = 'absent',
    this.heureArrivee,
  });

  /// Met à jour le nombre de personnes présentes et ajuste le statut de présence
  void enregistrerPresence(int nombre) {
    if (nombre < 0 || nombre > nombrePlaces) return; // Empêche des valeurs incorrectes
    nombrePresent = nombre;

    if (nombre == 0) {
      presence = 'absent';
    } else if (nombre < nombrePlaces) {
      presence = 'partiel';
    } else {
      presence = 'complet';
    }

    // Définir l'heure d'arrivée si c'est la première présence enregistrée
    heureArrivee ??= DateTime.now();
  }

  // Convertir en Map pour stockage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mariageId': mariageId,
      'nomPorteur': nomPorteur,
      'ville': ville,
      'nom': nom,
      'telephone': telephone,
      'nombrePlaces': nombrePlaces,
      'qrCode': qrCode,
      'nombrePresent': nombrePresent,
      'presence': presence,
      'heureArrivee': heureArrivee?.toIso8601String(),
    };
  }

  // Créer un objet Invite depuis un Map
  factory Invite.fromMap(Map<String, dynamic> map) {
    return Invite(
      id: map['id'],
      mariageId: map['mariageId'],
      nomPorteur: map['nomPorteur'],
      ville: map['ville'],
      nom: map['nom'],
      telephone: map['telephone'],
      nombrePlaces: map['nombrePlaces'],
      qrCode: map['qrCode'],
      nombrePresent: map['nombrePresent'] ?? 0,
      presence: map['presence'] ?? 'absent',
      heureArrivee: map['heureArrivee'] != null ? DateTime.parse(map['heureArrivee']) : null,
    );
  }
}
