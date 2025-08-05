import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Subir imagen a Supabase Storage
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final filePath = 'clothes/$fileName';
      
      final bytes = await imageFile.readAsBytes();
      
      // Verificar si el archivo existe
      if (!await imageFile.exists()) {
        print('Error: El archivo no existe: ${imageFile.path}');
        return null;
      }
      
      // Verificar el tamaño del archivo
      final fileSize = await imageFile.length();
      print('Subiendo archivo: $fileName, tamaño: $fileSize bytes');
      
      await _client.storage.from('clothe-images').uploadBinary(filePath, bytes);
      
      final imageUrl = _client.storage.from('clothe-images').getPublicUrl(filePath);
      print('Imagen subida exitosamente: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      print('Error details: ${e.toString()}');
      return null;
    }
  }

  // Remover fondo usando remove.bg API
  static Future<Uint8List?> removeBackground(File imageFile) async {
    try {
      const apiKey = 'JD9ppKu6KhbEtBck4UAAAMHd';
      const apiUrl = 'https://api.remove.bg/v1.0/removebg';
      
      final bytes = await imageFile.readAsBytes();
      
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['X-Api-Key'] = apiKey
        ..files.add(http.MultipartFile.fromBytes(
          'image_file',
          bytes,
          filename: path.basename(imageFile.path),
        ))
        ..fields['size'] = 'auto';

      final response = await request.send();
      final responseBytes = await response.stream.toBytes();
      
      if (response.statusCode == 200) {
        return responseBytes;
      } else {
        print('Error removing background: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error removing background: $e');
      return null;
    }
  }

  // Guardar prenda en la base de datos
  static Future<bool> saveClothing({
    required String name,
    required String type,
    String? subType,
    String? imageUrl,
    String? color,
    String? style,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        print('Error: Usuario no autenticado');
        return false;
      }

      final result = await _client.from('Clothes').insert({
        'user_id': userId,
        'name': name,
        'type': type,
        'sub_type': subType,
        'image_url': imageUrl,
        'color': color,
        'style': style,
        'created_at': DateTime.now().toIso8601String().split('.')[0], // Formato compatible con timestamp
        'is_delete': false,
      });

      print('✅ Prenda guardada exitosamente: $result');
      return true;
    } catch (e) {
      print('❌ Error saving clothing: $e');
      print('❌ Error details: ${e.toString()}');
      print('❌ Error type: ${e.runtimeType}');
      return false;
    }
  }

  // Obtener prendas del usuario
  static Future<List<Map<String, dynamic>>> getClothes() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('Clothes')
          .select()
          .eq('user_id', userId)
          .eq('is_delete', false)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting clothes: $e');
      return [];
    }
  }

  // Eliminar prenda (borrado lógico)
  static Future<bool> deleteClothing(String id) async {
    try {
      await _client
          .from('Clothes')
          .update({'is_delete': true})
          .eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting clothing: $e');
      return false;
    }
  }
}
