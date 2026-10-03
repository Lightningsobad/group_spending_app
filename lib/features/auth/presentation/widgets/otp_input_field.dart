import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class OtpInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onCompleted;
  final VoidCallback? onChanged;
  final int length;
  final bool isAlphanumeric;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onCompleted,
    this.onChanged,
    this.length = 6,
    this.isAlphanumeric = false,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleUpdate);
    widget.focusNode.addListener(_handleUpdate);
  }

  @override
  void didUpdateWidget(OtpInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleUpdate);
      widget.controller.addListener(_handleUpdate);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleUpdate);
      widget.focusNode.addListener(_handleUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleUpdate);
    widget.focusNode.removeListener(_handleUpdate);
    super.dispose();
  }

  void _handleUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final length = widget.length;
    final isAlphanumeric = widget.isAlphanumeric;
    final controller = widget.controller;
    final focusNode = widget.focusNode;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final isLong = length > 6;
        final cellHeight = isLong
            ? (totalWidth < 300 ? 42.0 : 48.0)
            : (totalWidth < 300 ? 46.0 : 52.0);
        final fontSize = isLong
            ? (totalWidth < 300 ? 15.0 : 17.0)
            : (totalWidth < 300 ? 18.0 : 22.0);
        final gap = isLong
            ? (totalWidth < 300 ? 3.0 : 5.0)
            : (totalWidth < 300 ? 5.0 : 8.0);

        return Stack(
          children: [
            Opacity(
              opacity: 0.0,
              child: SizedBox(
                height: cellHeight,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: isAlphanumeric
                      ? TextInputType.text
                      : TextInputType.number,
                  autofocus: true,
                  maxLength: length,
                  inputFormatters: [
                    if (isAlphanumeric) ...[
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      UpperCaseTextFormatter(),
                    ] else
                      FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(length),
                  ],
                  onChanged: (val) {
                    widget.onChanged?.call();
                    if (val.length == length) {
                      widget.onCompleted(val);
                    }
                  },
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                focusNode.requestFocus();
              },
              child: Row(
                children: [
                  for (int index = 0; index < length; index++) ...[
                    if (index > 0) SizedBox(width: gap),
                    Expanded(
                      child: Container(
                        height: cellHeight,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: index < controller.text.length
                              ? AppColors.successBg
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                index < controller.text.length ||
                                        (focusNode.hasFocus &&
                                            index == controller.text.length)
                                    ? AppColors.emerald
                                    : const Color(0xFFCBD5E1),
                            width:
                                (focusNode.hasFocus &&
                                        index == controller.text.length)
                                    ? 2.0
                                    : 1.5,
                          ),
                          boxShadow:
                              (focusNode.hasFocus &&
                                      index == controller.text.length)
                                  ? [
                                      BoxShadow(
                                        color: AppColors.emerald.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                        ),
                        child: Text(
                          index < controller.text.length
                              ? controller.text[index]
                              : '',
                          style: AppTextStyle.extraBold(
                            fontSize: fontSize,
                            color: index < controller.text.length
                                ? const Color(0xFF065F46)
                                : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
