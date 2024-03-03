import 'package:flutter/material.dart';
import 'package:flutter_joy_ble/bloc/app_bloc.dart';
import 'package:flutter_joy_ble/l10n/l10n.dart';
import 'package:flutter_joy_ble/model/button_configuration.dart';
import 'package:flutter_joy_ble/widget/widget.dart';

class ConnectedView extends StatelessWidget {
  const ConnectedView({required this.state, super.key});

  final Connected state;

  @override
  Widget build(BuildContext context) {
    final joypadConfig = state.joypadConfiguration;
    final buttonConfig = state.buttonConfiguration;

    final appBarTitle = context.l10n.appTitle + state.deviceName;

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: SafeArea(
        child: Stack(
          children: [
            if (joypadConfig.showLeftJoypad)
              JoystickController.left(
                axisX: joypadConfig.joy1AxisX,
                axisY: joypadConfig.joy1AxisY,
              ),
            if (joypadConfig.showRightJoypad)
              JoystickController.right(
                axisX: joypadConfig.joy2AxisX,
                axisY: joypadConfig.joy2AxisY,
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _ButtonsSection(buttonConfig: buttonConfig),
            ),
          ],
        ),
      ),
    );
  }
}

class _ButtonsSection extends StatelessWidget {
  const _ButtonsSection({required this.buttonConfig});

  final ButtonConfiguration buttonConfig;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (buttonConfig.showButtonA)
            ToyButton(
              buttonId: 'A',
              description: buttonConfig.buttonADescription,
            ),
          if (buttonConfig.showButtonB)
            ToyButton(
              buttonId: 'B',
              description: buttonConfig.buttonBDescription,
            ),
          if (buttonConfig.showButtonC)
            ToyButton(
              buttonId: 'C',
              description: buttonConfig.buttonCDescription,
            ),
        ],
      );
}
