# Fix multiple simple patterns across all dart files
$base = "E:\kwangmin\ai\healthon-platform\healthon-platform-main\apps\mobile\lib"

# Get all dart files
$dartFiles = Get-ChildItem -Path $base -Recurse -Filter "*.dart" | ForEach-Object { $_.FullName }
$fixed = 0

foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file -Raw -Encoding UTF8
    $original = $content
    $changed = $false

    # 1. Fix unnecessary underscores: __ → _ (but not ___)
    if ($content -match '__') {
        $newContent = $content -replace '(?<!_)__(?!_)', '_'
        if ($newContent -ne $content) { $content = $newContent; $changed = $true }
    }

    # 2. Fix unnecessary_brace_in_string_interps: ${simpleId} → $simpleId
    # Simple identifier: starts with letter/_, followed by letters/digits/_
    if ($content -match '\$\{([a-zA-Z_]\w*)\}') {
        $newContent = [regex]::Replace($content, '\$\{([a-zA-Z_]\w*)\}', '`$`$`$1')
        if ($newContent -ne $content) { $content = $newContent; $changed = $true }
    }

    # 3. Fix unnecessary_string_interpolations: '$simpleId' alone on a line where simpleId is used
    # This is tricky to do generically - skip for now

    if ($changed) {
        [System.IO.File]::WriteAllText($file, $content, [System.Text.UTF8Encoding]::new($true))
        $fixed++
        $shortName = $file.Replace($base + "\", "")
        Write-Host "Fixed: $shortName"
    }
}

Write-Host ""
Write-Host "Total files fixed: $fixed"
