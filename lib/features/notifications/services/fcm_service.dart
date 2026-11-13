import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../domain/entities/notification_entity.dart';
import '../domain/entities/notification_enums.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}
  debugPrint('FCM Background message: ${message.messageId}');
}

class FcmService {
  final AuthRepository authRepository;
  final void Function(NotificationEntity notification)? onNotificationReceived;
  final void Function(NotificationEntity notification)? onNotificationTapped;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;

  FcmService({
    required this.authRepository,
    this.onNotificationReceived,
    this.onNotificationTapped,
  });

  Future<void> init() async {
    // Chỉ chạy trên các nền tảng hỗ trợ Firebase Messaging (iOS, Android, Web)
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) return;

      final messaging = FirebaseMessaging.instance;

      // 1. Yêu cầu quyền nhận thông báo
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // 2. Lấy FCM Token và đồng bộ lên Backend
        final token = await messaging.getToken();
        if (token != null && token.isNotEmpty) {
          await _syncToken(token);
        }

        // 3. Lắng nghe khi token tự động làm mới
        _tokenRefreshSub?.cancel();
        _tokenRefreshSub = messaging.onTokenRefresh.listen((newToken) {
          _syncToken(newToken);
        });

        // 4. Lắng nghe thông báo khi ứng dụng đang mở (Foreground)
        _onMessageSub?.cancel();
        _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final entity = _parseRemoteMessage(message);
          onNotificationReceived?.call(entity);
        });

        // 5. Lắng nghe khi người dùng bấm vào thông báo từ khay (Background -> Foreground)
        _onMessageOpenedAppSub?.cancel();
        _onMessageOpenedAppSub =
            FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          final entity = _parseRemoteMessage(message);
          onNotificationTapped?.call(entity);
        });

        // 6. Kiểm tra thông báo khi mở app từ trạng thái Terminated
        final initialMessage = await messaging.getInitialMessage();
        if (initialMessage != null) {
          final entity = _parseRemoteMessage(initialMessage);
          onNotificationTapped?.call(entity);
        }
      }
    } catch (e) {
      debugPrint('Lỗi khởi tạo FcmService: $e');
    }
  }

  Future<void> syncToken() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    try {
      if (Firebase.apps.isEmpty) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _syncToken(token);
      }
    } catch (e) {
      debugPrint('Lỗi lấy FCM token khi đồng bộ: $e');
    }
  }

  Future<void> _syncToken(String token) async {
    try {
      final isAuth = await authRepository.isAuthenticated();
      if (isAuth) {
        await authRepository.updateFcmToken(fcmToken: token);
        debugPrint('Đã đồng bộ FCM Token thành công: $token');
      }
    } catch (e) {
      debugPrint('Không thể đồng bộ FCM Token: $e');
    }
  }

  NotificationEntity _parseRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;

    final id = int.tryParse(data['id']?.toString() ?? '') ??
        DateTime.now().millisecondsSinceEpoch;
    final title = notification?.title ?? data['title']?.toString() ?? 'Thông báo';
    final body = notification?.body ?? data['body']?.toString() ?? '';
    final typeStr = data['type']?.toString();
    final refTypeStr = data['referenceType']?.toString();
    final refId = int.tryParse(data['referenceId']?.toString() ?? '') ??
        int.tryParse(data['expenseId']?.toString() ?? '') ??
        int.tryParse(data['debtId']?.toString() ?? '') ??
        int.tryParse(data['settlementId']?.toString() ?? '') ??
        int.tryParse(data['fundId']?.toString() ?? '');
    final groupId = int.tryParse(data['groupId']?.toString() ?? '');
    final groupName = data['groupName']?.toString();
    final actorId = int.tryParse(data['actorId']?.toString() ?? '');
    final actorName = data['actorName']?.toString();
    final actorAvatarUrl = data['actorAvatarUrl']?.toString();

    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      type: NotificationType.fromString(typeStr),
      referenceType: NotificationReferenceType.fromString(refTypeStr),
      referenceId: refId,
      groupId: groupId,
      groupName: groupName,
      actorId: actorId,
      actorName: actorName,
      actorAvatarUrl: actorAvatarUrl,
      isRead: false,
      createdAt: DateTime.now(),
      data: data,
    );
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
    _onMessageSub?.cancel();
    _onMessageOpenedAppSub?.cancel();
  }
}
