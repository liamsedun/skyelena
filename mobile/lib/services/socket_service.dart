import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants/app_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _eventController;
  bool _isConnected = false;

  Stream<Map<String, dynamic>>? get events => _eventController?.stream;
  bool get isConnected => _isConnected;

  void connect(String userId) {
    if (_isConnected) return;

    _eventController = StreamController<Map<String, dynamic>>.broadcast();

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('${AppConstants.wsUrl}?userId=$userId'),
      );

      _channel!.stream.listen(
        (data) {
          _isConnected = true;
          if (data is String) {
            try {
              final parsed = jsonDecode(data);
              _eventController?.add(parsed);
            } catch (_) {}
          }
        },
        onDone: () {
          _isConnected = false;
          _reconnect(userId);
        },
        onError: (error) {
          _isConnected = false;
          _reconnect(userId);
        },
      );

      _channel!.sink.add(jsonEncode({
        'event': 'join',
        'data': userId,
      }));
    } catch (e) {
      _isConnected = false;
    }
  }

  void _reconnect(String userId) {
    Future.delayed(const Duration(seconds: 5), () {
      connect(userId);
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    _eventController?.close();
  }
}
