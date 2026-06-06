import 'package:flutter/material.dart';

class GamepadActionButton extends StatefulWidget {
  final Color color;
  final String text;
  final Function(bool)? onStateChanged;

  const GamepadActionButton({
    Key? key,
    required this.color,
    required this.text,
    this.onStateChanged,
  }) : super(key: key);

  @override
  State<GamepadActionButton> createState() => _GamepadActionButtonState();
}

class _GamepadActionButtonState extends State<GamepadActionButton> {
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
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 50),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: _isPressed
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

