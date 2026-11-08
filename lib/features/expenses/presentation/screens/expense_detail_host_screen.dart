import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/domain/repositories/groups_repository.dart';
import 'expense_detail_screen.dart';

class ExpenseDetailHostScreen extends StatefulWidget {
  final int groupId;
  final int expenseId;
  final GroupModel? group;

  const ExpenseDetailHostScreen({
    super.key,
    required this.groupId,
    required this.expenseId,
    this.group,
  });

  @override
  State<ExpenseDetailHostScreen> createState() =>
      _ExpenseDetailHostScreenState();
}

class _ExpenseDetailHostScreenState extends State<ExpenseDetailHostScreen> {
  GroupModel? _group;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    if (_group == null && widget.groupId > 0) {
      _loadGroup();
    }
  }

  Future<void> _loadGroup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<GroupsRepository>();
      final group = await repo.getGroupDetails(widget.groupId);
      if (mounted) {
        setState(() {
          _group = group;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Không thể tải thông tin nhóm hoặc bạn không có quyền truy cập.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.emerald),
        ),
      );
    }

    if (_errorMessage != null || _group == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard?tab=1');
              }
            },
          ),
          title: const Text('Khoản chi'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.alertCircle,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Khoản chi hoặc nhóm không tồn tại.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go('/dashboard?tab=1'),
                  child: const Text('Về danh sách nhóm'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ExpenseDetailScreen(
      expenseId: widget.expenseId,
      group: _group!,
    );
  }
}
