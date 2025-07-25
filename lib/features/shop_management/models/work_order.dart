import 'dart:convert';

class WorkOrder {
  final String id;
  final String customerId;
  final String? vehicleId;
  final DateTime createdDate;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final WorkOrderStatus status;
  final WorkOrderPriority priority;
  final String description;
  final List<ServiceItem> services;
  final List<WorkOrderPart> parts;
  final double laborCost;
  final double partsCost;
  final double totalCost;
  final String? technicianId;
  final String? notes;
  final List<String> imageUrls;
  final PaymentStatus paymentStatus;

  const WorkOrder({
    required this.id,
    required this.customerId,
    this.vehicleId,
    required this.createdDate,
    this.scheduledDate,
    this.completedDate,
    required this.status,
    this.priority = WorkOrderPriority.normal,
    required this.description,
    this.services = const [],
    this.parts = const [],
    this.laborCost = 0.0,
    this.partsCost = 0.0,
    this.totalCost = 0.0,
    this.technicianId,
    this.notes,
    this.imageUrls = const [],
    this.paymentStatus = PaymentStatus.pending,
  });

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    return WorkOrder(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      vehicleId: json['vehicleId'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      status: WorkOrderStatus.values.byName(json['status']),
      priority: WorkOrderPriority.values.byName(json['priority'] ?? 'normal'),
      description: json['description'] as String,
      services: (json['services'] as List?)
              ?.map((service) => ServiceItem.fromJson(service))
              .toList() ??
          [],
      parts: (json['parts'] as List?)
              ?.map((part) => WorkOrderPart.fromJson(part))
              .toList() ??
          [],
      laborCost: (json['laborCost'] as num?)?.toDouble() ?? 0.0,
      partsCost: (json['partsCost'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      technicianId: json['technicianId'] as String?,
      notes: json['notes'] as String?,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      paymentStatus: PaymentStatus.values.byName(json['paymentStatus'] ?? 'pending'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'vehicleId': vehicleId,
      'createdDate': createdDate.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'status': status.name,
      'priority': priority.name,
      'description': description,
      'services': services.map((service) => service.toJson()).toList(),
      'parts': parts.map((part) => part.toJson()).toList(),
      'laborCost': laborCost,
      'partsCost': partsCost,
      'totalCost': totalCost,
      'technicianId': technicianId,
      'notes': notes,
      'imageUrls': imageUrls,
      'paymentStatus': paymentStatus.name,
    };
  }

  WorkOrder copyWith({
    String? id,
    String? customerId,
    String? vehicleId,
    DateTime? createdDate,
    DateTime? scheduledDate,
    DateTime? completedDate,
    WorkOrderStatus? status,
    WorkOrderPriority? priority,
    String? description,
    List<ServiceItem>? services,
    List<WorkOrderPart>? parts,
    double? laborCost,
    double? partsCost,
    double? totalCost,
    String? technicianId,
    String? notes,
    List<String>? imageUrls,
    PaymentStatus? paymentStatus,
  }) {
    return WorkOrder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      vehicleId: vehicleId ?? this.vehicleId,
      createdDate: createdDate ?? this.createdDate,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      services: services ?? this.services,
      parts: parts ?? this.parts,
      laborCost: laborCost ?? this.laborCost,
      partsCost: partsCost ?? this.partsCost,
      totalCost: totalCost ?? this.totalCost,
      technicianId: technicianId ?? this.technicianId,
      notes: notes ?? this.notes,
      imageUrls: imageUrls ?? this.imageUrls,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  /// Calculate estimated duration based on services
  Duration get estimatedDuration {
    final totalMinutes = services.fold(0, (sum, service) => sum + service.estimatedDurationMinutes);
    return Duration(minutes: totalMinutes);
  }

  /// Check if work order is overdue
  bool get isOverdue {
    if (scheduledDate == null || status == WorkOrderStatus.completed) return false;
    return DateTime.now().isAfter(scheduledDate!);
  }

  /// Get progress percentage
  double get progressPercentage {
    switch (status) {
      case WorkOrderStatus.created:
        return 0.0;
      case WorkOrderStatus.pending:
        return 0.1;
      case WorkOrderStatus.inProgress:
        return 0.5;
      case WorkOrderStatus.completed:
        return 1.0;
      case WorkOrderStatus.cancelled:
        return 0.0;
      case WorkOrderStatus.onHold:
        return 0.3;
    }
  }

  /// Calculate subtotal (labor + parts)
  double get subtotal => laborCost + partsCost;

  /// Calculate tax amount
  double getTaxAmount(double taxRate) => subtotal * taxRate;

  /// Calculate total with tax
  double getTotalWithTax(double taxRate) => subtotal + getTaxAmount(taxRate);
}

class ServiceItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final int estimatedDurationMinutes;
  final ServiceCategory category;
  final bool isCompleted;
  final String? technicianId;
  final DateTime? startTime;
  final DateTime? endTime;

  const ServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.estimatedDurationMinutes,
    required this.category,
    this.isCompleted = false,
    this.technicianId,
    this.startTime,
    this.endTime,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int,
      category: ServiceCategory.values.byName(json['category']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      technicianId: json['technicianId'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'category': category.name,
      'isCompleted': isCompleted,
      'technicianId': technicianId,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  ServiceItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? estimatedDurationMinutes,
    ServiceCategory? category,
    bool? isCompleted,
    String? technicianId,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      technicianId: technicianId ?? this.technicianId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  /// Get actual duration if both start and end times are available
  Duration? get actualDuration {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!);
  }
}

class WorkOrderPart {
  final String id;
  final String partNumber;
  final String name;
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? supplierId;
  final PartStatus status;

  const WorkOrderPart({
    required this.id,
    required this.partNumber,
    required this.name,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.supplierId,
    this.status = PartStatus.pending,
  });

  factory WorkOrderPart.fromJson(Map<String, dynamic> json) {
    return WorkOrderPart(
      id: json['id'] as String,
      partNumber: json['partNumber'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      supplierId: json['supplierId'] as String?,
      status: PartStatus.values.byName(json['status'] ?? 'pending'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partNumber': partNumber,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'supplierId': supplierId,
      'status': status.name,
    };
  }

  WorkOrderPart copyWith({
    String? id,
    String? partNumber,
    String? name,
    String? description,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? supplierId,
    PartStatus? status,
  }) {
    return WorkOrderPart(
      id: id ?? this.id,
      partNumber: partNumber ?? this.partNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      supplierId: supplierId ?? this.supplierId,
      status: status ?? this.status,
    );
  }
}

enum WorkOrderStatus {
  created,
  pending,
  inProgress,
  completed,
  cancelled,
  onHold,
}

enum WorkOrderPriority {
  low,
  normal,
  high,
  urgent,
}

enum PaymentStatus {
  pending,
  partial,
  paid,
  refunded,
}

enum ServiceCategory {
  maintenance,
  repair,
  diagnostic,
  inspection,
  performance,
  bodywork,
  electrical,
  ac,
}

enum PartStatus {
  pending,
  ordered,
  received,
  installed,
  backordered,
}

// Extension methods for better enum usage
extension WorkOrderStatusExtension on WorkOrderStatus {
  String get displayName {
    switch (this) {
      case WorkOrderStatus.created:
        return 'Created';
      case WorkOrderStatus.pending:
        return 'Pending';
      case WorkOrderStatus.inProgress:
        return 'In Progress';
      case WorkOrderStatus.completed:
        return 'Completed';
      case WorkOrderStatus.cancelled:
        return 'Cancelled';
      case WorkOrderStatus.onHold:
        return 'On Hold';
    }
  }

  bool get isActive => this == WorkOrderStatus.pending || this == WorkOrderStatus.inProgress;
  bool get isFinished => this == WorkOrderStatus.completed || this == WorkOrderStatus.cancelled;
}

extension WorkOrderPriorityExtension on WorkOrderPriority {
  String get displayName {
    switch (this) {
      case WorkOrderPriority.low:
        return 'Low';
      case WorkOrderPriority.normal:
        return 'Normal';
      case WorkOrderPriority.high:
        return 'High';
      case WorkOrderPriority.urgent:
        return 'Urgent';
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.partial:
        return 'Partial';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  bool get isPaid => this == PaymentStatus.paid;
}

extension ServiceCategoryExtension on ServiceCategory {
  String get displayName {
    switch (this) {
      case ServiceCategory.maintenance:
        return 'Maintenance';
      case ServiceCategory.repair:
        return 'Repair';
      case ServiceCategory.diagnostic:
        return 'Diagnostic';
      case ServiceCategory.inspection:
        return 'Inspection';
      case ServiceCategory.performance:
        return 'Performance';
      case ServiceCategory.bodywork:
        return 'Body Work';
      case ServiceCategory.electrical:
        return 'Electrical';
      case ServiceCategory.ac:
        return 'A/C';
    }
  }
}