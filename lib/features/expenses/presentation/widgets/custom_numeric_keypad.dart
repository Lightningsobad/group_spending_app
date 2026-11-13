import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';

class CustomNumericKeypad extends StatelessWidget {
  final void Function(String digit) onDigitPressed;
  final VoidCallback onTripleZeroPressed;
  final VoidCallback onClearPressed;
  final VoidCallback onDeletePressed;

  const CustomNumericKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onTripleZeroPressed,
    required this.onClearPressed,
    required this.onDeletePressed,
  });

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
    Color? bgColor,
    Color? textColor,
    bool isWide = false,
  }) {
    final colors = context.colors;
    final defaultBg = colors.keypadDigitBg;
    final defaultText = colors.keypadDigitText;

    return Expanded(
      flex: isWide ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: bgColor ?? defaultBg,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTextStyle.bold(
                  fontSize: 18,
                  color: textColor ?? defaultText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: 1, 2, 3, CLR
        Row(
          children: [
            _buildButton(context: context, label: '1', onTap: () => onDigitPressed('1')),
            _buildButton(context: context, label: '2', onTap: () => onDigitPressed('2')),
            _buildButton(context: context, label: '3', onTap: () => onDigitPressed('3')),
            _buildButton(
              context: context,
              label: 'CLR',
              onTap: onClearPressed,
              bgColor: colors.keypadClearBg,
              textColor: colors.keypadClearText,
            ),
          ],
        ),
        // Row 2: 4, 5, 6, 000
        Row(
          children: [
            _buildButton(context: context, label: '4', onTap: () => onDigitPressed('4')),
            _buildButton(context: context, label: '5', onTap: () => onDigitPressed('5')),
            _buildButton(context: context, label: '6', onTap: () => onDigitPressed('6')),
            _buildButton(
              context: context,
              label: '000',
              onTap: onTripleZeroPressed,
              bgColor: colors.keypadActionBg,
              textColor: colors.keypadActionText,
            ),
          ],
        ),
        // Row 3: 7, 8, 9, DEL
        Row(
          children: [
            _buildButton(context: context, label: '7', onTap: () => onDigitPressed('7')),
            _buildButton(context: context, label: '8', onTap: () => onDigitPressed('8')),
            _buildButton(context: context, label: '9', onTap: () => onDigitPressed('9')),
            _buildButton(
              context: context,
              label: 'DEL',
              onTap: onDeletePressed,
              bgColor: colors.keypadDeleteBg,
              textColor: colors.keypadDeleteText,
            ),
          ],
        ),
        // Row 4: 0 (wide)
        Row(
          children: [
            _buildButton(
              context: context,
              label: '0',
              onTap: () => onDigitPressed('0'),
              isWide: true,
            ),
          ],
        ),
      ],
    );
  }
}
