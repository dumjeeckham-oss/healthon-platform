# Bulk fix script for community module files
$ErrorActionPreference = "Continue"
$base = "E:\kwangmin\ai\healthon-platform\healthon-platform-main\apps\mobile\lib\features"

# 1. community_mapper.dart - remove unused import supabase_flutter
$f = "$base\community\data\community_mapper.dart"
(Get-Content $f -Raw) -replace "import 'package:supabase_flutter/supabase_flutter.dart';\r?\n\r?\n", "" | Set-Content $f -NoNewline
Write-Host "Fixed community_mapper.dart"

# 2. community_comment.dart - remove unused import flutter/foundation
$f = "$base\community\domain\models\community_comment.dart"
(Get-Content $f -Raw) -replace "import 'package:flutter/foundation.dart';\r?\n\r?\n", "" | Set-Content $f -NoNewline
Write-Host "Fixed community_comment.dart"

# 3. community_post.dart - describeEnum deprecated -> .name
$f = "$base\community\domain\models\community_post.dart"
$c = Get-Content $f -Raw
$c = $c -replace 'describeEnum\(category\)', 'category.name'
# Also remove unused import flutter/foundation
$c = $c -replace "import 'package:flutter/foundation.dart';\r?\n\r?\n", ""
Set-Content $f $c -NoNewline
Write-Host "Fixed community_post.dart"

# 4. community_provider.dart - remove unused imports  
$f = "$base\community\presentation\providers\community_provider.dart"
$c = Get-Content $f -Raw
$c = $c -replace "import '../../data/community_repository.dart';\r?\n", ""
$c = $c -replace "import '../../data/community_mapper.dart';\r?\n", ""
Set-Content $f $c -NoNewline
Write-Host "Fixed community_provider.dart"

# 5. community_realtime_provider.dart - dangling + unused imports
$f = "$base\community\presentation\providers\community_realtime_provider.dart"
$c = Get-Content $f -Raw
$c = $c -replace "(/// =+\r?\n(?:///.*\r?\n)*/// =+\r?\n)", "`$1library;`r`n`r`n"
$c = $c -replace "import '../../domain/models/community_post.dart';\r?\n", ""
$c = $c -replace "import '../../domain/models/community_comment.dart';\r?\n", ""
Set-Content $f $c -NoNewline
Write-Host "Fixed community_realtime_provider.dart"

# 6. family_ranking_card.dart - remove unused import
$f = "$base\family\presentation\widgets\family_ranking_card.dart"
$c = Get-Content $f -Raw
$c = $c -replace "import '../../data/family_repository.dart';\r?\n", ""
Set-Content $f $c -NoNewline
Write-Host "Fixed family_ranking_card.dart"

# 7. emoji_bottom_sheet.dart - remove unused import + unused field
$f = "$base\community\presentation\widgets\emoji_bottom_sheet.dart"
$c = Get-Content $f -Raw
$c = $c -replace "import 'package:flutter/services.dart';\r?\n", ""
$c = $c -replace "  static const List<String> _recentKeys = <String>\[];\r?\n  ", ""
Set-Content $f $c -NoNewline
Write-Host "Fixed emoji_bottom_sheet.dart"

Write-Host "Done bulk fixes"
