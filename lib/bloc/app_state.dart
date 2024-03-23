part of 'app_bloc.dart';

@freezed
sealed class AppState with _$AppState {
  const factory AppState.initial() = Initial;

  const factory AppState.discoveringDevices() = DiscoveringDevices;

  const factory AppState.connecting({required String deviceName}) = Connecting;

  const factory AppState.connected({
    required BluetoothDevice targetDevice,
    required ButtonConfiguration buttonConfiguration,
    required JoypadConfiguration joypadConfiguration,
    BluetoothCharacteristic? writableCharacteristic,
    @Default('') String deviceName,
  }) = Connected;

  const factory AppState.disconnected({
    required List<BluetoothDevice> devices,
  }) = Disconnected;

  const factory AppState.noDevicesFound() = NoDevicesFound;

  const factory AppState.error() = Error;
}
