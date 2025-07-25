import 'dart:convert';

class InventoryItem {
  final String id;
  final String partNumber;
  final String name;
  final String description;
  final InventoryCategory category;
  final String? brand;
  final String? model;
  final int currentStock;
  final int minStock;
  final int maxStock;
  final double unitCost;
  final double sellingPrice;
  final String? supplierId;
  final String? location;
  final DateTime? lastRestockDate;
  final DateTime? expirationDate;
  final List<String> compatibleVehicles;
  final Map<String, dynamic> specifications;
  final bool isActive;

  const InventoryItem({
    required this.id,
    required this.partNumber,
    required this.name,
    required this.description,
    required this.category,
    this.brand,
    this.model,
    required this.currentStock,
    this.minStock = 0,
    this.maxStock = 100,
    required this.unitCost,
    required this.sellingPrice,
    this.supplierId,
    this.location,
    this.lastRestockDate,
    this.expirationDate,
    this.compatibleVehicles = const [],
    this.specifications = const {},
    this.isActive = true,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      partNumber: json['partNumber'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: InventoryCategory.values.byName(json['category']),
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      currentStock: json['currentStock'] as int,
      minStock: json['minStock'] as int? ?? 0,
      maxStock: json['maxStock'] as int? ?? 100,
      unitCost: (json['unitCost'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      supplierId: json['supplierId'] as String?,
      location: json['location'] as String?,
      lastRestockDate: json['lastRestockDate'] != null
          ? DateTime.parse(json['lastRestockDate'] as String)
          : null,
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
      compatibleVehicles: List<String>.from(json['compatibleVehicles'] ?? []),
      specifications: json['specifications'] as Map<String, dynamic>? ?? {},
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partNumber': partNumber,
      'name': name,
      'description': description,
      'category': category.name,
      'brand': brand,
      'model': model,
      'currentStock': currentStock,
      'minStock': minStock,
      'maxStock': maxStock,
      'unitCost': unitCost,
      'sellingPrice': sellingPrice,
      'supplierId': supplierId,
      'location': location,
      'lastRestockDate': lastRestockDate?.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'compatibleVehicles': compatibleVehicles,
      'specifications': specifications,
      'isActive': isActive,
    };
  }

  InventoryItem copyWith({
    String? id,
    String? partNumber,
    String? name,
    String? description,
    InventoryCategory? category,
    String? brand,
    String? model,
    int? currentStock,
    int? minStock,
    int? maxStock,
    double? unitCost,
    double? sellingPrice,
    String? supplierId,
    String? location,
    DateTime? lastRestockDate,
    DateTime? expirationDate,
    List<String>? compatibleVehicles,
    Map<String, dynamic>? specifications,
    bool? isActive,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      partNumber: partNumber ?? this.partNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      unitCost: unitCost ?? this.unitCost,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      supplierId: supplierId ?? this.supplierId,
      location: location ?? this.location,
      lastRestockDate: lastRestockDate ?? this.lastRestockDate,
      expirationDate: expirationDate ?? this.expirationDate,
      compatibleVehicles: compatibleVehicles ?? this.compatibleVehicles,
      specifications: specifications ?? this.specifications,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Check if item is low stock
  bool get isLowStock => currentStock <= minStock;

  /// Check if item is out of stock
  bool get isOutOfStock => currentStock <= 0;

  /// Check if item is overstocked
  bool get isOverstocked => currentStock > maxStock;

  /// Get stock status
  StockStatus get stockStatus {
    if (isOutOfStock) return StockStatus.outOfStock;
    if (isLowStock) return StockStatus.lowStock;
    if (isOverstocked) return StockStatus.overstocked;
    return StockStatus.normal;
  }

  /// Calculate profit margin
  double get profitMargin {
    if (unitCost <= 0) return 0.0;
    return ((sellingPrice - unitCost) / unitCost) * 100;
  }

  /// Calculate total value of current stock
  double get totalStockValue => currentStock * unitCost;

  /// Get full display name
  String get fullName {
    final parts = <String>[name];
    if (brand != null && brand!.isNotEmpty) parts.add('($brand)');
    if (model != null && model!.isNotEmpty) parts.add(model!);
    return parts.join(' ');
  }

  /// Check if item is expired
  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  /// Get days until expiration
  int? get daysUntilExpiration {
    if (expirationDate == null) return null;
    final difference = expirationDate!.difference(DateTime.now());
    return difference.inDays;
  }

  /// Check if item is compatible with a vehicle
  bool isCompatibleWith(String vehicleIdentifier) {
    return compatibleVehicles.any(
      (vehicle) => vehicle.toLowerCase().contains(vehicleIdentifier.toLowerCase()),
    );
  }

  /// Get suggested reorder quantity
  int get suggestedReorderQuantity {
    return maxStock - currentStock;
  }
}

class StockMovement {
  final String id;
  final String inventoryItemId;
  final MovementType type;
  final int quantity;
  final DateTime timestamp;
  final String? workOrderId;
  final String? supplierId;
  final String? notes;
  final double? unitCost;
  final String userId;

  const StockMovement({
    required this.id,
    required this.inventoryItemId,
    required this.type,
    required this.quantity,
    required this.timestamp,
    this.workOrderId,
    this.supplierId,
    this.notes,
    this.unitCost,
    required this.userId,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String,
      inventoryItemId: json['inventoryItemId'] as String,
      type: MovementType.values.byName(json['type']),
      quantity: json['quantity'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      workOrderId: json['workOrderId'] as String?,
      supplierId: json['supplierId'] as String?,
      notes: json['notes'] as String?,
      unitCost: (json['unitCost'] as num?)?.toDouble(),
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventoryItemId': inventoryItemId,
      'type': type.name,
      'quantity': quantity,
      'timestamp': timestamp.toIso8601String(),
      'workOrderId': workOrderId,
      'supplierId': supplierId,
      'notes': notes,
      'unitCost': unitCost,
      'userId': userId,
    };
  }

  StockMovement copyWith({
    String? id,
    String? inventoryItemId,
    MovementType? type,
    int? quantity,
    DateTime? timestamp,
    String? workOrderId,
    String? supplierId,
    String? notes,
    double? unitCost,
    String? userId,
  }) {
    return StockMovement(
      id: id ?? this.id,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      timestamp: timestamp ?? this.timestamp,
      workOrderId: workOrderId ?? this.workOrderId,
      supplierId: supplierId ?? this.supplierId,
      notes: notes ?? this.notes,
      unitCost: unitCost ?? this.unitCost,
      userId: userId ?? this.userId,
    );
  }

  /// Get the effective quantity change (positive for in, negative for out)
  int get effectiveQuantity {
    switch (type) {
      case MovementType.stockIn:
      case MovementType.adjustment:
        return quantity;
      case MovementType.stockOut:
      case MovementType.used:
      case MovementType.damaged:
      case MovementType.expired:
        return -quantity;
    }
  }

  /// Get total value of this movement
  double get totalValue {
    if (unitCost == null) return 0.0;
    return quantity * unitCost!;
  }
}

class Supplier {
  final String id;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String? website;
  final List<String> categories;
  final double rating;
  final SupplierStatus status;
  final Map<String, dynamic> terms;

  const Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    this.website,
    this.categories = const [],
    this.rating = 0.0,
    this.status = SupplierStatus.active,
    this.terms = const {},
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      contactPerson: json['contactPerson'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      website: json['website'] as String?,
      categories: List<String>.from(json['categories'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      status: SupplierStatus.values.byName(json['status'] ?? 'active'),
      terms: json['terms'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'website': website,
      'categories': categories,
      'rating': rating,
      'status': status.name,
      'terms': terms,
    };
  }

  Supplier copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? website,
    List<String>? categories,
    double? rating,
    SupplierStatus? status,
    Map<String, dynamic>? terms,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      website: website ?? this.website,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      terms: terms ?? this.terms,
    );
  }

  /// Get full address string
  String get fullAddress => '$address, $city, $state $zipCode';

  /// Check if supplier is active
  bool get isActive => status == SupplierStatus.active;
}

enum InventoryCategory {
  engine,
  transmission,
  brakes,
  suspension,
  electrical,
  cooling,
  fuel,
  exhaust,
  body,
  interior,
  tools,
  fluids,
  filters,
  belts,
  hoses,
}

enum StockStatus {
  normal,
  lowStock,
  outOfStock,
  overstocked,
}

enum MovementType {
  stockIn,
  stockOut,
  used,
  adjustment,
  damaged,
  expired,
}

enum SupplierStatus {
  active,
  inactive,
  onHold,
  blacklisted,
}

// Extension methods for better enum usage
extension InventoryCategoryExtension on InventoryCategory {
  String get displayName {
    switch (this) {
      case InventoryCategory.engine:
        return 'Engine';
      case InventoryCategory.transmission:
        return 'Transmission';
      case InventoryCategory.brakes:
        return 'Brakes';
      case InventoryCategory.suspension:
        return 'Suspension';
      case InventoryCategory.electrical:
        return 'Electrical';
      case InventoryCategory.cooling:
        return 'Cooling';
      case InventoryCategory.fuel:
        return 'Fuel System';
      case InventoryCategory.exhaust:
        return 'Exhaust';
      case InventoryCategory.body:
        return 'Body';
      case InventoryCategory.interior:
        return 'Interior';
      case InventoryCategory.tools:
        return 'Tools';
      case InventoryCategory.fluids:
        return 'Fluids';
      case InventoryCategory.filters:
        return 'Filters';
      case InventoryCategory.belts:
        return 'Belts';
      case InventoryCategory.hoses:
        return 'Hoses';
    }
  }
}

extension StockStatusExtension on StockStatus {
  String get displayName {
    switch (this) {
      case StockStatus.normal:
        return 'Normal';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.outOfStock:
        return 'Out of Stock';
      case StockStatus.overstocked:
        return 'Overstocked';
    }
  }
}

extension MovementTypeExtension on MovementType {
  String get displayName {
    switch (this) {
      case MovementType.stockIn:
        return 'Stock In';
      case MovementType.stockOut:
        return 'Stock Out';
      case MovementType.used:
        return 'Used';
      case MovementType.adjustment:
        return 'Adjustment';
      case MovementType.damaged:
        return 'Damaged';
      case MovementType.expired:
        return 'Expired';
    }
  }
}