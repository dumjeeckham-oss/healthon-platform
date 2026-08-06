import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_members_screen.dart';
import 'screens/admin_notices_screen.dart';
import 'screens/admin_reports_screen.dart';
import 'screens/admin_challenges_screen.dart';
import 'screens/admin_missions_screen.dart';
import 'screens/admin_seasons_screen.dart';
import 'screens/admin_banners_screen.dart';
import 'screens/admin_news_screen.dart';
import 'screens/admin_analytics_screen.dart';

/// ===============================================================
/// HealthON — Admin Shell (반응형 사이드바 + 컨텐츠)
/// ===============================================================

class AdminShell extends ConsumerStatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  bool _sidebarOpen = true;

  static const _navItems = [
    _NavItem(Icons.dashboard, '대시보드', '/admin'),
    _NavItem(Icons.analytics, 'Analytics', '/admin/analytics'),
    _NavItem(Icons.people, '회원관리', '/admin/members'),
    _NavItem(Icons.campaign, '공지사항', '/admin/notices'),
    _NavItem(Icons.newspaper, '법인소식', '/admin/news'),
    _NavItem(Icons.report, '신고관리', '/admin/reports'),
    _NavItem(Icons.emoji_events, 'Challenge', '/admin/challenges'),
    _NavItem(Icons.assignment, 'Mission', '/admin/missions'),
    _NavItem(Icons.forest, 'Forest 시즌', '/admin/seasons'),
    _NavItem(Icons.view_carousel, 'Banner', '/admin/banners'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('HealthON Admin', style: TextStyle(fontSize: 18)),
        leading: isWide
            ? null
            : IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => setState(() => _sidebarOpen = !_sidebarOpen),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: '앱으로 돌아가기',
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: Row(
        children: [
          if (_sidebarOpen || isWide)
            _Sidebar(
              items: _navItems,
              currentPath: GoRouterState.of(context).uri.toString(),
              onSelect: (path) {
                context.go(path);
                if (!isWide) setState(() => _sidebarOpen = false);
              },
              isWide: isWide,
            ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem(this.icon, this.label, this.path);
}

class _Sidebar extends StatelessWidget {
  final List<_NavItem> items;
  final String currentPath;
  final void Function(String) onSelect;
  final bool isWide;

  const _Sidebar({
    required this.items,
    required this.currentPath,
    required this.onSelect,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF1E1E2D),
      child: ListView(
        padding: EdgeInsets.zero,
        children: items.map((item) {
          final isActive = currentPath == item.path || (item.path != '/admin' && currentPath.startsWith(item.path));
          return InkWell(
            onTap: () => onSelect(item.path),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: isActive ? const Color(0xFF2E7D32).withOpacity(0.3) : null,
              child: Row(
                children: [
                  Icon(item.icon, size: 20, color: isActive ? const Color(0xFF4CAF50) : Colors.white54),
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white60,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 14,
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
