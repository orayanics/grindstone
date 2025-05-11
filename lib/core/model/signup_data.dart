class SignupData {
  String firstName;
  String lastName;
  String email;
  String password;
  int age;
  double height;
  double weight;

  SignupData(
      {required this.firstName,
      required this.lastName,
      required this.email,
      required this.password,
      required this.age,
      required this.height,
      required this.weight});

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'age': age,
      'height': height,
      'weight': weight,
    };
  }

  factory SignupData.fromMap(Map<String, dynamic> map) {
    return SignupData(
        firstName: map['firstName'],
        lastName: map['lastName'],
        email: map['email'],
        password: map['password'],
        age: map['age'],
        height: map['height'],
        weight: map['weight']);
  }
}
