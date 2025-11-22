// Modelo de pago
class Payment {
  final String id;
  final String displayId;
  final String memberId;
  final String memberName;
  final String subscriptionId;
  final double amount;
  final String paymentDate;
  final String method;
  final String status;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  Payment({
    required this.id,
    required this.displayId,
    required this.memberId,
    required this.memberName,
    required this.subscriptionId,
    required this.amount,
    required this.paymentDate,
    required this.method,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      displayId: json['displayId'],
      memberId: json['memberId'],
      memberName: json['memberName'] ?? '',
      subscriptionId: json['subscriptionId'],
      amount: (json['amount'] as num).toDouble(),
      paymentDate: json['paymentDate'],
      method: json['method'],
      status: json['status'],
      notes: json['notes'],
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
      'subscriptionId': subscriptionId,
      'amount': amount,
      'paymentDate': paymentDate,
      'method': method,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
