import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../data/models/notification_model.dart';
import '../domain/entities/notification_entity.dart';
import '../domain/entities/notification_enums.dart';

class StompNotificationService {
  final DataSyncCoordinator? dataSyncCoordinator;
  final void Function(NotificationEntity notification)? onNotificationReceived;

  StompClient? _client;
  int? _activeUserId;
  bool _isConnected = false;

  StompNotificationService({
    this.dataSyncCoordinator,
    this.onNotificationReceived,
  });

  bool get isConnected => _isConnected;

  void connect({required int userId, String? accessToken}) {
    if (_client != null && _activeUserId == userId && _isConnected) {
      return;
    }

    disconnect();
    _activeUserId = userId;

    final wsBaseUrl = '${AppConfig.baseUrl}/ws';

    _client = StompClient(
      config: StompConfig.sockJS(
        url: wsBaseUrl,
        reconnectDelay: const Duration(seconds: 5),
        stompConnectHeaders: {
          if (accessToken != null && accessToken.isNotEmpty)
            'Authorization': 'Bearer $accessToken',
        },
        onConnect: (StompFrame frame) {
          _isConnected = true;
          debugPrint('STOMP connected successfully for user $userId');

          _client?.subscribe(
            destination: '/topic/users/$userId/notifications',
            callback: (StompFrame messageFrame) {
              final body = messageFrame.body;
              if (body == null || body.isEmpty) return;

              try {
                final json = jsonDecode(body) as Map<String, dynamic>;
                final model = NotificationModel.fromJson(json);
                final entity = model.toEntity();

                // 1. Gửi thông báo tới UI / Cubit
                onNotificationReceived?.call(entity);

                // 2. Tự động đồng bộ dữ liệu các tab liên quan qua DataSyncCoordinator
                _dispatchDataSync(entity.type);
              } catch (e) {
                debugPrint('Lỗi parse STOMP notification: $e');
              }
            },
          );
        },
        onDisconnect: (StompFrame frame) {
          _isConnected = false;
          debugPrint('STOMP disconnected');
        },
        onStompError: (StompFrame frame) {
          _isConnected = false;
          debugPrint('STOMP error: ${frame.body}');
        },
        onWebSocketError: (dynamic error) {
          _isConnected = false;
          debugPrint('WebSocket error: $error');
        },
      ),
    );

    _client?.activate();
  }

  void _dispatchDataSync(NotificationType type) {
    if (dataSyncCoordinator == null) return;

    switch (type) {
      case NotificationType.expenseCreated:
      case NotificationType.expenseUpdated:
      case NotificationType.expenseDeleted:
        dataSyncCoordinator!.notifyDataChanged(DataSyncScope.expenses);
        break;

      case NotificationType.debtReminder:
      case NotificationType.debtPayRequest:
      case NotificationType.debtSettled:
      case NotificationType.debtRejected:
        dataSyncCoordinator!.notifyDataChanged(DataSyncScope.debts);
        break;

      case NotificationType.fundCreated:
      case NotificationType.fundReminder:
      case NotificationType.fundPaid:
        dataSyncCoordinator!.notifyDataChanged(DataSyncScope.funds);
        break;

      case NotificationType.memberJoinRequest:
      case NotificationType.memberJoinApproved:
      case NotificationType.memberJoinRejected:
        dataSyncCoordinator!.notifyDataChanged(DataSyncScope.groups);
        break;

      case NotificationType.unknown:
        dataSyncCoordinator!.notifyDataChanged(DataSyncScope.all);
        break;
    }
  }

  void disconnect() {
    try {
      _client?.deactivate();
    } catch (_) {}
    _client = null;
    _activeUserId = null;
    _isConnected = false;
  }
}
