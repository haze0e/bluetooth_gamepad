import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'widgets/virtual_joystick.dart';
import 'widgets/gamepad_action_button.dart';
import 'widgets/dpad_button.dart';

class GamepadView extends StatefulWidget {
  final ValueChanged<Uint8List> onGamepadData;

  const GamepadView({Key? key, required this.onGamepadData}) : super(key: key);

  @override
  State<GamepadView> createState() => _GamepadViewState();
}

class _GamepadViewState extends State<GamepadView> {
  double _leftX = 0.0;
  double _leftY = 0.0;

  double _rightX = 0.0;
  double _rightY = 0.0;

  bool _btnA = false;
  bool _btnB = false;
  bool _btnX = false;
  bool _btnY = false;
  bool _btnL1 = false;
  bool _btnR1 = false;
  bool _btnL2 = false;
  bool _btnR2 = false;

  bool _btnSelect = false;
  bool _btnStart = false;
  bool _btnBack = false;
  bool _btnUp = false;
  bool _btnDown = false;
  bool _btnLeft = false;
  bool _btnRight = false;
  bool _btnOK = false;

  void _updateGamepadState() {
    int byte0 = 0;
    if (_btnA) byte0 |= 1 << 0;
    if (_btnB) byte0 |= 1 << 1;
    if (_btnX) byte0 |= 1 << 3;
    if (_btnY) byte0 |= 1 << 4;
    if (_btnL1) byte0 |= 1 << 6;
    if (_btnR1) byte0 |= 1 << 7;

    int byte1 = 0;
    if (_btnL2) byte1 |= 1 << 0;
    if (_btnR2) byte1 |= 1 << 1;
    if (_btnSelect || _btnBack) byte1 |= 1 << 2;
    if (_btnStart) byte1 |= 1 << 3;
    if (_btnOK) byte1 |= 1 << 4;

    int byte2 = 0;

    int hat = 0;
    if (_btnUp && _btnRight) hat = 2;
    else if (_btnDown && _btnRight) hat = 4;
    else if (_btnDown && _btnLeft) hat = 6;
    else if (_btnUp && _btnLeft) hat = 8;
    else if (_btnUp) hat = 1;
    else if (_btnRight) hat = 3;
    else if (_btnDown) hat = 5;
    else if (_btnLeft) hat = 7;

    int lx = (_leftX * 127).toInt().clamp(-127, 127);
    int ly = (_leftY * 127).toInt().clamp(-127, 127);
    int rx = (_rightX * 127).toInt().clamp(-127, 127);
    int ry = (_rightY * 127).toInt().clamp(-127, 127);

    ByteData data = ByteData(8);
    data.setUint8(0, byte0);
    data.setUint8(1, byte1);
    data.setUint8(2, byte2);
    data.setUint8(3, hat);
    data.setInt8(4, lx);
    data.setInt8(5, ly);
    data.setInt8(6, rx);
    data.setInt8(7, ry);

    widget.onGamepadData(data.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _buildShoulderButton('L2', (v) {
                          _btnL2 = v;
                          _updateGamepadState();
                        }),
                        const SizedBox(width: 16),
                        _buildShoulderButton('L1', (v) {
                          _btnL1 = v;
                          _updateGamepadState();
                        }),
                      ],
                    ),
                    Row(
                      children: [
                        _buildShoulderButton('R1', (v) {
                          _btnR1 = v;
                          _updateGamepadState();
                        }),
                        const SizedBox(width: 16),
                        _buildShoulderButton('R2', (v) {
                          _btnR2 = v;
                          _updateGamepadState();
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 50.0,
                ),
                child: Stack(
                  children: [
                    Align(alignment: Alignment.topLeft, child: _buildDPad()),

                    Align(
                      alignment: Alignment.topRight,
                      child: _buildActionButtons(),
                    ),

                    Align(
                      alignment: Alignment.topCenter,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMenuButton('BACK', (v) {
                            _btnBack = v;
                            _updateGamepadState();
                          }),
                          const SizedBox(width: 16),
                          _buildMenuButton('SELECT', (v) {
                            _btnSelect = v;
                            _updateGamepadState();
                          }),
                          const SizedBox(width: 16),
                          _buildMenuButton('START', (v) {
                            _btnStart = v;
                            _updateGamepadState();
                          }),
                        ],
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VirtualJoystick(
                            radius: 70,
                            onDirectionChanged: (x, y) {
                              setState(() {
                                _leftX = x;
                                _leftY = y;
                              });
                              _updateGamepadState();
                            },
                          ),
                          const SizedBox(width: 80),
                          VirtualJoystick(
                            radius: 70,
                            onDirectionChanged: (x, y) {
                              setState(() {
                                _rightX = x;
                                _rightY = y;
                              });
                              _updateGamepadState();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoulderButton(String text, Function(bool) onStateChanged) {
    return GestureDetector(
      onTapDown: (_) => onStateChanged(true),
      onTapUp: (_) => onStateChanged(false),
      onTapCancel: () => onStateChanged(false),
      child: Container(
        width: 90,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF4A4A6A),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(4),
          ),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildDPad() {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 50,
            child: DPadButton(
              icon: Icons.arrow_drop_up,
              onStateChanged: (v) {
                _btnUp = v;
                _updateGamepadState();
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 50,
            child: DPadButton(
              icon: Icons.arrow_drop_down,
              onStateChanged: (v) {
                _btnDown = v;
                _updateGamepadState();
              },
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            child: DPadButton(
              icon: Icons.arrow_left,
              onStateChanged: (v) {
                _btnLeft = v;
                _updateGamepadState();
              },
            ),
          ),
          Positioned(
            top: 50,
            right: 0,
            child: DPadButton(
              icon: Icons.arrow_right,
              onStateChanged: (v) {
                _btnRight = v;
                _updateGamepadState();
              },
            ),
          ),
          Positioned(
            top: 50,
            left: 50,
            child: DPadButton(
              text: 'OK',
              isCenter: true,
              onStateChanged: (v) {
                _btnOK = v;
                _updateGamepadState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String text, Function(bool) onStateChanged) {
    return GestureDetector(
      onTapDown: (_) => onStateChanged(true),
      onTapUp: (_) => onStateChanged(false),
      onTapCancel: () => onStateChanged(false),
      child: Container(
        width: 100,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF3B3B6D),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 50,
            child: GamepadActionButton(
              color: const Color(0xFF5CB85C),
              text: 'Y',
              onStateChanged: (v) {
                _btnY = v;
                _updateGamepadState();
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 50,
            child: GamepadActionButton(
              color: const Color(0xFF5C85D6),
              text: 'A',
              onStateChanged: (v) {
                _btnA = v;
                _updateGamepadState();
              },
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            child: GamepadActionButton(
              color: const Color(0xFFD65C99),
              text: 'X',
              onStateChanged: (v) {
                _btnX = v;
                _updateGamepadState();
              },
            ),
          ),
          Positioned(
            top: 50,
            right: 0,
            child: GamepadActionButton(
              color: const Color(0xFFD65C5C),
              text: 'B',
              onStateChanged: (v) {
                _btnB = v;
                _updateGamepadState();
              },
            ),
          ),
        ],
      ),
    );
  }
}
