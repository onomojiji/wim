class Mariage {
  final int? id; // Identifiant unique
  final int userId; // Référence à l'utilisateur
  final String nomMarie1;
  final String nomMarie2;
  final String date;
  final String lieu;
  final String heure;

  Mariage({
    this.id,
    required this.userId,
    required this.nomMarie1,
    required this.nomMarie2,
    required this.date,
    required this.lieu,
    required this.heure,
  });

  // Convertir un objet Mariage en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'nomMarie1': nomMarie1,
      'nomMarie2': nomMarie2,
      'date': date,
      'lieu': lieu,
      'heure': heure,
    };
  }

  // Créer un objet Mariage à partir d'un Map
  factory Mariage.fromMap(Map<String, dynamic> map) {
    return Mariage(
      id: map['id'],
      userId: map['userId'],
      nomMarie1: map['nomMarie1'],
      nomMarie2: map['nomMarie2'],
      date: map['date'],
      lieu: map['lieu'],
      heure: map['heure'],
    );
  }
}
