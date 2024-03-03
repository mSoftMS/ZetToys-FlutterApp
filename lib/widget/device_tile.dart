import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_joy_ble/app_consts.dart';
import 'package:flutter_joy_ble/bloc/app_bloc.dart';
import 'package:flutter_joy_ble/l10n/l10n.dart';
import 'package:get/utils.dart';

class DeviceTile extends StatelessWidget {
  const DeviceTile({required this.device, super.key});

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    final deviceName =
        device.name.isNotEmpty ? device.name : context.l10n.unknownDevice;

    final deviceId = device.id.id;

    final subtitle = context.l10n.deviceId(deviceId);

    return Card(
      child: ListTile(
        onTap: () => _onTap(context),
        title: Text(
          deviceName,
          style: context.textTheme.titleMedium?.copyWith(
            color: _textColor,
          ),
        ),
        subtitle: Text(subtitle),
        enabled: _enabled,
      ),
    );
  }

  bool get _enabled => device.name.startsWith(zetToysPrefix);

  Color get _textColor => _enabled ? Colors.white : Colors.redAccent;

  void _onTap(BuildContext context) =>
      context.read<AppBloc>().add(AppEvent.connectToDevice(device: device));
}
