// Modelo de plan de membresía
class Plan {
  final String id;
  final String displayId;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final List<String> features;
  final String? status;
  final String createdAt;
  final String updatedAt;

  Plan({
    required this.id,
    required this.displayId,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.features,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      displayId: json['displayId'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      durationDays: json['durationDays'],
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : [],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayId': displayId,
      'name': name,
      'description': description,
      'price': price,
      'durationDays': durationDays,
      'features': features,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
