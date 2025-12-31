import 'dart:async';
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_constants.dart';

class SocketService {
  IO.Socket? _socket;
  final _kdsUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get kdsUpdateStream =>
      _kdsUpdateController.stream;

  void connect() {
    if (_socket != null && _socket!.connected) return;

    // The backend is at http://localhost:2580/api, so socket should be at http://localhost:2580
    final socketUrl = ApiConstants.baseUrl.replaceFirst('/api', '');

    log('Connecting to socket at $socketUrl');

    _socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.onConnect((_) {
      log('Connected to socket');
    });

    _socket!.onDisconnect((_) {
      log('Disconnected from socket');
    });

    _socket!.on('kds_update', (data) {
      log('KDS update received: $data');
      _kdsUpdateController.add(Map<String, dynamic>.from(data));
    });

    _socket!.onConnectError((err) => log('Connect Error: $err'));
    _socket!.onError((err) => log('Error: $err'));

    _socket!.connect();
  }

  void joinRestaurant(String restaurantId) {
    if (_socket == null) {
      connect();
    }

    if (_socket!.connected) {
      log('Joining restaurant room: $restaurantId');
      _socket!.emit('join_restaurant', restaurantId);
    } else {
      log(
        'Socket not connected yet. Waiting for connect to join $restaurantId',
      );
      // Using off to avoid duplicate listeners if called multiple times before connect
      _socket!.off('connect');
      _socket!.onConnect((_) {
        log('Connected to socket, now joining restaurant room: $restaurantId');
        _socket!.emit('join_restaurant', restaurantId);
      });
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    log('Does meee');
    _kdsUpdateController.close();
    disconnect();
  }
}
