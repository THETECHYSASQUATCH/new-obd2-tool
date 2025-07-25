import 'dart:convert';

class EcuInfo {
  final String id;
  final String name;
  final String address;
  final String protocol;
  final String? version;
  final String? partNumber;
  final String? softwareVersion;
  final Map<String, dynamic> capabilities;
  final bool isSupported;
  final List<String> supportedOperations;

  const EcuInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.protocol,
    this.version,
    this.partNumber,
    this.softwareVersion,
    this.capabilities = const {},
    this.isSupported = true,
    this.supportedOperations = const [],
  });

  factory EcuInfo.fromJson(Map<String, dynamic> json) {
    return EcuInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      protocol: json['protocol'] as String,
      version: json['version'] as String?,
      partNumber: json['partNumber'] as String?,
      softwareVersion: json['softwareVersion'] as String?,
      capabilities: json['capabilities'] as Map<String, dynamic>? ?? {},
      isSupported: json['isSupported'] as bool? ?? true,
      supportedOperations: List<String>.from(json['supportedOperations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'protocol': protocol,
      'version': version,
      'partNumber': partNumber,
      'softwareVersion': softwareVersion,
      'capabilities': capabilities,
      'isSupported': isSupported,
      'supportedOperations': supportedOperations,
    };
  }
}

class ProgrammingSession {
  final String id;
  final String ecuId;
  final DateTime startTime;
  final DateTime? endTime;
  final ProgrammingStatus status;
  final double progress;
  final String? currentOperation;
  final List<ProgrammingStep> steps;
  final Map<String, dynamic> results;
  final String? errorMessage;

  const ProgrammingSession({
    required this.id,
    required this.ecuId,
    required this.startTime,
    this.endTime,
    required this.status,
    this.progress = 0.0,
    this.currentOperation,
    this.steps = const [],
    this.results = const {},
    this.errorMessage,
  });

  factory ProgrammingSession.fromJson(Map<String, dynamic> json) {
    return ProgrammingSession(
      id: json['id'] as String,
      ecuId: json['ecuId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      status: ProgrammingStatus.values.byName(json['status']),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      currentOperation: json['currentOperation'] as String?,
      steps: (json['steps'] as List<dynamic>?)
          ?.map((s) => ProgrammingStep.fromJson(s as Map<String, dynamic>))
          .toList() ?? [],
      results: json['results'] as Map<String, dynamic>? ?? {},
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ecuId': ecuId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status.name,
      'progress': progress,
      'currentOperation': currentOperation,
      'steps': steps.map((s) => s.toJson()).toList(),
      'results': results,
      'errorMessage': errorMessage,
    };
  }

  ProgrammingSession copyWith({
    String? id,
    String? ecuId,
    DateTime? startTime,
    DateTime? endTime,
    ProgrammingStatus? status,
    double? progress,
    String? currentOperation,
    List<ProgrammingStep>? steps,
    Map<String, dynamic>? results,
    String? errorMessage,
  }) {
    return ProgrammingSession(
      id: id ?? this.id,
      ecuId: ecuId ?? this.ecuId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentOperation: currentOperation ?? this.currentOperation,
      steps: steps ?? this.steps,
      results: results ?? this.results,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  bool get isActive => status == ProgrammingStatus.inProgress;
  bool get isCompleted => status == ProgrammingStatus.completed;
  bool get hasError => status == ProgrammingStatus.error;
}

class ProgrammingStep {
  final String id;
  final String name;
  final String description;
  final ProgrammingStepStatus status;
  final double progress;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  const ProgrammingStep({
    required this.id,
    required this.name,
    required this.description,
    this.status = ProgrammingStepStatus.pending,
    this.progress = 0.0,
    this.startTime,
    this.endTime,
    this.errorMessage,
    this.metadata = const {},
  });

  factory ProgrammingStep.fromJson(Map<String, dynamic> json) {
    return ProgrammingStep(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: ProgrammingStepStatus.values.byName(json['status'] ?? 'pending'),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      startTime: json['startTime'] != null 
          ? DateTime.parse(json['startTime'] as String) 
          : null,
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'progress': progress,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }
}

enum ProgrammingStatus {
  pending,
  inProgress,
  completed,
  error,
  cancelled,
}

enum ProgrammingStepStatus {
  pending,
  inProgress,
  completed,
  error,
  skipped,
}

enum ProgrammingOperation {
  read,
  write,
  erase,
  verify,
  clone,
  backup,
  restore,
}

extension ProgrammingStatusExtension on ProgrammingStatus {
  String get displayName {
    switch (this) {
      case ProgrammingStatus.pending:
        return 'Pending';
      case ProgrammingStatus.inProgress:
        return 'In Progress';
      case ProgrammingStatus.completed:
        return 'Completed';
      case ProgrammingStatus.error:
        return 'Error';
      case ProgrammingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

extension ProgrammingStepStatusExtension on ProgrammingStepStatus {
  String get displayName {
    switch (this) {
      case ProgrammingStepStatus.pending:
        return 'Pending';
      case ProgrammingStepStatus.inProgress:
        return 'In Progress';
      case ProgrammingStepStatus.completed:
        return 'Completed';
      case ProgrammingStepStatus.error:
        return 'Error';
      case ProgrammingStepStatus.skipped:
        return 'Skipped';
    }
  }
}