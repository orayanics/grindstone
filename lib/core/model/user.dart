class User {
  String id;
  String name;
  String email;
  int age;
  double height; // in cm or meters depending on your use case
  double weight; // in kg

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.height,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'height': height,
      'weight': weight,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      age: map['age'],
      height: (map['height'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
    );
  }
}
