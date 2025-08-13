import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import '../localization/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  final Function(String?)? onProfileImageUpdated;
  
  const ProfileScreen({super.key, this.onProfileImageUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  String? _profileImageUrl;
  File? _selectedImage;
  String? _userEmail;
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _ensureAvatarBucketExists();
  }

  Future<void> _ensureAvatarBucketExists() async {
    try {
      final buckets = await Supabase.instance.client.storage.listBuckets();
      final avatarBucket = buckets.firstWhere(
        (bucket) => bucket.name == 'avatars',
        orElse: () => throw Exception('Bucket avatars no encontrado'),
      );
      
      if (avatarBucket.public) {
        await _verifyBucketPolicies();
      } else {
        _showBucketSetupInstructions();
      }
    } catch (e) {
      _showBucketSetupInstructions();
    }
  }

  void _showBucketSetupInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar Bucket de Avatares'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Para que las imágenes de perfil funcionen, necesitas ejecutar este SQL en Supabase:',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                '1. Ve a Supabase Dashboard → SQL Editor',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                '2. Ejecuta el SQL que se muestra a continuación',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 16),
              Text(
                'SQL a ejecutar:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              SelectableText(
                '''-- Crear bucket para avatares
                      INSERT INTO storage.buckets (id, name, public) 
                      VALUES ('avatars', 'avatars', true) 
                      ON CONFLICT (id) DO NOTHING;

                      -- Políticas RLS
                      CREATE POLICY "Public Access" ON storage.objects
                        FOR SELECT USING (bucket_id = 'avatars');

                      CREATE POLICY "Users can upload avatars" ON storage.objects
                        FOR INSERT WITH CHECK (
                          bucket_id = 'avatars' AND 
                          auth.role() = 'authenticated'
                        );''',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  backgroundColor: AppColors.platinum,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _createAvatarBucketIfNeeded() async {
    try {
      await Supabase.instance.client.rpc('create_avatar_bucket');
      
    } catch (e) {
      print('No se pudo crear el bucket automáticamente: $e');
      print('Se requiere configuración manual en Supabase');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Bucket creado pero se requieren políticas RLS. Ejecuta el SQL en Supabase.',
              style: TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: 'Ver SQL',
              textColor: Colors.white,
              onPressed: () {
                _showPoliciesSetupInstructions();
              },
            ),
          ),
        );
      }
    }
  }

  void _showPoliciesSetupInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar Políticas RLS'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'El bucket se creó pero necesitas configurar las políticas RLS:',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                '1. Ve a Supabase Dashboard → SQL Editor',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                '2. Ejecuta este SQL para las políticas:',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 16),
              SelectableText(
                '''-- Habilitar RLS si no está habilitado
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes
DROP POLICY IF EXISTS "Enable read access for all users" ON storage.objects;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON storage.objects;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON storage.objects;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON storage.objects;

-- Crear políticas correctas para bucket avatars
CREATE POLICY "Enable read access for all users" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Enable insert for authenticated users only" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'avatars' AND 
    auth.role() = 'authenticated'
  );

CREATE POLICY "Enable update for authenticated users only" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'avatars' AND 
    auth.role() = 'authenticated'
  );

CREATE POLICY "Enable delete for authenticated users only" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'avatars' AND 
    auth.role() = 'authenticated'
  );

-- Verificar políticas
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'objects';''',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  backgroundColor: AppColors.platinum,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyBucketPolicies() async {
    try {
      // Probar operaciones específicas para verificar cada política
      bool selectWorks = false;
      bool insertWorks = false;
      bool updateWorks = false;
      bool deleteWorks = false;
      
      // Probar SELECT (debería funcionar para todos)
      try {
        final files = await Supabase.instance.client.storage
            .from('avatars')
            .list(path: '');
        selectWorks = true;
      } catch (e) {
        print('❌ Política SELECT falla: $e');
      }
      
      // Probar INSERT (crear un archivo de prueba)
      try {
        // Crear un archivo de imagen de prueba temporal (1x1 pixel PNG)
        final tempDir = await getTemporaryDirectory();
        final testFile = File('${tempDir.path}/test_${DateTime.now().millisecondsSinceEpoch}.png');
        
        // Crear un PNG válido de 1x1 pixel (bytes mínimos para un PNG)
        final pngBytes = [
          0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
          0x00, 0x00, 0x00, 0x0D, // IHDR chunk length
          0x49, 0x48, 0x44, 0x52, // IHDR
          0x00, 0x00, 0x00, 0x01, // width: 1
          0x00, 0x00, 0x00, 0x01, // height: 1
          0x08, 0x02, 0x00, 0x00, 0x00, // bit depth, color type, compression, filter, interlace
          0x90, 0x77, 0x53, 0xDE, // CRC
          0x00, 0x00, 0x00, 0x0C, // IDAT chunk length
          0x49, 0x44, 0x41, 0x54, // IDAT
          0x08, 0x99, 0x01, 0x01, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, // compressed data
          0xE2, 0x21, 0xBC, 0x33, // CRC
          0x00, 0x00, 0x00, 0x00, // IEND chunk length
          0x49, 0x45, 0x4E, 0x44, // IEND
          0xAE, 0x42, 0x60, 0x82  // CRC
        ];
        
        await testFile.writeAsBytes(pngBytes);
        
        final testFileName = 'test_${DateTime.now().millisecondsSinceEpoch}.png';
        
        await Supabase.instance.client.storage
            .from('avatars')
            .upload(testFileName, testFile);
        
        insertWorks = true;
        
        // Limpiar archivo de prueba
        try {
          await Supabase.instance.client.storage
              .from('avatars')
              .remove([testFileName]);
        } catch (e) {
          print('⚠️ No se pudo eliminar archivo de prueba: $e');
        }
        
        // Limpiar archivo temporal local
        try {
          await testFile.delete();
        } catch (e) {
          print('⚠️ No se pudo eliminar archivo temporal local: $e');
        }
        
      } catch (e) {
        print('❌ Política INSERT falla: $e');
      }
      
      // Verificar estado general
      if (selectWorks && insertWorks) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Bucket de avatares configurado correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '❌ Algunas políticas RLS no funcionan. Revisa la configuración.',
                style: TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'Ver SQL',
                textColor: Colors.white,
                onPressed: () {
                  _showPoliciesSetupInstructions();
                },
              ),
            ),
          );
        }
      }
      
    } catch (e) {
      print('Error verificando políticas: $e');
      print('Las políticas RLS pueden no estar configuradas correctamente');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '❌ Error verificando políticas RLS. Configuración manual requerida.',
              style: TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Ver SQL',
              textColor: Colors.white,
              onPressed: () {
                _showPoliciesSetupInstructions();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _userEmail = user.email;
        
        // Cargar perfil existente
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('user_id', user.id)
            .single();
        
        if (response != null) {
          setState(() {
            _nameController.text = response['name'] ?? '';
            _phoneController.text = response['phone'] ?? '';
            _ageController.text = response['age']?.toString() ?? '';
            _heightController.text = response['height']?.toString() ?? '';
            _weightController.text = response['weight']?.toString() ?? '';
            _profileImageUrl = response['avatar_url'];
          });
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      // Si no existe perfil, crear uno básico
      await _createBasicProfile();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createBasicProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('profiles')
            .insert({
              'user_id': user.id,
              'name': '',
              'email': user.email,
              'phone': '',
              'age': null,
              'height': null,
              'weight': null,
              'avatar_url': null,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
      }
    } catch (e) {
      print('Error creating basic profile: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seleccionar la imagen')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        String? avatarUrl = _profileImageUrl;

        // Subir nueva imagen si se seleccionó una
        if (_selectedImage != null) {
          try {
            final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
            
            // Subir la imagen al bucket avatars directamente
            final response = await Supabase.instance.client.storage
                .from('avatars')
                .upload(fileName, _selectedImage!);
            
            if (response.isNotEmpty) {
              // Obtener la URL pública de la imagen
              avatarUrl = Supabase.instance.client.storage
                  .from('avatars')
                  .getPublicUrl(fileName);
            }
          } catch (uploadError) {
            print('Error uploading image: $uploadError');
            
            // Mostrar error específico según el tipo de error
            String errorMessage = 'Error al subir la imagen';
            if (uploadError.toString().contains('403')) {
              errorMessage = 'Error de permisos. Verifica la configuración del bucket.';
            } else if (uploadError.toString().contains('bucket')) {
              errorMessage = 'Bucket de almacenamiento no encontrado.';
            } else if (uploadError.toString().contains('Unauthorized')) {
              errorMessage = 'No tienes permisos para subir imágenes.';
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
            return; // No continuar si la imagen no se subió
          }
        }

        // Actualizar perfil existente en la base de datos
        await Supabase.instance.client
            .from('profiles')
            .update({
              'name': _nameController.text.trim(),
              'email': _userEmail,
              'phone': _phoneController.text.trim(),
              'age': int.tryParse(_ageController.text) ?? null,
              'height': double.tryParse(_heightController.text) ?? null,
              'weight': double.tryParse(_weightController.text) ?? null,
              'avatar_url': avatarUrl,
            })
            .eq('user_id', user.id);

        setState(() {
          _profileImageUrl = avatarUrl;
          _selectedImage = null;
          _isEditing = false;
        });

        // Notificar a otras pantallas que la imagen de perfil cambió
        if (widget.onProfileImageUpdated != null) {
          widget.onProfileImageUpdated!(avatarUrl);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).profileUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).errorSavingProfile}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).profileTitle,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.thistle,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveProfile,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image
                    GestureDetector(
                      onTap: _isEditing ? _pickImage : null,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.thistle.withOpacity(0.2),
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (_profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : null),
                            child: (_selectedImage == null && _profileImageUrl == null)
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.thistle,
                                  )
                                : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.thistle,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).fullName,
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context).pleaseEnterName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field (read-only)
                    TextFormField(
                      initialValue: _userEmail,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).email,
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).phone,
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Age Field
                    TextFormField(
                      controller: _ageController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).age,
                        prefixIcon: const Icon(Icons.cake),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final age = int.tryParse(value);
                          if (age == null || age < 0 || age > 120) {
                            return AppLocalizations.of(context).invalidAge;
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Height Field
                    TextFormField(
                      controller: _heightController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${AppLocalizations.of(context).height} (cm)',
                        prefixIcon: const Icon(Icons.height),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final height = double.tryParse(value);
                          if (height == null || height < 50 || height > 250) {
                            return AppLocalizations.of(context).invalidHeight;
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Weight Field
                    TextFormField(
                      controller: _weightController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${AppLocalizations.of(context).weight} (kg)',
                        prefixIcon: const Icon(Icons.monitor_weight),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final weight = double.tryParse(value);
                          if (weight == null || weight < 20 || weight > 300) {
                            return AppLocalizations.of(context).invalidWeight;
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.thistle,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context).save,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
} 