import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations.dart';
import 'closet_screen.dart';
import 'outfit_generator_screen.dart';
import 'upload_screen.dart';
import 'profile_screen.dart';
import 'create_clothing_screen.dart';
import 'history_screen.dart';
import 'laundry_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final Function(String) onLanguageChanged;
  
  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLanguageChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  String? _profileImageUrl;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
        return AppColors.littleBoyBlue;
      default:
        return AppColors.platinum;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('avatar_url')
            .eq('user_id', user.id)
            .single();
        
        if (response != null && response['avatar_url'] != null) {
          setState(() {
            _profileImageUrl = response['avatar_url'];
          });
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  void _updateProfileImage(String? newImageUrl) {
    setState(() {
      _profileImageUrl = newImageUrl;
    });
    print('Profile image updated in HomeScreen: $newImageUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor(_currentIndex),
      endDrawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: getBackgroundColor(_currentIndex),
        elevation: 0,
        title: SizedBox(
          height: 120,
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
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.liberty,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child: _profileImageUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 24,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (selectedIndex) {
          setState(() {
            _currentIndex = selectedIndex;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: getBackgroundColor(_currentIndex),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom_outlined),
            activeIcon: Icon(Icons.checkroom),
            label: AppLocalizations.of(context).closet,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: AppLocalizations.of(context).add,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: AppLocalizations.of(context).generate,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.thistle, AppColors.platinum],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : null,
                    child: _profileImageUrl == null
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).myProfile,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu Items
            _buildDrawerItem(
              icon: Icons.person,
              title: AppLocalizations.of(context).viewProfile,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      onProfileImageUpdated: _updateProfileImage,
                    ),
                  ),
                );
              },
            ),
            
            _buildDrawerItem(
              icon: Icons.add_circle,
              title: AppLocalizations.of(context).create,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateClothingScreen()),
                );
              },
            ),
            
            _buildDrawerItem(
              icon: Icons.history,
              title: AppLocalizations.of(context).history,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
            ),
            
            _buildDrawerItem(
              icon: Icons.local_laundry_service,
              title: AppLocalizations.of(context).laundry,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LaundryScreen()),
                );
              },
            ),
            
            _buildDrawerItem(
              icon: Icons.settings,
              title: AppLocalizations.of(context).settings,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      onThemeChanged: widget.onThemeChanged,
                      onLanguageChanged: widget.onLanguageChanged,
                    ),
                  ),
                );
              },
            ),
            
            const Divider(color: Colors.white54, height: 32),
            
            // Log Out
            _buildDrawerItem(
              icon: Icons.logout,
              title: AppLocalizations.of(context).logout,
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Colors.white,
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : Colors.white,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
