import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    try {
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload the file to the 'profiles' bucket
      await _supabase.storage.from('profiles').upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      
      // Get the public URL
      final publicUrl = _supabase.storage.from('profiles').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      throw Exception('Gagal mengunggah gambar ke Supabase: $e');
    }
  }

  Future<void> deleteProfilePicture(String fileUrl) async {
    try {
      // Extract filename from URL if needed, though usually not strictly necessary 
      // if we're just overriding or leaving old ones. 
      // A more robust implementation would parse the filename from the URL to delete it.
      final uri = Uri.parse(fileUrl);
      final fileName = uri.pathSegments.last;
      await _supabase.storage.from('profiles').remove([fileName]);
    } catch (e) {
      // It's okay if the file doesn't exist when we try to delete it
    }
  }
}
