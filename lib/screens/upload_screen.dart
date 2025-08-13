import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../localization/app_localizations.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  File? _selectedImage;
  Uint8List? _processedImage;
  bool _isLoading = false;
  bool _isProcessing = false;
  
  String _selectedType = '';
  String? _selectedSubType;
  String? _selectedColor;
  String? _selectedStyle;

  // Opciones que se cargarán desde la base de datos del usuario
  List<String> _types = [];
  Map<String, List<String>> _subTypes = {};
  List<String> _colors = [];
  List<String> _styles = [];
  
  // Datos de la base de datos
  List<Map<String, dynamic>> _existingTypes = [];
  List<Map<String, dynamic>> _existingSubtypes = [];
  List<Map<String, dynamic>> _existingStyles = [];
  List<Map<String, dynamic>> _existingColors = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    try {
      print('Loading existing data for upload screen...');
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }
      
      print('Loading data for user: ${user.id}');
      
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

      print('Raw responses for user ${user.id}:');
      print('Types: $typesResponse');
      print('Subtypes: $subtypesResponse');
      print('Styles: $stylesResponse');
      print('Colors: $colorsResponse');

      setState(() {
        _existingTypes = List<Map<String, dynamic>>.from(typesResponse);
        _existingSubtypes = List<Map<String, dynamic>>.from(subtypesResponse);
        _existingStyles = List<Map<String, dynamic>>.from(stylesResponse);
        _existingColors = List<Map<String, dynamic>>.from(colorsResponse);
        
        // Construir el mapa de tipos y subtipos desde la base de datos
        _subTypes.clear();
        for (final type in _existingTypes) {
          final typeName = type['name'] as String;
          final subtypesForType = _existingSubtypes
              .where((subtype) => subtype['type_id'] == type['id'])
              .map((subtype) => subtype['name'] as String)
              .toList();
          _subTypes[typeName] = subtypesForType;
        }
        
        // Poblar las listas de estilos y colores desde la base de datos
        _styles = _existingStyles.map((style) => style['name'] as String).toList();
        _colors = _existingColors.map((color) => color['name'] as String).toList();
        _types = _existingTypes.map((type) => type['name'] as String).toList();
        
        // Seleccionar el primer tipo si existe
        if (_types.isNotEmpty) {
          _selectedType = _types.first;
        }
      });
      
      print('Data loaded successfully for user ${user.id}:');
      print('Types: ${_existingTypes.length}');
      print('Subtypes: ${_existingSubtypes.length}');
      print('Styles: ${_existingStyles.length}');
      print('Colors: ${_existingColors.length}');
      print('Type-Subtypes map: $_subTypes');
      print('Styles list: $_styles');
      print('Colors list: $_colors');
      
      // Mostrar mensaje si no hay datos
      if (_existingTypes.isEmpty && _existingStyles.isEmpty && _existingColors.isEmpty) {
        print('⚠️ No hay datos en la base de datos para este usuario. Usa "Crear" para crear tipos, estilos y colores.');
      }
    } catch (e) {
      print('Error loading existing data: $e');
      // Inicializar con listas vacías si hay error
      setState(() {
        _existingTypes = [];
        _existingSubtypes = [];
        _existingStyles = [];
        _existingColors = [];
        _types = [];
        _subTypes = {};
        _styles = [];
        _colors = [];
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, maxWidth: 1024);
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _processedImage = null;
        });
      }
    } catch (e) {
      _showError('Error al seleccionar la imagen: $e');
    }
  }

  Future<void> _removeBackground() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final processedBytes = await SupabaseService.removeBackground(_selectedImage!);
      
      if (processedBytes != null) {
        setState(() {
          _processedImage = processedBytes;
          _isProcessing = false;
        });
        _showSuccess('¡Fondo removido exitosamente!');
      } else {
        setState(() {
          _isProcessing = false;
        });
        _showError('Error al remover el fondo');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Error al procesar la imagen: $e');
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).camera),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.liberty),
                title: Text(AppLocalizations.of(context).camera),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.liberty),
                title: Text(AppLocalizations.of(context).gallery),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).cancel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveClothing() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      _showError('Por favor completa todos los campos requeridos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Subir imagen a Supabase Storage
      String? imageUrl;
      if (_processedImage != null) {
        // Guardar imagen procesada temporalmente
        final tempFile = File('${Directory.systemTemp.path}/processed_${DateTime.now().millisecondsSinceEpoch}.png');
        await tempFile.writeAsBytes(_processedImage!);
        imageUrl = await SupabaseService.uploadImage(tempFile);
        await tempFile.delete();
      } else {
        imageUrl = await SupabaseService.uploadImage(_selectedImage!);
      }

      if (imageUrl == null) {
        throw Exception('Error al subir la imagen');
      }

      // Guardar en la base de datos
      final success = await SupabaseService.saveClothing(
        name: _nameController.text.trim(),
        type: _selectedType,
        subType: _selectedSubType,
        imageUrl: imageUrl,
        color: _selectedColor,
        style: _selectedStyle,
      );

      if (success) {
        _showSuccess('¡Prenda guardada exitosamente!');
        _resetForm();
      } else {
        _showError('Error al guardar la prenda');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _selectedImage = null;
      _processedImage = null;
      _nameController.clear();
      _selectedType = '';
      _selectedSubType = null;
      _selectedColor = null;
      _selectedStyle = null;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              Text(
                AppLocalizations.of(context).addNewClothing,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3, end: 0),

              const SizedBox(height: 24),

              // Selección de imagen
              _buildImageSection()
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideX(begin: -0.3, end: 0),

              // Solo mostrar formulario si hay imagen seleccionada
              if (_selectedImage != null || _processedImage != null) ...[
                const SizedBox(height: 24),

                // Formulario
                _buildFormSection()
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideX(begin: -0.3, end: 0),

                const SizedBox(height: 24),

                // Botón de guardar
                _buildSaveButton()
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
              ] else ...[
                // Mensaje cuando no hay imagen
                const SizedBox(height: 32),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.photo_camera,
                          size: 64,
                          color: AppColors.thistle.withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).selectImageFirst,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).thenAddClothingInfo,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context).selectImage,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).tapButtonsBelow,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            if (_selectedImage != null || _processedImage != null) ...[
              GestureDetector(
                onTap: () => _showImagePickerDialog(),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.softPink, width: 2),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _processedImage != null
                            ? Image.memory(
                                _processedImage!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Image.file(
                                _selectedImage!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context).change,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (_selectedImage != null && _processedImage == null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _removeBackground,
                    icon: _isProcessing 
                        ? const SizedBox(
                            width: 16, 
                            height: 16, 
                            child: CircularProgressIndicator(strokeWidth: 2)
                          )
                        : const Icon(Icons.auto_fix_high),
                    label: Text(
                      _isProcessing 
                          ? AppLocalizations.of(context).processing 
                          : AppLocalizations.of(context).removeBackground
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.liberty,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ] else ...[
              // Placeholder cuando no hay imagen
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.thistle.withOpacity(0.3), style: BorderStyle.solid),
                  color: AppColors.thistle.withOpacity(0.1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 48,
                      color: AppColors.thistle.withOpacity(0.6),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).tapButtonsBelow,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(AppLocalizations.of(context).camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.thistle,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text(AppLocalizations.of(context).gallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.thistle,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context).garmentInformation,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16),

            // Nombre
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).garmentName,
                hintText: 'Ej: Blusa roja Zara',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context).pleaseEnterName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tipo
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _types.isNotEmpty 
                  ? _types.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toUpperCase()),
                      );
                    }).toList()
                  : [DropdownMenuItem(value: '', child: Text('No hay tipos disponibles'))],
              onChanged: _types.isNotEmpty ? (value) {
                setState(() {
                  _selectedType = value!;
                  _selectedSubType = null;
                });
              } : null,
            ),
            if (_types.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'No has creado ningún tipo de ropa. Ve a "Crear" para crear tu primer tipo.',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Subtipo
            DropdownButtonFormField<String>(
              value: _selectedSubType,
              decoration: InputDecoration(
                labelText: 'Subtipo',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.style),
              ),
              items: _subTypes[_selectedType]?.isNotEmpty == true
                  ? _subTypes[_selectedType]!.map((subType) {
                      return DropdownMenuItem(
                        value: subType,
                        child: Text(subType),
                      );
                    }).toList()
                  : [DropdownMenuItem(value: '', child: Text('No hay subtipos disponibles'))],
              onChanged: _subTypes[_selectedType]?.isNotEmpty == true ? (value) {
                setState(() {
                  _selectedSubType = value;
                });
              } : null,
            ),
            if (_subTypes[_selectedType]?.isEmpty ?? true) ...[
              const SizedBox(height: 8),
              Text(
                'No has creado subtipos para este tipo. Ve a "Crear" para crear subtipos.',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Color
            DropdownButtonFormField<String>(
              value: _selectedColor,
              decoration: InputDecoration(
                labelText: 'Color',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.palette),
              ),
              items: _colors.isNotEmpty
                  ? _colors.map((color) {
                      return DropdownMenuItem(
                        value: color,
                        child: Text(color),
                      );
                    }).toList()
                  : [DropdownMenuItem(value: '', child: Text('No hay colores disponibles'))],
              onChanged: _colors.isNotEmpty ? (value) {
                setState(() {
                  _selectedColor = value;
                });
              } : null,
            ),
            if (_colors.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'No has creado ningún color. Ve a "Crear" para crear tu primer color.',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Estilo
            DropdownButtonFormField<String>(
              value: _selectedStyle,
              decoration: InputDecoration(
                labelText: 'Estilo',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.style),
              ),
              items: _styles.isNotEmpty
                  ? _styles.map((style) {
                      return DropdownMenuItem(
                        value: style,
                        child: Text(style),
                      );
                    }).toList()
                  : [DropdownMenuItem(value: '', child: Text('No hay estilos disponibles'))],
              onChanged: _styles.isNotEmpty ? (value) {
                setState(() {
                  _selectedStyle = value;
                });
              } : null,
            ),
            if (_styles.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'No has creado ningún estilo. Ve a "Crear" para crear tu primer estilo.',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveClothing,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.thistle,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).saveGarment,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
