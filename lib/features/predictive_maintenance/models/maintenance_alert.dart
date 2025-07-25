import 'dart:convert';

class MaintenanceAlert {
  final String id;
  final DateTime timestamp;
  final String vehicleId;
  final String title;
  final String description;
  final MaintenancePriority priority;
  final MaintenanceType type;
  final DateTime? dueDate;
  final int? dueMileage;
  final bool isActive;
  final bool isAcknowledged;
  final Map<String, dynamic> metadata;

  const MaintenanceAlert({
    required this.id,
    required this.timestamp,
    required this.vehicleId,
    required this.title,
    required this.description,
    required this.priority,
    required this.type,
    this.dueDate,
    this.dueMileage,
    this.isActive = true,
    this.isAcknowledged = false,
    this.metadata = const {},
  });

  factory MaintenanceAlert.fromJson(Map<String, dynamic> json) {
    return MaintenanceAlert(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      vehicleId: json['vehicleId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: MaintenancePriority.values.byName(json['priority']),
      type: MaintenanceType.values.byName(json['type']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      dueMileage: json['dueMileage'] as int?,
      isActive: json['isActive'] as bool? ?? true,
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'vehicleId': vehicleId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'type': type.name,
      'dueDate': dueDate?.toIso8601String(),
      'dueMileage': dueMileage,
      'isActive': isActive,
      'isAcknowledged': isAcknowledged,
      'metadata': metadata,
    };
  }

  MaintenanceAlert copyWith({
    String? id,
    DateTime? timestamp,
    String? vehicleId,
    String? title,
    String? description,
    MaintenancePriority? priority,
    MaintenanceType? type,
    DateTime? dueDate,
    int? dueMileage,
    bool? isActive,
    bool? isAcknowledged,
    Map<String, dynamic>? metadata,
  }) {
    return MaintenanceAlert(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      dueMileage: dueMileage ?? this.dueMileage,
      isActive: isActive ?? this.isActive,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get days until due date
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final difference = dueDate!.difference(now);
    return difference.inDays;
  }

  /// Check if alert is overdue
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Get urgency level based on priority and time remaining
  AlertUrgency get urgency {
    if (isOverdue) return AlertUrgency.critical;
    
    final daysLeft = daysUntilDue;
    if (daysLeft == null) return AlertUrgency.low;

    switch (priority) {
      case MaintenancePriority.high:
        if (daysLeft <= 3) return AlertUrgency.critical;
        if (daysLeft <= 7) return AlertUrgency.high;
        return AlertUrgency.medium;
      case MaintenancePriority.medium:
        if (daysLeft <= 7) return AlertUrgency.high;
        if (daysLeft <= 14) return AlertUrgency.medium;
        return AlertUrgency.low;
      case MaintenancePriority.low:
        if (daysLeft <= 14) return AlertUrgency.medium;
        return AlertUrgency.low;
    }
  }
}

class MaintenanceSchedule {
  final String id;
  final String vehicleId;
  final String serviceType;
  final String description;
  final MaintenanceInterval interval;
  final DateTime? lastServiceDate;
  final int? lastServiceMileage;
  final DateTime? nextDueDate;
  final int? nextDueMileage;
  final bool isActive;
  final Map<String, dynamic> serviceDetails;

  const MaintenanceSchedule({
    required this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.description,
    required this.interval,
    this.lastServiceDate,
    this.lastServiceMileage,
    this.nextDueDate,
    this.nextDueMileage,
    this.isActive = true,
    this.serviceDetails = const {},
  });

  factory MaintenanceSchedule.fromJson(Map<String, dynamic> json) {
    return MaintenanceSchedule(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      serviceType: json['serviceType'] as String,
      description: json['description'] as String,
      interval: MaintenanceInterval.fromJson(json['interval']),
      lastServiceDate: json['lastServiceDate'] != null
          ? DateTime.parse(json['lastServiceDate'])
          : null,
      lastServiceMileage: json['lastServiceMileage'] as int?,
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'])
          : null,
      nextDueMileage: json['nextDueMileage'] as int?,
      isActive: json['isActive'] as bool? ?? true,
      serviceDetails: json['serviceDetails'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'serviceType': serviceType,
      'description': description,
      'interval': interval.toJson(),
      'lastServiceDate': lastServiceDate?.toIso8601String(),
      'lastServiceMileage': lastServiceMileage,
      'nextDueDate': nextDueDate?.toIso8601String(),
      'nextDueMileage': nextDueMileage,
      'isActive': isActive,
      'serviceDetails': serviceDetails,
    };
  }

  MaintenanceSchedule copyWith({
    String? id,
    String? vehicleId,
    String? serviceType,
    String? description,
    MaintenanceInterval? interval,
    DateTime? lastServiceDate,
    int? lastServiceMileage,
    DateTime? nextDueDate,
    int? nextDueMileage,
    bool? isActive,
    Map<String, dynamic>? serviceDetails,
  }) {
    return MaintenanceSchedule(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      interval: interval ?? this.interval,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      lastServiceMileage: lastServiceMileage ?? this.lastServiceMileage,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      nextDueMileage: nextDueMileage ?? this.nextDueMileage,
      isActive: isActive ?? this.isActive,
      serviceDetails: serviceDetails ?? this.serviceDetails,
    );
  }

  /// Calculate next service date based on interval
  DateTime? calculateNextServiceDate(DateTime currentDate) {
    if (lastServiceDate == null) return null;
    
    if (interval.months != null) {
      return DateTime(
        lastServiceDate!.year,
        lastServiceDate!.month + interval.months!,
        lastServiceDate!.day,
      );
    }
    
    return null;
  }

  /// Calculate next service mileage based on interval
  int? calculateNextServiceMileage(int currentMileage) {
    if (lastServiceMileage == null || interval.miles == null) return null;
    return lastServiceMileage! + interval.miles!;
  }

  /// Check if service is due
  bool isDue(DateTime currentDate, int currentMileage) {
    final dueDateCheck = nextDueDate != null && currentDate.isAfter(nextDueDate!);
    final dueMileageCheck = nextDueMileage != null && currentMileage >= nextDueMileage!;
    
    return dueDateCheck || dueMileageCheck;
  }

  /// Get service status
  ServiceStatus getStatus(DateTime currentDate, int currentMileage) {
    if (!isActive) return ServiceStatus.inactive;
    if (isDue(currentDate, currentMileage)) return ServiceStatus.due;
    
    // Check if approaching due date/mileage
    if (nextDueDate != null) {
      final daysUntilDue = nextDueDate!.difference(currentDate).inDays;
      if (daysUntilDue <= 7) return ServiceStatus.approaching;
    }
    
    if (nextDueMileage != null) {
      final milesUntilDue = nextDueMileage! - currentMileage;
      if (milesUntilDue <= 500) return ServiceStatus.approaching;
    }
    
    return ServiceStatus.scheduled;
  }
}

class MaintenanceInterval {
  final int? miles;
  final int? months;
  final int? hours; // For engine hours
  final IntervalType type;

  const MaintenanceInterval({
    this.miles,
    this.months,
    this.hours,
    required this.type,
  });

  factory MaintenanceInterval.fromJson(Map<String, dynamic> json) {
    return MaintenanceInterval(
      miles: json['miles'] as int?,
      months: json['months'] as int?,
      hours: json['hours'] as int?,
      type: IntervalType.values.byName(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'miles': miles,
      'months': months,
      'hours': hours,
      'type': type.name,
    };
  }

  String get displayText {
    final parts = <String>[];
    
    if (miles != null) {
      parts.add('${miles!.toStringAsFixed(0)} miles');
    }
    
    if (months != null) {
      parts.add('$months months');
    }
    
    if (hours != null) {
      parts.add('$hours hours');
    }
    
    return parts.join(' or ');
  }
}

class MaintenancePrediction {
  final String id;
  final String vehicleId;
  final String systemName;
  final String prediction;
  final double confidence;
  final DateTime predictedDate;
  final int? predictedMileage;
  final List<String> indicators;
  final Map<String, dynamic> analysisData;

  const MaintenancePrediction({
    required this.id,
    required this.vehicleId,
    required this.systemName,
    required this.prediction,
    required this.confidence,
    required this.predictedDate,
    this.predictedMileage,
    this.indicators = const [],
    this.analysisData = const {},
  });

  factory MaintenancePrediction.fromJson(Map<String, dynamic> json) {
    return MaintenancePrediction(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      systemName: json['systemName'] as String,
      prediction: json['prediction'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      predictedDate: DateTime.parse(json['predictedDate']),
      predictedMileage: json['predictedMileage'] as int?,
      indicators: List<String>.from(json['indicators'] ?? []),
      analysisData: json['analysisData'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'systemName': systemName,
      'prediction': prediction,
      'confidence': confidence,
      'predictedDate': predictedDate.toIso8601String(),
      'predictedMileage': predictedMileage,
      'indicators': indicators,
      'analysisData': analysisData,
    };
  }

  /// Get confidence level category
  ConfidenceLevel get confidenceLevel {
    if (confidence >= 0.9) return ConfidenceLevel.high;
    if (confidence >= 0.7) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }
}

enum MaintenancePriority {
  low,
  medium,
  high,
}

enum MaintenanceType {
  scheduled,
  predictive,
  emergency,
  inspection,
  repair,
  replacement,
}

enum AlertUrgency {
  low,
  medium,
  high,
  critical,
}

enum IntervalType {
  mileage,
  time,
  hybrid, // Both mileage and time
  condition, // Based on condition monitoring
}

enum ServiceStatus {
  scheduled,
  approaching,
  due,
  overdue,
  completed,
  inactive,
}

enum ConfidenceLevel {
  low,
  medium,
  high,
}

// Extension methods for better enum usage
extension MaintenancePriorityExtension on MaintenancePriority {
  String get displayName {
    switch (this) {
      case MaintenancePriority.low:
        return 'Low';
      case MaintenancePriority.medium:
        return 'Medium';
      case MaintenancePriority.high:
        return 'High';
    }
  }
}

extension AlertUrgencyExtension on AlertUrgency {
  String get displayName {
    switch (this) {
      case AlertUrgency.low:
        return 'Low';
      case AlertUrgency.medium:
        return 'Medium';
      case AlertUrgency.high:
        return 'High';
      case AlertUrgency.critical:
        return 'Critical';
    }
  }
}

extension ServiceStatusExtension on ServiceStatus {
  String get displayName {
    switch (this) {
      case ServiceStatus.scheduled:
        return 'Scheduled';
      case ServiceStatus.approaching:
        return 'Approaching';
      case ServiceStatus.due:
        return 'Due';
      case ServiceStatus.overdue:
        return 'Overdue';
      case ServiceStatus.completed:
        return 'Completed';
      case ServiceStatus.inactive:
        return 'Inactive';
    }
  }
}