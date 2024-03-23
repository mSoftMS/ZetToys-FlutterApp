import 'package:flutter_joy_ble/model/button_configuration.dart';
import 'package:flutter_joy_ble/model/joypad_configuration.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'read_configuration.freezed.dart';

@freezed
class ReadConfiguration with _$ReadConfiguration {
  const factory ReadConfiguration({
    required ButtonConfiguration buttonConfiguration,
    required JoypadConfiguration joypadConfiguration,
    required String deviceName,
  }) = _ReadConfiguration;

  const ReadConfiguration._();

  static const empty = ReadConfiguration(
    buttonConfiguration: ButtonConfiguration(),
    joypadConfiguration: JoypadConfiguration(),
    deviceName: '',
  );
}
