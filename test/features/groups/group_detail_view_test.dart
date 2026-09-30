import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/auth/domain/entities/user_entity.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:group_spending_app/features/funds/domain/entities/fund_entities.dart';
import 'package:group_spending_app/features/funds/domain/entities/fund_enums.dart';
import 'package:group_spending_app/features/funds/domain/repositories/funds_repository.dart';
import 'package:group_spending_app/features/funds/presentation/cubit/funds_cubit.dart';
import 'package:group_spending_app/features/funds/presentation/widgets/group_funds_tab_view.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/group_detail_view.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/group_invite_qr_sheet.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../auth/presentation/cubit/auth_cubit_test.dart';
import 'groups_cubit_test.dart';

class FakeFundsRepo implements FundsRepository {
  @override
  Future<GroupFundsOverviewEntity> getGroupFundsOverview(
    int groupId, {
    String? search,
    FundTimeFilter? timeFilter,
    FundCollectionStatus? status,
  }) async {
    return const GroupFundsOverviewEntity(
      groupId: 1,
      totalCollectedAmount: 13000,
      totalCollectedAmountVnd: 13000000,
      totalTargetAmount: 20000,
      totalTargetAmountVnd: 20000000,
      completionPercentage: 65.0,
      funds: [],
    );
  }

  @override
  Future<FundCollectionEntity> createFundCollection(
    int groupId, {
    required String name,
    String? description,
    required num targetAmountPerPersonVnd,
    String? dueDate,
    List<int>? memberUserIds,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<FundCollectionEntity> updateFundCollection(
    int fundId, {
    required String name,
    String? description,
    required num targetAmountPerPersonVnd,
    String? dueDate,
    List<int>? memberUserIds,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFundCollection(int fundId) async {}

  @override
  Future<FundCollectionEntity> getFundCollectionDetails(int fundId) async {
    throw UnimplementedError();
  }

  @override
  Future<FundCollectionEntity> markMemberPaid(int fundId, int targetUserId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> sendFundReminder(int fundId) async {}

  @override
  Future<List<int>> exportFundCsv(int fundId) async {
    return [];
  }
}

void main() {
  group('GroupDetailView Widget Tests', () {
    late FakeGroupsRepo groupsRepo;
    late GroupsCubit groupsCubit;
    late FakeAuthRepository authRepo;
    late AuthCubit authCubit;
    late FakeFundsRepo fundsRepo;
    late FundsCubit fundsCubit;

    const testGroup = GroupModel(
      id: 1,
      name: 'Chung cư Sunrise Room',
      description: 'Chi tiêu tiền phòng, điện nước và sinh hoạt chung 4 người',
      category: 'Apartment',
      inviteCode: 'SUN402-VIP',
      status: 'ACTIVE',
      role: 'ADMIN',
      ownerId: 1,
      userBalance: 2450000,
      totalSpendingVnd: 6830000,
      totalFundCollectedVnd: 13000000,
      memberCount: 5,
      createdAt: '2024-01-01T00:00:00Z',
    );

    setUp(() {
      groupsRepo = FakeGroupsRepo();
      groupsRepo.groups = [testGroup];
      groupsCubit = GroupsCubit(groupsRepo);
      authRepo = FakeAuthRepository();
      authCubit = AuthCubit(authRepo);
      fundsRepo = FakeFundsRepo();
      fundsCubit = FundsCubit(fundsRepo);
      authCubit.emit(
        authCubit.state.copyWith(
          currentUser: const UserEntity(
            id: 1,
            email: 'admin@fairshare.app',
            fullName: 'Nguyễn Nhật Minh',
            role: 'USER',
            isEmailVerified: true,
          ),
        ),
      );
    });

    Widget createWidgetUnderTest({
      GroupModel group = testGroup,
      VoidCallback? onBack,
      VoidCallback? onNavigateToDebts,
    }) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<GroupsCubit>.value(value: groupsCubit),
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<FundsCubit>.value(value: fundsCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: GroupDetailView(
              initialGroup: group,
              onBack: onBack ?? () {},
              onNavigateToDebts: onNavigateToDebts,
            ),
          ),
        ),
      );
    }

    testWidgets('renders header, tabs, group info, financial overview and quick actions', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Header card
      expect(find.text('Chung cư Sunrise Room'), findsWidgets);
      expect(find.byIcon(LucideIcons.arrowLeft), findsOneWidget);

      // 4 horizontal tabs
      expect(find.text('Tổng quan'), findsOneWidget);
      expect(find.text('Chi tiêu'), findsWidgets);
      expect(find.text('Quỹ'), findsOneWidget);
      expect(find.text('Thành viên'), findsOneWidget);

      // Card 1: THÔNG TIN NHÓM
      expect(find.text('THÔNG TIN NHÓM'), findsOneWidget);
      expect(find.text('Chi tiêu tiền phòng, điện nước và sinh hoạt chung 4 người'), findsOneWidget);
      expect(find.text('Căn hộ & Phòng trọ'), findsOneWidget);
      expect(find.text('01/01/2024'), findsOneWidget);
      expect(find.text('5 thành viên'), findsWidgets);

      // Invite Code Banner
      expect(find.text('MÃ MỜI THAM GIA NHÓM'), findsOneWidget);
      expect(find.text('SUN402-VIP'), findsOneWidget);
      expect(find.text('Sao chép mã mời'), findsOneWidget);
      expect(find.byIcon(LucideIcons.qrCode), findsOneWidget);

      // Card 2: TỔNG QUAN TÀI CHÍNH NHÓM
      expect(find.text('TỔNG QUAN TÀI CHÍNH NHÓM'), findsOneWidget);
      expect(find.text('Số dư của bạn trong nhóm'), findsOneWidget);
      expect(find.text('+2.450.000 đ'), findsOneWidget);
      expect(find.text('Bạn nhận'), findsOneWidget);
      expect(find.text('Tổng chi tiêu'), findsOneWidget);
      expect(find.text('6.830.000 đ'), findsOneWidget);
      expect(find.text('Xem báo cáo →'), findsOneWidget);
      expect(find.text('Quỹ đã thu'), findsOneWidget);
      expect(find.text('13.000.000 đ'), findsOneWidget);

      // Section 3: LỐI TẮT & THAO TÁC NHANH
      expect(find.text('LỐI TẮT & THAO TÁC NHANH'), findsOneWidget);
      expect(find.text('Xem công nợ'), findsOneWidget);
      expect(find.text('Tất toán nợ'), findsOneWidget);
      expect(find.text('Quỹ chung'), findsWidgets);
      expect(find.text('Thu quỹ chung'), findsOneWidget);
      expect(find.text('Thêm khoản chi'), findsOneWidget);
      expect(find.text('Chia hóa đơn'), findsOneWidget);
      expect(find.text('Cài đặt'), findsOneWidget);

      // Section 4: QUẢN TRỊ NHÓM
      expect(find.text('QUẢN TRỊ NHÓM'), findsOneWidget);
      expect(find.text('Sửa thông tin'), findsOneWidget);
      expect(find.text('Lưu trữ nhóm'), findsOneWidget);
      expect(find.text('Xóa nhóm vĩnh viễn'), findsOneWidget);
    });

    testWidgets('tapping back button calls onBack', (tester) async {
      bool backCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(onBack: () => backCalled = true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.arrowLeft));
      await tester.pumpAndSettle();

      expect(backCalled, isTrue);
    });

    testWidgets('tapping QR button opens GroupInviteQrSheet modal', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.qrCode));
      await tester.pumpAndSettle();

      expect(find.byType(GroupInviteQrSheet), findsOneWidget);
      expect(find.text('Mời thành viên vào nhóm'), findsOneWidget);
    });

    testWidgets('switching between tabs displays corresponding content', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap tab "Thành viên"
      await tester.tap(find.text('Thành viên'));
      await tester.pumpAndSettle();
      expect(find.text('THÀNH VIÊN (5)'), findsOneWidget);

      // Tap tab "Quỹ"
      await tester.tap(find.text('Quỹ'));
      await tester.pumpAndSettle();
      expect(find.byType(GroupFundsTabView), findsOneWidget);
      expect(find.text('TỔNG TIỀN QUỸ CHUNG'), findsOneWidget);

      // Tap tab "Tổng quan"
      await tester.tap(find.text('Tổng quan'));
      await tester.pumpAndSettle();
      expect(find.text('THÔNG TIN NHÓM'), findsOneWidget);
    });
  });
}
