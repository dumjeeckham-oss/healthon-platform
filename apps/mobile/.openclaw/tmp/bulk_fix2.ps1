# Comprehensive bulk fix script v2
$ErrorActionPreference = "Continue"
$base = "E:\kwangmin\ai\healthon-platform\healthon-platform-main\apps\mobile\lib\features"

# --- Dangling doc comment fix helper ---
function Fix-Dangling {
    param($file)
    if (-not (Test-Path $file)) { return }
    $c = Get-Content $file -Raw
    # Replace first /// ===== block end with itself + library;
    if ($c -match '^(/// =+\s*\r?\n(?:///.*\r?\n)*/// =+\s*\r?\n)(\r?\n)(import|class|enum|mixin)') {
        $before = $matches[1]
        $afterBlank = $matches[2]
        $c = $c -replace [regex]::Escape($before + $afterBlank), ($before + "library;`r`n`r`n")
        Set-Content $file $c -NoNewline
        Write-Host "  dangling_library_doc_comments fixed: $file"
    } else {
        Write-Host "  SKIP (no match): $file"
    }
}

# --- withOpacity -> withValues helper ---
function Fix-WithOpacity {
    param($file)
    if (-not (Test-Path $file)) { return }
    $c = Get-Content $file -Raw
    $count = 0
    $c = [regex]::Replace($c, '\.withOpacity\(([0-9.]+)\)', { param($m) 
        $script:count++
        return ".withValues(alpha: $($m.Groups[1].Value))" 
    })
    if ($count -gt 0) {
        Set-Content $file $c -NoNewline
        Write-Host "  withOpacity->withValues x$count: $file"
    }
}

# --- unnecessary_underscores helper ---
function Fix-Underscores {
    param($file)
    if (-not (Test-Path $file)) { return }
    $c = Get-Content $file -Raw
    $count = 0
    $c = [regex]::Replace($c, '__([a-zA-Z])', { param($m) 
        $script:count++
        return "_$($m.Groups[1].Value)" 
    })
    # Don't double-replace
    $c = $c -replace '___', '__'
    if ($count -gt 0) {
        Set-Content $file $c -NoNewline
        Write-Host "  unnecessary_underscores x$count: $file"
    }
}

# --- unnecessary_brace_in_string_interps: ${simpleWord} -> $simpleWord ---
function Fix-BracesInStrings {
    param($file)
    if (-not (Test-Path $file)) { return }
    $c = Get-Content $file -Raw
    $count = 0
    # Match ${word} where word is a simple identifier ($word would work)
    $c = [regex]::Replace($c, '\$\{([a-zA-Z_]\w*)\}', { param($m)
        $script:count++
        return "`$$($m.Groups[1].Value)"
    })
    if ($count -gt 0) {
        Set-Content $file $c -NoNewline
        Write-Host "  unnecessary_brace_in_string_interps x$count: $file"
    }
}

# ========================================================================
# Apply fixes
# ========================================================================

# --- Community dangling ---
Fix-Dangling "$base\community\data\community_realtime_service.dart"
Fix-Dangling "$base\community\presentation\community_screen.dart"
Fix-Dangling "$base\community\presentation\widgets\realtime_widgets.dart"
Fix-Dangling "$base\family\data\family_repository.dart"
Fix-Dangling "$base\family\presentation\family_screen.dart"
Fix-Dangling "$base\family\presentation\providers\family_provider.dart"

# --- withOpacity fixes ---
Fix-WithOpacity "$base\community\presentation\screens\community_detail_screen.dart"
Fix-WithOpacity "$base\community\presentation\screens\community_home_screen.dart"
Fix-WithOpacity "$base\community\presentation\screens\write_post_screen.dart"
Fix-WithOpacity "$base\community\presentation\widgets\comment_widgets.dart"
Fix-WithOpacity "$base\community\presentation\widgets\community_post_card.dart"

# --- unnecessary_underscores ---
Fix-Underscores "$base\community\presentation\community_screen.dart"
Fix-Underscores "$base\community\presentation\screens\community_detail_screen.dart"
Fix-Underscores "$base\community\presentation\screens\community_home_screen.dart"
Fix-Underscores "$base\community\presentation\widgets\comment_widgets.dart"
Fix-Underscores "$base\community\presentation\widgets\gif_picker_bottom_sheet.dart"
Fix-Underscores "$base\community\presentation\widgets\mention_mixin.dart"
Fix-Underscores "$base\challenge\presentation\challenge_screen.dart"

# --- unnecessary_brace_in_string_interps ---
Fix-BracesInStrings "$base\community\presentation\screens\community_home_screen.dart"

Write-Host "`nAll bulk fixes complete!"
