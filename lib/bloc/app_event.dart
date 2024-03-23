part of 'app_bloc.dart';

@freezed
sealed class AppEvent with _$AppEvent {
  const factory AppEvent.discoverDevices() = _DiscoverDevices;

  const factory AppEvent.connectToDevice({required BluetoothDevice device}) =
      _ConnectToDevice;

  const factory AppEvent.disconnect() = _Disconnect;

  const factory AppEvent.sendData({required String data}) = _SendData;
}
