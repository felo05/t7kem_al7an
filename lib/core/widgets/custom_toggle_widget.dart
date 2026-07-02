import 'package:flutter/material.dart';

class CustomToggleWidget extends StatelessWidget {
  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;
  const CustomToggleWidget({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color defaultActiveColor = Colors.green.shade700;
    final Color defaultInactiveColor =Colors.grey.shade400;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: defaultActiveColor,
              activeTrackColor: defaultActiveColor.withValues(alpha: 0.3),
              inactiveThumbColor: defaultInactiveColor,
              inactiveTrackColor: defaultInactiveColor.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
