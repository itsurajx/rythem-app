import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rythem_app/core/database/database.dart';
import 'package:rythem_app/core/ingestion/ingestion.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

RawResourceItem _item(String title, int index, {String? author}) {
  return RawResourceItem(
    title: title,
    sourceUrl: 'https://www.youtube.com/watch?v=vid_$index',
    durationSeconds: 600,
    index: index,
    author: author,
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('PlaylistOrderNormalizer Unit Tests', () {
    test('reverses single-author playlist when episode numbers are descending (5,4,3,2,1 -> 1,2,3,4,5)', () {
      final raw = [
        _item('Lecture 5: Graphs & BFS', 0, author: 'CodeMentor'),
        _item('Lecture 4: Trees & Traversals', 1, author: 'CodeMentor'),
        _item('Lecture 3: Recursion Basics', 2, author: 'CodeMentor'),
        _item('Lecture 2: Sliding Window', 3, author: 'CodeMentor'),
        _item('Lecture 1: Arrays & Complexity', 4, author: 'CodeMentor'),
      ];

      final normalized = PlaylistOrderNormalizer.normalize(raw);

      expect(normalized.map((e) => e.title).toList(), [
        'Lecture 1: Arrays & Complexity',
        'Lecture 2: Sliding Window',
        'Lecture 3: Recursion Basics',
        'Lecture 4: Trees & Traversals',
        'Lecture 5: Graphs & BFS',
      ]);
      expect(normalized.map((e) => e.index).toList(), [0, 1, 2, 3, 4]);
    });

    test('preserves single-author playlist already in ascending order (1,2,3,4,5)', () {
      final raw = [
        _item('#1 Intro to Compilers', 0, author: 'SystemsLab'),
        _item('#2 Lexical Analysis', 1, author: 'SystemsLab'),
        _item('#3 Parsing & ASTs', 2, author: 'SystemsLab'),
        _item('#4 Semantic Checks', 3, author: 'SystemsLab'),
        _item('#5 Codegen', 4, author: 'SystemsLab'),
      ];

      final normalized = PlaylistOrderNormalizer.normalize(raw);

      expect(normalized.map((e) => e.title).toList(), raw.map((e) => e.title).toList());
      expect(normalized.map((e) => e.index).toList(), [0, 1, 2, 3, 4]);
    });

    test('preserves multi-author custom playlist even if titles have descending numbers', () {
      final raw = [
        _item('5. Dynamic Programming Intro', 0, author: 'Channel A'),
        _item('4. Backtracking Deep Dive', 1, author: 'Channel B'),
        _item('3. Greedy Algorithms', 2, author: 'Channel C'),
        _item('2. Binary Search Variants', 3, author: 'Channel D'),
        _item('1. Arrays Foundations', 4, author: 'Channel E'),
      ];

      final normalized = PlaylistOrderNormalizer.normalize(raw);

      expect(normalized.map((e) => e.title).toList(), raw.map((e) => e.title).toList());
      expect(normalized.map((e) => e.index).toList(), [0, 1, 2, 3, 4]);
    });

    test('preserves playlist when author metadata is missing (fail-safe)', () {
      final raw = [
        _item('Part 4: Consensus', 0),
        _item('Part 3: Replication', 1),
        _item('Part 2: Partitioning', 2),
        _item('Part 1: Storage Engines', 3),
      ];

      final normalized = PlaylistOrderNormalizer.normalize(raw);

      expect(normalized.map((e) => e.title).toList(), raw.map((e) => e.title).toList());
    });

    test('ignores tech version numbers and years so topical single-author playlists stay untouched', () {
      expect(PlaylistOrderNormalizer.extractSequenceNumber('Python 3 Crash Course'), isNull);
      expect(PlaylistOrderNormalizer.extractSequenceNumber('IPv4 vs IPv6 Explained'), isNull);
      expect(PlaylistOrderNormalizer.extractSequenceNumber('HTTP/2 & Web3 Overview'), isNull);
      expect(PlaylistOrderNormalizer.extractSequenceNumber('Backend Roadmap (2026)'), isNull);
      expect(PlaylistOrderNormalizer.extractSequenceNumber('Lecture 12: Raft'), 12);
      expect(PlaylistOrderNormalizer.extractSequenceNumber('03 - Binary Search'), 3);

      final raw = [
        _item('Backend Roadmap (2026)', 0, author: 'TechChannel'),
        _item('Python 3 Crash Course', 1, author: 'TechChannel'),
        _item('HTTP/2 Deep Dive', 2, author: 'TechChannel'),
        _item('OAuth 2.0 Security', 3, author: 'TechChannel'),
      ];

      final normalized = PlaylistOrderNormalizer.normalize(raw);
      expect(normalized.map((e) => e.title).toList(), raw.map((e) => e.title).toList());
    });
  });

  group('YoutubeExtractorService Innertube Author Extraction & Order Normalization', () {
    test('extractPlaylist parses shortBylineText author and fixes descending single-author Innertube playlist', () async {
      final mockHttp = MockClient((request) async {
        if (request.url.path.contains('/youtubei/v1/browse')) {
          return http.Response(
            jsonEncode({
              'contents': {
                'twoColumnBrowseResultsRenderer': {
                  'tabs': [
                    {
                      'tabRenderer': {
                        'content': {
                          'sectionListRenderer': {
                            'contents': [
                              {
                                'playlistVideoListRenderer': {
                                  'contents': [
                                    {
                                      'playlistVideoRenderer': {
                                        'videoId': 'v4',
                                        'title': {'runs': [{'text': 'Ep 4: Final Boss'}]},
                                        'lengthSeconds': '700',
                                        'shortBylineText': {'runs': [{'text': 'CourseCreator'}]},
                                      },
                                    },
                                    {
                                      'playlistVideoRenderer': {
                                        'videoId': 'v3',
                                        'title': {'runs': [{'text': 'Ep 3: Graphs'}]},
                                        'lengthSeconds': '600',
                                        'shortBylineText': {'runs': [{'text': 'CourseCreator'}]},
                                      },
                                    },
                                    {
                                      'playlistVideoRenderer': {
                                        'videoId': 'v2',
                                        'title': {'runs': [{'text': 'Ep 2: Trees'}]},
                                        'lengthSeconds': '500',
                                        'shortBylineText': {'runs': [{'text': 'CourseCreator'}]},
                                      },
                                    },
                                    {
                                      'playlistVideoRenderer': {
                                        'videoId': 'v1',
                                        'title': {'runs': [{'text': 'Ep 1: Intro'}]},
                                        'lengthSeconds': '400',
                                        'shortBylineText': {'runs': [{'text': 'CourseCreator'}]},
                                      },
                                    },
                                  ],
                                },
                              },
                            ],
                          },
                        },
                      },
                    },
                  ],
                },
              },
            }),
            200,
          );
        }
        return http.Response('{}', 404);
      });

      final extractor = YoutubeExtractorService(
        client: yt.YoutubeExplode(httpClient: yt.YoutubeHttpClient(mockHttp)),
        httpClient: mockHttp,
      );

      final extracted = await extractor.extractPlaylist(
        'https://www.youtube.com/playlist?list=PL_TEST_DESC',
      );

      expect(extracted.items.map((e) => e.title).toList(), [
        'Ep 1: Intro',
        'Ep 2: Trees',
        'Ep 3: Graphs',
        'Ep 4: Final Boss',
      ]);
      expect(extracted.items.every((e) => e.author == 'CourseCreator'), isTrue);
      expect(extracted.items.map((e) => e.index).toList(), [0, 1, 2, 3]);
    });

    test('extractPlaylist preserves multi-author lockupViewModel custom playlist order', () async {
      final mockHttp = MockClient((request) async {
        if (request.url.path.contains('/youtubei/v1/browse')) {
          Map<String, dynamic> makeLockup(String id, String title, String author) => {
                'lockupViewModel': {
                  'contentId': id,
                  'metadata': {
                    'lockupMetadataViewModel': {
                      'title': {'content': title},
                      'metadata': {
                        'contentMetadataViewModel': {
                          'metadataRows': [
                            {
                              'metadataParts': [
                                {'text': {'content': author}},
                              ],
                            },
                          ],
                        },
                      },
                    },
                  },
                },
              };

          return http.Response(
            jsonEncode({
              'items': [
                makeLockup('a1', 'Part 4: Distributed Consensus', 'Author One'),
                makeLockup('a2', 'Part 3: Replication', 'Author Two'),
                makeLockup('a3', 'Part 2: Sharding', 'Author Three'),
                makeLockup('a4', 'Part 1: Storage', 'Author Four'),
              ],
            }),
            200,
          );
        }
        return http.Response('{}', 404);
      });

      final extractor = YoutubeExtractorService(
        client: yt.YoutubeExplode(httpClient: yt.YoutubeHttpClient(mockHttp)),
        httpClient: mockHttp,
      );

      final extracted = await extractor.extractPlaylist(
        'https://www.youtube.com/playlist?list=PL_TEST_MULTI',
      );

      expect(extracted.items.map((e) => e.title).toList(), [
        'Part 4: Distributed Consensus',
        'Part 3: Replication',
        'Part 2: Sharding',
        'Part 1: Storage',
      ]);
    });
  });

  group('End-to-End Ingestion Sequence Preservation', () {
    setUp(() async {
      await DatabaseService.instance.initInMemoryForTesting();
    });

    tearDown(() async {
      await DatabaseService.instance.close();
    });

    test('ingestExtractedResource persists normalized 1..5 beat order in SQLite', () async {
      final beatRepo = BeatRepository();
      final ingestionService = CurriculumIngestionService();

      final rawItems = [
        _item('Lesson 5: Deployment', 0, author: 'MentorX'),
        _item('Lesson 4: Testing', 1, author: 'MentorX'),
        _item('Lesson 3: State', 2, author: 'MentorX'),
        _item('Lesson 2: Routing', 3, author: 'MentorX'),
        _item('Lesson 1: Setup', 4, author: 'MentorX'),
      ];

      final resource = ExtractedResource(
        title: 'Flutter Masterclass',
        description: 'Engineering',
        author: 'MentorX',
        sourceUrl: 'https://www.youtube.com/playlist?list=PL_E2E',
        resourceType: ExtractedResourceType.playlist,
        items: PlaylistOrderNormalizer.normalize(rawItems),
      );

      final result = await ingestionService.ingestExtractedResource(extracted: resource);
      final persistedBeats = await beatRepo.getBeatsByRoadmapId(result.roadmapId);
      persistedBeats.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      expect(persistedBeats.map((b) => b.title).toList(), [
        'Lesson 1: Setup',
        'Lesson 2: Routing',
        'Lesson 3: State',
        'Lesson 4: Testing',
        'Lesson 5: Deployment',
      ]);
    });
  });
}
