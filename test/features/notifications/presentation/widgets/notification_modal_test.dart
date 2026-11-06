import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/main_shell/presentation/widgets/notification_modal.dart';
import 'package:group_spending_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:group_spending_app/features/notifications/domain/entities/notification_enums.dart';
import 'package:group_spending_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:group_spending_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

class MockNotificationsRepo implements NotificationsRepository {
  bool getNotificationsCalled = false;
  bool loadMoreCalled = false;

  @override
  Future<NotificationPageResult> getNotifications({
    bool? unreadOnly,
    NotificationType? type,
    int page = 0,
    int size = 20,
  }) async {
    getNotificationsCalled = true;
    return const NotificationPageResult(
      items: [],
      pageNumber: 0,
      totalElements: 0,
      totalPages: 1,
      isLast: true,
    );
  }

  @override
  Future<int> getUnreadCount() async => 0;

  @override
  Future<void> markAsRead(int notificationId) async {}

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> deleteNotification(int notificationId) async {}

  @override
  Future<void> deleteAllRead() async {}
}

void main() {
  group('NotificationModal Widget Test', () {
    late MockNotificationsRepo repo;
    late NotificationsCubit cubit;

    setUp(() {
      repo = MockNotificationsRepo();
      cubit = NotificationsCubit(repo);
    });

    tearDown(() {
      cubit.close();
    });

    Widget createWidgetUnderTest(NotificationsCubit cubitInstance) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
        home: Scaffold(
          body: BlocProvider<NotificationsCubit>.value(
            value: cubitInstance,
            child: const NotificationModal(),
          ),
        ),
      );
    }

    testWidgets('NOTI-07: Displays error state and retry button when hasInitialError is true',
        (tester) async {
      // Simulate initial error state
      cubit.emit(
        cubit.state.copyWith(
          hasInitialError: true,
          errorMessage: 'Lỗi kết nối mạng máy chủ.',
          notifications: [],
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pumpAndSettle();

      // Must show error message
      expect(find.text('Lỗi kết nối mạng máy chủ.'), findsOneWidget);

      // Must show "Thử lại" button
      final retryButton = find.widgetWithText(ElevatedButton, 'Thử lại');
      expect(retryButton, findsOneWidget);

      // Must NOT show "Hiện bạn chưa có thông báo mới nào"
      expect(find.text('Hiện bạn chưa có thông báo mới nào.'), findsNothing);

      // Tapping retry calls loadNotifications
      await tester.tap(retryButton);
      await tester.pump();
      expect(repo.getNotificationsCalled, isTrue);
    });

    testWidgets('NOTI-07: Displays retry load more footer when hasLoadMoreError is true',
        (tester) async {
      final notif = NotificationEntity(
        id: 1,
        title: 'Title',
        body: 'Body',
        type: NotificationType.expenseCreated,
        referenceType: NotificationReferenceType.expense,
        isRead: false,
        createdAt: DateTime.now(),
      );

      cubit.emit(
        cubit.state.copyWith(
          notifications: [notif],
          hasLoadMoreError: true,
          isLoadingMore: false,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pumpAndSettle();

      // Must show "Tải thêm thất bại. Thử lại"
      expect(find.text('Tải thêm thất bại. Thử lại'), findsOneWidget);
    });

    testWidgets('NOTI-06: Disables bulk action buttons when isBulkActionInProgress is true',
        (tester) async {
      final notif = NotificationEntity(
        id: 1,
        title: 'Title',
        body: 'Body',
        type: NotificationType.expenseCreated,
        referenceType: NotificationReferenceType.expense,
        isRead: true,
        createdAt: DateTime.now(),
      );

      cubit.emit(
        cubit.state.copyWith(
          notifications: [notif],
          unreadCount: 1,
          isBulkActionInProgress: true,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pumpAndSettle();

      // Find TextButton "Đã đọc tất cả"
      final markAllBtn = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Đã đọc tất cả'),
      );
      expect(markAllBtn.onPressed, isNull); // Disabled

      // Find TextButton "Xóa các thông báo đã đọc"
      final deleteAllBtn = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Xóa các thông báo đã đọc'),
      );
      expect(deleteAllBtn.onPressed, isNull); // Disabled
    });
  });
}
