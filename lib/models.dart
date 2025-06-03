class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? siteId;
  final String? idType;
  final String? idNumber;
  final String? tinNumber;
  final String? notes;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.siteId,
    this.idType,
    this.idNumber,
    this.tinNumber,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'site_id': siteId,
    'id_type': idType,
    'id_number': idNumber,
    'tin_number': tinNumber,
    'notes': notes,
  };
}

class Lead {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? siteId;
  final String? notes;

  const Lead({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.siteId,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'site_id': siteId,
    'notes': notes,
  };
}

class Ticket {
  final String id;
  final String title;
  final String description;
  final String? customerId;
  final String? siteId;
  final String? status;
  final String? type;

  const Ticket({
    required this.id,
    required this.title,
    required this.description,
    this.customerId,
    this.siteId,
    this.status,
    this.type,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'customer_id': customerId,
    'site_id': siteId,
    'status': status,
    'type': type,
  };
}

class AppNotification {
  final String id;
  final String message;
  final String date;

  const AppNotification({
    required this.id,
    required this.message,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'message': message,
    'date': date,
  };
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
  };
}