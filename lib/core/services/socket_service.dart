import 'dart:async';
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_constants.dart';

class SocketService {
  IO.Socket? _socket;
  final _kdsUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _groupCartUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _tableStatusUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _tableOrderUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _orderDeletedController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get kdsUpdateStream =>
      _kdsUpdateController.stream;
  Stream<Map<String, dynamic>> get tableStatusUpdateStream =>
      _tableStatusUpdateController.stream;
  Stream<Map<String, dynamic>> get tableOrderUpdateStream =>
      _tableOrderUpdateController.stream;
  Stream<Map<String, dynamic>> get groupCartUpdateStream =>
      _groupCartUpdateController.stream;

  Stream<Map<String, dynamic>> get orderDeletedStream =>
      _orderDeletedController.stream;

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

    _socket!.on('group_cart_updated', (data) {
      log('Group cart update received: $data');
      _groupCartUpdateController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('table_status_updated', (data) {
      log('Table status updated received: $data');
      _tableStatusUpdateController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('table_order_updated', (data) {
      log('Table order updated received: $data');
      _tableOrderUpdateController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('order_deleted', (data) {
      log('Order deleted received: $data');
      _orderDeletedController.add(Map<String, dynamic>.from(data));
    });

    _socket!.onConnectError((err) => log('Connect Error: $err'));
    _socket!.onError((err) => log('Error: $err'));

    _socket!.connect();
  }

  String _sanitizeId(String id) {
    return id.replaceFirst('restaurant_', '');
  }

  void joinRestaurant(String restaurantId) {
    if (_socket == null) {
      connect();
    }

    final sanitizedId = _sanitizeId(restaurantId);

    if (_socket!.connected) {
      log('Joining restaurant room: $sanitizedId');
      _socket!.emit('join_restaurant', sanitizedId);
    } else {
      log('Socket not connected yet. Waiting for connect to join $sanitizedId');
      // Using off to avoid duplicate listeners if called multiple times before connect
      _socket!.onConnect((_) {
        log('Connected to socket, now joining restaurant room: $sanitizedId');
        _socket!.emit('join_restaurant', sanitizedId);
      });
    }
  }

  void joinTable(String restaurantId, String tableNumber) {
    if (_socket == null) {
      connect();
    }

    final sanitizedRestaurantId = _sanitizeId(restaurantId);
    final data = {
      'restaurantId': sanitizedRestaurantId,
      'tableNumber': tableNumber,
    };

    if (_socket!.connected) {
      log('Joining table room: $data');
      _socket!.emit('join_table', data);
    } else {
      _socket!.onConnect((_) {
        log('Connected to socket, now joining table room: $data');
        _socket!.emit('join_table', data);
      });
    }
  }

  void joinGroup(String restaurantId, String tableNumber) {
    if (_socket == null) {
      connect();
    }

    final sanitizedRestaurantId = _sanitizeId(restaurantId);
    final data = {
      'restaurantId': sanitizedRestaurantId,
      'tableNumber': tableNumber,
    };

    if (_socket!.connected) {
      log('Joining group room: $data');
      _socket!.emit('join_group', data);
    } else {
      _socket!.onConnect((_) {
        log('Connected to socket, now joining group room: $data');
        _socket!.emit('join_group', data);
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
    _groupCartUpdateController.close();
    _tableStatusUpdateController.close();
    _tableOrderUpdateController.close();
    _orderDeletedController.close();
    disconnect();
  }
}
