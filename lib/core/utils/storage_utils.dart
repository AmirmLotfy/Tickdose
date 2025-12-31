class StorageUtils {
  /// localized standard size for thumbnails in Tickdose
  static const String thumbnailSize = '200x200';

  /// Derives the storage path (filename) for a resized image based on the original filename.
  /// 
  /// Example: 
  /// Original: `.../medicine_123.jpg`
  /// Result: `.../medicine_123_200x200.jpg`
  ///
  /// Note: This manipulated the *filename*, not the full download URL with tokens. 
  /// You should use this to get a Reference, then call getDownloadURL().
  static String getThumbnailFilename(String originalFilename, [String size = thumbnailSize]) {
    final dotIndex = originalFilename.lastIndexOf('.');
    if (dotIndex == -1) return '${originalFilename}_$size';
    
    final name = originalFilename.substring(0, dotIndex);
    final extension = originalFilename.substring(dotIndex);
    return '${name}_$size$extension';
  }
}
