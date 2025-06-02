class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });
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
}
