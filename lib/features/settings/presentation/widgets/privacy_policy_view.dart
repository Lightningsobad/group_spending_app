import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class PrivacyPolicyView extends StatelessWidget {
  final VoidCallback onBack;

  const PrivacyPolicyView({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          onBack();
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          top: true,
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sub-header navigation row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onBack,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Icon(
                        LucideIcons.arrowLeft,
                        size: 18,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  LucideIcons.shieldCheck,
                  color: Color(0xFF4F46E5),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.privacyPolicyTitle,
                        style: AppTextStyle.bold(
                          fontSize: 16,
                          color: colors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr.privacyPolicyCommitmentSubtitle,
                        style: AppTextStyle.medium(
                          fontSize: 11.5,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hero banner card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF059669),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          tr.privacyStandardBadge,
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        tr.privacyUpdatedDate,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr.privacyHeroTitle,
                    style: AppTextStyle.bold(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr.privacyHeroDescription,
                    style: AppTextStyle.regular(
                      fontSize: 12.5,
                      color: const Color(0xFFCBD5E1),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section 1: Dữ liệu ứng dụng thu thập
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.cardBorder, width: 1.2),
                boxShadow: [colors.cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.database,
                          color: Color(0xFF4F46E5),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tr.privacyDataCollectedTitle,
                          style: AppTextStyle.bold(
                            fontSize: 13.5,
                            color: colors.textPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr.privacyDataCollectedDesc,
                    style: AppTextStyle.regular(
                      fontSize: 12.5,
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildCheckItem(
                    colors: colors,
                    title: tr.privacyIdentityTitle,
                    desc: tr.privacyIdentityDesc,
                  ),
                  const SizedBox(height: 12),
                  _buildCheckItem(
                    colors: colors,
                    title: tr.privacyBankTitle,
                    desc: tr.privacyBankDesc,
                  ),
                  const SizedBox(height: 12),
                  _buildCheckItem(
                    colors: colors,
                    title: tr.privacyTransactionTitle,
                    desc: tr.privacyTransactionDesc,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section 2: An toàn mật khẩu & mã hóa đầu cuối
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.cardBorder, width: 1.2),
                boxShadow: [colors.cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.lock,
                          color: Color(0xFF16A34A),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tr.privacySecurityTitle,
                          style: AppTextStyle.bold(
                            fontSize: 13.5,
                            color: colors.textPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr.privacySecurityDesc,
                    style: AppTextStyle.regular(
                      fontSize: 12.5,
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF451A03).withValues(alpha: 0.35)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFFB45309).withValues(alpha: 0.6)
                            : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          LucideIcons.sparkles,
                          size: 18,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tr.privacyChangePasswordTip,
                            style: AppTextStyle.medium(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFFFDE68A)
                                  : const Color(0xFF92400E),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section 3: Cam kết không chia sẻ dữ liệu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.cardBorder, width: 1.2),
                boxShadow: [colors.cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.eyeOff,
                          color: Color(0xFFDC2626),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tr.privacyNoShareTitle,
                          style: AppTextStyle.bold(
                            fontSize: 13.5,
                            color: colors.textPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr.privacyNoShareDesc,
                    style: AppTextStyle.regular(
                      fontSize: 12.5,
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section 4: Quyền làm chủ dữ liệu của bạn
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.cardBorder, width: 1.2),
                boxShadow: [colors.cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.userCheck,
                          color: Color(0xFF9333EA),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tr.privacyUserRightsTitle,
                          style: AppTextStyle.bold(
                            fontSize: 13.5,
                            color: colors.textPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildBulletItem(colors: colors, text: tr.privacyRightEditProfile),
                  const SizedBox(height: 10),
                  _buildBulletItem(colors: colors, text: tr.privacyRightTransferAdmin),
                  const SizedBox(height: 10),
                  _buildBulletItem(colors: colors, text: tr.privacyRightArchiveGroup),
                  const SizedBox(height: 10),
                  _buildBulletItem(colors: colors, text: tr.privacyRightLogoutSafe),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bottom CTA: Quay lại Cài đặt
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onBack,
                icon: const Icon(
                  LucideIcons.arrowLeft,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  tr.privacyBackToSettings,
                  style: AppTextStyle.bold(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14532D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildCheckItem({
    required AppThemeColors colors,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            LucideIcons.circleCheck,
            size: 18,
            color: Color(0xFF16A34A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: AppTextStyle.bold(
                    fontSize: 12.5,
                    color: colors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: desc,
                  style: AppTextStyle.regular(
                    fontSize: 12.5,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletItem({
    required AppThemeColors colors,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2, left: 4, right: 10),
          child: Text(
            '•',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.textSlate800,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTextStyle.regular(
              fontSize: 12.5,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
