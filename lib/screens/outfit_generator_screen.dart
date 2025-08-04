import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OutfitGeneratorScreen extends StatefulWidget {
  const OutfitGeneratorScreen({super.key});

  @override
  State<OutfitGeneratorScreen> createState() => _OutfitGeneratorScreenState();
}

class _OutfitGeneratorScreenState extends State<OutfitGeneratorScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generador de Atuendos')),
      body: Center(
        child: Text('Aquí puedes generar atuendos con tu ropa!'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí puedes implementar la lógica para generar atuendos
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionalidad de generación de atuendos no implementada aún')),
          );
        },
        child: const Icon(Icons.auto_awesome),
      ),
    );
  }
}