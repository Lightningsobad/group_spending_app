import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../l10n/l10n.dart';
import 'expense_note_editor_sheet.dart';

class ExpenseNoteInputField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const ExpenseNoteInputField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  State<ExpenseNoteInputField> createState() => _ExpenseNoteInputFieldState();
}

class _ExpenseNoteInputFieldState extends State<ExpenseNoteInputField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(covariant ExpenseNoteInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChange);
      widget.controller.addListener(_handleTextChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    if (mounted) {
      setState(() {});
    }
  }

  int get _lineCount {
    if (widget.controller.text.isEmpty) return 0;
    return widget.controller.text.split('\n').length;
  }

  Future<void> _openEditor(BuildContext context) async {
    final updatedText = await ExpenseNoteEditorSheet.show(
      context,
      initialText: widget.controller.text,
    );

    if (updatedText != null && updatedText != widget.controller.text && mounted) {
      widget.controller.text = updatedText;
      widget.onChanged?.call(updatedText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final isLongContent = _lineCount > 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: GHI CHÚ + (Tùy chọn) ---- Nút Mở rộng (Chống overflow trên 320px + 1.35x font)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.fileText, size: 14, color: colors.textSecondary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      l10n.expenseNotesCaps,
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.caption,
                        letterSpacing: 0.5,
                        color: colors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.optionalLabel,
                    style: AppTextStyle.regular(
                      fontSize: AppFontSize.caption,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => _openEditor(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.maximize2, size: 13, color: colors.brandEmerald),
                    const SizedBox(width: 4),
                    Text(
                      l10n.expandNoteAction,
                      style: AppTextStyle.bold(
                        fontSize: 12,
                        color: colors.brandEmerald,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Dynamic Text Field (minLines: 2, maxLines: 5)
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          minLines: 2,
          maxLines: 5,
          style: AppTextStyle.medium(
            fontSize: AppFontSize.secondary,
            color: colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: l10n.expenseNotesHint,
            hintStyle: AppTextStyle.regular(
              fontSize: AppFontSize.secondary,
              color: colors.textMuted,
            ),
            filled: true,
            fillColor: colors.surfaceMuted,
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
              borderSide: BorderSide(color: colors.brandEmerald, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),

        // Gợi ý xem toàn bộ khi nội dung vượt quá 5 dòng
        if (isLongContent) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _openEditor(context),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.maximize2, size: 12, color: colors.brandEmerald),
                    const SizedBox(width: 4),
                    Text(
                      l10n.viewAllNotesHint(_lineCount),
                      style: AppTextStyle.medium(
                        fontSize: 12,
                        color: colors.brandEmerald,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
