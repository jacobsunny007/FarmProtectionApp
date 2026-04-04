class AppNotification {
  final String id;
  final String deviceId;
  final String type;
  final String title;
  final String message;
  final String? detectionId;
  final bool read;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.title,
    required this.message,
    this.detectionId,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      deviceId: json['deviceId'] ?? '',
      type: json['type'] ?? 'detection',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      detectionId: json['detectionId']?.toString(),
      read: json['read'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
