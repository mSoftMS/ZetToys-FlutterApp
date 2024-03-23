import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_joy_ble/bloc/app_bloc.dart';
import 'package:flutter_joy_ble/widget/device_tile.dart';

class DisconnectedView extends StatelessWidget {
  const DisconnectedView({required this.devices, super.key});

  final List<BluetoothDevice> devices;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: RefreshIndicator(
              onRefresh: () async =>
                  context.read<AppBloc>().add(const AppEvent.discoverDevices()),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final device = devices[index];

                  return DeviceTile(device: device);
                },
                itemCount: devices.length,
              ),
            ),
          ),
        ),
      );
}
