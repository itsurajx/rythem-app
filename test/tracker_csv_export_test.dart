import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rythem_app/core/backup/services/tracker_csv_export_service.dart';
import 'package:rythem_app/core/database/database.dart';
import 'package:rythem_app/core/theme/theme.dart';
import 'package:rythem_app/features/explore/explore_screen.dart';
import 'package:rythem_app/features/explore/roadmap_detail_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Beat startedAt Tracking & DB v3 Migration', () {
    setUp(() async {
      await DatabaseService.instance.initInMemoryForTesting();
    });

    tearDown(() async {
      await DatabaseService.instance.close();
    });

    test('markBeatStarted records initial startedAt and preserves it on subsequent calls', () async {
      final roadmapRepo = RoadmapRepository();
      final chapterRepo = ChapterRepository();
      final beatRepo = BeatRepository();
      final now = DateTime(2026, 11, 1, 9, 0);

      await roadmapRepo.createRoadmap(RoadmapEntity(
        id: 'rm_csv_1',
        title: 'Systems Track',
        createdAt: now,
        updatedAt: now,
      ));
      await chapterRepo.createChapter(ChapterEntity(
        id: 'ch_csv_1',
        roadmapId: 'rm_csv_1',
        title: 'Module 1',
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ));
      await beatRepo.createBeat(BeatEntity(
        id: 'b_csv_1',
        chapterId: 'ch_csv_1',
        roadmapId: 'rm_csv_1',
        title: 'Topic A',
        createdAt: now,
        updatedAt: now,
      ));

      final firstStart = DateTime(2026, 11, 2, 10, 30);
      await beatRepo.markBeatStarted('b_csv_1', startedAt: firstStart);
      final laterStart = DateTime(2026, 11, 5, 14, 0);
      await beatRepo.markBeatStarted('b_csv_1', startedAt: laterStart);

      final beat = await beatRepo.getBeatById('b_csv_1');
      expect(beat?.startedAt, firstStart);
    });

    test('toggleBeatCompletion sets startedAt when null and preserves original startedAt', () async {
      final roadmapRepo = RoadmapRepository();
      final chapterRepo = ChapterRepository();
      final beatRepo = BeatRepository();
      final created = DateTime(2026, 11, 1);

      await roadmapRepo.createRoadmap(RoadmapEntity(
        id: 'rm_csv_2',
        title: 'Track',
        createdAt: created,
        updatedAt: created,
      ));
      await chapterRepo.createChapter(ChapterEntity(
        id: 'ch_csv_2',
        roadmapId: 'rm_csv_2',
        title: 'Ch 1',
        sortOrder: 0,
        createdAt: created,
        updatedAt: created,
      ));
      await beatRepo.createBeat(BeatEntity(
        id: 'b_direct',
        chapterId: 'ch_csv_2',
        roadmapId: 'rm_csv_2',
        title: 'Direct Complete',
        createdAt: created,
        updatedAt: created,
      ));
      await beatRepo.createBeat(BeatEntity(
        id: 'b_pulled',
        chapterId: 'ch_csv_2',
        roadmapId: 'rm_csv_2',
        title: 'Pulled First',
        startedAt: DateTime(2026, 11, 2, 8, 0),
        createdAt: created,
        updatedAt: created,
      ));

      final doneAt = DateTime(2026, 11, 4, 18, 0);
      final directDone = await beatRepo.toggleBeatCompletion(
        'b_direct',
        isCompleted: true,
        completedAt: doneAt,
      );
      final pulledDone = await beatRepo.toggleBeatCompletion(
        'b_pulled',
        isCompleted: true,
        completedAt: doneAt,
      );

      expect(directDone?.startedAt, doneAt);
      expect(directDone?.completedAt, doneAt);
      expect(pulledDone?.startedAt, DateTime(2026, 11, 2, 8, 0));
      expect(pulledDone?.completedAt, doneAt);
    });

    test('v2 database upgrades cleanly to v3 adding beats.started_at', () async {
      await DatabaseService.instance.close();
      final tempDir = await Directory.systemTemp.createTemp('rythem_v2_upgrade_');
      final dbPath = '${tempDir.path}/upgrade_test.db';

      // Create a v2 database without started_at
      final v2Db = await openDatabase(
        dbPath,
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${DatabaseTables.roadmaps} (
              ${RoadmapColumns.id} TEXT PRIMARY KEY,
              ${RoadmapColumns.title} TEXT NOT NULL,
              ${RoadmapColumns.description} TEXT,
              ${RoadmapColumns.startDate} TEXT,
              ${RoadmapColumns.targetCompletionDate} TEXT,
              ${RoadmapColumns.status} TEXT NOT NULL DEFAULT 'active',
              ${RoadmapColumns.isPrimary} INTEGER NOT NULL DEFAULT 0,
              ${RoadmapColumns.createdAt} TEXT NOT NULL,
              ${RoadmapColumns.updatedAt} TEXT NOT NULL
            );
          ''');
          await db.execute('''
            CREATE TABLE ${DatabaseTables.chapters} (
              ${ChapterColumns.id} TEXT PRIMARY KEY,
              ${ChapterColumns.roadmapId} TEXT NOT NULL,
              ${ChapterColumns.title} TEXT NOT NULL,
              ${ChapterColumns.sortOrder} INTEGER NOT NULL DEFAULT 0,
              ${ChapterColumns.createdAt} TEXT NOT NULL,
              ${ChapterColumns.updatedAt} TEXT NOT NULL
            );
          ''');
          await db.execute('''
            CREATE TABLE ${DatabaseTables.beats} (
              ${BeatColumns.id} TEXT PRIMARY KEY,
              ${BeatColumns.chapterId} TEXT NOT NULL,
              ${BeatColumns.roadmapId} TEXT NOT NULL,
              ${BeatColumns.title} TEXT NOT NULL,
              ${BeatColumns.sourceUrl} TEXT,
              ${BeatColumns.timestampSeconds} INTEGER,
              ${BeatColumns.effortWeight} REAL NOT NULL DEFAULT 1.0,
              ${BeatColumns.sortOrder} INTEGER NOT NULL DEFAULT 0,
              ${BeatColumns.isCompleted} INTEGER NOT NULL DEFAULT 0,
              ${BeatColumns.completedAt} TEXT,
              ${BeatColumns.isMentorExtra} INTEGER NOT NULL DEFAULT 0,
              ${BeatColumns.matchConfidence} REAL,
              ${BeatColumns.syllabusTopicId} TEXT,
              ${BeatColumns.createdAt} TEXT NOT NULL,
              ${BeatColumns.updatedAt} TEXT NOT NULL
            );
          ''');
        },
      );
      await v2Db.close();

      // Reopen at v3 with the exact migration statement
      final v3Db = await openDatabase(
        dbPath,
        version: 3,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 3) {
            await db.execute('''
              ALTER TABLE ${DatabaseTables.beats}
              ADD COLUMN ${BeatColumns.startedAt} TEXT;
            ''');
          }
        },
      );
      final columns = await v3Db.rawQuery('PRAGMA table_info(${DatabaseTables.beats})');
      final columnNames = columns.map((c) => c['name'] as String).toSet();
      expect(columnNames.contains(BeatColumns.startedAt), isTrue);

      await v3Db.close();
      await tempDir.delete(recursive: true);
    });
  });

  group('TrackerCsvExportService Tests', () {
    const service = TrackerCsvExportService();

    test('builds CSV with chapter/beat order, RFC-4180 escaping, and inclusive days taken', () async {
      final now = DateTime(2026, 11, 1);
      final roadmap = RoadmapEntity(
        id: 'rm_1',
        title: 'Distributed Systems',
        createdAt: now,
        updatedAt: now,
      );
      final chapters = [
        ChapterEntity(id: 'ch_2', roadmapId: 'rm_1', title: 'Ch 2', sortOrder: 1, createdAt: now, updatedAt: now),
        ChapterEntity(id: 'ch_1', roadmapId: 'rm_1', title: 'Ch 1', sortOrder: 0, createdAt: now, updatedAt: now),
      ];
      final beats = [
        BeatEntity(
          id: 'b_3',
          chapterId: 'ch_2',
          roadmapId: 'rm_1',
          title: 'Paxos, "Consensus"',
          sortOrder: 0,
          isCompleted: false,
          startedAt: DateTime(2026, 11, 4),
          createdAt: now,
          updatedAt: now,
        ),
        BeatEntity(
          id: 'b_2',
          chapterId: 'ch_1',
          roadmapId: 'rm_1',
          title: 'Raft Protocol',
          sortOrder: 1,
          isCompleted: true,
          startedAt: DateTime(2026, 11, 2, 9, 0),
          completedAt: DateTime(2026, 11, 4, 21, 0),
          createdAt: now,
          updatedAt: now,
        ),
        BeatEntity(
          id: 'b_1',
          chapterId: 'ch_1',
          roadmapId: 'rm_1',
          title: 'Clocks & Ordering',
          sortOrder: 0,
          isCompleted: true,
          startedAt: DateTime(2026, 11, 1, 8, 0),
          completedAt: DateTime(2026, 11, 1, 19, 0),
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final csv = service.buildCsv(
        roadmap: roadmap,
        chapters: chapters,
        beats: beats,
      );

      final lines = csv.trim().split('\n');
      expect(lines, [
        'topic-name,topic start date,topic end date,total number of days taken to finish that topic',
        'Clocks & Ordering,2026-11-01,2026-11-01,1',
        'Raft Protocol,2026-11-02,2026-11-04,3',
        '"Paxos, ""Consensus""",2026-11-04,,',
      ]);
    });

    test('writes tracker CSV file to local storage path', () async {
      final tempDir = await Directory.systemTemp.createTemp('rythem_csv_export_');
      try {
        final now = DateTime(2026, 11, 5);
        final roadmap = RoadmapEntity(
          id: 'rm_exp',
          title: 'Compiler Design',
          createdAt: now,
          updatedAt: now,
        );
        final chapters = [
          ChapterEntity(id: 'ch_1', roadmapId: 'rm_exp', title: 'Lexing', sortOrder: 0, createdAt: now, updatedAt: now),
        ];
        final beats = [
          BeatEntity(
            id: 'b_1',
            chapterId: 'ch_1',
            roadmapId: 'rm_exp',
            title: 'Tokenization',
            isCompleted: true,
            startedAt: DateTime(2026, 11, 1),
            completedAt: DateTime(2026, 11, 2),
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final file = await service.exportTrackerCsvToFile(
          roadmap: roadmap,
          chapters: chapters,
          beats: beats,
          customPath: '${tempDir.path}/compiler_design_topics.csv',
        );

        expect(file, isNotNull);
        expect(file!.existsSync(), isTrue);
        final written = await file.readAsString();
        expect(written, contains('Tokenization,2026-11-01,2026-11-02,2'));
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });

  group('CSV Download Icon UI Tests', () {
    testWidgets('RoadmapDetailScreen shows download icon for both main tracker and Open Lab',
        (tester) async {
      final now = DateTime(2026, 11, 1);
      final mainTrack = RoadmapEntity(
        id: 'rm_main',
        title: 'Main Track',
        createdAt: now,
        updatedAt: now,
      );
      final openLab = RoadmapEntity(
        id: RoadmapEntity.openLabId,
        title: 'Open Lab',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: RythemTheme.darkTheme,
          home: RoadmapDetailScreen(
            roadmap: mainTrack,
            chapters: const [],
            beats: const [],
            onBeatToggled: (_, __) async {},
          ),
        ),
      );
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
      expect(find.byIcon(Icons.sync_rounded), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: RythemTheme.darkTheme,
          home: RoadmapDetailScreen(
            roadmap: openLab,
            chapters: const [],
            beats: const [],
            onBeatToggled: (_, __) async {},
          ),
        ),
      );
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
      expect(find.byIcon(Icons.sync_rounded), findsNothing);
    });

    testWidgets('ExploreScreen main tracker and Open Lab cards display download icon and trigger export callback',
        (tester) async {
      final now = DateTime(2026, 11, 1);
      final openLab = RoadmapEntity(
        id: RoadmapEntity.openLabId,
        title: 'Open Lab',
        createdAt: now,
        updatedAt: now,
      );
      final track = RoadmapEntity(
        id: 'rm_card',
        title: 'Algorithms',
        createdAt: now,
        updatedAt: now,
      );
      final exportedIds = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          theme: RythemTheme.darkTheme,
          home: Scaffold(
            body: ExploreScreen(
              roadmaps: [openLab, track],
              chaptersByRoadmap: const {
                RoadmapEntity.openLabId: [],
                'rm_card': [],
              },
              beatsByRoadmap: const {
                RoadmapEntity.openLabId: [],
                'rm_card': [],
              },
              onBeatToggled: (_, __) async {},
              onCreateTrack: ({
                required title,
                required category,
                startDate,
                targetDate,
                resourceUrl,
                syllabusText,
              }) async {},
              onExportTrackerCsv: (rm) async {
                exportedIds.add(rm.id);
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.download_rounded), findsNWidgets(2));
      await tester.tap(find.byIcon(Icons.download_rounded).first);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.download_rounded).last);
      await tester.pump();

      expect(exportedIds, [RoadmapEntity.openLabId, 'rm_card']);
    });
  });
}

