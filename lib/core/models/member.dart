// Modelo de miembro del gimnasio
class Member {
  final String id;
  final String displayId;
  final String name;
  final String email;
  final String? phone;
  final String joinDate;
  final String status;
  final String? planId;
  final String? planName;
  final String createdAt;
  final String updatedAt;

  Member({
    required this.id,
    required this.displayId,
    required this.name,
    required this.email,
    this.phone,
    required this.joinDate,
    required this.status,
    this.planId,
    this.planName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      displayId: json['displayId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      joinDate: json['joinDate'],
      status: json['status'],
      planId: json['planId'],
      planName: json['planName'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayId': displayId,
      'name': name,
      'email': email,
      'phone': phone,
      'joinDate': joinDate,
      'status': status,
      'planId': planId,
      'planName': planName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
