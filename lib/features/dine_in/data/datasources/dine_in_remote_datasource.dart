import 'dart:developer';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/dine_in_order_entity.dart';
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
  }) async {
    final body = {
      'tableNumber': tableNumber,
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
    return DineInOrderEntity.fromJson(response.data);
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
    return DineInOrderEntity.fromJson(response.data);
  }

  Future<void> completePayment(
    String orderId,
    Map<String, dynamic> paymentDetails,
  ) async {
    final body = {'payment': paymentDetails};
    await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.orders}${ApiConstants.dineIn}/$orderId/pay',
      data: body,
    );
  }

  Future<DineInOrderEntity> getOrderDetails(String orderId) async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.orders}/$orderId',
    );
    return DineInOrderEntity.fromJson(response.data);
  }
}
