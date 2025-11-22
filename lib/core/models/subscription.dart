// Modelo de suscripción
class Subscription {
  final String id;
  final String displayId;
  final String memberId;
  final String memberName;
  final String planId;
  final String planName;
  final String startDate;
  final String endDate;
  final String status;
  final double amount;
  final String createdAt;
  final String updatedAt;

  Subscription({
    required this.id,
    required this.displayId,
    required this.memberId,
    required this.memberName,
    required this.planId,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      displayId: json['displayId'],
      memberId: json['memberId'],
      memberName: json['memberName'] ?? '',
      planId: json['planId'],
      planName: json['planName'] ?? '',
      startDate: json['startDate'],
      endDate: json['endDate'],
      status: json['status'],
      amount: (json['amount'] as num).toDouble(),
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
      'planId': planId,
      'planName': planName,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'amount': amount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
