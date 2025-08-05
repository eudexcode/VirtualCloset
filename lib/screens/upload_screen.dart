import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../services/supabase_service.dart';

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
  
  String _selectedType = 'top';
  String? _selectedSubType;
  String? _selectedColor;
  String? _selectedStyle;

  final List<String> _types = ['top', 'bottom', 'onepiece', 'shoes', 'accessory'];
  final Map<String, List<String>> _subTypes = {
    'top': ['blusa', 'camiseta', 'chaqueta', 'suéter', 'camisa'],
    'bottom': ['pantalón', 'falda', 'shorts', 'jeans', 'leggings'],
    'onepiece': ['vestido', 'mono', 'jumpsuit', 'overol'],
    'shoes': ['zapatillas', 'zapatos', 'botas', 'sandalias', 'tenis'],
    'accessory': ['bolso', 'cinturón', 'gorra', 'bufanda', 'joyas', 'cartera'],
  };
  
  final List<String> _colors = ['rojo', 'negro', 'azul', 'blanco', 'verde', 'amarillo', 'rosa', 'gris', 'marrón', 'morado'];
  final List<String> _styles = ['casual', 'formal', 'deportivo', 'elegante', 'vintage', 'moderno'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
          title: Text(
            'Seleccionar Imagen',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.liberty),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.liberty),
                title: const Text('Galería'),
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
              child: const Text('Cancelar'),
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
      _selectedType = 'top';
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
                'Subir Nueva Prenda',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
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
                          'Selecciona una imagen primero',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkText.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Después podrás agregar la información de la prenda',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: AppColors.darkText.withOpacity(0.5),
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
              'Seleccionar Imagen',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
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
                                'Cambiar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
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
              const SizedBox(height: 16),
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
                      'Toca los botones de abajo para seleccionar una imagen',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: AppColors.darkText.withOpacity(0.6),
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
                    label: const Text('Cámara'),
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
                    label: const Text('Galería'),
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

            if (_selectedImage != null && _processedImage == null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _removeBackground,
                  icon: _isProcessing 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_fix_high),
                  label: Text(_isProcessing ? 'Procesando...' : 'Remover Fondo'),
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
              'Información de la Prenda',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16),

            // Nombre
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la prenda',
                hintText: 'Ej: Blusa roja Zara',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un nombre';
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
              items: _types.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _selectedSubType = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Subtipo
            DropdownButtonFormField<String>(
              value: _selectedSubType,
              decoration: InputDecoration(
                labelText: 'Subtipo (opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.style),
              ),
              items: _subTypes[_selectedType]?.map((subType) {
                return DropdownMenuItem(
                  value: subType,
                  child: Text(subType),
                );
              }).toList() ?? [],
              onChanged: (value) {
                setState(() {
                  _selectedSubType = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Color
            DropdownButtonFormField<String>(
              value: _selectedColor,
              decoration: InputDecoration(
                labelText: 'Color (opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.palette),
              ),
              items: _colors.map((color) {
                return DropdownMenuItem(
                  value: color,
                  child: Text(color),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedColor = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Estilo
            DropdownButtonFormField<String>(
              value: _selectedStyle,
              decoration: InputDecoration(
                labelText: 'Estilo (opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.style),
              ),
              items: _styles.map((style) {
                return DropdownMenuItem(
                  value: style,
                  child: Text(style),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStyle = value;
                });
              },
            ),
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
                    'Guardar Prenda',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
