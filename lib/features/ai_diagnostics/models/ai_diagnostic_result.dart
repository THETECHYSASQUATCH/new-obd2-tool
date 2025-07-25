import 'dart:convert';

class AIDiagnosticResult {
  final String id;
  final DateTime timestamp;
  final String vehicleId;
  final Map<String, SystemAnalysis> systemAnalyses;
  final List<AIInsight> insights;
  final List<AIRecommendation> recommendations;
  final double overallHealthScore;
  final RiskLevel riskLevel;

  const AIDiagnosticResult({
    required this.id,
    required this.timestamp,
    required this.vehicleId,
    required this.systemAnalyses,
    required this.insights,
    required this.recommendations,
    required this.overallHealthScore,
    required this.riskLevel,
  });

  factory AIDiagnosticResult.fromJson(Map<String, dynamic> json) {
    return AIDiagnosticResult(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      vehicleId: json['vehicleId'] as String,
      systemAnalyses: (json['systemAnalyses'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, SystemAnalysis.fromJson(value))),
      insights: (json['insights'] as List)
          .map((insight) => AIInsight.fromJson(insight))
          .toList(),
      recommendations: (json['recommendations'] as List)
          .map((rec) => AIRecommendation.fromJson(rec))
          .toList(),
      overallHealthScore: (json['overallHealthScore'] as num).toDouble(),
      riskLevel: RiskLevel.values.byName(json['riskLevel']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'vehicleId': vehicleId,
      'systemAnalyses': systemAnalyses.map((key, value) => MapEntry(key, value.toJson())),
      'insights': insights.map((insight) => insight.toJson()).toList(),
      'recommendations': recommendations.map((rec) => rec.toJson()).toList(),
      'overallHealthScore': overallHealthScore,
      'riskLevel': riskLevel.name,
    };
  }

  AIDiagnosticResult copyWith({
    String? id,
    DateTime? timestamp,
    String? vehicleId,
    Map<String, SystemAnalysis>? systemAnalyses,
    List<AIInsight>? insights,
    List<AIRecommendation>? recommendations,
    double? overallHealthScore,
    RiskLevel? riskLevel,
  }) {
    return AIDiagnosticResult(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      vehicleId: vehicleId ?? this.vehicleId,
      systemAnalyses: systemAnalyses ?? this.systemAnalyses,
      insights: insights ?? this.insights,
      recommendations: recommendations ?? this.recommendations,
      overallHealthScore: overallHealthScore ?? this.overallHealthScore,
      riskLevel: riskLevel ?? this.riskLevel,
    );
  }
}

class SystemAnalysis {
  final String systemName;
  final SystemStatus status;
  final double healthScore;
  final String description;
  final List<String> anomalies;
  final Map<String, double> parameters;

  const SystemAnalysis({
    required this.systemName,
    required this.status,
    required this.healthScore,
    required this.description,
    required this.anomalies,
    required this.parameters,
  });

  factory SystemAnalysis.fromJson(Map<String, dynamic> json) {
    return SystemAnalysis(
      systemName: json['systemName'] as String,
      status: SystemStatus.values.byName(json['status']),
      healthScore: (json['healthScore'] as num).toDouble(),
      description: json['description'] as String,
      anomalies: List<String>.from(json['anomalies']),
      parameters: Map<String, double>.from(json['parameters']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'systemName': systemName,
      'status': status.name,
      'healthScore': healthScore,
      'description': description,
      'anomalies': anomalies,
      'parameters': parameters,
    };
  }
}

class AIInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final InsightSeverity severity;
  final Map<String, dynamic> data;
  final double confidence;

  const AIInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.data,
    required this.confidence,
  });

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    return AIInsight(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: InsightType.values.byName(json['type']),
      severity: InsightSeverity.values.byName(json['severity']),
      data: json['data'] as Map<String, dynamic>,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'severity': severity.name,
      'data': data,
      'confidence': confidence,
    };
  }
}

class AIRecommendation {
  final String id;
  final String title;
  final String description;
  final RecommendationType type;
  final Priority priority;
  final List<String> actions;
  final double estimatedCost;
  final Duration estimatedTime;

  const AIRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.actions,
    required this.estimatedCost,
    required this.estimatedTime,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: RecommendationType.values.byName(json['type']),
      priority: Priority.values.byName(json['priority']),
      actions: List<String>.from(json['actions']),
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      estimatedTime: Duration(minutes: json['estimatedTimeMinutes'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'priority': priority.name,
      'actions': actions,
      'estimatedCost': estimatedCost,
      'estimatedTimeMinutes': estimatedTime.inMinutes,
    };
  }
}

enum SystemStatus {
  optimal,
  good,
  warning,
  critical,
  unknown,
}

enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

enum InsightType {
  performance,
  efficiency,
  maintenance,
  safety,
  cost,
  trend,
}

enum InsightSeverity {
  info,
  warning,
  error,
  critical,
}

enum RecommendationType {
  immediate,
  scheduled,
  preventive,
  optimization,
  inspection,
}

enum Priority {
  low,
  medium,
  high,
  urgent,
}

// Extension methods for better enum usage
extension SystemStatusExtension on SystemStatus {
  String get displayName {
    switch (this) {
      case SystemStatus.optimal:
        return 'Optimal';
      case SystemStatus.good:
        return 'Good';
      case SystemStatus.warning:
        return 'Warning';
      case SystemStatus.critical:
        return 'Critical';
      case SystemStatus.unknown:
        return 'Unknown';
    }
  }

  bool get isHealthy => this == SystemStatus.optimal || this == SystemStatus.good;
  bool get needsAttention => this == SystemStatus.warning || this == SystemStatus.critical;
}

extension RiskLevelExtension on RiskLevel {
  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
      case RiskLevel.critical:
        return 'Critical';
    }
  }
}

extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Low Priority';
      case Priority.medium:
        return 'Medium Priority';
      case Priority.high:
        return 'High Priority';
      case Priority.urgent:
        return 'Urgent';
    }
  }
}