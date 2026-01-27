import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/dine_in_order_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/table_entity.dart';

class DineInRemoteDataSource {
  final DioClient _dioClient;

  DineInRemoteDataSource(this._dioClient);

  Future<List<TableEntity>> getTables() async {
    final response = await _dioClient.get(
      ApiConstants.v1 + ApiConstants.orders + ApiConstants.tables,
    );

    final data = response.data;
    if (data is List) {
      return data.map((e) => TableEntity.fromJson(e)).toList();
    } else if (data is Map) {
      if (data['data'] is List) {
        return (data['data'] as List)
            .map((e) => TableEntity.fromJson(e))
            .toList();
      } else if (data['data'] is Map && data['data']['tables'] is List) {
        return (data['data']['tables'] as List)
            .map((e) => TableEntity.fromJson(e))
            .toList();
      } else if (data['tables'] is List) {
        return (data['tables'] as List)
            .map((e) => TableEntity.fromJson(e))
            .toList();
      }
    }
    return [];
  }

  Future<DineInOrderEntity> createDineInOrder(
    String tableNumber, {
    List<DineInOrderItem>? items,
    String? orderTypeId,
    required String customerId,
  }) async {
    final body = {
      'tableNumber': tableNumber,
      if (orderTypeId != null) 'orderType': orderTypeId,
      if (customerId != null) 'customerId': customerId,
      if (items != null && items.isNotEmpty)
        'items': items
            .map(
              (e) => {
                'item': e.itemId,
                'quantity': e.quantity,
                'specialInstructions': e.specialInstructions,
                'modifiers': e.modifiers.map((m) => m.toJson()).toList(),
              },
            )
            .toList(),
    };
    final response = await _dioClient.post(
      ApiConstants.v1 + ApiConstants.orders + ApiConstants.dineIn,
      data: body,
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return DineInOrderEntity.fromJson(data['data']);
    }
    return DineInOrderEntity.fromJson(data);
  }

  Future<DineInOrderEntity> addItemsToOrder(
    String orderId,
    List<DineInOrderItem> items,
  ) async {
    final body = {
      'items': items
          .map(
            (e) => {
              'item': e.itemId,
              'quantity': e.quantity,
              'specialInstructions': e.specialInstructions,
              'modifiers': e.modifiers.map((m) => m.toJson()).toList(),
            },
          )
          .toList(),
    };
    final response = await _dioClient.put(
      '${ApiConstants.v1}${ApiConstants.orders}${ApiConstants.dineIn}/$orderId/items',
      data: body,
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return DineInOrderEntity.fromJson(data['data']);
    }
    return DineInOrderEntity.fromJson(data);
  }

  Future<void> completePayment(
    String orderId,
    PaymentEntity paymentDetails,
  ) async {
    await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.orders}${ApiConstants.dineIn}/$orderId/pay',
      data: paymentDetails.toJson(),
    );
  }

  Future<DineInOrderEntity> getOrderDetails(String orderId) async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.orders}/$orderId',
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return DineInOrderEntity.fromJson(data['data']);
    }
    return DineInOrderEntity.fromJson(data);
  }

  Future<void> deleteDineInOrder(String orderId) async {
    await _dioClient.delete(
      '${ApiConstants.v1}${ApiConstants.orders}${ApiConstants.dineIn}/$orderId',
    );
  }

  Future<DineInOrderEntity> deleteDineInOrderItem(
    String orderId,
    String itemId,
  ) async {
    final response = await _dioClient.delete(
      '${ApiConstants.v1}${ApiConstants.orders}${ApiConstants.dineIn}/$orderId/item/$itemId',
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return DineInOrderEntity.fromJson(data['data']);
    }
    return DineInOrderEntity.fromJson(data);
  }

  Future<TableEntity> createTable(String tableNumber, int capacity) async {
    final body = {
      'tableNumber': tableNumber,
      'capacity': capacity,
      'status': 'available',
    };
    final response = await _dioClient.post(
      ApiConstants.v1 + ApiConstants.orders + ApiConstants.tables,
      data: body,
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return TableEntity.fromJson(data['data']);
    }
    return TableEntity.fromJson(data);
  }

  Future<TableEntity> updateTable(
    String id,
    String tableNumber,
    int capacity,
    TableStatus status,
  ) async {
    final body = {
      'tableNumber': tableNumber,
      'capacity': capacity,
      'status': status.name,
    };
    final response = await _dioClient.put(
      '${ApiConstants.v1}${ApiConstants.orders}${ApiConstants.tables}/$id',
      data: body,
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return TableEntity.fromJson(data['data']);
    }
    return TableEntity.fromJson(data);
  }

  Future<void> deleteTable(String id) async {
    await _dioClient.delete(
      '${ApiConstants.v1}${ApiConstants.orders}${ApiConstants.tables}/$id',
    );
  }
}
