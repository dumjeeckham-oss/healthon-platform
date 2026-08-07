import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../health/presentation/providers/health_provider.dart';
import '../../domain/models/community_post.dart';
import '../providers/community_provider.dart';
import '../widgets/community_post_card.dart';

class CommunityWritePostScreen extends ConsumerStatefulWidget {
  const CommunityWritePostScreen({super.key});

  @override
  ConsumerState<CommunityWritePostScreen> createState() =>
      _CommunityWritePostScreenState();
}

class _CommunityWritePostScreenState
    extends ConsumerState<CommunityWritePostScreen>
    with TickerProviderStateMixin {
  // ===============================================================
  // ① Title + Content
  // ===============================================================

  final TextEditingController _titleController =
      TextEditingController();
  final TextEditingController _contentController =
      TextEditingController();

  static const int _maxTitleLength = 60;
  static const int _maxContentLength = 2000;

  // ===============================================================
  // ② Photo
  // ===============================================================

  final List<String> _selectedImages = [];
  static const int _maxImages = 10;

  // ===============================================================
  // ③④⑤⑥ Snapshot selectors
  // ===============================================================

  Map<String, dynamic>? _forestSnapshot;
  Map<String, dynamic>? _walkingSnapshot;
  Map<String, dynamic>? _missionSnapshot;
  Map<String, dynamic>? _challengeSnapshot;

  bool _showForestOptions = false;
  bool _showWalkingOptions = false;
  bool _showMissionOptions = false;
  bool _showChallengeOptions = false;

  // ===============================================================
  // ⑦ Visibility
  // ===============================================================

  String _visibility = 'public';

  static const List<Map<String, String>> _visibilityOptions = [
    {'value': 'public', 'label': '전체 공개'},
    {'value': 'member', 'label': '조합원'},
    {'value': 'friend', 'label': '친구'},
    {'value': 'private', 'label': '비공개'},
  ];

  // ===============================================================
  // ⑧ Hashtag
  // ===============================================================

  final List<String> _hashtags = [];
  final TextEditingController _hashtagController =
      TextEditingController();

  static const List<String> _suggestedHashtags = [
    'Forest',
    'Walking',
    'Challenge',
    'Mission',
    'HealthON',
  ];

  // ===============================================================
  // ⑨ Emoji
  // ===============================================================

  bool _showEmojiPicker = false;

  static const List<String> _emojis = [
    '😀',
    '😁',
    '😂',
    '🔥',
    '❤️',
    '🌳',
    '🏃',
    '🚶',
    '🌱',
    '🏅',
    '🎯',
    '💪',
    '🌟',
    '🍃',
    '🏆',
    '😊',
    '🙌',
    '✨',
    '🌿',
    '💚',
  ];

  // ===============================================================
  // ⑩ Preview
  // ===============================================================

  bool _showPreview = false;

  // ===============================================================
  // ⑪ Publish state
  // ===============================================================

  bool _isPublishing = false;

  // ===============================================================
  // Tab
  // ===============================================================

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _hashtagController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ===============================================================
  // ② Add / Remove Images
  // ===============================================================

  void _addImage(String path) {
    if (_selectedImages.length >= _maxImages) {
      _showSnackBar('사진은 최대 $_maxImages장까지 첨부할 수 있습니다');
      return;
    }

    setState(() {
      _selectedImages.add(path);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // ===============================================================
  // ⑧ Add / Remove Hashtags
  // ===============================================================

  void _addHashtag(String tag) {
    final String trimmed = tag.trim().replaceAll('#', '');

    if (trimmed.isEmpty) return;

    if (_hashtags.contains(trimmed)) {
      _showSnackBar('이미 추가된 해시태그입니다');
      return;
    }

    setState(() {
      _hashtags.add(trimmed);
      _hashtagController.clear();
    });
  }

  void _removeHashtag(int index) {
    setState(() {
      _hashtags.removeAt(index);
    });
  }

  // ===============================================================
  // ⑫ Validation
  // ===============================================================

  bool _validate() {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('제목을 입력해주세요');
      return false;
    }

    if (_contentController.text.trim().isEmpty &&
        _selectedImages.isEmpty &&
        _forestSnapshot == null &&
        _walkingSnapshot == null) {
      _showDialog('내용 없음', '본문, 사진 또는 Snapshot 중 하나 이상 입력해주세요');
      return false;
    }

    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // ⑪ Publish
  // ===============================================================

  CommunityPost _buildPost() {
    return CommunityPost(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: 'current_user',
      category: CommunityCategory.free,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      images: _selectedImages,
      forestSnapshot: _forestSnapshot,
      walkingSnapshot: _walkingSnapshot,
      badgeSnapshot: _missionSnapshot,
      visibility: _visibility,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _publish() async {
    if (!_validate()) return;

    setState(() {
      _isPublishing = true;
    });

    try {
      final CommunityPost post = _buildPost();

      await ref.read(createPostProvider(post).future);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
        _showSnackBar('게시 실패. 다시 시도해주세요');
      }
      return;
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _saveDraft() async {
    _showSnackBar('임시저장되었습니다');
  }

  Future<bool> _onWillPop() async {
    if (_titleController.text.trim().isNotEmpty ||
        _contentController.text.trim().isNotEmpty ||
        _selectedImages.isNotEmpty) {
      final bool? result = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('작성 취소'),
          content: const Text('작성 중인 내용이 사라집니다.\n그래도 나가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                '계속 작성',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                '나가기',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      return result ?? false;
    }

    return true;
  }

  // ===============================================================
  // Build
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        final bool shouldPop = await _onWillPop();

        if (shouldPop && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F7),

        appBar: AppBar(
          title: const Text(
            '글쓰기',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          actions: [
            // --- ⑩ Preview toggle ---

            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showPreview = !_showPreview;
                });
              },
              icon: Icon(
                _showPreview
                    ? Icons.edit
                    : Icons.visibility_outlined,
                size: 18,
              ),
              label: Text(
                _showPreview ? '편집' : '미리보기',
                style: const TextStyle(fontSize: 13),
              ),
            ),

            const SizedBox(width: 4),
          ],
        ),

        body: _showPreview ? _previewBody() : _editorBody(),

        // =========================================================
        // ⑪ Bottom Bar — Publish / Draft / Cancel
        // =========================================================

        bottomNavigationBar: _showPreview
            ? null
            : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // --- Draft ---

                      OutlinedButton(
                        onPressed:
                            _isPublishing ? null : _saveDraft,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '임시저장',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // --- Publish ---

                      Expanded(
                        child: FilledButton(
                          onPressed:
                              _isPublishing ? null : _publish,
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                          child: _isPublishing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  '게시하기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ===============================================================
  // ⑩ Preview Body
  // ===============================================================

  Widget _previewBody() {
    final CommunityPost previewPost = _buildPost();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.shade200,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Color(0xFF2E7D32),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '실제 Community Card와 동일한 디자인으로 미리보기됩니다',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ),

          CommunityPostCard(post: previewPost),
        ],
      ),
    );
  }

  // ===============================================================
  // Editor Body
  // ===============================================================

  Widget _editorBody() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // ① Title
            // =====================================================

            _sectionLabel('제목'),

            const SizedBox(height: 6),

            TextField(
              controller: _titleController,
              maxLength: _maxTitleLength,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: const Color(0xFF2E7D32),
              decoration: _inputDecoration(
                hintText: '제목을 입력하세요',
                suffix: Text(
                  '${_titleController.text.length}/$_maxTitleLength',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 18),

            // =====================================================
            // ① Content
            // =====================================================

            _sectionLabel('본문'),

            const SizedBox(height: 6),

            TextField(
              controller: _contentController,
              maxLength: _maxContentLength,
              maxLines: 8,
              minLines: 4,
              cursorColor: const Color(0xFF2E7D32),
              style: const TextStyle(fontSize: 15),
              decoration: _inputDecoration(
                hintText: '내용을 입력하세요...',
                suffix: Text(
                  '${_contentController.text.length}/$_maxContentLength',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 18),

            // =====================================================
            // ⑨ Emoji
            // =====================================================

            _sectionLabel('이모지'),

            const SizedBox(height: 6),

            GestureDetector(
              onTap: () {
                setState(() {
                  _showEmojiPicker = !_showEmojiPicker;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      '😊',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '이모지 추가하기',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _showEmojiPicker ? 0.5 : 0,
                      duration:
                          const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _showEmojiPicker
                  ? Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: _emojis.map((String e) {
                          return GestureDetector(
                            onTap: () {
                              final int pos =
                                  _contentController
                                      .selection
                                      .baseOffset;

                              final String text =
                                  _contentController.text;

                              final String newText =
                                  text.substring(0, pos) +
                                      e +
                                      text.substring(pos);

                              _contentController.text =
                                  newText;

                              _contentController.selection =
                                  TextSelection.collapsed(
                                offset: pos + e.length,
                              );

                              setState(() {});
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              child: Text(
                                e,
                                style: const TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // =====================================================
            // ② Photo Upload
            // =====================================================

            _sectionLabel(
              '사진  ${_selectedImages.length}/$_maxImages',
            ),

            const SizedBox(height: 6),

            _PhotoGrid(
              images: _selectedImages,
              maxImages: _maxImages,
              onAdd: () => _pickImages(),
              onRemove: _removeImage,
            ),

            const SizedBox(height: 24),

            // =====================================================
            // ③ Forest Snapshot
            // =====================================================

            _snapshotToggleTile(
              icon: '🌳',
              title: 'Forest 공유',
              subtitle:
                  '오늘 성장, 나무, Forest Level, Badge',
              isExpanded: _showForestOptions,
              isActive: _forestSnapshot != null,
              onToggle: () {
                setState(() {
                  _showForestOptions =
                      !_showForestOptions;
                });
              },
            ),

            // --- Forest Snapshot 동적 옵션 ---
            Consumer(
              builder: (context, ref, _) {
                final todayAsync = ref.watch(healthTodayProvider);
                final weekAsync = ref.watch(healthWeekProvider);
                final weekSteps = weekAsync.valueOrNull?.$1 ?? 0;

                int forestLv = 1;
                String forestName = '새싹';
                if (weekSteps >= 200000) { forestLv = 8; forestName = '열대우림'; }
                else if (weekSteps >= 120000) { forestLv = 7; forestName = '울창한숲'; }
                else if (weekSteps >= 80000) { forestLv = 6; forestName = '숲'; }
                else if (weekSteps >= 50000) { forestLv = 5; forestName = '큰나무'; }
                else if (weekSteps >= 30000) { forestLv = 4; forestName = '성장나무'; }
                else if (weekSteps >= 15000) { forestLv = 3; forestName = '어린나무'; }
                else if (weekSteps >= 5000) { forestLv = 2; forestName = '묘목'; }

                final forestOptions = [
                  {'icon': '🌱', 'label': '오늘 성장', 'level': 'Lv.$forestLv $forestName'},
                  {'icon': '👣', 'label': '주간 걸음', 'level': '$weekSteps보'},
                  {'icon': '🏅', 'label': 'Forest Level', 'level': 'Lv.$forestLv'},
                ];

                return AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _showForestOptions
                      ? _SnapshotOptionList(
                          options: forestOptions,
                          selectedLabel: _forestSnapshot?['label']?.toString() ?? '',
                          onSelected: (option) {
                            setState(() { _forestSnapshot = option; });
                          },
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),

            const SizedBox(height: 12),

            // =====================================================
            // ④ Walking Snapshot
            // =====================================================

            _snapshotToggleTile(
              icon: '🚶',
              title: 'Walking 공유',
              subtitle:
                  '오늘 걸음, 거리, 칼로리 (Health 자동)',
              isExpanded: _showWalkingOptions,
              isActive: _walkingSnapshot != null,
              onToggle: () {
                setState(() {
                  _showWalkingOptions =
                      !_showWalkingOptions;
                });
              },
            ),

            // --- Forest Snapshot 동적 옵션 ---
            Consumer(
              builder: (context, ref, _) {
                final todayAsync = ref.watch(healthTodayProvider);
                final steps = todayAsync.valueOrNull?.steps ?? 0;
                final dist = todayAsync.valueOrNull?.distanceKm ?? 0.0;
                final cal = todayAsync.valueOrNull?.calories ?? 0.0;

                final walkingOptions = [
                  {'icon': '🚶', 'label': '오늘 걸음', 'level': '${steps.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}보'},
                  {'icon': '📏', 'label': '거리', 'level': '${dist.toStringAsFixed(1)}km'},
                  {'icon': '🔥', 'label': '칼로리', 'level': '${cal.round()}kcal'},
                ];

                return AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _showWalkingOptions
                      ? _SnapshotOptionList(
                          options: walkingOptions,
                          selectedLabel: _walkingSnapshot?['label']?.toString() ?? '',
                          onSelected: (option) {
                            setState(() { _walkingSnapshot = option; });
                          },
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),

            const SizedBox(height: 12),

            // =====================================================
            // ⑤ Mission Snapshot
            // =====================================================

            _snapshotToggleTile(
              icon: '🎯',
              title: 'Mission 공유',
              subtitle:
                  '오늘 미션, 보상, 완료 여부, XP, Leaf',
              isExpanded: _showMissionOptions,
              isActive: _missionSnapshot != null,
              onToggle: () {
                setState(() {
                  _showMissionOptions =
                      !_showMissionOptions;
                });
              },
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _showMissionOptions
                  ? _SnapshotOptionList(
                      options: const [
                        {
                          'icon': '🎯',
                          'label': '오늘 미션',
                          'level': '완료 ✨',
                        },
                        {
                          'icon': '🎁',
                          'label': '보상',
                          'level': '+50XP',
                        },
                        {
                          'icon': '🍃',
                          'label': 'Leaf',
                          'level': '+3',
                        },
                      ],
                      selectedLabel:
                          _missionSnapshot?['label']
                                  ?.toString() ??
                              '',
                      onSelected: (option) {
                        setState(() {
                          _missionSnapshot = option;
                        });
                      },
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 12),

            // =====================================================
            // ⑥ Challenge Snapshot
            // =====================================================

            _snapshotToggleTile(
              icon: '🔥',
              title: 'Challenge 공유',
              subtitle:
                  '참여 챌린지, 100K, 연속걷기, 랭킹',
              isExpanded: _showChallengeOptions,
              isActive: _challengeSnapshot != null,
              onToggle: () {
                setState(() {
                  _showChallengeOptions =
                      !_showChallengeOptions;
                });
              },
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _showChallengeOptions
                  ? _SnapshotOptionList(
                      options: const [
                        {
                          'icon': '🎯',
                          'label': '100K Challenge',
                          'level': '진행중',
                        },
                        {
                          'icon': '🔥',
                          'label': '연속걷기',
                          'level': '10일째',
                        },
                        {
                          'icon': '🏆',
                          'label': '주간랭킹',
                          'level': 'Top 12',
                        },
                      ],
                      selectedLabel:
                          _challengeSnapshot?['label']
                                  ?.toString() ??
                              '',
                      onSelected: (option) {
                        setState(() {
                          _challengeSnapshot = option;
                        });
                      },
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // =====================================================
            // ⑦ Visibility
            // =====================================================

            _sectionLabel('공개 범위'),

            const SizedBox(height: 6),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _visibility,
                  isExpanded: true,
                  icon: const Icon(Icons.expand_more),
                  items: _visibilityOptions
                      .map((o) => DropdownMenuItem(
                            value: o['value'],
                            child: Text(
                              o['label'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (String? v) {
                    if (v != null) {
                      setState(() {
                        _visibility = v;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =====================================================
            // ⑧ Hashtag
            // =====================================================

            _sectionLabel('해시태그'),

            const SizedBox(height: 6),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ..._hashtags.asMap().entries.map((e) {
                  return Chip(
                    label: Text('#${e.value}'),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 16,
                    ),
                    onDeleted: () =>
                        _removeHashtag(e.key),
                    backgroundColor:
                        Colors.green.shade50,
                    side: BorderSide(
                      color: Colors.green.shade200,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hashtagController,
                    cursorColor:
                        const Color(0xFF2E7D32),
                    decoration: _inputDecoration(
                      hintText: '해시태그 입력 후 엔터',
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (v) =>
                        _addHashtag(v),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton.filled(
                  onPressed: () => _addHashtag(
                    _hashtagController.text,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2E7D32),
                  ),
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // --- Auto-suggest ---

            Text(
              '추천 해시태그',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 6),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _suggestedHashtags
                  .where(
                    (t) => !_hashtags.contains(t),
                  )
                  .map((String tag) {
                return GestureDetector(
                  onTap: () => _addHashtag(tag),
                  child: Chip(
                    label: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    backgroundColor:
                        Colors.grey.shade100,
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                    visualDensity:
                        VisualDensity.compact,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ② Pick Images (Gallery)
  // ===============================================================

  Future<void> _pickImages() async {
    _showSnackBar('갤러리에서 사진을 선택하세요');

    // Mock — 실제 image_picker 연동 시 대체
    setState(() {
      final int remaining =
          _maxImages - _selectedImages.length;

      for (int i = 0;
          i < remaining && i < 3;
          i++) {
        _selectedImages.add(
          'https://picsum.photos/seed/img${_selectedImages.length + DateTime.now().millisecond}/400/400',
        );
      }
    });
  }

  // ===============================================================
  // Helpers
  // ===============================================================

  InputDecoration _inputDecoration({
    String? hintText,
    Widget? suffix,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 15,
      ),
      suffix: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF2E7D32),
        ),
      ),
      counterStyle: const TextStyle(
        fontSize: 0,
        height: 0,
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  Widget _snapshotToggleTile({
    required String icon,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required bool isActive,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green.shade50
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? const Color(0xFF2E7D32)
                : Colors.grey.shade300,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isActive
                          ? const Color(0xFF2E7D32)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 22,
              ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// ② Photo Grid
// =================================================================

class _PhotoGrid extends StatelessWidget {
  final List<String> images;
  final int maxImages;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _PhotoGrid({
    required this.images,
    required this.maxImages,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...images.asMap().entries.map((entry) {
          final int i = entry.key;
          final String path = entry.value;

          return GestureDetector(
            onTap: () {
              // --- full-screen preview ---

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    backgroundColor: Colors.black,
                    appBar: AppBar(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    body: Center(
                      child: Hero(
                        tag: 'write_img_$i',
                        child: Image.network(
                          path,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Hero(
              tag: 'write_img_$i',
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(10),
                    child: Image.network(
                      path,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        if (images.length < maxImages)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 28,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${images.length}/$maxImages',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// =================================================================
// Snapshot Option List
// =================================================================

class _SnapshotOptionList extends StatelessWidget {
  final List<Map<String, String>> options;
  final String selectedLabel;
  final ValueChanged<Map<String, dynamic>> onSelected;

  const _SnapshotOptionList({
    required this.options,
    required this.selectedLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((o) {
          final bool isSelected =
              selectedLabel == o['label'];

          return GestureDetector(
            onTap: () => onSelected({
              'icon': o['icon'],
              'label': o['label'],
              'level': o['level'],
            }),
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade50,
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    o['icon'] ?? '',
                    style:
                        const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    o['label'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '· ${o['level'] ?? ''}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white70
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
