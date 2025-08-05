import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'closet_screen.dart';
import 'upload_screen.dart';
import 'outfit_generator_screen.dart';
import '../theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  final NotchBottomBarController _controller = NotchBottomBarController(
    index: 0,
  );

  final screens = const [
    ClosetScreen(),
    UploadScreen(),
    OutfitGeneratorScreen(),
  ];

  Color getBackgroundColor(int index) {
    switch (index) {
      case 0:
        return AppColors.platinum;
      case 1:
        return AppColors.thistle;
      case 2:
        return AppColors.tealMist;
      default:
        return AppColors.platinum;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: getBackgroundColor(index),
      appBar: AppBar(
        backgroundColor: getBackgroundColor(index),
        elevation: 0,
        title: SizedBox(
          height: 120, // Aumentado de 40 a 120 para mejor visibilidad
          child: Image.asset(
            'assets/logo_home.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                'Closet Virtual',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.darkText),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80), // Aumentado de 60 a 80 para dar más espacio
            child: screens[index],
          ),

          // if (index == 1)
          //   Positioned(
          //     bottom: 120, // Aumentado de 76 a 120 para separarlo más de la barra
          //     right: 16,
          //     child: FloatingActionButton(
          //       backgroundColor: AppColors.thistle,
          //       onPressed: () {
          //         // acción para subir ropa
          //       },
          //       child: const Icon(Icons.add),
          //     ),
          //   ),
        ],
      ),

      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        kIconSize: 24.0,
        kBottomRadius: 28.0,
        color: Colors.black,
        notchColor: getBackgroundColor(index),
        showLabel: false,
        bottomBarItems: [
          BottomBarItem(
            inActiveItem: const Icon(
              Icons.checkroom_outlined,
              color: Colors.white,
            ),
            activeItem: const Icon(Icons.checkroom, color: Colors.pinkAccent),
          ),
          BottomBarItem(
            inActiveItem: const Icon(
              Icons.upload_file_outlined,
              color: Colors.white,
            ),
            activeItem: const Icon(Icons.upload_file, color: Color(0xFF5B61B2)),
          ),
          BottomBarItem(
            inActiveItem: const Icon(
              Icons.auto_awesome_outlined,
              color: Colors.white,
            ),
            activeItem: const Icon(
              Icons.auto_awesome,
              color: Color(0xFF2B2B2B),
            ),
          ),
        ],
        onTap: (selectedIndex) {
          setState(() {
            index = selectedIndex;
          });
        },
      ),
    );
  }
}
