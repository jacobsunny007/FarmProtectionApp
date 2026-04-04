class Detection {
  final String id;
  final String animal;
  final double confidence;
  final String deviceId;
  final String imageUrl;
  final bool sensorTriggered;
  final String detectionSource;
  final String timestamp;
  final String riskLevel;
  final String status;
  final String? notes;
  final String? officerNote;

  Detection({
    required this.id,
    required this.animal,
    required this.confidence,
    required this.deviceId,
    required this.imageUrl,
    required this.sensorTriggered,
    required this.detectionSource,
    required this.timestamp,
    this.riskLevel = 'medium',
    this.status = 'Pending',
    this.notes = '',
    this.officerNote = '',
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      id: json['_id'] ?? json['id'] ?? '',
      animal: json['animal'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      deviceId: json['deviceId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      sensorTriggered: json['sensorTriggered'] ?? false,
      detectionSource: json['detectionSource'] ?? '',
      timestamp: json['timestamp'] ?? '',
      riskLevel: json['riskLevel'] ?? 'medium',
      status: json['status'] ?? 'Pending',
      notes: json['notes'] ?? '',
      officerNote: json['officerNote'] ?? '',
    );
  }
}