import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_joy_ble/app_consts.dart';
import 'package:flutter_joy_ble/model/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_bloc.freezed.dart';

part 'app_event.dart';

part 'app_state.dart';

typedef _CompleteConfig = ({
  ReadConfiguration readConfig,
  BluetoothCharacteristic? writableCharacteristics,
});

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState.initial()) {
    on<AppEvent>((event, emit) async {
      switch (event) {
        case _DiscoverDevices():
          await _onDiscoverDevices(emit);
        case _ConnectToDevice(:final device):
          await _onConnectToDevice(emit, device: device);
        case _Disconnect():
          await _onDisconnect(emit);
        case _SendData(:final data):
          await _onSendData(emit, data);
      }
    });
  }

  StreamSubscription<BluetoothDeviceState>? _deviceStateSubscription;

  Future<void> _startListeningToDeviceState(BluetoothDevice device) async {
    await _deviceStateSubscription?.cancel();
    _deviceStateSubscription = device.state.listen((state) {
      if (state == BluetoothDeviceState.disconnected) {
        add(AppEvent.connectToDevice(device: device));
      }
    });
  }

  Future<void> _stopListeningToDeviceState() async =>
      _deviceStateSubscription?.cancel();

  final _flutterBlue = FlutterBlue.instance;

  void _emitError(Emitter<AppState> emit) => emit(const AppState.error());

  Future<void> _onDiscoverDevices(Emitter<AppState> emit) async {
    try {
      emit(const AppState.discoveringDevices());

      final scanResults = await _flutterBlue.startScan(
        timeout: const Duration(seconds: 4),
      );

      if (scanResults is List && scanResults.isEmpty) {
        return emit(const AppState.noDevicesFound());
      }

      if (scanResults is! List<ScanResult>) return _emitError(emit);

      final devices = scanResults.map((result) => result.device).toList()
        ..sort(_compareDeviceNames);

      emit(AppState.disconnected(devices: devices));
    } catch (e) {
      emit(const AppState.error());
      log(e.toString());
    }
  }

  int _compareDeviceNames(BluetoothDevice a, BluetoothDevice b) {
    final aName = a.name;
    final bName = b.name;

    final isAZetToysDevice = aName.startsWith(zetToysPrefix);
    final isBZetToysDevice = bName.startsWith(zetToysPrefix);

    if (isAZetToysDevice) return -1;

    if (isBZetToysDevice) return 1;

    return bName.compareTo(aName);
  }

  Future<void> _onConnectToDevice(
    Emitter<AppState> emit, {
    required BluetoothDevice device,
  }) async {
    try {
      emit(AppState.connecting(deviceName: device.name));

      await device.connect();

      final completeConfig = await _discoverServicesAndCharacteristics(device);

      final buttonConfig = completeConfig.readConfig.buttonConfiguration;
      final joypadConfig = completeConfig.readConfig.joypadConfiguration;
      final deviceName = completeConfig.readConfig.deviceName;

      emit(
        AppState.connected(
          buttonConfiguration: buttonConfig,
          joypadConfiguration: joypadConfig,
          targetDevice: device,
          deviceName: deviceName,
          writableCharacteristic: completeConfig.writableCharacteristics,
        ),
      );

      await _startListeningToDeviceState(device);
    } catch (e) {
      emit(const AppState.error());
      log(e.toString());
    }
  }

  Future<_CompleteConfig> _discoverServicesAndCharacteristics(
    BluetoothDevice device,
  ) async {
    BluetoothCharacteristic? writableCharacteristic;
    var readConfig = ReadConfiguration.empty;

    final services = await device.discoverServices();

    for (final service in services) {
      final characteristics = service.characteristics;
      for (final characteristic in characteristics) {
        if (characteristic.properties.read) {
          readConfig = await _getReadConfig(characteristic);
        }
        if (characteristic.properties.write) {
          writableCharacteristic = characteristic;
          break;
        }
      }

      if (writableCharacteristic != null) break;
    }

    return (
      readConfig: readConfig,
      writableCharacteristics: writableCharacteristic,
    );
  }

  Future<ReadConfiguration> _getReadConfig(
    BluetoothCharacteristic characteristic,
  ) async {
    final value = await characteristic.read();
    final receivedData = utf8.decode(value);

    final parsedConfig = _parseReadConfig(receivedData);

    return parsedConfig;
  }

  ReadConfiguration _parseReadConfig(String config) {
    var deviceName = '';
    var buttonConfiguration = const ButtonConfiguration();
    var joypadConfiguration = const JoypadConfiguration();

    final parts = config.split(':');

    for (final part in parts) {
      if (part.startsWith(joystickPrefix)) {
        joypadConfiguration = _parseJoyConfig(part, joypadConfiguration);
      } else if (part.startsWith(buttonsConfigPrefix)) {
        buttonConfiguration = _parseButtonConfig(part);
      } else if (part.startsWith(deviceNameConfigPrefix)) {
        deviceName = _getDeviceName(part);
      }
    }

    return ReadConfiguration(
      deviceName: deviceName,
      buttonConfiguration: buttonConfiguration,
      joypadConfiguration: joypadConfiguration,
    );
  }

  String _getDeviceName(String part) => part.substring(part.indexOf('=') + 1);

  JoypadConfiguration _parseJoyConfig(String part, JoypadConfiguration config) {
    if (!part.startsWith(leftJoystickPrefix) &&
        !part.startsWith(rightJoystickPrefix)) {
      throw ArgumentError('Invalid joy configuration part: $part');
    }

    final isJoy1 = part.startsWith(leftJoystickPrefix);

    final joyConfig =
        part.substring(part.indexOf('[') + 1, part.indexOf(']')).split(',');
    final joyAxisX = joyConfig.isNotEmpty ? joyConfig[0] : '';
    final joyAxisY = joyConfig.length > 1 ? joyConfig[1] : '';

    return isJoy1
        ? config.copyWith(
            showLeftJoypad: true,
            joy1AxisX: joyAxisX,
            joy1AxisY: joyAxisY,
          )
        : config.copyWith(
            showRightJoypad: true,
            joy2AxisX: joyAxisX,
            joy2AxisY: joyAxisY,
          );
  }

  ButtonConfiguration _parseButtonConfig(String part) {
    var buttonConfiguration = const ButtonConfiguration();
    final buttonConfigs = _getButtonConfigs(part);

    for (final buttonConfig in buttonConfigs) {
      if (buttonConfig.startsWith('A')) {
        buttonConfiguration = buttonConfiguration.copyWith(
          showButtonA: true,
          buttonADescription: _getButtonDescription(buttonConfig),
        );
      } else if (buttonConfig.startsWith('B')) {
        buttonConfiguration = buttonConfiguration.copyWith(
          showButtonB: true,
          buttonBDescription: _getButtonDescription(buttonConfig),
        );
      } else if (buttonConfig.startsWith('C')) {
        buttonConfiguration = buttonConfiguration.copyWith(
          showButtonC: true,
          buttonCDescription: _getButtonDescription(buttonConfig),
        );
      }
    }

    return buttonConfiguration;
  }

  List<String> _getButtonConfigs(String part) =>
      part.substring(part.indexOf('[') + 1, part.indexOf(']')).split(',');

  String _getButtonDescription(String buttonConfig) =>
      buttonConfig.substring(buttonConfig.indexOf('=') + 1);

  Future<void> _onDisconnect(Emitter<AppState> emit) async {
    await _stopListeningToDeviceState();
    add(const AppEvent.discoverDevices());
  }

  Future<void> _onSendData(Emitter<AppState> emit, String data) async {
    switch (state) {
      case Connected(:final BluetoothCharacteristic? writableCharacteristic):
        if (writableCharacteristic == null) return;

        final messageBytes = utf8.encode(data);

        await writableCharacteristic.write(messageBytes);
      default:
        return;
    }
  }
}
