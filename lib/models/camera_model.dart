class CameraDevice {
  final String id;
  final String cameraId;
  final String name;
  final String status;
  final String streamUrl;
  final String location;

  CameraDevice({
    required this.id,
    required this.cameraId,
    required this.name,
    required this.status,
    required this.streamUrl,
    required this.location,
  });

  bool get isConnected => status == "connected";

  factory CameraDevice.fromJson(Map<String, dynamic> json) {
    return CameraDevice(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      cameraId: json['cameraId'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 'disconnected',
      streamUrl: json['streamUrl'] ?? '',
      location: json['location'] ?? '',
    );
  }
}
