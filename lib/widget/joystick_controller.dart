import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_joy_ble/bloc/app_bloc.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

enum _JoyStickType { left, right }

class JoystickController extends StatelessWidget {
  const JoystickController.left({
    required this.axisX,
    required this.axisY,
    super.key,
  }) : _type = _JoyStickType.left;

  const JoystickController.right({
    required this.axisX,
    required this.axisY,
    super.key,
  }) : _type = _JoyStickType.right;

  final _JoyStickType _type;

  final String axisX;
  final String axisY;

  @override
  Widget build(BuildContext context) {
    final alignment = switch (_type) {
      _JoyStickType.left => Alignment.bottomLeft,
      _JoyStickType.right => Alignment.bottomRight,
    };

    return Align(
      alignment: alignment,
      child: Joystick(
        base: const JoystickSquareBase(),
        stickOffsetCalculator: const RectangleStickOffsetCalculator(),
        listener: (details) => _handleJoyStickChange(
          context,
          dragDetails: details,
        ),
      ),
    );
  }

  void _handleJoyStickChange(
    BuildContext context, {
    required StickDragDetails dragDetails,
  }) {
    final x = dragDetails.x.toStringAsFixed(2);
    final y = dragDetails.y.toStringAsFixed(2);

    final data = '$axisX:$x,$axisY:$y';

    context.read<AppBloc>().add(AppEvent.sendData(data: data));
  }
}
