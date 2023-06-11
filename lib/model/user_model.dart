class MyUser {
  String? id;
  String email;
  String password;
  String name;

  MyUser(
      {this.id,
      required this.email,
      required this.password,
      required this.name});

  factory MyUser.fromJson(Map<String, dynamic> json) {
    return MyUser(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
    };
  }
}
