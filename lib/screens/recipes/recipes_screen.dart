import 'package:flutter/material.dart';

/// Provisória: a lista de sugestões entra na Fase 4.
class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receitas')),
      body: const Center(child: Text('Sugestões de receitas em breve.')),
    );
  }
}
