import 'package:flutter_test/flutter_test.dart';
import 'package:new_obd2_tool/features/ai_diagnostics/models/ai_diagnostic_result.dart';

void main() {
  group('AI Diagnostic Result', () {
    test('should create AI diagnostic result with valid data', () {
      final result = AIDiagnosticResult(
        id: 'test-id',
        timestamp: DateTime.now(),
        vehicleId: 'vehicle-123',
        systemAnalyses: {
          'Engine': SystemAnalysis(
            systemName: 'Engine Performance',
            status: SystemStatus.optimal,
            healthScore: 0.95,
            description: 'Engine is performing optimally',
            anomalies: [],
            parameters: {'efficiency': 0.95},
          ),
        },
        insights: [],
        recommendations: [],
        overallHealthScore: 0.95,
        riskLevel: RiskLevel.low,
      );

      expect(result.id, equals('test-id'));
      expect(result.vehicleId, equals('vehicle-123'));
      expect(result.overallHealthScore, equals(0.95));
      expect(result.riskLevel, equals(RiskLevel.low));
      expect(result.systemAnalyses.length, equals(1));
    });

    test('should serialize and deserialize correctly', () {
      final originalResult = AIDiagnosticResult(
        id: 'test-id',
        timestamp: DateTime.parse('2024-01-01T12:00:00Z'),
        vehicleId: 'vehicle-123',
        systemAnalyses: {},
        insights: [],
        recommendations: [],
        overallHealthScore: 0.85,
        riskLevel: RiskLevel.medium,
      );

      final json = originalResult.toJson();
      final deserializedResult = AIDiagnosticResult.fromJson(json);

      expect(deserializedResult.id, equals(originalResult.id));
      expect(deserializedResult.vehicleId, equals(originalResult.vehicleId));
      expect(deserializedResult.overallHealthScore, equals(originalResult.overallHealthScore));
      expect(deserializedResult.riskLevel, equals(originalResult.riskLevel));
    });

    test('should create system analysis with correct status', () {
      final systemAnalysis = SystemAnalysis(
        systemName: 'Transmission',
        status: SystemStatus.warning,
        healthScore: 0.65,
        description: 'Minor transmission issues detected',
        anomalies: ['Shift delay detected'],
        parameters: {'temperature': 200.0, 'pressure': 45.0},
      );

      expect(systemAnalysis.status.isHealthy, isFalse);
      expect(systemAnalysis.status.needsAttention, isTrue);
      expect(systemAnalysis.anomalies.length, equals(1));
      expect(systemAnalysis.parameters['temperature'], equals(200.0));
    });

    test('should create AI insight with correct data', () {
      final insight = AIInsight(
        id: 'insight-1',
        title: 'Fuel Efficiency',
        description: 'Improved fuel efficiency detected',
        type: InsightType.efficiency,
        severity: InsightSeverity.info,
        data: {'improvement': 15.5},
        confidence: 0.92,
      );

      expect(insight.title, equals('Fuel Efficiency'));
      expect(insight.type, equals(InsightType.efficiency));
      expect(insight.confidence, equals(0.92));
      expect(insight.data['improvement'], equals(15.5));
    });

    test('should create AI recommendation with correct priority', () {
      final recommendation = AIRecommendation(
        id: 'rec-1',
        title: 'Check Air Filter',
        description: 'Air filter replacement recommended',
        type: RecommendationType.preventive,
        priority: Priority.medium,
        actions: ['Inspect filter', 'Replace if needed'],
        estimatedCost: 25.99,
        estimatedTime: Duration(minutes: 30),
      );

      expect(recommendation.priority.displayName, equals('Medium Priority'));
      expect(recommendation.actions.length, equals(2));
      expect(recommendation.estimatedCost, equals(25.99));
      expect(recommendation.estimatedTime.inMinutes, equals(30));
    });
  });

  group('System Status', () {
    test('should correctly identify healthy systems', () {
      expect(SystemStatus.optimal.isHealthy, isTrue);
      expect(SystemStatus.good.isHealthy, isTrue);
      expect(SystemStatus.warning.isHealthy, isFalse);
      expect(SystemStatus.critical.isHealthy, isFalse);
    });

    test('should correctly identify systems needing attention', () {
      expect(SystemStatus.optimal.needsAttention, isFalse);
      expect(SystemStatus.good.needsAttention, isFalse);
      expect(SystemStatus.warning.needsAttention, isTrue);
      expect(SystemStatus.critical.needsAttention, isTrue);
    });
  });

  group('Risk Level', () {
    test('should have correct display names', () {
      expect(RiskLevel.low.displayName, equals('Low'));
      expect(RiskLevel.medium.displayName, equals('Medium'));
      expect(RiskLevel.high.displayName, equals('High'));
      expect(RiskLevel.critical.displayName, equals('Critical'));
    });
  });

  group('Priority', () {
    test('should have correct display names', () {
      expect(Priority.low.displayName, equals('Low Priority'));
      expect(Priority.medium.displayName, equals('Medium Priority'));
      expect(Priority.high.displayName, equals('High Priority'));
      expect(Priority.urgent.displayName, equals('Urgent'));
    });
  });
}