import 'package:freezed_annotation/freezed_annotation.dart';

part 'button_configuration.freezed.dart';

@freezed
class ButtonConfiguration with _$ButtonConfiguration {
  const factory ButtonConfiguration({
    @Default(false) bool showButtonA,
    @Default(false) bool showButtonB,
    @Default(false) bool showButtonC,
    @Default('') String buttonADescription,
    @Default('') String buttonBDescription,
    @Default('') String buttonCDescription,
  }) = _ButtonConfiguration;
}
