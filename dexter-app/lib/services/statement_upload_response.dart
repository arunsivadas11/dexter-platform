class StatementUploadResponse {
  final String uploadId;
  final String? objectPath;
  final int? fileSizeBytes;
  final int recordCount;
  final int? maxColumnCount;
  final String status;

  const StatementUploadResponse({
    required this.uploadId,
    required this.recordCount,
    required this.status,
    this.objectPath,
    this.fileSizeBytes,
    this.maxColumnCount,
  });

  factory StatementUploadResponse.fromJson(Map<String, dynamic> json) {
    final uploadId = json['uploadId'];
    final recordCount = json['recordCount'];
    final status = json['status'];
    if (uploadId is! String || uploadId.trim().isEmpty) {
      throw const FormatException('Missing upload ID.');
    }
    if (recordCount is! num || status is! String || status.trim().isEmpty) {
      throw const FormatException('Missing upload details.');
    }

    return StatementUploadResponse(
      uploadId: uploadId,
      objectPath: json['objectPath'] as String?,
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt(),
      recordCount: recordCount.toInt(),
      maxColumnCount: (json['maxColumnCount'] as num?)?.toInt(),
      status: status,
    );
  }
}

class StatementUploadException implements Exception {
  final String message;

  const StatementUploadException(this.message);

  @override
  String toString() => message;
}
