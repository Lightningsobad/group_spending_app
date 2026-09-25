import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onCompleted;
  final VoidCallback? onChanged;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final cellHeight = totalWidth < 300 ? 46.0 : 52.0;
        final fontSize = totalWidth < 300 ? 18.0 : 22.0;
        final gap = totalWidth < 300 ? 5.0 : 8.0;

        return Stack(
          children: [
            Opacity(
              opacity: 0.0,
              child: SizedBox(
                height: cellHeight,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  maxLength: 6,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onChanged: (val) {
                    onChanged?.call();
                    if (val.length == 6) {
                      onCompleted(val);
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
                  for (int index = 0; index < 6; index++) ...[
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
