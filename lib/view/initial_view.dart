import 'package:flutter/material.dart';
import 'package:flutter_joy_ble/l10n/l10n.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:get/utils.dart';

class InitialView extends StatelessWidget {
  const InitialView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.appTitle,
              style: context.textTheme.headlineMedium,
            ),
            const Gap(15),
            const SpinKitWave(color: Colors.blue),
          ],
        ),
      );
}
