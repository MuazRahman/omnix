import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/bindings/controller_binder.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/main_layout_shell/screens/main_layout_shell_screen.dart';

class Omnix extends StatelessWidget {
  const Omnix({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Omnix',
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppTheme.windowWidgetBackgroundBlack,
        useMaterial3: true,
      ),
      home: MainLayoutShellScreen(),
      initialBinding: ControllerBinder(),
    );
  }
}
