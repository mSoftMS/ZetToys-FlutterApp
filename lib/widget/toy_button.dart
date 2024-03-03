import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_joy_ble/bloc/app_bloc.dart';

class ToyButton extends StatelessWidget {
  const ToyButton({
    required this.buttonId,
    required this.description,
    super.key,
  });

  final String buttonId;
  final String description;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => _handleButtonPressed(context, isPressed: true),
        onTapUp: (_) => _handleButtonPressed(context, isPressed: false),
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.radio_button_unchecked),
              Text(description),
            ],
          ),
        ),
      );

  void _handleButtonPressed(BuildContext context, {required bool isPressed}) {
    final data = "$buttonId:${isPressed ? '1' : '0'}";

    context.read<AppBloc>().add(AppEvent.sendData(data: data));
  }
}
