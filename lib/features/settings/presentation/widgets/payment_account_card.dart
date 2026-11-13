import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../groups/presentation/widgets/viet_qr_modal_sheet.dart';
import 'edit_profile_dialog.dart';

class PaymentAccountCard extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  const PaymentAccountCard({
    super.key,
    this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;
    final authState = context.watch<AuthCubit>().state;
    final user = authState.currentUser;

    final hasBankInfo = user?.bankName != null &&
        user!.bankName!.trim().isNotEmpty &&
        user.bankAccountNumber != null &&
        user.bankAccountNumber!.trim().isNotEmpty;

    final bankInfoText = hasBankInfo
        ? '${user.bankName} - ${user.bankAccountNumber}'
        : tr.noBankData;

    final accountNameText = (user?.bankAccountName != null &&
            user!.bankAccountName!.trim().isNotEmpty)
        ? user.bankAccountName!
        : (user?.fullName.isNotEmpty == true ? user!.fullName : '');

    void handleCardTap() {
      if (onTap != null) {
        onTap!();
        return;
      }

      if (hasBankInfo) {
        VietQrModalSheet.show(
          context,
          bankName: user.bankName!,
          accountNumber: user.bankAccountNumber!,
          accountName: (user.bankAccountName != null &&
                  user.bankAccountName!.trim().isNotEmpty)
              ? user.bankAccountName!
              : user.fullName,
        );
      } else {
        EditProfileDialog.show(context);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.cardBorder, width: 1.2),
        boxShadow: [colors.cardShadow],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: handleCardTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.creditCard,
                          size: 18,
                          color: colors.brandEmerald,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tr.vietqrTitle,
                          style: AppTextStyle.bold(
                            fontSize: 12,
                            color: colors.textSlate800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onEdit ?? () => EditProfileDialog.show(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Text(
                          tr.edit,
                          style: AppTextStyle.bold(
                            fontSize: 13,
                            color: colors.brandEmerald,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bankInfoText,
                              style: AppTextStyle.bold(
                                fontSize: 14,
                                color: hasBankInfo
                                    ? colors.textPrimary
                                    : colors.textMuted,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (hasBankInfo) ...[
                              const SizedBox(height: 4),
                              Text(
                                accountNameText,
                                style: AppTextStyle.semiBold(
                                  fontSize: 12,
                                  color: colors.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: hasBankInfo
                              ? colors.brandEmeraldMuted
                              : colors.divider.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          hasBankInfo ? LucideIcons.qrCode : LucideIcons.creditCard,
                          size: 20,
                          color: hasBankInfo
                              ? colors.brandEmerald
                              : colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
