import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ===============================================================
/// HealthON GIF Search Provider (Mock)
///
/// 실제 Giphy API로 교체 가능
/// ===============================================================

class GifItem {
  final String id;
  final String url;
  final String previewUrl;
  final String title;

  const GifItem({
    required this.id,
    required this.url,
    required this.previewUrl,
    required this.title,
  });
}

class GifSearchState {
  final List<GifItem> items;
  final bool isLoading;
  final String? error;
  final List<GifItem> trending;
  final List<String> recentQueries;

  const GifSearchState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.trending = const [],
    this.recentQueries = const [],
  });
}

class GifSearchNotifier extends StateNotifier<GifSearchState> {
  GifSearchNotifier() : super(const GifSearchState()) {
    _loadTrending();
  }

  void _loadTrending() {
    state = GifSearchState(
      trending: _mockGifs(),
      recentQueries: state.recentQueries,
    );
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _loadTrending();
      return;
    }

    state = GifSearchState(
      isLoading: true,
      trending: state.trending,
      recentQueries: state.recentQueries,
    );

    await Future.delayed(const Duration(milliseconds: 400));

    // Mock — Giphy API 연동 시 교체
    final results = _mockGifs().where((g) {
      return g.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    final recent = List<String>.from(state.recentQueries);
    if (!recent.contains(query)) {
      recent.insert(0, query);
      if (recent.length > 10) recent.removeLast();
    }

    state = GifSearchState(
      items: results,
      trending: state.trending,
      recentQueries: recent,
    );
  }

  void clear() => _loadTrending();
}

List<GifItem> _mockGifs() => const [
  GifItem(id: 'g1', url: 'https://media.giphy.com/media/v1.Y2lk/1.gif', previewUrl: 'https://media.giphy.com/media/v1.Y2lk/1_s.gif', title: '박수'),
  GifItem(id: 'g2', url: 'https://media.giphy.com/media/v1.Y2lk/2.gif', previewUrl: 'https://media.giphy.com/media/v1.Y2lk/2_s.gif', title: '웃음'),
  GifItem(id: 'g3', url: 'https://media.giphy.com/media/v1.Y2lk/3.gif', previewUrl: 'https://media.giphy.com/media/v1.Y2lk/3_s.gif', title: '좋아요'),
  GifItem(id: 'g4', url: 'https://media.giphy.com/media/v1.Y2lk/4.gif', previewUrl: 'https://media.giphy.com/media/v1.Y2lk/4_s.gif', title: '축하'),
  GifItem(id: 'g5', url: 'https://media.giphy.com/media/v1.Y2lk/5.gif', previewUrl: 'https://media.giphy.com/media/v1.Y2lk/5_s.gif', title: '화이팅'),
  GifItem(id: 'g6', url: 'https://media.giphy.com/media/v1.Y2lk/6.gif', previewUrl: 'https://media.giphy.com/media/v1.Y2lk/6_s.gif', title: '놀람'),
];

final gifSearchProvider =
    StateNotifierProvider<GifSearchNotifier, GifSearchState>(
  (ref) => GifSearchNotifier(),
);
