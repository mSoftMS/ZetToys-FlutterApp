import 'package:flutter/material.dart';
import 'package:flutter_joy_ble/l10n/l10n.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:get/utils.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    final title = this.title ?? context.l10n.appTitle;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: context.textTheme.headlineMedium),
          const Gap(15),
          const SpinKitWave(color: Colors.blue),
        ],
      ),
    );
  }
}
