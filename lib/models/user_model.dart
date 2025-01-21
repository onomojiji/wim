class User {
  final int? id;
  final String pseudo;
  final String pin;

  User({this.id, required this.pseudo, required this.pin});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pseudo': pseudo,
      'pin': pin,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      pseudo: map['pseudo'],
      pin: map['pin'],
    );
  }
}
