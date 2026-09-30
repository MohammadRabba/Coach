class UserModel {
  String? id;
  String? email;
  String? password;
  String? fullName;
  String? phone;
  String? type;
  String? photo;
  String? address;
  int? gender;
  double? height;
  double? weight;
  DateTime? registrationDate;
  double? bmi;
  UserModel({
    this.id,
    this.email,
    this.password,
    this.fullName,
    this.phone,
    this.type,
    this.photo,
    this.gender,
    this.registrationDate,
    this.height,
    this.weight,
    this.bmi,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      fullName: json['name'] as String?,
      phone: json['phone'] as String?,
      type: json['type'] as String?,
      photo: json['photo'] as String?,
      address: json['address'] as String?,
      gender: json['gender'] as int?,
      height: json['height'] as double?,
      weight: json['weight'] as double?,
      registrationDate: json['registrationDate'] as DateTime?,
      bmi: json['bmi'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': fullName,
      'phone': phone,
      'type': type,
      'photo': photo,
      'gender': gender,
      'registrationDate': registrationDate,
      'height': height,
      'weight': weight,
      'bmi': bmi,
    };
  }
}
