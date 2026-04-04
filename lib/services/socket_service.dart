import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';

class SocketService {
  late IO.Socket socket;

  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Timer? _heartbeatTimer;

  // Callbacks for external listeners
  VoidCallback? onReconnect;
  VoidCallback? onDisconnect;

  void connect() {
    socket = IO.io(
      ApiConfig.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath("/socket.io/")
          .enableForceNew()
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(_maxReconnectAttempts)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(30000)
          .build(),
    );

    socket.onConnect((_) {
      debugPrint("SOCKET CONNECTED");
      _isConnected = true;
      _reconnectAttempts = 0;
      _startHeartbeat();
      onReconnect?.call();
    });

    socket.onDisconnect((_) {
      debugPrint("SOCKET DISCONNECTED");
      _isConnected = false;
      _stopHeartbeat();
      onDisconnect?.call();
    });

    socket.onReconnect((_) {
      debugPrint("SOCKET RECONNECTED");
      _isConnected = true;
      _reconnectAttempts = 0;
      _startHeartbeat();
      onReconnect?.call();
    });

    socket.onReconnectAttempt((attempt) {
      _reconnectAttempts = attempt is int ? attempt : 0;
      debugPrint("SOCKET RECONNECT ATTEMPT: $_reconnectAttempts");
    });

    socket.onConnectError((data) {
      debugPrint("SOCKET CONNECT ERROR: $data");
      _isConnected = false;
    });

    socket.onError((data) {
      debugPrint("SOCKET ERROR: $data");
    });
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 25),
      (_) {
        if (_isConnected) {
          socket.emit('ping');
        }
      },
    );
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void listen(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void off(String event) {
    socket.off(event);
  }

  void emit(String event, dynamic data) {
    if (_isConnected) {
      socket.emit(event, data);
    }
  }

  void disconnect() {
    _stopHeartbeat();
    socket.dispose();
    _isConnected = false;
  }
}