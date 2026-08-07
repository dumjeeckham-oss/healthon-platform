# Fix dangling_library_doc_comments - add 'library;' after first doc comment block
$files = @(
    "lib\features\ai\ai_notification_engine.dart",
    "lib\features\ai\ai_provider.dart",
    "lib\features\ai\health_analytics_engine.dart",
    "lib\features\ai\presentation\ai_settings_screen.dart",
    "lib\features\ai\smart_challenge_matcher.dart",
    "lib\features\community\data\community_realtime_service.dart",
    "lib\features\community\presentation\community_screen.dart",
    "lib\features\community\presentation\providers\community_realtime_provider.dart",
    "lib\features\community\presentation\widgets\realtime_widgets.dart",
    "lib\features\family\data\family_repository.dart",
    "lib\features\family\presentation\family_screen.dart",
    "lib\features\family\presentation\providers\family_provider.dart"
)

foreach ($file in $files) {
    $path = Join-Path $PSScriptRoot $file
    if (-not (Test-Path $path)) { continue }
    $content = Get-Content $path -Raw
    # Add 'library;' after the first `/// =====` closing line followed by blank line(s) and import
    if ($content -match '(?m)^(/// =+\s*\r?\n(?:///.*\r?\n)*/// =+\s*\r?\n)') {
        $match = $matches[1]
        $replacement = $match + "library;`r`n`r`n"
        $content = $content.Replace($match, $replacement)
        Set-Content $path $content -NoNewline
        Write-Host "Fixed dangling_library_doc_comments in $file"
    }
}

Write-Host "Done with dangling_library_doc_comments fixes"
