import 'package:flutter/material.dart';
import 'closet_screen.dart';
import 'upload_screen.dart';
import 'outfit_generator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  final screens = const [
    ClosetScreen(),
    UploadScreen(),
    OutfitGeneratorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: 'Closet'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Subir'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Generar'),
        ],
      ),
    );
  }
}
