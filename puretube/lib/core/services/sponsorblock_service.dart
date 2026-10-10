import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class SponsorSegment {
  final double start; // seconds
  final double end; // seconds
  final String category;

  const SponsorSegment({
    required this.start,
    required this.end,
    required this.category,
  });

  bool contains(Duration position) {
    final s = position.inMilliseconds / 1000.0;
    return s >= start && s < end;
  }
}

class SponsorBlockService {
  SponsorBlockService({http.Client? client})
      : _client = client ?? http.Client();

  static const _base = 'https://sponsor.ajay.app';

  static const defaultCategories = [
    'sponsor',
    'selfpromo',
    'interaction_reminder',
    'intro',
    'outro',
    'music_offtopic',
  ];

  final http.Client _client;

  /// Returns skip segments for [videoId], or an empty list when the video
  /// has none, the API is down, or the network fails. Never throws:
  /// SponsorBlock is best-effort and must never break playback.
  Future<List<SponsorSegment>> getSegments(
    String videoId, {
    List<String>? categories,
  }) async {
    final cats =
        (categories ?? defaultCategories).map((c) => '"$c"').join(',');
    final uri = Uri.parse(
        '$_base/api/skipSegments?videoID=$videoId&categories=[$cats]');
    try {
      final res =
          await _client.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode == 404) return const []; // no segments submitted
      if (res.statusCode != 200) return const [];
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) {
        final seg = (e['segment'] as List<dynamic>);
        return SponsorSegment(
          start: (seg[0] as num).toDouble(),
          end: (seg[1] as num).toDouble(),
          category: e['category'] as String? ?? 'sponsor',
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }
}
