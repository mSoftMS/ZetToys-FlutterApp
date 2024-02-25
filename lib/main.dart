import 'dart:async';
import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(MainScreen());
  });
}
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZetToys BLE',
      debugShowCheckedModeBanner: false,
      home: ZetToy(),
      theme: ThemeData.dark(),
    );
  }
}

class ZetToy extends StatefulWidget {
  @override
  _ZetToyState createState() => _ZetToyState();
}

class _ZetToyState extends State<ZetToy> with WidgetsBindingObserver{

  final String TARGET_DEVICE_NAME = "ZetToys001";

  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? targetDevice;
  bool isDeviceConnected = false;
  BluetoothCharacteristic? writableCharacteristic;
  String espConfig = "";
  StreamSubscription? scanSubscription;
  bool showLeftJoypad = false;
  bool showRightJoypad = false;
  bool showButtonA = false;
  bool showButtonB = false;
  bool showButtonC = false;
  String joy1AxisX = "";
  String joy1AxisY = "";
  String joy2AxisX = "";
  String joy2AxisY = "";
  String buttonADescription = "";
  String buttonBDescription = "";
  String buttonCDescription = "";
  String deviceName = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    findAndConnectToDevice();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scanSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      scanSubscription?.cancel();
      flutterBlue.stopScan();
    } else if (state == AppLifecycleState.resumed) {
      findAndConnectToDevice();
    }
  }
  
  void findAndConnectToDevice() async {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    print("Skanowanie BLE"); 
    await scanSubscription?.cancel();
    try {
      var result = await flutterBlue.scanResults.firstWhere((results) {
        return results.any((result) => result.device.name == TARGET_DEVICE_NAME);
      });
      var device = result.firstWhere((r) => r.device.name == TARGET_DEVICE_NAME).device;
      print("Znaleziono zabawkę - ${device.name}");
      setState(() {
        targetDevice = device;
      });
      flutterBlue.stopScan();
      connectToDevice();
    } catch (e) {
      print("Nie znaleziono urządzenia: $e");
    } finally {
      flutterBlue.stopScan();
      scanSubscription?.cancel();
    }
  }

  void connectToDevice() async {
    if (targetDevice == null) return;
    await targetDevice!.connect().then((_) {
      setState(() {
        isDeviceConnected = true;
      });
      print("Połączono z zabawką!"); 
      discoverServicesAndCharacteristics(targetDevice!);
      targetDevice!.state.listen((state) {
        if (state == BluetoothDeviceState.disconnected) {
          setState(() {
            isDeviceConnected = false;
          });
          print("Ponowne łączenie...");
          connectToDevice();
        }
      });
    }).catchError((error) {
      print("Błąd: ${error}");
    });
  }

  Future<void> discoverServicesAndCharacteristics(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic characteristic in characteristics) {
        if (characteristic.properties.read) {
          List<int> value = await characteristic.read();
          String receivedData = utf8.decode(value);
          print("Odczytany config: $receivedData");
          setState(() {
            espConfig = receivedData;
            parseConfig(espConfig); 
          });
        }
        if (characteristic.properties.write) {
          writableCharacteristic = characteristic;
          print("Charakterystyka OK");
          break;
        }
      }
      if (writableCharacteristic != null) break;
    }
  }
  
  void parseConfig(String config) {
    List<String> parts = config.split(':');
    for (String part in parts) {
      if (part.startsWith("joy1")) {
        showLeftJoypad = true;
        var joy1Config = part.substring(part.indexOf('[') + 1, part.indexOf(']')).split(',');
        joy1AxisX = joy1Config.length > 0 ? joy1Config[0] : "";
        joy1AxisY = joy1Config.length > 1 ? joy1Config[1] : "";
        print("Lewy: $joy1AxisX , $joy1AxisY");
      } else if (part.startsWith("joy2")) {
        showRightJoypad = true;
        var joy2Config = part.substring(part.indexOf('[') + 1, part.indexOf(']')).split(',');
        joy2AxisX = joy2Config.length > 0 ? joy2Config[0] : "";
        joy2AxisY = joy2Config.length > 1 ? joy2Config[1] : "";
        print("Prawy: $joy2AxisX , $joy2AxisY");
      } else if (part.startsWith("buttons")) {
        var buttonsConfig = part.substring(part.indexOf('[') + 1, part.indexOf(']')).split(',');
        print("Przyciski: $buttonsConfig");
        for (String buttonConfig in buttonsConfig) {
          if (buttonConfig.startsWith("A")) {
            showButtonA = true;
            buttonADescription = buttonConfig.substring(buttonConfig.indexOf('=') + 1);
          } else if (buttonConfig.startsWith("B")) {
            showButtonB = true;
            buttonBDescription = buttonConfig.substring(buttonConfig.indexOf('=') + 1);
          } else if (buttonConfig.startsWith("C")) {
            showButtonC = true;
            buttonCDescription = buttonConfig.substring(buttonConfig.indexOf('=') + 1);
          }
        }
      } else if (part.startsWith("nazwa")) {
        deviceName = " - " + part.substring(part.indexOf('=') + 1);
      }
    }
  }

  writeData(String data) async {
    if (writableCharacteristic == null) {
      print("Charakterystyka nie jest dostępna");
      return;
    }
    List<int> messageBytes = utf8.encode(data);
    await writableCharacteristic!.write(messageBytes);
    print("Wysłane");
  }

  void _handleLeftJoystickChanged(double x, double y) {
    String data = "$joy1AxisX:${x.toStringAsFixed(2)},$joy1AxisY:${y.toStringAsFixed(2)}";
    print(data);
    writeData(data);
  }

  void _handleRightJoystickChanged(double x, double y) {
    String data = "$joy2AxisX:${x.toStringAsFixed(2)},$joy2AxisY:${y.toStringAsFixed(2)}";
    print(data);
    writeData(data);
  }

  void _handleButtonPressed(String buttonId, bool isPressed) {
    String data = "$buttonId:${isPressed ? '1' : '0'}";
    print(data);
    writeData(data);
  }

  Widget _buildButton(String buttonId, String description) {
    print("Przycisk: $buttonId , $description");
    return GestureDetector(
      onTapDown: (_) => _handleButtonPressed(buttonId, true),
      onTapUp: (_) => _handleButtonPressed(buttonId, false),
      child: Container(
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.radio_button_unchecked),
            Text(description),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (espConfig.isEmpty) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('ZetToys BLE'),
          ),
          body: SafeArea(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    } else {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('ZetToys BLE' + deviceName),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Container(
                  color: Colors.green,
                ),
                if (showLeftJoypad)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Joystick(
                      mode: JoystickMode.all,
                      base: JoystickSquareBase(mode: JoystickMode.all),
                      stickOffsetCalculator: const RectangleStickOffsetCalculator(),
                      listener: (details) {
                        _handleLeftJoystickChanged(details.x, details.y);
                      },
                    ),
                  ),
                if (showRightJoypad)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Joystick(
                      mode: JoystickMode.all,
                      base: JoystickSquareBase(mode: JoystickMode.all),
                      stickOffsetCalculator: const RectangleStickOffsetCalculator(),
                      listener: (details) {
                        _handleRightJoystickChanged(details.x, details.y);
                      },
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showButtonA) _buildButton("A", buttonADescription),
                      if (showButtonB) _buildButton("B", buttonBDescription),
                      if (showButtonC) _buildButton("C", buttonCDescription),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
