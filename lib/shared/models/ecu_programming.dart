import 'package:json_annotation/json_annotation.dart';

part 'ecu_programming.g.dart';

enum EcuType {
  engine,
  transmission,
  abs,
  airbag,
  body,
  climate,
  infotainment,
  hybrid,
  other
}

enum ProgrammingMode {
  flash,
  calibration,
  adaptation,
  coding,
  configuration
}

enum ProgrammingStatus {
  idle,
  connecting,
  authenticating,
  reading,
  erasing,
  programming,
  verifying,
  completed,
  error,
  cancelled
}

@JsonSerializable()
class EcuInfo {
  final String id;
  final String name;
  final EcuType type;
  final String address;
  final String? partNumber;
  final String? softwareVersion;
  final String? hardwareVersion;
  final bool programmingSupported;
  final List<ProgrammingMode> supportedModes;

  const EcuInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    this.partNumber,
    this.softwareVersion,
    this.hardwareVersion,
    this.programmingSupported = false,
    this.supportedModes = const [],
  });

  factory EcuInfo.fromJson(Map<String, dynamic> json) => 
      _$EcuInfoFromJson(json);

  Map<String, dynamic> toJson() => _$EcuInfoToJson(this);

  @override
  String toString() => '$name ($address)';
}

@JsonSerializable()
class ProgrammingSession {
  final String id;
  final String ecuId;
  final ProgrammingMode mode;
  final DateTime startTime;
  final DateTime? endTime;
  final ProgrammingStatus status;
  final double progress;
  final String? filePath;
  final String? backupPath;
  final String? errorMessage;
  final List<String> log;

  const ProgrammingSession({
    required this.id,
    required this.ecuId,
    required this.mode,
    required this.startTime,
    this.endTime,
    required this.status,
    this.progress = 0.0,
    this.filePath,
    this.backupPath,
    this.errorMessage,
    this.log = const [],
  });

  factory ProgrammingSession.fromJson(Map<String, dynamic> json) => 
      _$ProgrammingSessionFromJson(json);

  Map<String, dynamic> toJson() => _$ProgrammingSessionToJson(this);

  ProgrammingSession copyWith({
    ProgrammingStatus? status,
    double? progress,
    String? errorMessage,
    DateTime? endTime,
    String? backupPath,
    List<String>? log,
  }) {
    return ProgrammingSession(
      id: id,
      ecuId: ecuId,
      mode: mode,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      filePath: filePath,
      backupPath: backupPath ?? this.backupPath,
      errorMessage: errorMessage ?? this.errorMessage,
      log: log ?? this.log,
    );
  }

  bool get isActive => status != ProgrammingStatus.completed && 
                      status != ProgrammingStatus.error && 
                      status != ProgrammingStatus.cancelled;

  Duration? get duration => endTime?.difference(startTime);
}

@JsonSerializable()
class ProgrammingFile {
  final String path;
  final String name;
  final String checksum;
  final int size;
  final String? description;
  final String? version;
  final List<String> compatibleEcus;
  final DateTime createdAt;

  const ProgrammingFile({
    required this.path,
    required this.name,
    required this.checksum,
    required this.size,
    this.description,
    this.version,
    this.compatibleEcus = const [],
    required this.createdAt,
  });

  factory ProgrammingFile.fromJson(Map<String, dynamic> json) => 
      _$ProgrammingFileFromJson(json);

  Map<String, dynamic> toJson() => _$ProgrammingFileToJson(this);

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

@JsonSerializable()
class SecurityAccess {
  final String seed;
  final String key;
  final DateTime timestamp;
  final bool isValid;

  const SecurityAccess({
    required this.seed,
    required this.key,
    required this.timestamp,
    required this.isValid,
  });

  factory SecurityAccess.fromJson(Map<String, dynamic> json) => 
      _$SecurityAccessFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityAccessToJson(this);

  bool get isExpired => DateTime.now().difference(timestamp).inMinutes > 30;
}