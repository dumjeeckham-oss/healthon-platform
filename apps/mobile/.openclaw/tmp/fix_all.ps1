$ErrorActionPreference = 'Stop'
$enc = [System.Text.UTF8Encoding]::new($false)
$base = 'E:\kwangmin\ai\healthon-platform\healthon-platform-main\apps\mobile\lib\features'

function Fix-File($relativePath, [ScriptBlock]$fixer) {
    $path = Join-Path $base $relativePath
    Write-Host "Fixing: $relativePath"
    $c = [System.IO.File]::ReadAllText($path, $enc)
    $c = & $fixer $c
    [System.IO.File]::WriteAllText($path, $c, $enc)
    Write-Host "  Done: $relativePath"
}

# Utility: Add library; after doc comment
function Add-Library($content) {
    return $content -replace "^(///[^\r\n]*\r?\n(?:.*\r?\n)*?///[^\r\n]*\r?\n)(\r?\n)", "`$1library;`$2`$2"
}

# ==========================================================
# AI MODULE
# ==========================================================

# 1. ai_coach_screen.dart
Fix-File 'ai\ai_coach_screen.dart' {
    param($c)
    $c = Add-Library $c
    $c = $c -replace "import 'package:healthon_app/app_colors\.dart';\r\n", ''
    $c = $c -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha:$1)'
    $c = $c -replace "'`\$\{score\}점'", "'`$score점'"
    # Fix any remaining `${x}` to `$x` for simple identifiers
    $c = [regex]::Replace($c, "'`\$\{(\w+)\}([a-zA-Z])'", "'`$1`$2'")
    $c
}

# 2. ai_coach_service.dart
Fix-File 'ai\ai_coach_service.dart' {
    param($c)
    $c = Add-Library $c
    $c = $c -replace "if \(payload\.newRecord != null\) \{\r\n        final newRecord = payload\.newRecord;", "if (payload.newRecord != null) {`r`n        final newRecord = payload.newRecord!;"
    $c = $c -replace "if \(profile\.consistencyScore > 0\.7\) tip = ", "if (profile.consistencyScore > 0.7) { tip = "
    $c = $c -replace "else if \(profile\.weeklyTrend > 0\) tip = ", "else if (profile.weeklyTrend > 0) { tip = "
    $c = $c -replace "else tip = ", "else { tip = "
    $c = $c -replace "(tip = '[^']+';)\r\n", "`$1 }`r`n"
    $c
}

Write-Host "AI module done"

# ==========================================================
# COMMUNITY MODULE
# ==========================================================

# 3. community_mapper.dart - remove unused import
Fix-File 'community\data\community_mapper.dart' {
    param($c)
    $c = $c -replace "import 'package:supabase_flutter/supabase_flutter.dart';\r\n", ''
    $c
}

# 4. community_comment.dart - remove unused import + add library
Fix-File 'community\domain\models\community_comment.dart' {
    param($c)
    $c = Add-Library $c
    $c = $c -replace "import 'package:flutter/foundation.dart';\r\n\r\n", ''
    $c
}

# 5. community_post.dart - describeEnum→.name + remove unused import + add library
Fix-File 'community\domain\models\community_post.dart' {
    param($c)
    $c = Add-Library $c
    $c = $c -replace "// import 'package:flutter/foundation.dart';", ""
    $c = [regex]::Replace($c, "describeEnum\((\w+)\)", '${1}.name')
    $c
}

# 6. community_provider.dart - remove unused imports
Fix-File 'community\presentation\providers\community_provider.dart' {
    param($c)
    $c = $c -replace "import '../../data/community_repository.dart';\r\n", ''
    $c = $c -replace "import '../../data/community_mapper.dart';\r\n", ''
    $c
}

# 7. community_realtime_provider.dart - add library + remove unused imports
Fix-File 'community\presentation\providers\community_realtime_provider.dart' {
    param($c)
    $c = Add-Library $c
    $c = $c -replace "import '../domain/models/community_post.dart';\r\n", ''
    $c = $c -replace "import '../domain/models/community_comment.dart';\r\n", ''
    $c
}

