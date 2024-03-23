import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_joy_ble/bloc/app_bloc.dart';
import 'package:flutter_joy_ble/l10n/l10n.dart';
import 'package:gap/gap.dart';
import 'package:get/get_utils/get_utils.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.errorOccurred,
                style: context.textTheme.headlineMedium,
              ),
              const Gap(15),
              const _TryAgainButton(),
            ],
          ),
        ),
      );
}

class _TryAgainButton extends StatelessWidget {
  const _TryAgainButton();

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: () => _onPressed(context),
        child: Text(context.l10n.tryAgain),
      );

  void _onPressed(BuildContext context) =>
      context.read<AppBloc>().add(const AppEvent.discoverDevices());
}
