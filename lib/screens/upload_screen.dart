import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: Center(
        child: Text('Upload your clothes here!'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí puedes implementar la lógica para subir ropa
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload functionality not implemented yet')),
          );
        },
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}