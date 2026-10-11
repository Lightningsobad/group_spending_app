import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/name_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import 'bank_picker_bottom_sheet.dart';

class EditProfileDialog extends StatefulWidget {
  final AuthCubit? authCubit;
  final VoidCallback? onSuccess;

  const EditProfileDialog({
    super.key,
    this.authCubit,
    this.onSuccess,
  });

  static Future<bool?> show(
    BuildContext context, {
    AuthCubit? authCubit,
    VoidCallback? onSuccess,
  }) {
    final cubit = authCubit ?? context.read<AuthCubit>();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<AuthCubit>.value(
        value: cubit,
        child: EditProfileDialog(
          authCubit: cubit,
          onSuccess: onSuccess,
        ),
      ),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _bankAccountNumberController;
  late final TextEditingController _bankAccountNameController;

  File? _avatarFile;
  String? _currentAvatarUrl;
  String? _selectedBankLogo;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final cubit = widget.authCubit ?? context.read<AuthCubit>();
    final user = cubit.state.currentUser;

    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _bankNameController = TextEditingController(text: user?.bankName ?? '');
    _bankAccountNumberController =
        TextEditingController(text: user?.bankAccountNumber ?? '');
    _bankAccountNameController =
        TextEditingController(text: user?.bankAccountName ?? '');
    _currentAvatarUrl = user?.avatarUrl;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankAccountNameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(ImageSource source) async {
    Navigator.of(context).pop(); // Close picker bottom sheet
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      final file = File(picked.path);
      final size = await file.length();
      if (size > 10 * 1024 * 1024) {
        if (!mounted) return;
        setState(() {
          _errorMessage = context.l10n.imageTooLargeError;
        });
        return;
      }

      setState(() {
        _avatarFile = file;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = context.l10n.imagePickerGenericError;
      });
    }
  }

