import 'package:flutter/material.dart';

/// Tela exibida enquanto o Firebase verifica se já existe uma sessão salva.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
