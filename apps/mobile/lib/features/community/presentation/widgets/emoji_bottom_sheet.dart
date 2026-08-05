import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ===============================================================
/// HealthON Emoji Bottom Sheet
///
/// Material emoji picker
/// emoji_picker_flutter 로 교체 가능
/// ===============================================================

class EmojiBottomSheet extends StatefulWidget {
  final void Function(String emoji) onEmojiSelected;

  const EmojiBottomSheet({super.key, required this.onEmojiSelected});

  @override
  State<EmojiBottomSheet> createState() => _EmojiBottomSheetState();
}

class _EmojiBottomSheetState extends State<EmojiBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  static const List<String> _recentKeys = <String>[];
  static const Map<String, List<String>> _categories = {
    '😀': ['😀','😃','😄','😁','😆','😅','🤣','😂','🙂','😊','😇','🥰','😍','🤩','😘','😗','😚','😋','😛','😜','🤪','😝','🤑','🤗','🤭','🤫','🤔','🤐','🤨','😐','😑','😶','😏','😒','🙄','😬','🤥','😌','😔','😪','🤤','😴','😷','🤒','🤕','🤢','🤮','🥴','😵','🤯','🥳','🥺','😢','😭','😤','😠','😡','🤬','💀'],
    '🍔': ['🍏','🍎','🍐','🍊','🍋','🍌','🍉','🍇','🍓','🍈','🍒','🍑','🥭','🍍','🥥','🥝','🍅','🍆','🥑','🥦','🥒','🌶','🌽','🥕','🧄','🧅','🥔','🍠','🥐','🍞','🥖','🥨','🧀','🥚','🍳','🧈','🥞','🧇','🥓','🥩','🍗','🍖','🦴','🌭','🍔','🍟','🍕','🥪','🥙','🧆','🌮','🌯','🥗','🥘','🥫','🍝'],
    '✈️': ['🚗','🚕','🚙','🚌','🚎','🏎','🚓','🚑','🚒','🚐','🚚','🚛','🚜','🛴','🚲','🛵','🏍','🚨','🚔','🚍','🚘','🚖','🚡','🚠','🚟','🚃','🚋','🚞','🚝','🚄','🚅','🚈','🚂','🚆','🚇','🚊','🚉','✈️','🛫','🛬','🛩','💺','🛰','🚀','🛸','🚁','🛶','⛵️','🚤','🛥','🛳','⛴','🚢'],
    '⚽️': ['⚽️','🏀','🏈','⚾️','🥎','🎾','🏐','🏉','🥏','🎱','🪀','🏓','🏸','🏒','🏑','🥍','🏏','🥅','⛳️','🪁','🏹','🎣','🤿','🥊','🥋','🎽','🛹','🛼','🛷','⛸','🥌','🎿','⛷','🏂','🪂','🏋️','🤼','🤸','🤺','⛹️','🤾','🏌️','🏇','🧘','🏄','🏊','🤽','🚣'],
  };

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _categories.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cats = _categories.entries.toList();

    return Container(
      height: 340,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('이모지', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tab bar
          SizedBox(
            height: 44,
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              indicatorColor: const Color(0xFF2E7D32),
              labelColor: const Color(0xFF2E7D32),
              unselectedLabelColor: Colors.grey,
              tabs: [
                const Tab(icon: Icon(Icons.history, size: 20)),
                ...cats.map((e) => Tab(child: Text(e.key, style: const TextStyle(fontSize: 20)))),
              ],
            ),
          ),

          // Tab view
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // Recent
                _RecentEmojiGrid(onEmoji: widget.onEmojiSelected),
                ...cats.map((e) => _EmojiGrid(emojis: e.value, onEmoji: widget.onEmojiSelected)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiGrid extends StatelessWidget {
  final List<String> emojis;
  final void Function(String) onEmoji;

  const _EmojiGrid({required this.emojis, required this.onEmoji});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: emojis.length,
      itemBuilder: (_, i) => Semantics(
        label: '이모지 ${emojis[i]}',
        child: GestureDetector(
          onTap: () {
            onEmoji(emojis[i]);
            Navigator.pop(context);
          },
          child: Center(
            child: Text(emojis[i], style: const TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }
}

class _RecentEmojiGrid extends StatelessWidget {
  final void Function(String) onEmoji;

  const _RecentEmojiGrid({required this.onEmoji});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '최근 사용한 이모지가 없습니다\n😊 이모지를 선택해보세요!',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }
}
