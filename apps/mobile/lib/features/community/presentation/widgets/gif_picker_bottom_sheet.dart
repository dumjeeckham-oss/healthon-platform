import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/comment_gif_provider.dart';

/// ===============================================================
/// HealthON GIF Picker Bottom Sheet
/// ===============================================================

class GifPickerBottomSheet extends ConsumerStatefulWidget {
  final void Function(String gifUrl) onGifSelected;

  const GifPickerBottomSheet({super.key, required this.onGifSelected});

  @override
  ConsumerState<GifPickerBottomSheet> createState() => _GifPickerBottomSheetState();
}

class _GifPickerBottomSheetState extends ConsumerState<GifPickerBottomSheet> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gifSearchProvider);

    return Container(
      height: 420,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header + Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                const Text('GIF', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      controller: _searchCtrl,
                      cursorColor: const Color(0xFF2E7D32),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'GIF 검색...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      onSubmitted: (v) => ref.read(gifSearchProvider.notifier).search(v.trim()),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Recent queries
          if (state.recentQueries.isNotEmpty)
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.recentQueries.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () {
                    ref.read(gifSearchProvider.notifier).search(state.recentQueries[i]);
                  },
                  child: Chip(
                    label: Text(state.recentQueries[i], style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),

          // Trending / Results
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2E7D32)),
                    ),
                  )
                : _GifGrid(
                    items: state.items.isNotEmpty ? state.items : state.trending,
                    onTap: (gif) {
                      widget.onGifSelected(gif.url);
                      Navigator.pop(context);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _GifGrid extends StatelessWidget {
  final List<GifItem> items;
  final void Function(GifItem) onTap;

  const _GifGrid({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text('GIF를 찾을 수 없습니다', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final gif = items[i];
        return Semantics(
          label: 'GIF ${gif.title}',
          child: GestureDetector(
            onTap: () => onTap(gif),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(gif.previewUrl, fit: BoxFit.cover),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      color: Colors.black54,
                      child: Text(
                        gif.title,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
