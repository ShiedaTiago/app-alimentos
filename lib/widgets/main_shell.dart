import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Moldura das 4 abas principais com a barra de navegação inferior.
/// O `StatefulNavigationShell` guarda o estado de cada aba (ex.: filtros da
/// lista continuam lá ao voltar para Alimentos).
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // Tocar na aba atual volta para a raiz dela.
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.kitchen), label: 'Alimentos'),
          NavigationDestination(
            icon: Icon(Icons.restaurant),
            label: 'Receitas',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