# 8. community_realtime_service.dart - add library + unnecessary_null_comparison + dead_null_aware
Fix-File 'community\data\community_realtime_service.dart' {
    param($c)
    $c = Add-Library $c
    # Fix unnecessary_null_comparison (line ~172): payload.newRecord != null
    $c = $c -replace "if \(payload\.newRecord != null\) \{\r\n        final newRecord = payload\.newRecord;", "if (payload.newRecord != null) {`r`n        final newRecord = payload.newRecord!;"
    # Fix line ~201: record == null check
    $c = $c -replace "if \(record == null\) return;\r\n\r\n      final cmp = record\['created_at'\] as String\?;", "if (record == null) return;`r`n`r`n      final cmp = record['created_at'] as String;"
    # Fix dead_null_aware_expression: record['id'] as String? ?? ''
    $c = $c -replace "record\['id'\] as String\? \?\? ''", "record['id'] as String"
    $c = $c -replace "record\['post_id'\] as String\? \?\? ''", "record['post_id'] as String"
    $c = $c -replace "record\['user_id'\] as String\? \?\? ''", "record['user_id'] as String"
    $c = $c -replace "record\['content'\] as String\? \?\? ''", "record['content'] as String"
    $c
}

# 9. supabase_community_repository.dart - remove _notificationTable
Fix-File 'community\data\supabase_community_repository.dart' {
    param($c)
    $c = $c -replace "  static const String _notificationTable = 'community_notifications';\r\n", ""
    $c
}

# 10. emoji_bottom_sheet.dart
Fix-File 'community\presentation\widgets\emoji_bottom_sheet.dart' {
    param($c)
    $c = $c -replace "import 'package:flutter/services.dart';\r\n", ''
    $c = $c -replace "  static const List<String> _recentKeys = [];\r\n", ''
    $c
}

# 11. realtime_widgets.dart
Fix-File 'community\presentation\widgets\realtime_widgets.dart' {
    param($c)
    $c = Add-Library $c
    $c
}

# 12. community_screen.dart
Fix-File 'community\presentation\community_screen.dart' {
    param($c)
    $c = Add-Library $c
    # Remove unused commentChanges
    $c = $c -replace "    final commentChanges = ref\.watch\(realtimeCommentStreamProvider\);\r\n", ""
    $c
}

Write-Host "Community module done"

# ==========================================================
# BULK FIXES: withOpacity, unnecessary_underscores across all files
# ==========================================================

$files = @(
    'community\presentation\screens\community_detail_screen.dart',
    'community\presentation\screens\community_home_screen.dart',
    'community\presentation\screens\write_post_screen.dart',
    'community\presentation\widgets\comment_widgets.dart',
    'community\presentation\widgets\community_post_card.dart',
    'community\presentation\widgets\gif_picker_bottom_sheet.dart',
    'community\presentation\widgets\mention_mixin.dart',
    'community\presentation\screens\community_screen.dart',
    'challenge\presentation\challenge_screen.dart'
)

foreach ($f in $files) {
    $fullPath = Join-Path $base $f
    if (Test-Path $fullPath) {
        $c = [System.IO.File]::ReadAllText($fullPath, $enc)
        $changed = $false
        if ($c -match '\.withOpacity\(') {
            $c = $c -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha:$1)'
            $changed = $true
        }
        if ($c -match '__') {
            $c = $c -replace '\(_, __\)', '(_, _)'
            $changed = $true
        }
        if ($changed) {
            [System.IO.File]::WriteAllText($fullPath, $c, $enc)
            Write-Host "Bulk fixed: $f"
        }
    }
}
Write-Host "Bulk fixes done"

# ==========================================================
# REWARD FLOW - remove unused methods
# ==========================================================
Fix-File 'daily_mission\application\reward_flow.dart' {
    param($c)
    if ($c -match '(?s)(\r?\n  ////////////////////////////////////////////////////////////////\r?\n  ///\r?\n  /// Helper.*)') {
        $c = $c -replace '(?s)(\r?\n  ////////////////////////////////////////////////////////////////\r?\n  ///\r?\n  /// Helper.*)$', "`r`n}"
    }
    $c
}
Write-Host "Reward flow done"

# ==========================================================
# FAMILY MODULE - add library
# ==========================================================
foreach ($f in @('family\data\family_repository.dart', 'family\presentation\family_screen.dart', 'family\presentation\providers\family_provider.dart')) {
    $fullPath = Join-Path $base $f
    if (Test-Path $fullPath) {
        $c = [System.IO.File]::ReadAllText($fullPath, $enc)
        $c = Add-Library $c
        [System.IO.File]::WriteAllText($fullPath, $c, $enc)
        Write-Host "Library added: $f"
    }
}
Write-Host "Family module done"

# ==========================================================
# HOME SCREEN - remove unused import
# ==========================================================
Fix-File 'home\presentation\home_screen.dart' {
    param($c)
    $c = $c -replace "import '../../daily_mission/presentation/providers/daily_mission_provider.dart';\r\n", ''
    $c
}
Write-Host "Home screen done"

Write-Host ""
Write-Host "========== ALL FIXES APPLIED =========="