import 'dart:convert';

class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final DateTime createdAt;
  final DateTime? lastServiceDate;
  final List<String> vehicleIds;
  final CustomerStatus status;
  final Map<String, dynamic> preferences;
  final double totalSpent;
  final int visitCount;

  const Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    required this.createdAt,
    this.lastServiceDate,
    this.vehicleIds = const [],
    this.status = CustomerStatus.active,
    this.preferences = const {},
    this.totalSpent = 0.0,
    this.visitCount = 0,
  });

  String get fullName => '$firstName $lastName';

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastServiceDate: json['lastServiceDate'] != null
          ? DateTime.parse(json['lastServiceDate'] as String)
          : null,
      vehicleIds: List<String>.from(json['vehicleIds'] ?? []),
      status: CustomerStatus.values.byName(json['status'] ?? 'active'),
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      visitCount: json['visitCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'createdAt': createdAt.toIso8601String(),
      'lastServiceDate': lastServiceDate?.toIso8601String(),
      'vehicleIds': vehicleIds,
      'status': status.name,
      'preferences': preferences,
      'totalSpent': totalSpent,
      'visitCount': visitCount,
    };
  }

  Customer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    DateTime? createdAt,
    DateTime? lastServiceDate,
    List<String>? vehicleIds,
    CustomerStatus? status,
    Map<String, dynamic>? preferences,
    double? totalSpent,
    int? visitCount,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      createdAt: createdAt ?? this.createdAt,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      vehicleIds: vehicleIds ?? this.vehicleIds,
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      totalSpent: totalSpent ?? this.totalSpent,
      visitCount: visitCount ?? this.visitCount,
    );
  }

  /// Check if customer is a repeat customer
  bool get isRepeatCustomer => visitCount > 1;

  /// Get customer tier based on spending
  CustomerTier get tier {
    if (totalSpent >= 5000) return CustomerTier.platinum;
    if (totalSpent >= 2000) return CustomerTier.gold;
    if (totalSpent >= 500) return CustomerTier.silver;
    return CustomerTier.bronze;
  }

  /// Get full address string
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    return parts.join(', ');
  }

  /// Get average spending per visit
  double get averageSpendingPerVisit {
    if (visitCount == 0) return 0.0;
    return totalSpent / visitCount;
  }

  /// Get days since last service
  int? get daysSinceLastService {
    if (lastServiceDate == null) return null;
    return DateTime.now().difference(lastServiceDate!).inDays;
  }
}

class CustomerVehicle {
  final String id;
  final String customerId;
  final String year;
  final String make;
  final String model;
  final String? trim;
  final String? vin;
  final String? licensePlate;
  final String? color;
  final int? mileage;
  final DateTime? lastServiceDate;
  final List<String> serviceHistory;
  final Map<String, dynamic> specifications;

  const CustomerVehicle({
    required this.id,
    required this.customerId,
    required this.year,
    required this.make,
    required this.model,
    this.trim,
    this.vin,
    this.licensePlate,
    this.color,
    this.mileage,
    this.lastServiceDate,
    this.serviceHistory = const [],
    this.specifications = const {},
  });

  String get displayName => '$year $make $model${trim != null ? ' $trim' : ''}';

  factory CustomerVehicle.fromJson(Map<String, dynamic> json) {
    return CustomerVehicle(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      year: json['year'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      trim: json['trim'] as String?,
      vin: json['vin'] as String?,
      licensePlate: json['licensePlate'] as String?,
      color: json['color'] as String?,
      mileage: json['mileage'] as int?,
      lastServiceDate: json['lastServiceDate'] != null
          ? DateTime.parse(json['lastServiceDate'] as String)
          : null,
      serviceHistory: List<String>.from(json['serviceHistory'] ?? []),
      specifications: json['specifications'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'year': year,
      'make': make,
      'model': model,
      'trim': trim,
      'vin': vin,
      'licensePlate': licensePlate,
      'color': color,
      'mileage': mileage,
      'lastServiceDate': lastServiceDate?.toIso8601String(),
      'serviceHistory': serviceHistory,
      'specifications': specifications,
    };
  }

  CustomerVehicle copyWith({
    String? id,
    String? customerId,
    String? year,
    String? make,
    String? model,
    String? trim,
    String? vin,
    String? licensePlate,
    String? color,
    int? mileage,
    DateTime? lastServiceDate,
    List<String>? serviceHistory,
    Map<String, dynamic>? specifications,
  }) {
    return CustomerVehicle(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      year: year ?? this.year,
      make: make ?? this.make,
      model: model ?? this.model,
      trim: trim ?? this.trim,
      vin: vin ?? this.vin,
      licensePlate: licensePlate ?? this.licensePlate,
      color: color ?? this.color,
      mileage: mileage ?? this.mileage,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      serviceHistory: serviceHistory ?? this.serviceHistory,
      specifications: specifications ?? this.specifications,
    );
  }
}

class ContactInfo {
  final String? primaryPhone;
  final String? secondaryPhone;
  final String? email;
  final String? preferredContactMethod;
  final List<String> emergencyContacts;

  const ContactInfo({
    this.primaryPhone,
    this.secondaryPhone,
    this.email,
    this.preferredContactMethod,
    this.emergencyContacts = const [],
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      primaryPhone: json['primaryPhone'] as String?,
      secondaryPhone: json['secondaryPhone'] as String?,
      email: json['email'] as String?,
      preferredContactMethod: json['preferredContactMethod'] as String?,
      emergencyContacts: List<String>.from(json['emergencyContacts'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryPhone': primaryPhone,
      'secondaryPhone': secondaryPhone,
      'email': email,
      'preferredContactMethod': preferredContactMethod,
      'emergencyContacts': emergencyContacts,
    };
  }

  ContactInfo copyWith({
    String? primaryPhone,
    String? secondaryPhone,
    String? email,
    String? preferredContactMethod,
    List<String>? emergencyContacts,
  }) {
    return ContactInfo(
      primaryPhone: primaryPhone ?? this.primaryPhone,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      email: email ?? this.email,
      preferredContactMethod: preferredContactMethod ?? this.preferredContactMethod,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }
}

enum CustomerStatus {
  active,
  inactive,
  blocked,
  prospect,
}

enum CustomerTier {
  bronze,
  silver,
  gold,
  platinum,
}

enum ContactMethod {
  phone,
  email,
  text,
  mail,
}

// Extension methods for better enum usage
extension CustomerStatusExtension on CustomerStatus {
  String get displayName {
    switch (this) {
      case CustomerStatus.active:
        return 'Active';
      case CustomerStatus.inactive:
        return 'Inactive';
      case CustomerStatus.blocked:
        return 'Blocked';
      case CustomerStatus.prospect:
        return 'Prospect';
    }
  }

  bool get isActive => this == CustomerStatus.active;
}

extension CustomerTierExtension on CustomerTier {
  String get displayName {
    switch (this) {
      case CustomerTier.bronze:
        return 'Bronze';
      case CustomerTier.silver:
        return 'Silver';
      case CustomerTier.gold:
        return 'Gold';
      case CustomerTier.platinum:
        return 'Platinum';
    }
  }

  double get discountPercentage {
    switch (this) {
      case CustomerTier.bronze:
        return 0.0;
      case CustomerTier.silver:
        return 0.05; // 5%
      case CustomerTier.gold:
        return 0.10; // 10%
      case CustomerTier.platinum:
        return 0.15; // 15%
    }
  }
}