  void _showAvatarPickerSheet() {
    final tr = context.l10n;
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.camera, color: AppColors.emeraldForest),
                title: Text(tr.takePhoto, style: AppTextStyle.bold(fontSize: 14)),
                onTap: () => _pickAvatar(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(LucideIcons.image, color: AppColors.emeraldForest),
                title: Text(tr.chooseFromGallery, style: AppTextStyle.bold(fontSize: 14)),
                onTap: () => _pickAvatar(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openBankPicker() async {
    final selectedBank = await BankPickerBottomSheet.show(
      context,
      currentBankShortName: _bankNameController.text.trim(),
    );

    if (selectedBank != null) {
      setState(() {
        _bankNameController.text = selectedBank.shortName;
        _selectedBankLogo = selectedBank.logo;
      });
    }
  }

  Future<void> _submit() async {
    final tr = context.l10n;
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cubit = widget.authCubit ?? context.read<AuthCubit>();
      await cubit.updateProfile(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        bankName: _bankNameController.text.trim().isEmpty
            ? null
            : _bankNameController.text.trim(),
        bankAccountNumber: _bankAccountNumberController.text.trim().isEmpty
            ? null
            : _bankAccountNumberController.text.trim(),
        bankAccountName: _bankAccountNameController.text.trim().isEmpty
            ? null
            : _bankAccountNameController.text.trim().toUpperCase(),
        avatarFile: _avatarFile,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      widget.onSuccess?.call();
      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.circleCheck, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr.updateProfileSuccess,
                  style: AppTextStyle.medium(fontSize: 13, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.emeraldForest,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = context.l10n.updateProfileGenericError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;
    final initials = NameUtils.getInitials(_fullNameController.text);
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

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.activePillBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          LucideIcons.userPen,
                          size: 20,
                          color: colors.activePillText,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr.editProfileTitle,
                              style: AppTextStyle.bold(
                                fontSize: 16,
                                color: colors.textPrimary,
                              ),
                            ),
                            Text(
                              tr.editProfileSubtitle,
                              style: AppTextStyle.regular(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.x, size: 20, color: colors.textSecondary),
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Avatar Picker Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.brandEmeraldBorder,
                              width: 2.5,
                            ),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF065F46), Color(0xFF047857)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _avatarFile != null
                              ? Image.file(_avatarFile!, fit: BoxFit.cover)
                              : (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty)
                                  ? Image.network(
                                      _currentAvatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Center(
                                        child: Text(
                                          initials,
                                          style: AppTextStyle.bold(
                                            fontSize: 26,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        initials,
                                        style: AppTextStyle.bold(
                                          fontSize: 26,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isLoading ? null : _showAvatarPickerSheet,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: colors.brandEmerald,
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.cardBackground, width: 2),
                              ),
                              child: const Icon(
                                LucideIcons.camera,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Error Banner
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.errorSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.errorBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.alertCircle, size: 18, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyle.medium(fontSize: 12, color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Full Name Field (Required)
                  _buildLabel('${tr.fullNameLabel} *', colors),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _fullNameController,
                    hintText: tr.fullNameHint,
                    prefixIcon: LucideIcons.user,
                    colors: colors,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return tr.fullNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Phone Field (Optional)
                  _buildLabel(tr.phoneLabel, colors),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _phoneController,
                    hintText: tr.phoneHint,
                    prefixIcon: LucideIcons.phone,
                    colors: colors,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 18),

                  // VietQR Payment Account Section Divider & Title
                  Row(
                    children: [
                      Icon(LucideIcons.creditCard, size: 16, color: colors.brandEmerald),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tr.vietqrTitle,
                          style: AppTextStyle.bold(
                            fontSize: 12,
                            color: colors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Bank Name (Selector with VietQR API)
                  _buildLabel(tr.bankNameLabel, colors),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _isLoading ? null : _openBankPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          if (_selectedBankLogo != null && _selectedBankLogo!.isNotEmpty)
                            Container(
                              width: 32,
                              height: 22,
                              margin: const EdgeInsets.only(right: 10),
                              child: Image.network(_selectedBankLogo!, fit: BoxFit.contain),
                            )
                          else
                            Icon(LucideIcons.landmark, size: 18, color: colors.textSecondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _bankNameController.text.isNotEmpty
                                  ? _bankNameController.text
                                  : tr.bankNameHint,
                              style: AppTextStyle.medium(
                                fontSize: 14,
                                color: _bankNameController.text.isNotEmpty
                                    ? colors.textPrimary
                                    : colors.textSecondary,
                              ),
                            ),
                          ),
                          if (_bankNameController.text.isNotEmpty) ...[
                            Tooltip(
                              message: tr.clearBankPrompt,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _bankNameController.clear();
                                          _bankAccountNumberController.clear();
                                          _bankAccountNameController.clear();
                                          _selectedBankLogo = null;
                                        });
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    LucideIcons.circleX,
                                    size: 18,
                                    color: colors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Icon(LucideIcons.chevronDown, size: 18, color: colors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bank Account Number
                  _buildLabel(tr.bankAccountNumberLabel, colors),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _bankAccountNumberController,
                    hintText: tr.bankAccountNumberHint,
                    prefixIcon: LucideIcons.hash,
                    colors: colors,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 12),

                  // Bank Account Name
                  _buildLabel(tr.bankAccountNameLabel, colors),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _bankAccountNameController,
                    hintText: tr.bankAccountNameHint,
                    prefixIcon: LucideIcons.badgeCheck,
                    colors: colors,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 22),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
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
                              fontSize: 13.5,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: AppPrimaryButton(
                          text: tr.saveChanges,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _submit,
                          height: 46,
                          borderRadius: 12,
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
    return Text(
      text,
      style: AppTextStyle.bold(
        fontSize: 13,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required dynamic colors,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      style: AppTextStyle.medium(
        fontSize: 14,
        color: colors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyle.regular(
          fontSize: 13,
          color: colors.textSecondary,
        ),
        prefixIcon: Icon(prefixIcon, size: 18, color: colors.textSecondary),
        filled: true,
        fillColor: colors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.brandEmerald, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
