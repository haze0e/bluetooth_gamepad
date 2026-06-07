package com.example.bluetooth_gamepad

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.BluetoothHidDevice
import android.bluetooth.BluetoothHidDeviceAppSdpSettings
import android.content.Context
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.bluetooth_gamepad/hid"

    private var bluetoothManager: BluetoothManager? = null
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var hidDevice: BluetoothHidDevice? = null
    
    private var connectedDevice: BluetoothDevice? = null

    private val GAMEPAD_REPORT_DESCRIPTOR = byteArrayOf(
        0x05.toByte(), 0x01.toByte(),
        0x09.toByte(), 0x05.toByte(),
        0xa1.toByte(), 0x01.toByte(),
        0x85.toByte(), 0x01.toByte(),
        0xa1.toByte(), 0x02.toByte(),

        0x05.toByte(), 0x09.toByte(),
        0x19.toByte(), 0x01.toByte(),
        0x29.toByte(), 0x18.toByte(),
        0x15.toByte(), 0x00.toByte(),
        0x25.toByte(), 0x01.toByte(),
        0x75.toByte(), 0x01.toByte(),
        0x95.toByte(), 0x18.toByte(),
        0x81.toByte(), 0x02.toByte(),

        0x05.toByte(), 0x01.toByte(),
        0x09.toByte(), 0x39.toByte(),
        0x15.toByte(), 0x01.toByte(),
        0x25.toByte(), 0x08.toByte(),
        0x35.toByte(), 0x00.toByte(),
        0x46.toByte(), 0x3B.toByte(), 0x01.toByte(),
        0x65.toByte(), 0x14.toByte(),
        0x75.toByte(), 0x04.toByte(),
        0x95.toByte(), 0x01.toByte(),
        0x81.toByte(), 0x42.toByte(),

        0x75.toByte(), 0x04.toByte(),
        0x95.toByte(), 0x01.toByte(),
        0x81.toByte(), 0x03.toByte(),

        0x05.toByte(), 0x01.toByte(),
        0x09.toByte(), 0x30.toByte(),
        0x09.toByte(), 0x31.toByte(),
        0x09.toByte(), 0x32.toByte(),
        0x09.toByte(), 0x35.toByte(),
        0x15.toByte(), 0x81.toByte(),
        0x25.toByte(), 0x7f.toByte(),
        0x75.toByte(), 0x08.toByte(),
        0x95.toByte(), 0x04.toByte(),
        0x81.toByte(), 0x02.toByte(),

        0xc0.toByte(),
        0xc0.toByte()
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "initBluetooth") {
                setupBluetoothHid()
                result.success(null)
            } else if (call.method == "sendGamepadData") {
                val data = call.arguments as? ByteArray
                if (data != null) {
                    val host = connectedDevice
                    if (host != null && hidDevice != null) {
                        try {
                            hidDevice?.sendReport(host, 1, data)
                        } catch (e: SecurityException) {
                            Log.e("GamepadHID", "SecurityException when sending report")
                        }
                    } else {
                        Log.d("GamepadHID", "No device connected to send data to")
                    }

                    result.success(null)
                } else {
                    result.error("INVALID_DATA", "Payload was not a byte array", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setupBluetoothHid() {
        bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager?.adapter

        if (bluetoothAdapter == null) return

        bluetoothAdapter?.getProfileProxy(applicationContext, object : BluetoothProfile.ServiceListener {
            override fun onServiceConnected(profile: Int, proxy: BluetoothProfile) {
                if (profile == BluetoothProfile.HID_DEVICE) {
                    hidDevice = proxy as BluetoothHidDevice
                    registerApp()
                }
            }

            override fun onServiceDisconnected(profile: Int) {
                if (profile == BluetoothProfile.HID_DEVICE) {
                    hidDevice = null
                }
            }
        }, BluetoothProfile.HID_DEVICE)
    }

    private fun registerApp() {
        val sdpSettings = BluetoothHidDeviceAppSdpSettings(
            "Flutter Gamepad",
            "Virtual Gamepad",
            "Flutter",
            2.toByte(),
            GAMEPAD_REPORT_DESCRIPTOR
        )

        try {
            hidDevice?.registerApp(
                sdpSettings,
                null, 
                null, 
                Executors.newSingleThreadExecutor(),
                object : BluetoothHidDevice.Callback() {
                    override fun onAppStatusChanged(pluggedDevice: BluetoothDevice?, registered: Boolean) {
                        Log.d("GamepadHID", "App Registration Status: \$registered")
                        if (registered) {
                            try {
                                val pairedDevices = bluetoothAdapter?.bondedDevices
                                pairedDevices?.forEach { device ->
                                    Log.d("GamepadHID", "Attempting HID connection to \${device.name}")
                                    hidDevice?.connect(device)
                                }
                            } catch (e: SecurityException) {
                                Log.e("GamepadHID", "Missing permissions to connect to bonded devices")
                            }
                        }
                    }

                    override fun onConnectionStateChanged(device: BluetoothDevice, state: Int) {
                        Log.d("GamepadHID", "Connection state changed: \$state")
                        if (state == BluetoothProfile.STATE_CONNECTED) {
                            Log.d("GamepadHID", "PC CONNECTED: \${device.name}")
                            connectedDevice = device
                        } else if (state == BluetoothProfile.STATE_DISCONNECTED) {
                            Log.d("GamepadHID", "PC DISCONNECTED")
                            if (connectedDevice == device) {
                                connectedDevice = null
                            }
                        }
                    }
                }
            )
        } catch (e: SecurityException) {
            Log.e("GamepadHID", "Security Exception: Missing Bluetooth Permissions")
        }
    }
}
