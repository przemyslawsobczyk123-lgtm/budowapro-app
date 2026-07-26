abstract final class StoragePolicy {
  static const int maximumAttachmentBytes = 512 * 1024 * 1024;

  static const Set<String> supportedAttachmentExtensions = <String>{
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'txt',
    'csv',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'mp3',
    'm4a',
    'aac',
    'wav',
    'ogg',
    'opus',
  };
}
