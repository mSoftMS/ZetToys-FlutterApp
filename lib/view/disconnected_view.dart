import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DisconnectedView extends StatelessWidget {
  const DisconnectedView({required this.devices, super.key});

  final List<BluetoothDevice> devices;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
