import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../localization/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final Function(String) onLanguageChanged;
  
  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLanguageChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _outfitNotificationsEnabled = true;
  bool _laundryNotificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoSaveEnabled = true;
  String _selectedLanguage = 'Español';
  String _selectedTheme = 'Automático';
  
  // Variables para rastrear cambios
  String _previousLanguage = 'Español';
  String _previousTheme = 'Automático';
  bool _previousDarkMode = false;
  
  // Animaciones
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _languages = ['Español', 'English', 'Français'];
  
  // Lista de temas que se traducirá dinámicamente
  List<String> get _themes {
    return [
      AppLocalizations.of(context).automaticTheme,
      AppLocalizations.of(context).lightTheme,
      AppLocalizations.of(context).darkTheme,
    ];
  }
  
  // Obtener el tema traducido para mostrar en el dropdown
  String get _translatedSelectedTheme {
    switch (_selectedTheme) {
      case 'Automático':
        return AppLocalizations.of(context).automaticTheme;
      case 'Claro':
        return AppLocalizations.of(context).lightTheme;
      case 'Oscuro':
        return AppLocalizations.of(context).darkTheme;
      default:
        return AppLocalizations.of(context).automaticTheme;
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
    _loadSettings();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reconstruir cuando cambien las dependencias (como el idioma)
    setState(() {});
  }
  
  // Actualizar el tema seleccionado cuando cambie el idioma
  void _updateThemeForLanguage() {
    // Asegurarse de que el tema seleccionado sea válido para el idioma actual
    if (!_themes.contains(_translatedSelectedTheme)) {
      // Si el tema traducido no está en la lista, usar el valor por defecto
      setState(() {
        _selectedTheme = 'Automático';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('user_settings')
          .select()
          .eq('user_id', user.id)
          .single();

      if (response != null) {
        setState(() {
          _notificationsEnabled = response['notifications_enabled'] ?? true;
          _outfitNotificationsEnabled = response['outfit_notifications_enabled'] ?? true;
          _laundryNotificationsEnabled = response['laundry_notifications_enabled'] ?? true;
          _darkModeEnabled = response['dark_mode_enabled'] ?? false;
          _autoSaveEnabled = response['auto_save_enabled'] ?? true;
          _selectedLanguage = response['language'] ?? 'es';
          _selectedTheme = response['theme'] ?? 'Automático';
          
          // Inicializar valores previos
          _previousLanguage = _selectedLanguage;
          _previousTheme = _selectedTheme;
          _previousDarkMode = _darkModeEnabled;
        });
      } else {
        await _createDefaultSettings();
      }
    } catch (e) {
      if (e.toString().contains('No rows returned')) {
        await _createDefaultSettings();
      } else {
        print('Error loading settings: $e');
      }
    }
  }

  Future<void> _createDefaultSettings() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client
          .from('user_settings')
          .insert({
            'user_id': user.id,
            'notifications_enabled': true,
            'outfit_notifications_enabled': true,
            'laundry_notifications_enabled': true,
            'dark_mode_enabled': false,
            'auto_save_enabled': true,
            'language': 'Español',
            'theme': 'Automático', // Siempre en español en la base de datos
          });
      
      print('Default settings created successfully');
    } catch (e) {
      print('Error creating default settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      print('Saving settings for user: ${user.id}');
      print('Settings to save:');
      print('- notifications_enabled: $_notificationsEnabled');
      print('- outfit_notifications_enabled: $_outfitNotificationsEnabled');
      print('- laundry_notifications_enabled: $_laundryNotificationsEnabled');
      print('- dark_mode_enabled: $_darkModeEnabled');
      print('- auto_save_enabled: $_autoSaveEnabled');
      print('- language: $_selectedLanguage');
      print('- theme: $_selectedTheme');

      await Supabase.instance.client
          .from('user_settings')
          .update({
            'notifications_enabled': _notificationsEnabled,
            'outfit_notifications_enabled': _outfitNotificationsEnabled,
            'laundry_notifications_enabled': _laundryNotificationsEnabled,
            'dark_mode_enabled': _darkModeEnabled,
            'auto_save_enabled': _autoSaveEnabled,
            'language': _selectedLanguage,
            'theme': _selectedTheme,
          })
          .eq('user_id', user.id);
        
      print('Settings saved successfully');
      
      // Solo aplicar tema si realmente cambió
      bool themeChanged = (_selectedTheme != _previousTheme) || 
                         (_darkModeEnabled != _previousDarkMode);
      
      if (themeChanged) {
        // Convertir el tema traducido de vuelta a español para la base de datos
        String themeForDatabase = _convertThemeToSpanish(_selectedTheme);
        
        if (themeForDatabase == 'Oscuro' || (themeForDatabase == 'Automático' && _darkModeEnabled)) {
          _applyDarkTheme();
        } else {
          _applyLightTheme();
        }
        
        // Actualizar variables de rastreo
        _previousTheme = _selectedTheme;
        _previousDarkMode = _darkModeEnabled;
      }
      
      // Solo aplicar idioma si realmente cambió
      if (_selectedLanguage != _previousLanguage) {
        _applyLanguage(_selectedLanguage);
        _previousLanguage = _selectedLanguage;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).settingsSaved),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving settings: $e');
      print('Error details: ${e.toString()}');
      
      // Mostrar mensaje de error más específico
      String errorMessage = AppLocalizations.of(context).errorSaving;
      if (e.toString().contains('laundry_notifications_enabled')) {
        errorMessage = 'Error: Columna de notificaciones de lavado no encontrada. Ejecuta el SQL de actualización.';
      } else if (e.toString().contains('outfit_notifications_enabled')) {
        errorMessage = 'Error: Columna de notificaciones de outfits no encontrada. Ejecuta el SQL de actualización.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _applyDarkTheme() {
    // Cambiar el tema de toda la app a oscuro
    widget.onThemeChanged(true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).darkThemeApplied),
        backgroundColor: AppColors.darkMode,
      ),
    );
  }

  void _applyLightTheme() {
    // Cambiar el tema de toda la app a claro
    widget.onThemeChanged(false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).lightThemeApplied),
        backgroundColor: AppColors.lightMode,
      ),
    );
  }

  void _applyLanguage(String language) {
    // Cambiar el idioma de toda la app
    widget.onLanguageChanged(language);
    
    // Actualizar el tema para el nuevo idioma
    _updateThemeForLanguage();
    
    String message = '';
    switch (language) {
      case 'Español':
        message = AppLocalizations.of(context).languageChangedToSpanish;
        break;
      case 'English':
        message = AppLocalizations.of(context).languageChangedToEnglish;
        break;
      case 'Français':
        message = AppLocalizations.of(context).languageChangedToFrench;
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[600],
      ),
    );
  }
  
  // Aplicar el tema inicial al cargar la pantalla
  void _applyInitialTheme() {
    if (_selectedTheme == 'Oscuro' || (_selectedTheme == 'Automático' && _darkModeEnabled)) {
      widget.onThemeChanged(true);
    } else {
      widget.onThemeChanged(false);
    }
  }
  
  // Convertir el tema traducido de vuelta a español para la base de datos
  String _convertThemeToSpanish(String translatedTheme) {
    if (translatedTheme == AppLocalizations.of(context).automaticTheme) {
      return 'Automático';
    } else if (translatedTheme == AppLocalizations.of(context).lightTheme) {
      return 'Claro';
    } else if (translatedTheme == AppLocalizations.of(context).darkTheme) {
      return 'Oscuro';
    }
    return 'Automático'; // Valor por defecto si no coincide
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).settings,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.thistle,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
          // Notifications Section
          _buildSectionHeader(AppLocalizations.of(context).notifications),
          _buildSwitchTile(
            title: AppLocalizations.of(context).generalNotifications,
            subtitle: AppLocalizations.of(context).toggleAllNotifications,
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                // Si se desactivan las notificaciones generales, desactivar también las específicas
                if (!value) {
                  _outfitNotificationsEnabled = false;
                  _laundryNotificationsEnabled = false;
                }
              });
              _saveSettings();
            },
            icon: Icons.notifications,
          ),
          if (_notificationsEnabled) ...[
            const SizedBox(height: 8),
            _buildSwitchTile(
              title: AppLocalizations.of(context).outfitNotifications,
              subtitle: AppLocalizations.of(context).alertsAboutOutfitsAndSuggestions,
              value: _outfitNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _outfitNotificationsEnabled = value;
                });
                _saveSettings();
              },
              icon: Icons.checkroom,
            ),
            const SizedBox(height: 8),
            _buildSwitchTile(
              title: AppLocalizations.of(context).laundryNotifications,
              subtitle: AppLocalizations.of(context).remindersToWashDirtyClothes,
              value: _laundryNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _laundryNotificationsEnabled = value;
                });
                _saveSettings();
              },
              icon: Icons.local_laundry_service,
            ),
          ],

          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader(AppLocalizations.of(context).appearance),
          _buildDropdownTile(
            title: AppLocalizations.of(context).theme,
            subtitle: AppLocalizations.of(context).chooseAppTheme,
            value: _translatedSelectedTheme,
            items: _themes,
            onChanged: (value) {
              setState(() {
                _selectedTheme = _convertThemeToSpanish(value!);
              });
              _saveSettings();
            },
            icon: Icons.palette,
          ),
          _buildDropdownTile(
            title: AppLocalizations.of(context).language,
            subtitle: AppLocalizations.of(context).selectAppLanguage,
            value: _selectedLanguage,
            items: _languages,
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
              _saveSettings();
            },
            icon: Icons.language,
          ),

          const SizedBox(height: 24),

          // Data Section
          _buildSectionHeader(AppLocalizations.of(context).data),
          _buildSwitchTile(
            title: AppLocalizations.of(context).autoSave,
            subtitle: AppLocalizations.of(context).automaticallySaveYourChanges,
            value: _autoSaveEnabled,
            onChanged: (value) {
              setState(() {
                _autoSaveEnabled = value;
              });
              _saveSettings();
            },
            icon: Icons.save,
          ),
          _buildListTile(
            title: AppLocalizations.of(context).exportData,
            subtitle: AppLocalizations.of(context).downloadACopyOfYourData,
            icon: Icons.download,
            onTap: () {
              _showExportDialog();
            },
          ),
          _buildListTile(
            title: AppLocalizations.of(context).importData,
            subtitle: AppLocalizations.of(context).restoreDataFromAFile,
            icon: Icons.upload,
            onTap: () {
              _showImportDialog();
            },
          ),

          const SizedBox(height: 24),

          // Privacy Section
          _buildSectionHeader(AppLocalizations.of(context).privacy),
          _buildListTile(
            title: AppLocalizations.of(context).privacyPolicy,
            subtitle: AppLocalizations.of(context).readOurPrivacyPolicy,
            icon: Icons.privacy_tip,
            onTap: () {
              _showPrivacyPolicy();
            },
          ),
          _buildListTile(
            title: AppLocalizations.of(context).termsOfService,
            subtitle: AppLocalizations.of(context).readOurTermsOfService,
            icon: Icons.description,
            onTap: () {
              _showTermsOfService();
            },
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(AppLocalizations.of(context).about),
          _buildListTile(
            title: AppLocalizations.of(context).appVersion,
            subtitle: '1.0.0',
            icon: Icons.info,
            onTap: null,
          ),
          _buildListTile(
            title: AppLocalizations.of(context).developer,
            subtitle: 'EudexCode',
            icon: Icons.people,
            onTap: () {
              _showDevelopersInfo();
            },
          ),
          _buildListTile(
            title: AppLocalizations.of(context).contact,
            subtitle: AppLocalizations.of(context).sendUsAMessage,
            icon: Icons.contact_support,
            onTap: () {
              _showContactDialog();
            },
          ),

          const SizedBox(height: 32),

          // Reset Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showResetDialog,
              icon: const Icon(Icons.restore),
              label: Text(
                AppLocalizations.of(context).resetSettings,
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.thistle,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.thistle,
        secondary: Icon(
          icon,
          color: AppColors.thistle,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        leading: Icon(
          icon,
          color: AppColors.thistle,
        ),
        trailing: DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.montserrat(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        leading: Icon(
          icon,
          color: AppColors.thistle,
        ),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).exportData,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: Text(
          AppLocalizations.of(context).exportDataConfirmationMessage,
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).cancel,
              style: GoogleFonts.montserrat(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context).exportFunctionInDevelopment)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.thistle,
            ),
            child: Text(
              AppLocalizations.of(context).export,
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).importData,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: Text(
          AppLocalizations.of(context).importDataConfirmationMessage,
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).cancel,
              style: GoogleFonts.montserrat(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context).importFunctionInDevelopment)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.thistle,
            ),
            child: Text(
              AppLocalizations.of(context).import,
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).privacyPolicy,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Text(
            AppLocalizations.of(context).privacyPolicyContent,
            style: GoogleFonts.montserrat(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).close,
              style: GoogleFonts.montserrat(color: AppColors.thistle),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).termsOfService,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Text(
            AppLocalizations.of(context).termsOfServiceContent,
            style: GoogleFonts.montserrat(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).close,
              style: GoogleFonts.montserrat(color: AppColors.thistle),
            ),
          ),
        ],
      ),
    );
  }

  void _showDevelopersInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).developer,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EudexCode',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).developerMessage,
              style: GoogleFonts.montserrat(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).close,
              style: GoogleFonts.montserrat(color: AppColors.thistle),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).contact,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email, color: AppColors.thistle),
              title: Text(
                AppLocalizations.of(context).email,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'support@virtualcloset.com',
                style: GoogleFonts.montserrat(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.web, color: AppColors.thistle),
              title: Text(
                AppLocalizations.of(context).website,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'www.virtualcloset.com',
                style: GoogleFonts.montserrat(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).close,
              style: GoogleFonts.montserrat(color: AppColors.thistle),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).resetSettings,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: Text(
          AppLocalizations.of(context).resetSettingsConfirmationMessage,
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).cancel,
              style: GoogleFonts.montserrat(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notificationsEnabled = true;
                _outfitNotificationsEnabled = true;
                _laundryNotificationsEnabled = true;
                _darkModeEnabled = false;
                _autoSaveEnabled = true;
                _selectedLanguage = 'Español';
                _selectedTheme = 'Automático'; // En español para la base de datos
                
                // Resetear variables de rastreo
                _previousLanguage = 'Español';
                _previousTheme = 'Automático';
                _previousDarkMode = false;
              });
              _saveSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context).settingsReset)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              AppLocalizations.of(context).reset,
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
} 