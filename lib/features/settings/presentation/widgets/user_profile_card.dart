import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/name_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/storage/app_preferences.dart';
import 'change_password_dialog.dart';
import 'edit_profile_dialog.dart';

class UserProfileCard extends StatelessWidget {
  final VoidCallback? onEditProfile;
  final VoidCallback? onChangePassword;

  const UserProfileCard({
    super.key,
    this.onEditProfile,
    this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;
    final authState = context.watch<AuthCubit>().state;
    final prefs = context.read<AppPreferences>();

    final user = authState.currentUser;
    final name = (user?.fullName.isNotEmpty == true)
        ? user!.fullName
        : (prefs.getUserFullName() ?? '');
    final email = (user?.email.isNotEmpty == true)
        ? user!.email
        : (prefs.getUserEmail() ?? '');
    final avatarUrl = user?.avatarUrl;
    final initials = NameUtils.getInitials(name);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.cardBorder, width: 1.2),
        boxShadow: [colors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Avatar with Online dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.emerald.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF065F46), Color(0xFF047857)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Center(
                              child: Text(
                                initials,
                                style: AppTextStyle.bold(
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initials,
                              style: AppTextStyle.bold(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.cardBackground,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyle.black(
                        fontSize: 17,
                        color: colors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Tạm ẩn vai trò người dùng (Group leader Admin)
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: AppTextStyle.medium(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Actions Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEditProfile ?? () => EditProfileDialog.show(context),
                  icon: const Icon(LucideIcons.userCheck, size: 16),
                  label: Text(
                    tr.editProfile,
                    style: AppTextStyle.bold(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.emeraldForest,
                    side: const BorderSide(color: AppColors.emerald, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onChangePassword ??
                      () => ChangePasswordDialog.show(context),
                  icon: Icon(
                    LucideIcons.keyRound,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  label: Text(
                    tr.changePassword,
                    style: AppTextStyle.bold(
                      fontSize: 13,
                      color: colors.textSlate800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.cardBorder, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
