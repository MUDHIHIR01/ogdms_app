class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? siteId;
  final String? address;
  final String? idType;
  final String? idNumber;
  final String? tinNumber;
  final String? latitude;
  final String? longitude;
  final String? leadId;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.siteId,
    this.address,
    this.idType,
    this.idNumber,
    this.tinNumber,
    this.latitude,
    this.longitude,
    this.leadId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'site_id': siteId,
    'address': address,
    'id_type': idType,
    'id_number': idNumber,
    'tin_number': tinNumber,
    'latitude': latitude,
    'longitude': longitude,
    'lead_id': leadId,
  };
}

class Lead {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? siteId;
  final String? notes;
  final String? status;

  const Lead({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.siteId,
    this.notes,
    this.status,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'site_id': siteId,
    'notes': notes,
    'status': status,
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
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profilePhotoUrl;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.profilePhotoUrl,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone': phone,
    'profile_photo_url': profilePhotoUrl,
  };
}

class Site {
  final String id;
  final String name;
  final String? address;
  final String? clusterId;
  final String? siteId;

  const Site({
    required this.id,
    required this.name,
    this.address,
    this.clusterId,
    this.siteId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'address': address,
    'cluster_id': clusterId,
    'site_id': siteId,
  };
}

class Cluster {
  final String id;
  final String name;
  final String townId;
  final Map<String, dynamic>? town;

  const Cluster({
    required this.id,
    required this.name,
    required this.townId,
    this.town,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'town_id': townId,
    'town': town,
  };
}

class DeviceType {
  final String id;
  final String name;

  const DeviceType({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };
}

class ServiceType {
  final String id;
  final String name;

  const ServiceType({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };
}

class Town {
  final String id;
  final String name;

  const Town({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };
}