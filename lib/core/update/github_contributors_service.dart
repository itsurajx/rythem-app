import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../database/repositories/app_settings_repository.dart';

class GithubCreatorProfile {
  final String login;
  final String? name;
  final String? bio;
  final String avatarUrl;
  final String htmlUrl;
  final int publicRepos;
  final int followers;

  const GithubCreatorProfile({
    required this.login,
    this.name,
    this.bio,
    required this.avatarUrl,
    required this.htmlUrl,
    this.publicRepos = 0,
    this.followers = 0,
  });

  String get displayName =>
      (name != null && name!.trim().isNotEmpty) ? name!.trim() : login;

  Map<String, dynamic> toJson() => {
        'login': login,
        'name': name,
        'bio': bio,
        'avatar_url': avatarUrl,
        'html_url': htmlUrl,
        'public_repos': publicRepos,
        'followers': followers,
      };

  factory GithubCreatorProfile.fromJson(Map<String, dynamic> json) {
    final login = (json['login'] as String?)?.trim();
    final effectiveLogin = (login != null && login.isNotEmpty) ? login : 'itsurajx';
    return GithubCreatorProfile(
      login: effectiveLogin,
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: (json['avatar_url'] as String?) ?? 'https://github.com/$effectiveLogin.png',
      htmlUrl: (json['html_url'] as String?) ?? 'https://github.com/$effectiveLogin',
      publicRepos: (json['public_repos'] as num?)?.toInt() ?? 0,
      followers: (json['followers'] as num?)?.toInt() ?? 0,
    );
  }

  static const GithubCreatorProfile fallback = GithubCreatorProfile(
    login: 'itsurajx',
    name: 'Suraj',
    bio: 'Creator of Rythem • Local-first learning tools',
    avatarUrl: 'https://github.com/itsurajx.png',
    htmlUrl: 'https://github.com/itsurajx',
  );
}

class GithubContributor {
  final String login;
  final String avatarUrl;
  final String htmlUrl;
  final int contributions;

  const GithubContributor({
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
    required this.contributions,
  });

  Map<String, dynamic> toJson() => {
        'login': login,
        'avatar_url': avatarUrl,
        'html_url': htmlUrl,
        'contributions': contributions,
      };

  factory GithubContributor.fromJson(Map<String, dynamic> json) {
    final login = (json['login'] as String?) ?? 'contributor';
    return GithubContributor(
      login: login,
      avatarUrl: (json['avatar_url'] as String?) ?? 'https://github.com/$login.png',
      htmlUrl: (json['html_url'] as String?) ?? 'https://github.com/$login',
      contributions: (json['contributions'] as num?)?.toInt() ?? 0,
    );
  }
}

class GithubProjectCredits {
  final GithubCreatorProfile creator;
  final List<GithubContributor> contributors;
  final bool isFromCache;
  final DateTime fetchedAt;

  const GithubProjectCredits({
    required this.creator,
    required this.contributors,
    this.isFromCache = false,
    required this.fetchedAt,
  });

  Map<String, dynamic> toJson() => {
        'creator': creator.toJson(),
        'contributors': contributors.map((c) => c.toJson()).toList(),
        'fetched_at': fetchedAt.toIso8601String(),
      };

