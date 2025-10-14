// Datos mock para la aplicación de gimnasio
class Member {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime joinDate;
  final String status;
  final String planId;

  const Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.joinDate,
    required this.status,
    required this.planId,
  });
}

class Plan {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final List<String> features;

  const Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.features,
  });
}

class Subscription {
  final String id;
  final String memberId;
  final String planId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double amount;

  const Subscription({
    required this.id,
    required this.memberId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.amount,
  });
}

class Payment {
  final String id;
  final String memberId;
  final String subscriptionId;
  final double amount;
  final DateTime paymentDate;
  final String method;
  final String status;

  const Payment({
    required this.id,
    required this.memberId,
    required this.subscriptionId,
    required this.amount,
    required this.paymentDate,
    required this.method,
    required this.status,
  });
}

class Attendance {
  final String id;
  final String memberId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status;

  const Attendance({
    required this.id,
    required this.memberId,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
  });
}

// Datos mock
final List<Member> kMembers = [
  Member(
    id: 'M001',
    name: 'Juan Pérez',
    email: 'juan.perez@email.com',
    phone: '+52 55 1234 5678',
    joinDate: DateTime(2024, 1, 15),
    status: 'Activo',
    planId: 'P001',
  ),
  Member(
    id: 'M002',
    name: 'María García',
    email: 'maria.garcia@email.com',
    phone: '+52 55 2345 6789',
    joinDate: DateTime(2024, 2, 20),
    status: 'Activo',
    planId: 'P002',
  ),
  Member(
    id: 'M003',
    name: 'Carlos López',
    email: 'carlos.lopez@email.com',
    phone: '+52 55 3456 7890',
    joinDate: DateTime(2024, 3, 10),
    status: 'Inactivo',
    planId: 'P001',
  ),
  Member(
    id: 'M004',
    name: 'Ana Martínez',
    email: 'ana.martinez@email.com',
    phone: '+52 55 4567 8901',
    joinDate: DateTime(2024, 4, 5),
    status: 'Activo',
    planId: 'P003',
  ),
];

final List<Plan> kPlans = [
  Plan(
    id: 'P001',
    name: 'Plan Básico',
    description: 'Acceso básico al gimnasio',
    price: 500.0,
    durationDays: 30,
    features: ['Acceso al gimnasio', 'Vestidores', 'Ducha'],
  ),
  Plan(
    id: 'P002',
    name: 'Plan Premium',
    description: 'Acceso completo con clases grupales',
    price: 800.0,
    durationDays: 30,
    features: ['Acceso al gimnasio', 'Clases grupales', 'Entrenador personal', 'Nutricionista'],
  ),
  Plan(
    id: 'P003',
    name: 'Plan VIP',
    description: 'Acceso premium con servicios exclusivos',
    price: 1200.0,
    durationDays: 30,
    features: ['Acceso completo', 'Clases privadas', 'Masajes', 'Spa', 'Nutricionista personal'],
  ),
];

final List<Subscription> kSubscriptions = [
  Subscription(
    id: 'S001',
    memberId: 'M001',
    planId: 'P001',
    startDate: DateTime(2024, 1, 15),
    endDate: DateTime(2024, 2, 14),
    status: 'Activa',
    amount: 500.0,
  ),
  Subscription(
    id: 'S002',
    memberId: 'M002',
    planId: 'P002',
    startDate: DateTime(2024, 2, 20),
    endDate: DateTime(2024, 3, 21),
    status: 'Activa',
    amount: 800.0,
  ),
];

final List<Payment> kPayments = [
  Payment(
    id: 'PAY001',
    memberId: 'M001',
    subscriptionId: 'S001',
    amount: 500.0,
    paymentDate: DateTime(2024, 1, 15),
    method: 'Efectivo',
    status: 'Completado',
  ),
  Payment(
    id: 'PAY002',
    memberId: 'M002',
    subscriptionId: 'S002',
    amount: 800.0,
    paymentDate: DateTime(2024, 2, 20),
    method: 'Tarjeta',
    status: 'Completado',
  ),
];

final List<Attendance> kAttendance = [
  Attendance(
    id: 'A001',
    memberId: 'M001',
    checkInTime: DateTime(2024, 1, 20, 8, 30),
    checkOutTime: DateTime(2024, 1, 20, 10, 15),
    status: 'Completado',
  ),
  Attendance(
    id: 'A002',
    memberId: 'M002',
    checkInTime: DateTime(2024, 1, 20, 9, 0),
    status: 'En curso',
  ),
];

// KPIs para el dashboard
final Map<String, dynamic> kDashboardKPIs = {
  'totalMembers': 156,
  'activeMembers': 142,
  'monthlyRevenue': 125000.0,
  'averageAttendance': 78.5,
  'newMembersThisMonth': 23,
  'renewalRate': 85.2,
};
