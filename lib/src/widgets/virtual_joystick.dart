import 'package:flutter/material.dart';

class VirtualJoystick extends StatefulWidget {
  final double radius;
  final Function(double x, double y) onDirectionChanged;

  const VirtualJoystick({
    Key? key,
    this.radius = 100.0,
    required this.onDirectionChanged,
  }) : super(key: key);

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _thumbPosition = Offset.zero;

  void _updatePosition(Offset localPosition) {
    Offset center = Offset(widget.radius, widget.radius);
    Offset offsetFromCenter = localPosition - center;

    double distance = offsetFromCenter.distance;

    if (distance > widget.radius) {
      double ratio = widget.radius / distance;
      offsetFromCenter = Offset(
        offsetFromCenter.dx * ratio,
        offsetFromCenter.dy * ratio,
      );
    }

    setState(() {
      _thumbPosition = offsetFromCenter;
    });

    double normalizedX = offsetFromCenter.dx / widget.radius;
    double normalizedY = -(offsetFromCenter.dy / widget.radius);

    widget.onDirectionChanged(normalizedX, normalizedY);
  }

  void _resetPosition() {
    setState(() {
      _thumbPosition = Offset.zero;
    });
    widget.onDirectionChanged(0.0, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    double size = widget.radius * 2;

    return GestureDetector(
      onPanStart: (details) => _updatePosition(details.localPosition),
      onPanUpdate: (details) => _updatePosition(details.localPosition),
      onPanEnd: (details) => _resetPosition(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withValues(alpha: 0.3),
        ),
        child: Center(
          child: Transform.translate(
            offset: _thumbPosition,
            child: Container(
              width: widget.radius,
              height: widget.radius,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

