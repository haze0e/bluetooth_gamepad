import 'package:flutter/material.dart';

class DPadButton extends StatefulWidget {
  final IconData? icon;
  final String? text;
  final bool isCenter;
  final Function(bool)? onStateChanged;

  const DPadButton({
    Key? key,
    this.icon,
    this.text,
    this.isCenter = false,
    this.onStateChanged,
  }) : super(key: key);

  @override
  State<DPadButton> createState() => _DPadButtonState();
}

class _DPadButtonState extends State<DPadButton> {
  bool _isPressed = false;

  void _handleStateChange(bool isPressed) {
    setState(() => _isPressed = isPressed);
    widget.onStateChanged?.call(isPressed);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handleStateChange(true),
      onTapUp: (_) => _handleStateChange(false),
      onTapCancel: () => _handleStateChange(false),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: widget.isCenter
              ? (_isPressed ? const Color(0xFF14305E) : const Color(0xFF1A457B))
              : (_isPressed
                    ? const Color(0xFF202040)
                    : const Color(0xFF2A2A5A)),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: widget.text != null
            ? Text(
                widget.text!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            : Icon(widget.icon, color: Colors.white, size: 32),
      ),
    );
  }
}
