import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rythem_app/core/database/database.dart';
import 'package:rythem_app/core/theme/theme.dart';
import 'package:rythem_app/core/update/github_contributors_service.dart';
import 'package:rythem_app/features/settings/widgets/creator_contributors_card.dart';

class _MemoryAppSettingsRepository extends AppSettingsRepository {
  final Map<String, String> _store = {};

  @override
  Future<String?> getSetting(String key) async => _store[key];

  @override
  Future<void> setSetting(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> removeSetting(String key) async {
    _store.remove(key);
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('GithubContributorsService Tests', () {
    setUp(() async {
      await DatabaseService.instance.initInMemoryForTesting();
    });

    tearDown(() async {
      await DatabaseService.instance.close();
    });

    test('fetches creator profile and contributors from GitHub API and caches result', () async {
      int callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        if (request.url.path == '/users/itsurajx') {
          return http.Response(
            jsonEncode({
              'login': 'itsurajx',
              'name': 'Suraj',
              'bio': 'Building local-first learning systems',
              'avatar_url': 'https://avatars.githubusercontent.com/u/12345?v=4',
              'html_url': 'https://github.com/itsurajx',
              'public_repos': 24,
              'followers': 50,
            }),
            200,
          );
        }
        if (request.url.path == '/repos/itsurajx/rythem-app/contributors') {
          return http.Response(
            jsonEncode([
              {
                'login': 'itsurajx',
                'avatar_url': 'https://avatars.githubusercontent.com/u/12345?v=4',
                'html_url': 'https://github.com/itsurajx',
                'contributions': 142,
                'type': 'User',
              },
              {
                'login': 'dependabot[bot]',
                'avatar_url': 'https://avatars.githubusercontent.com/in/29110?v=4',
                'html_url': 'https://github.com/apps/dependabot',
                'contributions': 4,
                'type': 'Bot',
              },
              {
                'login': 'alice-dev',
                'avatar_url': 'https://avatars.githubusercontent.com/u/67890?v=4',
                'html_url': 'https://github.com/alice-dev',
                'contributions': 7,
                'type': 'User',
              },
            ]),
            200,
          );
        }
        return http.Response('Not found', 404);
      });

      final service = GithubContributorsService(client: mockClient);
      final credits = await service.fetchCredits();

      expect(callCount, 2);
      expect(credits.isFromCache, isFalse);
      expect(credits.creator.login, 'itsurajx');
      expect(credits.creator.name, 'Suraj');
      expect(credits.creator.bio, 'Building local-first learning systems');
      expect(credits.contributors.length, 2);
      expect(credits.contributors[0].login, 'itsurajx');
      expect(credits.contributors[0].contributions, 142);
      expect(credits.contributors[1].login, 'alice-dev');

      // Second call within TTL uses cache without extra HTTP calls
      final cached = await service.fetchCredits();
      expect(callCount, 2);
      expect(cached.creator.login, 'itsurajx');
    });

    test('falls back cleanly to offline default when GitHub API is unreachable', () async {
      final failingClient = MockClient((_) async {
        throw Exception('No network connection');
      });

      final service = GithubContributorsService(client: failingClient);
      final credits = await service.fetchCredits();

      expect(credits.creator.login, 'itsurajx');
      expect(credits.creator.htmlUrl, 'https://github.com/itsurajx');
      expect(credits.contributors, isNotEmpty);
      expect(credits.isFromCache, isTrue);
    });
  });

  group('CreatorContributorsCard Widget Tests', () {
    testWidgets('renders creator and contributors cleanly in dark and light themes and refreshes',
        (tester) async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/users/itsurajx') {
          return http.Response(
            jsonEncode({
              'login': 'itsurajx',
              'name': 'Suraj',
              'bio': 'Creator of Rythem',
              'avatar_url': 'https://github.com/itsurajx.png',
              'html_url': 'https://github.com/itsurajx',
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode([
            {
              'login': 'itsurajx',
              'avatar_url': 'https://github.com/itsurajx.png',
              'html_url': 'https://github.com/itsurajx',
              'contributions': 99,
              'type': 'User',
            },
            {
              'login': 'open-source-helper',
              'avatar_url': 'https://github.com/open-source-helper.png',
              'html_url': 'https://github.com/open-source-helper',
              'contributions': 5,
              'type': 'User',
            },
          ]),
          200,
        );
      });

      final service = GithubContributorsService(
        client: mockClient,
        settingsRepo: _MemoryAppSettingsRepository(),
      );

      final initialCredits = GithubProjectCredits(
        creator: GithubCreatorProfile.fallback,
        contributors: const [
          GithubContributor(
            login: 'itsurajx',
            avatarUrl: 'https://github.com/itsurajx.png',
            htmlUrl: 'https://github.com/itsurajx',
            contributions: 10,
          ),
        ],
        fetchedAt: DateTime.now(),
      );

      for (final theme in [RythemTheme.darkTheme, RythemTheme.lightTheme]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: CreatorContributorsCard(
                  service: service,
                  initialCredits: initialCredits,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Suraj'), findsOneWidget);
        expect(find.text('CREATOR'), findsOneWidget);
        expect(find.text('@itsurajx'), findsNWidgets(2));
        expect(find.text('CONTRIBUTORS (1)'), findsOneWidget);
      }

      // Trigger manual refresh
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pumpAndSettle();

      expect(find.text('CONTRIBUTORS (2)'), findsOneWidget);
      expect(find.text('@open-source-helper'), findsOneWidget);
      expect(find.text('• 99'), findsOneWidget);
    });
  });
}
