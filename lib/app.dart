import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';

class App extends StatelessWidget {
  const App({super.key, required this.authProvider, required this.router});

  final AuthProvider authProvider;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: authProvider,
      child: MaterialApp.router(
        title: 'Gestão de Alimentos',
        theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
        routerConfig: router,
        // Deixa o app inteiro em pt-BR (date picker, botões, etc.).
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
