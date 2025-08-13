import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations.dart';

class CreateClothingScreen extends StatefulWidget {
  const CreateClothingScreen({super.key});

  @override
  State<CreateClothingScreen> createState() => _CreateClothingScreenState();
}

class _CreateClothingScreenState extends State<CreateClothingScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _newItemController = TextEditingController();
  
  String _selectedCategoryToAdd = 'Tipo';
  String? _selectedParentType;
  List<Map<String, dynamic>> _existingTypes = [];
  List<Map<String, dynamic>> _existingSubtypes = [];
  List<Map<String, dynamic>> _existingStyles = [];
  List<Map<String, dynamic>> _existingColors = [];

  // Animaciones
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _loadExistingData();
  }

  @override
  void dispose() {
    _newItemController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }
      
      // Cargar tipos existentes del usuario actual
      final typesResponse = await Supabase.instance.client
          .from('Clothe_Types')
          .select()
          .eq('user_id', user.id)
          .order('name');
      
      // Cargar subtipos existentes del usuario actual con sus tipos padre
      final subtypesResponse = await Supabase.instance.client
          .from('Clothe_Subtypes')
          .select('*, Clothe_Types(name)')
          .eq('user_id', user.id)
          .order('name');
      
      // Cargar estilos existentes del usuario actual
      final stylesResponse = await Supabase.instance.client
          .from('Clothe_Styles')
          .select()
          .eq('user_id', user.id)
          .order('name');
      
      // Cargar colores existentes del usuario actual
      final colorsResponse = await Supabase.instance.client
          .from('Clothe_Colors')
          .select()
          .eq('user_id', user.id)
          .order('name');

      setState(() {
        _existingTypes = List<Map<String, dynamic>>.from(typesResponse);
        _existingSubtypes = List<Map<String, dynamic>>.from(subtypesResponse);
        _existingStyles = List<Map<String, dynamic>>.from(stylesResponse);
        _existingColors = List<Map<String, dynamic>>.from(colorsResponse);
      });
    } catch (e) {
      print('Error loading existing data: $e');
      setState(() {
        _existingTypes = [];
        _existingSubtypes = [];
        _existingStyles = [];
        _existingColors = [];
      });
    }
  }

  Future<void> _addNewCategory() async {
    if (_newItemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseEnterName)),
      );
      return;
    }

    if (_selectedCategoryToAdd == 'Subtipo' && (_selectedParentType == null || _selectedParentType!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseSelectParentType)),
      );
      return;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        Map<String, dynamic> newItem = {
          'name': _newItemController.text.trim(),
          'user_id': user.id,
        };

        switch (_selectedCategoryToAdd) {
          case 'Tipo':
            await Supabase.instance.client
                .from('Clothe_Types')
                .insert(newItem);
            break;
          case 'Subtipo':
            final parentType = _existingTypes.firstWhere(
              (type) => type['name'] == _selectedParentType,
              orElse: () => <String, dynamic>{},
            );
            if (parentType.isNotEmpty) {
              newItem['type_id'] = parentType['id'];
              await Supabase.instance.client
                  .from('Clothe_Subtypes')
                  .insert(newItem);
            } else {
              throw Exception(AppLocalizations.of(context).parentTypeNotFound);
            }
            break;
          case 'Estilo':
            await Supabase.instance.client
                .from('Clothe_Styles')
                .insert(newItem);
            break;
          case 'Color':
            await Supabase.instance.client
                .from('Clothe_Colors')
                .insert(newItem);
            break;
          default:
            throw Exception(AppLocalizations.of(context).invalidCategory);
        }

        // Limpiar formulario y recargar datos
        _newItemController.clear();
        _selectedParentType = null;
        await _loadExistingData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedCategoryToAdd} ${AppLocalizations.of(context).categoryAddedSuccessfully}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error adding new category: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).errorAddingCategory} ${_selectedCategoryToAdd.toLowerCase()}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).addNewCategory,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.thistle,
      ),
      body: _buildNewCategoriesTab(),
    );
  }

  Widget _buildNewCategoriesTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnimatedHeader(),
              const SizedBox(height: 24),
              _buildCategorySelector(),
              const SizedBox(height: 24),
              if (_selectedCategoryToAdd == 'Subtipo') ...[
                _buildParentTypeSelector(),
                const SizedBox(height: 24),
              ],
              _buildTextField(
                controller: _newItemController,
                label: '${AppLocalizations.of(context).garmentName} ${AppLocalizations.of(context).type.toLowerCase()}',
                icon: _getCategoryIcon(_selectedCategoryToAdd),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).pleaseEnterName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _buildAnimatedAddButton(),
              const SizedBox(height: 32),
              _buildExistingItemsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(-20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).addNewCategory,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).createClothingDescription,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 700),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).whatDoYouWantToAdd,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [AppLocalizations.of(context).type, AppLocalizations.of(context).subtype, AppLocalizations.of(context).style, AppLocalizations.of(context).color].map((category) {
                        final isSelected = _selectedCategoryToAdd == category;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryToAdd = category;
                              _selectedParentType = null;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.thistle 
                                  : Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected 
                                    ? AppColors.thistle 
                                    : Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.thistle.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(category),
                                  color: isSelected ? Colors.white : AppColors.thistle,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected 
                                        ? Colors.white 
                                        : Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParentTypeSelector() {
    if (_selectedCategoryToAdd != 'Subtipo') return const SizedBox.shrink();
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[600]!
                      : Colors.grey[300]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).parentType,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedParentType,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).selectParentType,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    dropdownColor: Theme.of(context).cardColor,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    items: _existingTypes.isNotEmpty
                        ? _existingTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type['name'],
                              child: Text(
                                type['name'],
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            );
                          }).toList()
                        : [DropdownMenuItem(
                            value: null,
                            child: Text(
                              'No hay tipos disponibles',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                              ),
                            ),
                          )],
                    onChanged: _existingTypes.isNotEmpty ? (value) {
                      setState(() {
                        _selectedParentType = value;
                      });
                    } : null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).pleaseSelectParentType;
                      }
                      return null;
                    },
                  ),
                  if (_existingTypes.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'No has creado ningún tipo. Crea un tipo primero antes de crear subtipos.',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.orange[300]
                            : Colors.orange[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedAddButton() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 900),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addNewCategory,
                icon: const Icon(Icons.add_circle),
                label: Text(
                  '${AppLocalizations.of(context).add} ${_selectedCategoryToAdd}',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.thistle.withOpacity(0.8)
                      : AppColors.thistle,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.thistle.withOpacity(0.4),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExistingItemsList() {
    List<Map<String, dynamic>> items = [];
    String title = '';
    
    switch (_selectedCategoryToAdd) {
      case 'Tipo':
        items = _existingTypes;
        title = AppLocalizations.of(context).existingTypes;
        break;
      case 'Subtipo':
        items = _existingSubtypes;
        title = AppLocalizations.of(context).existingSubtypes;
        break;
      case 'Estilo':
        items = _existingStyles;
        title = AppLocalizations.of(context).existingStyles;
        break;
      case 'Color':
        items = _existingColors;
        title = AppLocalizations.of(context).existingColors;
        break;
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[600]!
                      : Colors.grey[300]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty) ...[
                    Text(
                      'No has creado ningún ${_selectedCategoryToAdd.toLowerCase()} aún. Los que crees aparecerán aquí.',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ] else ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: items.map((item) {
                        String displayName = item['name'];
                        if (_selectedCategoryToAdd == 'Subtipo' && item['Clothe_Types'] != null) {
                          displayName = '${item['name']} (${item['Clothe_Types']['name']})';
                        }
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.thistle.withOpacity(0.2)
                                : AppColors.thistle.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.thistle.withOpacity(0.5)
                                  : AppColors.thistle.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            displayName,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Tipo':
        return Icons.category;
      case 'Subtipo':
        return Icons.subdirectory_arrow_right;
      case 'Estilo':
        return Icons.style;
      case 'Color':
        return Icons.palette;
      default:
        return Icons.category;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.thistle),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.thistle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.thistle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.thistle, width: 2),
        ),
        labelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }
} 