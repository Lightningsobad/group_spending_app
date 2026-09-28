import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/privacy_policy_view.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: PrivacyPolicyView(
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
