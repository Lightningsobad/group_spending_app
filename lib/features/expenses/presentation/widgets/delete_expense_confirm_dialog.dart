import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

class DeleteExpenseConfirmDialog extends StatelessWidget {
  const DeleteExpenseConfirmDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteExpenseConfirmDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colors.cardBackground,
      title: Text(
        'Xác nhận xóa khoản chi?',
        style: AppTextStyle.bold(fontSize: 17, color: colors.textPrimary),
      ),
      content: Text(
        'Bạn có chắc chắn muốn xóa khoản chi này? Công nợ của các thành viên trong nhóm sẽ được tính toán lại ngay lập tức.',
        style: AppTextStyle.regular(fontSize: 14, color: colors.textSecondary),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Hủy bỏ',
            style: AppTextStyle.medium(fontSize: 14, color: colors.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            'Xác nhận xóa',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
