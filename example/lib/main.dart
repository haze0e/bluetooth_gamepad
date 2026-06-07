import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:virtual_gamepad/virtual_gamepad.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Virtual Joystick Example',
      theme: ThemeData.dark(),
      home: const InstructionScreen(),
    );
  }
}

class GamepadHostScreen extends StatefulWidget {
  const GamepadHostScreen({Key? key}) : super(key: key);

  @override
  State<GamepadHostScreen> createState() => _GamepadHostScreenState();
}

class _GamepadHostScreenState extends State<GamepadHostScreen> {
  static const platform = MethodChannel('com.example.bluetooth_gamepad/hid');

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    try {
      await platform.invokeMethod('initBluetooth');
    } catch (e) {
      print("Failed to init bluetooth: \$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GamepadView(
      onGamepadData: (data) {
        try {
          platform.invokeMethod('sendGamepadData', data);
        } on PlatformException catch (e) {
          print("Failed to send gamepad data: '\${e.message}'.");
        }
      },
    );
  }
}

class InstructionScreen extends StatelessWidget {
  const InstructionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.gamepad, size: 30, color: Colors.blueAccent),
              const SizedBox(height: 16),

              const SizedBox(height: 24),
              _buildStep(
                '1',
                'Turn on Bluetooth on both your phone and your PC.',
              ),
              _buildStep(
                '2',
                'Completely unpair/forget this phone from your PC if it was previously connected.',
              ),
              _buildStep(
                '3',
                'Press "Start" below and accept all requested permissions.',
              ),
              _buildStep(
                '4',
                'From your PC, pair with this phone to establish the HID Gamepad link.',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const GamepadHostScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Start Gamepad',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
