import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseStorageDataSource {
  Future<List<String>> uploadImages(List<File> images, String orderId, String clientId);
  Future<void> deleteImage(String imageUrl);
  Future<List<String>> getImagesForClient(String orderId, String clientId);
}

class SupabaseStorageDataSourceImpl implements SupabaseStorageDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<String>> uploadImages(List<File> images, String orderId, String clientId) async {
    try {
      List<String> uploadedUrls = [];
      
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final fileName = '${orderId}_${clientId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final filePath = 'order_images/$fileName';
        
        // Upload file to Supabase Storage
        await _supabase.storage
            .from('order-images')
            .upload(filePath, file);
        
        // Get public URL
        final imageUrl = _supabase.storage
            .from('order-images')
            .getPublicUrl(filePath);
        
        uploadedUrls.add(imageUrl);
      }
      
      return uploadedUrls;
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  @override
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final filePath = pathSegments.sublist(2).join('/'); // Skip 'storage/v1/object/public/order-images'
      
      await _supabase.storage
          .from('order-images')
          .remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  @override
  Future<List<String>> getImagesForClient(String orderId, String clientId) async {
    try {
      // This would typically query a database table that stores image URLs
      // For now, we'll return an empty list as the images are stored in the order data
      return [];
    } catch (e) {
      throw Exception('Failed to get images: $e');
    }
  }
} 