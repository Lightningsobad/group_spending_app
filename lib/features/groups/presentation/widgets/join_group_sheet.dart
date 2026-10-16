import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../cubit/groups_cubit.dart';

class JoinGroupSheet extends StatefulWidget {
  final VoidCallback? onSuccess;

  const JoinGroupSheet({super.key, this.onSuccess});

  static Future<void> show(BuildContext context, {VoidCallback? onSuccess}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<GroupsCubit>(),
        child: JoinGroupSheet(onSuccess: onSuccess),
      ),
    );
  }

  @override
  State<JoinGroupSheet> createState() => _JoinGroupSheetState();
}

class _JoinGroupSheetState extends State<JoinGroupSheet> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tr = context.l10n;
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = tr.inviteCodeRequired;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await context.read<GroupsCubit>().joinGroup(code);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      widget.onSuccess?.call();
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = context.read<GroupsCubit>().state.errorMessage ??
            tr.loadGroupsFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          LucideIcons.qrCode,
                          size: 20,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        tr.joinGroupTitle,
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.h4,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: colors.textMuted, size: 20),
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.errorSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.errorBorder),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyle.medium(
                      fontSize: AppFontSize.caption,
                      color: colors.errorAccent,
                    ),
                  ),
                ),

              Text(
                tr.inviteCodeLabel.toUpperCase(),
                style: AppTextStyle.bold(
                  fontSize: AppFontSize.caption,
                  letterSpacing: 0.8,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: tr.inviteCodeHint,
                  hintStyle: AppTextStyle.regular(
                    fontSize: AppFontSize.secondary,
                    color: colors.textMuted,
                  ),
                  prefixIcon: const Icon(LucideIcons.keyRound, size: 18),
                  filled: true,
                  fillColor: colors.surfaceMuted,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: colors.brandEmeraldBorder,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primaryButton,
                  foregroundColor: colors.onPrimaryButton,
                  minimumSize: const Size(double.infinity, 48),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        tr.joinGroupButton,
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.body,
                          color: colors.onPrimaryButton,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
