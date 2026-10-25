import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class ChangePasswordDialog extends StatefulWidget {
  final AuthRepository? authRepository;
  final VoidCallback? onSuccess;

  const ChangePasswordDialog({
    super.key,
    this.authRepository,
    this.onSuccess,
  });

  static Future<bool?> show(
    BuildContext context, {
    AuthRepository? authRepository,
    VoidCallback? onSuccess,
  }) {
    final repo = authRepository ?? context.read<AuthRepository>();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangePasswordDialog(
        authRepository: repo,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tr = context.l10n;
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final oldPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      final repo = widget.authRepository ?? context.read<AuthRepository>();
      await repo.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      widget.onSuccess?.call();
      Navigator.of(context).pop(true);

      AppSnackBar.showSuccess(context, tr.changePasswordSuccess);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = tr.underDevelopment;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.dragHandle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.badgeIndigoBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Icon(
                            LucideIcons.keyRound,
                            size: 22,
                            color: colors.badgeIndigo,
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr.changePasswordTitle,
                            style: AppTextStyle.bold(
                              fontSize: 16,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tr.changePasswordSubtitle,
                            style: AppTextStyle.regular(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.x,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Error Banner if present
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.errorSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.errorBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.alertCircle,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyle.medium(
                              fontSize: 12.5,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Field 1: Mật khẩu hiện tại *
                _buildLabel(tr.currentPasswordLabel, colors),
                const SizedBox(height: 6),
                _buildPasswordField(
                  controller: _currentPasswordController,
                  hintText: tr.currentPasswordHint,
                  obscureText: _obscureCurrentPassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return tr.enterCurrentPasswordPrompt;
                    }
                    return null;
                  },
                  colors: colors,
                ),
                const SizedBox(height: 14),

                // Field 2: Mật khẩu mới *
                _buildLabel(tr.newPasswordLabel, colors),
                const SizedBox(height: 6),
                _buildPasswordField(
                  controller: _newPasswordController,
                  hintText: tr.newPasswordHint,
                  obscureText: _obscureNewPassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr.enterNewPasswordPrompt;
                    }
                    if (value.length < 6) {
                      return tr.passwordMinLengthPrompt;
                    }
                    if (value == _currentPasswordController.text) {
                      return tr.newPasswordSameAsCurrentPrompt;
                    }
                    return null;
                  },
                  colors: colors,
                ),
                const SizedBox(height: 14),

                // Field 3: Xác nhận mật khẩu mới *
                _buildLabel(tr.confirmNewPasswordLabel, colors),
                const SizedBox(height: 6),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  hintText: tr.confirmNewPasswordHint,
                  obscureText: _obscureConfirmPassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr.confirmPasswordMismatchPrompt;
                    }
                    if (value != _newPasswordController.text) {
                      return tr.confirmPasswordMismatchPrompt;
                    }
                    return null;
                  },
                  colors: colors,
                ),
                const SizedBox(height: 14),

                // Password Tip Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Text(
                    tr.passwordSafetyTip,
                    style: AppTextStyle.regular(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.cardBorder, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          tr.cancel,
                          style: AppTextStyle.bold(
                            fontSize: 14,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    LucideIcons.check,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      tr.changePasswordSubmitButton,
                                      style: AppTextStyle.bold(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildLabel(String text, dynamic colors) {
    return RichText(
      text: TextSpan(
        text: text,
        style: AppTextStyle.bold(
          fontSize: 13,
          color: colors.textPrimary,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    required String? Function(String?) validator,
    required dynamic colors,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: AppTextStyle.semiBold(
        fontSize: 14,
        color: colors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyle.regular(
          fontSize: 13.5,
          color: colors.textMuted,
        ),
        prefixIcon: Icon(
          LucideIcons.lock,
          size: 18,
          color: colors.textMuted,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
            size: 18,
            color: colors.textMuted,
          ),
          onPressed: onToggleObscure,
        ),
        filled: true,
        fillColor: colors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.cardBorder,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.badgeIndigo,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