  factory GithubProjectCredits.fromJson(
    Map<String, dynamic> json, {
    bool isFromCache = true,
  }) {
    final creatorMap = json['creator'] as Map<String, dynamic>? ?? const {};
    final rawContributors = json['contributors'] as List<dynamic>? ?? const [];
    final fetchedAtStr = json['fetched_at'] as String?;

    return GithubProjectCredits(
      creator: GithubCreatorProfile.fromJson(creatorMap),
      contributors: rawContributors
          .whereType<Map<String, dynamic>>()
          .map(GithubContributor.fromJson)
          .toList(),
      isFromCache: isFromCache,
      fetchedAt: fetchedAtStr != null
          ? (DateTime.tryParse(fetchedAtStr) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  static GithubProjectCredits offlineDefault() {
    return GithubProjectCredits(
      creator: GithubCreatorProfile.fallback,
      contributors: const [
        GithubContributor(
          login: 'itsurajx',
          avatarUrl: 'https://github.com/itsurajx.png',
          htmlUrl: 'https://github.com/itsurajx',
          contributions: 0,
        ),
      ],
      isFromCache: true,
      fetchedAt: DateTime.now(),
    );
  }
}

/// Fetches and caches creator profile and contributor details from GitHub.
class GithubContributorsService {
  static const String creatorHandle = 'itsurajx';
  static const String repoSlug = 'itsurajx/rythem-app';
  static const String _cacheKey = 'github_credits_cache';
  static const Duration _cacheTtl = Duration(hours: 6);

  static const String _userApiUrl = 'https://api.github.com/users/$creatorHandle';
  static const String _contributorsApiUrl =
      'https://api.github.com/repos/$repoSlug/contributors';

  static GithubContributorsService? _sharedInstance;
  static GithubContributorsService get instance =>
      _sharedInstance ??= GithubContributorsService();

  final http.Client _client;
  final AppSettingsRepository _settingsRepo;
  GithubProjectCredits? _memoryCache;

  GithubContributorsService({
    http.Client? client,
    AppSettingsRepository? settingsRepo,
  })  : _client = client ?? http.Client(),
        _settingsRepo = settingsRepo ?? AppSettingsRepository();

  GithubProjectCredits? get cachedCredits => _memoryCache;

  /// Loads creator profile and repository contributors from cache or live GitHub API.
  Future<GithubProjectCredits> fetchCredits({bool forceRefresh = false}) async {
    final stored = await _readCachedCredits();
    if (!forceRefresh && stored != null) {
      final age = DateTime.now().difference(stored.fetchedAt);
      if (age < _cacheTtl) {
        _memoryCache = stored;
        return stored;
      }
    }

    try {
      const headers = {
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'Rythem-App',
      };

      final responses = await Future.wait([
        _client.get(Uri.parse(_userApiUrl), headers: headers).timeout(
              const Duration(seconds: 10),
            ),
        _client.get(Uri.parse(_contributorsApiUrl), headers: headers).timeout(
              const Duration(seconds: 10),
            ),
      ]);

      final userResp = responses[0];
      final contribResp = responses[1];

      GithubCreatorProfile creator = stored?.creator ?? GithubCreatorProfile.fallback;
      if (userResp.statusCode == 200) {
        final decoded = jsonDecode(userResp.body);
        if (decoded is Map<String, dynamic>) {
          creator = GithubCreatorProfile.fromJson(decoded);
        }
      }

      List<GithubContributor> contributors =
          stored?.contributors ?? GithubProjectCredits.offlineDefault().contributors;
      if (contribResp.statusCode == 200) {
        final decoded = jsonDecode(contribResp.body);
        if (decoded is List<dynamic>) {
          final parsed = decoded
              .whereType<Map<String, dynamic>>()
              .where((m) => (m['type'] as String?) != 'Bot')
              .map(GithubContributor.fromJson)
              .toList();
          if (parsed.isNotEmpty) {
            contributors = parsed;
          }
        }
      }

      if (userResp.statusCode != 200 && contribResp.statusCode != 200) {
        return stored ?? GithubProjectCredits.offlineDefault();
      }

      final fresh = GithubProjectCredits(
        creator: creator,
        contributors: contributors,
        isFromCache: false,
        fetchedAt: DateTime.now(),
      );
      _memoryCache = fresh;
      await _writeCachedCredits(fresh);
      return fresh;
    } catch (e) {
      debugPrint('Notice: GitHub credits fetch skipped/offline: $e');
      return stored ?? GithubProjectCredits.offlineDefault();
    }
  }

  Future<GithubProjectCredits?> _readCachedCredits() async {
    if (_memoryCache != null) return _memoryCache;
    try {
      final raw = await _settingsRepo.getSetting(_cacheKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return GithubProjectCredits.fromJson(decoded, isFromCache: true);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _writeCachedCredits(GithubProjectCredits credits) async {
    try {
      await _settingsRepo.setSetting(_cacheKey, jsonEncode(credits.toJson()));
    } catch (_) {}
  }
}

