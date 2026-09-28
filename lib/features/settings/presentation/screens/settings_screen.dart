import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../widgets/appearance_language_card.dart';
import '../widgets/logout_button.dart';
import '../widgets/payment_account_card.dart';
import '../widgets/privacy_policy_view.dart';
import '../widgets/support_info_card.dart';
import '../widgets/user_profile_card.dart';

class SettingsScreen extends StatefulWidget {
  final bool initialShowPrivacyPolicy;

  const SettingsScreen({
    super.key,
    this.initialShowPrivacyPolicy = false,
  });

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late bool _showPrivacyPolicy;

  @override
  void initState() {
    super.initState();
    _showPrivacyPolicy = widget.initialShowPrivacyPolicy;
  }

  void openPrivacyPolicy() {
    setState(() {
      _showPrivacyPolicy = true;
    });
  }

  void closePrivacyPolicy() {
    setState(() {
      _showPrivacyPolicy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showPrivacyPolicy) {
      return PrivacyPolicyView(
        onBack: closePrivacyPolicy,
      );
    }

    final tr = context.l10n;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title: Cài đặt
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.activePillBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.settings,
                  size: 20,
                  color: colors.activePillText,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                tr.settingsTitle,
                style: AppTextStyle.black(
                  fontSize: 18,
                  color: colors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User Profile Card
          const UserProfileCard(),
          const SizedBox(height: 14),

          // Payment Account (VietQR) Card
          const PaymentAccountCard(),
          const SizedBox(height: 14),

          // Appearance & Language Card
          const AppearanceLanguageCard(),
          const SizedBox(height: 14),

          // Support & Info Card
          SupportInfoCard(
            onOpenPrivacyPolicy: openPrivacyPolicy,
          ),
          const SizedBox(height: 20),

          // Logout Button
          const LogoutButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
