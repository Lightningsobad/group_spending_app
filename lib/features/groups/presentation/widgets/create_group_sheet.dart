import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../cubit/groups_cubit.dart';
import 'group_category_helper.dart';

class CreateGroupSheet extends StatefulWidget {
  final VoidCallback? onSuccess;

  const CreateGroupSheet({super.key, this.onSuccess});

  static Future<void> show(BuildContext context, {VoidCallback? onSuccess}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<GroupsCubit>(),
        child: CreateGroupSheet(onSuccess: onSuccess),
      ),
    );
  }

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Other';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await context.read<GroupsCubit>().createGroup(
          name: _nameController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          category: _selectedCategory,
        );

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
            context.l10n.loadGroupsFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.surfaceMuted,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.cardBorder),
                          ),
                          child: GroupCategoryHelper.buildIcon(
                            _selectedCategory,
                            width: 28,
                            height: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr.createGroupTitle,
                                style: AppTextStyle.bold(
                                  fontSize: 17,
                                  color: colors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                GroupCategoryHelper.getLabel(_selectedCategory),
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
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: colors.textMuted, size: 20),
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
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                ),

              // Group Name
              Text(
                tr.groupNameLabel.toUpperCase(),
                style: AppTextStyle.bold(
                  fontSize: 11,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: tr.groupNameHint,
                  hintStyle: AppTextStyle.regular(
                    fontSize: 14,
                    color: colors.textMuted,
                  ),
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
                    borderSide: const BorderSide(
                      color: AppColors.emerald,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return tr.groupNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                tr.groupDescLabel.toUpperCase(),
                style: AppTextStyle.bold(
                  fontSize: 11,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: tr.groupDescHint,
                  hintStyle: AppTextStyle.regular(
                    fontSize: 14,
                    color: colors.textMuted,
                  ),
                  filled: true,
                  fillColor: colors.surfaceMuted,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
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
                    borderSide: const BorderSide(
                      color: AppColors.emerald,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Selector
              Text(
                tr.groupCategoryLabel.toUpperCase(),
                style: AppTextStyle.bold(
                  fontSize: 11,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: GroupCategoryHelper.categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final label = GroupCategoryHelper.getLabel(cat);

                  return ChoiceChip(
                    showCheckmark: false,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GroupCategoryHelper.buildIcon(
                          cat,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: AppTextStyle.bold(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white
                                : colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.emeraldDark,
                    backgroundColor: colors.surfaceMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.emeraldDark
                            : colors.cardBorder,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: colors.cardBorder),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        tr.cancel,
                        style: AppTextStyle.bold(
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
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
                              tr.createGroupAction,
                              style: AppTextStyle.bold(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
