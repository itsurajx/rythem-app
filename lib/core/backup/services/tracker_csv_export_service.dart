import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../database/models/beat_entity.dart';
import '../../database/models/chapter_entity.dart';
import '../../database/models/roadmap_entity.dart';

/// Builds and exports per-tracker CSV progress reports to local storage.
class TrackerCsvExportService {
  const TrackerCsvExportService();

  static const String headerRow =
      'topic-name,topic start date,topic end date,total number of days taken to finish that topic';

  /// Builds an RFC-4180 CSV string for all topics in [roadmap], ordered by
  /// chapter sequence and beat sequence.
  String buildCsv({
    required RoadmapEntity roadmap,
    required List<ChapterEntity> chapters,
    required List<BeatEntity> beats,
  }) {
    final chapterOrder = <String, int>{
      for (int i = 0; i < chapters.length; i++) chapters[i].id: chapters[i].sortOrder,
    };

    final sortedBeats = List<BeatEntity>.from(beats)
      ..sort((a, b) {
        final chA = chapterOrder[a.chapterId] ?? 999;
        final chB = chapterOrder[b.chapterId] ?? 999;
        if (chA != chB) return chA.compareTo(chB);
        final sortCmp = a.sortOrder.compareTo(b.sortOrder);
        if (sortCmp != 0) return sortCmp;
        return a.createdAt.compareTo(b.createdAt);
      });

    final buffer = StringBuffer()..writeln(headerRow);
    for (final beat in sortedBeats) {
      final startDateStr = beat.startedAt != null ? _formatDate(beat.startedAt!) : '';
      final endDateStr = (beat.isCompleted && beat.completedAt != null)
          ? _formatDate(beat.completedAt!)
          : '';
      final daysTakenStr = _calculateDaysTaken(beat);

      buffer.writeln([
        escapeCsvField(beat.title),
        escapeCsvField(startDateStr),
        escapeCsvField(endDateStr),
        escapeCsvField(daysTakenStr),
      ].join(','));
    }

    return buffer.toString();
  }

  /// Generates a filesystem-safe `.csv` filename for [roadmap].
  String suggestedFileName(RoadmapEntity roadmap) {
    final sanitized = roadmap.title
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final base = sanitized.isEmpty ? 'tracker' : sanitized;
    return '${base}_topics.csv';
  }

  /// Exports [roadmap]'s topics CSV to local storage using the native save
  /// dialog (or directly to [customPath] when provided). Returns null if the
  /// user cancels the save dialog.
  Future<File?> exportTrackerCsvToFile({
    required RoadmapEntity roadmap,
    required List<ChapterEntity> chapters,
    required List<BeatEntity> beats,
    String? customPath,
  }) async {
    final csvContent = buildCsv(
      roadmap: roadmap,
      chapters: chapters,
      beats: beats,
    );
    final fileName = suggestedFileName(roadmap);

    if (customPath != null && customPath.isNotEmpty) {
      final target = customPath.endsWith('.csv') ? customPath : '$customPath.csv';
      final customFile = File(target);
      if (!customFile.parent.existsSync()) {
        await customFile.parent.create(recursive: true);
      }
      await customFile.writeAsString(csvContent);
      return customFile;
    }

    File? safeLocalFile;
    try {
      final directory = await getApplicationDocumentsDirectory();
      safeLocalFile = File('${directory.path}/$fileName');
      await safeLocalFile.writeAsString(csvContent);
    } catch (_) {}

    try {
      final bytes = Uint8List.fromList(utf8.encode(csvContent));
      final pickedResult = await FilePicker.saveFile(
        dialogTitle: 'Save Tracker CSV',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['csv'],
        bytes: bytes,
      );

      if (pickedResult == null) {
        return null;
      }

      if (pickedResult.scheme == 'content') {
        return safeLocalFile ?? File(pickedResult.path);
      }

      String rawPath;
      try {
        rawPath = pickedResult.toFilePath();
      } catch (_) {
        rawPath = pickedResult.path;
      }
      final destPath = rawPath.endsWith('.csv') ? rawPath : '$rawPath.csv';
      final destFile = File(destPath);
      try {
        if (!destFile.parent.existsSync()) {
          await destFile.parent.create(recursive: true);
        }
        if (!destFile.existsSync() || (await destFile.length()) == 0) {
          await destFile.writeAsString(csvContent);
        }
        return destFile;
      } catch (_) {
        return safeLocalFile ?? destFile;
      }
    } catch (e) {
      if (safeLocalFile != null && safeLocalFile.existsSync()) {
        return safeLocalFile;
      }
      rethrow;
    }
  }

  static String escapeCsvField(String value) {
    final needsQuoting = value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    if (!needsQuoting) return value;
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  static String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  static String _calculateDaysTaken(BeatEntity beat) {
    if (!beat.isCompleted || beat.completedAt == null || beat.startedAt == null) {
      return '';
    }
    final startDay = DateTime(beat.startedAt!.year, beat.startedAt!.month, beat.startedAt!.day);
    final endDay = DateTime(beat.completedAt!.year, beat.completedAt!.month, beat.completedAt!.day);
    final diffDays = endDay.difference(startDay).inDays;
    final inclusiveDays = diffDays < 0 ? 1 : diffDays + 1;
    return inclusiveDays.toString();
  }
}

