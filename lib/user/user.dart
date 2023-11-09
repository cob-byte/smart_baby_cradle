class User {
  String image;
  String name;
  String device;
  String email;
  String fname;
  String lname;

  // Constructor
  User({
    required this.image,
    required this.name,
    required this.device,
    required this.email,
    required this.fname,
    required this.lname,
  });

  User copy({
    String? imagePath,
    String? name,
    String? device,
    String? email,
    String? fname,
    String? lname,
  }) =>
      User(
        image: imagePath ?? this.image,
        name: name ?? this.name,
        device: device ?? this.device,
        email: email ?? this.email,
        fname: fname ?? this.fname,
        lname: lname ?? this.lname,
      );

  static User fromJson(Map<String, dynamic> json) => User(
        image: json['imagePath'],
        name: json['name'],
        device: json['device'],
        email: json['email'],
        fname: json['fname'],
        lname: json['lname'],
  );

  Map<String, dynamic> toJson() => {
        'imagePath': image,
        'name': name,
        'device': device,
        'email': email,
        'fname': fname,
        'lname': lname,
      };
}
