class User {
  String id;
  String firstName;
  String lastName;
  String email;
  int age;
  double height;
  double weight;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
    required this.height,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'age': age,
      'height': height,
      'weight': weight,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      age: map['age'],
      height: (map['height'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
    );
  }
}
