$files = @(
"lib\features\admin\admin_models.dart",
"lib\features\admin\analytics_provider.dart",
"lib\features\admin\analytics_repository.dart",
"lib\features\ai\ai_coach_screen.dart",
"lib\features\ai\ai_coach_service.dart",
"lib\features\ai\ai_health_chatbot.dart",
"lib\features\ai\ai_models.dart",
"lib\features\ai\ai_notification_engine.dart",
"lib\features\ai\ai_provider.dart",
"lib\features\ai\health_analytics_engine.dart",
"lib\features\ai\presentation\ai_settings_screen.dart",
"lib\features\ai\smart_challenge_matcher.dart",
"lib\features\community\data\community_realtime_service.dart",
"lib\features\community\presentation\providers\community_realtime_provider.dart",
"lib\features\community\presentation\widgets\realtime_widgets.dart",
"lib\features\family\data\family_repository.dart",
"lib\features\health\data\services\challenge_sync_service.dart",
"lib\features\health\data\services\forest_sync_service.dart",
"lib\features\health\data\services\mission_sync_service.dart",
"lib\features\health\data\services\post_sync_orchestrator.dart",
"lib\features\health\data\services\ranking_service.dart",
"lib\features\health\domain\models\health_models.dart",
"lib\features\health\presentation\providers\health_provider.dart",
"lib\features\push\push_initializer.dart",
"lib\features\push\push_notification_service.dart",
"lib\features\push\push_provider.dart",
"lib\features\push\push_settings.dart",
"lib\features\push\push_settings_screen.dart",
"lib\features\social_engine\social_engine.dart",
"lib\features\social_engine\widgets\widgets.dart"
)

foreach ($file in $files) {
    $content = Get-Content -Path $file -Raw -Encoding UTF8
    # Check if file starts with a doc comment (///)
    if ($content -match '^\s*///') {
        # Find end of doc comment block (last consecutive /// line before non-/// line)
        $lines = $content -split "`r?`n"
        $insertAt = 0
        $inDocComment = $false
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $trimmed = $lines[$i].Trim()
            if ($trimmed -match '^///' -or $trimmed -eq '' -or $trimmed -match '^// ') {
                if ($trimmed -match '^///') { $inDocComment = $true }
                $insertAt = $i + 1
            } else {
                break
            }
        }
        if ($inDocComment -and $insertAt -gt 0) {
            # Check if 'library' already exists
            $hasLibrary = $false
            for ($i = 0; $i -lt [Math]::Min($insertAt + 3, $lines.Count); $i++) {
                if ($lines[$i] -match '^\s*library\b') { $hasLibrary = $true; break }
            }
            if (-not $hasLibrary) {
                $newLines = $lines[0..($insertAt-1)] + @('library;', '') + $lines[$insertAt..($lines.Count-1)]
                $newContent = $newLines -join "`r`n"
                [System.IO.File]::WriteAllText((Resolve-Path $file), $newContent, [System.Text.UTF8Encoding]::new($true))
                Write-Host "Fixed: $file"
            } else {
                Write-Host "Already has library: $file"
            }
        } else {
            Write-Host "No doc comment found: $file"
        }
    } else {
        Write-Host "No doc comment start: $file"
    }
}
