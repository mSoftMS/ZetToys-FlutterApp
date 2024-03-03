import 'package:freezed_annotation/freezed_annotation.dart';

part 'joypad_configuration.freezed.dart';

@freezed
class JoypadConfiguration with _$JoypadConfiguration {
  const factory JoypadConfiguration({
    @Default(false) bool showLeftJoypad,
    @Default(false) bool showRightJoypad,
    @Default('') String joy1AxisX,
    @Default('') String joy1AxisY,
    @Default('') String joy2AxisX,
    @Default('') String joy2AxisY,
  }) = _JoypadConfiguration;
}
