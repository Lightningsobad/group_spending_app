import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_primary_button.dart';

class ExpenseNoteEditorSheet extends StatefulWidget {
  final String initialText;

  const ExpenseNoteEditorSheet({
    super.key,
    required this.initialText,
  });

  static Future<String?> show(
    BuildContext context, {
    required String initialText,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseNoteEditorSheet(initialText: initialText),
    );
  }

  @override
  State<ExpenseNoteEditorSheet> createState() => _ExpenseNoteEditorSheetState();
}

class _ExpenseNoteEditorSheetState extends State<ExpenseNoteEditorSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _lineCount {
    if (_controller.text.isEmpty) return 0;
    return _controller.text.split('\n').length;
  }

  void _onDone() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(_controller.text);
  }

  void _onClear() {
    HapticFeedback.selectionClick();
    setState(() {
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              const SizedBox(height: 12),
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
              const SizedBox(height: 8),

              // Header: Close - Title - Clear
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(LucideIcons.x, size: 20, color: colors.textSecondary),
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        l10n.expenseNoteEditorTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.h4,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        icon: Icon(LucideIcons.trash2, size: 18, color: colors.textSecondary),
                        tooltip: l10n.clearNoteAction,
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        onPressed: _onClear,
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Text Area
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: TextField(
                      controller: _controller,
                      autofocus: false,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      onChanged: (_) => setState(() {}),
                      style: AppTextStyle.regular(
                        fontSize: AppFontSize.secondary,
                        color: colors.textPrimary,
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: l10n.expenseNotesHint,
                        hintStyle: AppTextStyle.regular(
                          fontSize: AppFontSize.secondary,
                          color: colors.textMuted,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Stats & Primary Submit Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_controller.text.length} ký tự${_lineCount > 1 ? ' • $_lineCount dòng' : ''}',
                        style: AppTextStyle.regular(
                          fontSize: AppFontSize.caption,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppPrimaryButton(
                      text: l10n.doneAction,
                      onPressed: _onDone,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
