import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:odisha_air_map/pages/login/login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 198, 229, 255),
          ),
        );
      });
  }
}
