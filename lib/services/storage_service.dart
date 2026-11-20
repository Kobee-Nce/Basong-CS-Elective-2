import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import 'supabase_errors.dart';

/// Product images in the Supabase Storage bucket `product-images`.
class StorageService {
  StorageService(this._client);

  final SupabaseClient _client;

  static const bucket = 'product-images';

  /// Uploads the image and returns its public URL (saved in
  /// products.image_url).
  Future<String> uploadProductImage(PickedImage image) {
    return guard(() async {
      final safeName = image.fileName
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9._-]'), '_');
      final path =
          'products/${DateTime.now().millisecondsSinceEpoch}_$safeName';

      await _client.storage.from(bucket).uploadBinary(
        path,
        image.bytes,
        fileOptions: FileOptions(
          contentType: image.mimeType ?? _guessMime(safeName),
          upsert: false,
        ),
      );
      return _client.storage.from(bucket).getPublicUrl(path);
    });
  }

  /// Best-effort cleanup of an image we uploaded earlier. Bundled asset
  /// paths (the original items) are ignored.
  Future<void> deleteByPublicUrl(String? url) async {
    if (url == null) return;
    const marker = '/storage/v1/object/public/$bucket/';
    final index = url.indexOf(marker);
    if (index < 0) return;
    final path = Uri.decodeComponent(url.substring(index + marker.length));
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (_) {
      // The product change already succeeded; a leftover file is harmless.
    }
  }

  static String _guessMime(String name) {
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
