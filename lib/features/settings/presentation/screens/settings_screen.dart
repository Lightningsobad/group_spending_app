import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/l10n.dart';
import '../widgets/appearance_language_card.dart';
import '../widgets/logout_button.dart';
import '../widgets/payment_account_card.dart';
import '../widgets/privacy_policy_view.dart';
import '../widgets/support_info_card.dart';
import '../widgets/user_profile_card.dart';
import '../../../main_shell/presentation/widgets/main_tab_app_bar.dart';

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

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            MainTabAppBar(
              icon: LucideIcons.settings,
              title: tr.settingsTitle,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
