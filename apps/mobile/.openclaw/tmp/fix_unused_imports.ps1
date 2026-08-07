$baseDir = "E:\kwangmin\ai\healthon-platform\healthon-platform-main\apps\mobile"
$warnings = Get-Content "$baseDir\.openclaw\tmp\analyze_output.txt" -Encoding UTF8

# Extract only unused_import warnings: file path and line number
$importFixes = @{}
foreach ($line in $warnings) {
    if ($line -match "warning - Unused import.*- (lib\\.+\.dart):(\d+):\d+ - unused_import") {
        $file = $matches[1]
        $lineNum = [int]$matches[2]
        if (-not $importFixes.ContainsKey($file)) {
            $importFixes[$file] = @()
        }
        $importFixes[$file] += $lineNum
    }
}

# Also handle duplicate_import
foreach ($line in $warnings) {
    if ($line -match "warning - Duplicate import.*- (lib\\.+\.dart):(\d+):\d+ - duplicate_import") {
        $file = $matches[1]
        $lineNum = [int]$matches[2]
        if (-not $importFixes.ContainsKey($file)) {
            $importFixes[$file] = @()
        }
        $importFixes[$file] += $lineNum
    }
}

Write-Host "Files to fix: $($importFixes.Count)"

foreach ($file in $importFixes.Keys) {
    $fullPath = Join-Path $baseDir $file
    $lines = Get-Content $fullPath -Encoding UTF8
    $linesToRemove = $importFixes[$file] | Sort-Object -Descending
    foreach ($ln in $linesToRemove) {
        $idx = $ln - 1  # 0-based
        if ($idx -lt $lines.Count) {
            Write-Host "Removing line $ln from $file : $($lines[$idx].Trim())"
            $lines = $lines[0..($idx-1)] + $lines[($idx+1)..($lines.Count-1)]
        }
    }
    [System.IO.File]::WriteAllLines($fullPath, $lines, [System.Text.UTF8Encoding]::new($true))
    Write-Host "Fixed: $file"
}
