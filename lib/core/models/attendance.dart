// Modelo de asistencia
class Attendance {
  final String id;
  final String displayId;
  final String memberId;
  final String memberName;
  final String checkInTime;
  final String? checkOutTime;
  final String status;
  final String createdAt;
  final String updatedAt;

  Attendance({
    required this.id,
    required this.displayId,
    required this.memberId,
    required this.memberName,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      displayId: json['displayId'],
      memberId: json['memberId'],
      memberName: json['memberName'] ?? '',
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayId': displayId,
      'memberId': memberId,
      'memberName': memberName,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
