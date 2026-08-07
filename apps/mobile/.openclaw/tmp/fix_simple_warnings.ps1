$baseDir = "E:\kwangmin\ai\healthon-platform\healthon-platform-main\apps\mobile"
$output = Get-Content "$baseDir\.openclaw\tmp\analyze_output3.txt" -Encoding UTF8

# Parse all warnings with file:line:col
$fixes = @{}  # file -> @{ line -> action }

foreach ($line in $output) {
    if ($line -match "warning.*- (lib\\.+\.dart):(\d+):\d+ - (\w+)$") {
        $file = $matches[1]
        $lineNum = [int]$matches[2]
        $code = $matches[3]
        if (-not $fixes.ContainsKey($file)) {
            $fixes[$file] = @{}
        }
        if (-not $fixes[$file].ContainsKey($lineNum)) {
            $fixes[$file][$lineNum] = @()
        }
        $fixes[$file][$lineNum] += $code
    }
}

# Track files to fix
$filesFixed = 0
$linesRemoved = 0

foreach ($file in $fixes.Keys) {
    $fileFixes = $fixes[$file]
    $fullPath = Join-Path $baseDir $file
    
    if (-not (Test-Path $fullPath)) {
        Write-Host "SKIP (not found): $file"
        continue
    }
    
    $lines = Get-Content $fullPath -Encoding UTF8
    $changed = $false
    
    # Process lines in descending order
    $sortedLines = $fileFixes.Keys | Sort-Object -Descending
    
    foreach ($ln in $sortedLines) {
        $codes = $fileFixes[$ln]
        $idx = $ln - 1
        
        if ($idx -ge $lines.Count) { continue }
        
        # Only remove lines for these simple categories
        $canRemove = $false
        foreach ($c in $codes) {
            if ($c -in @('unused_field', 'unused_local_variable', 'unused_import', 'unused_catch_stack')) {
                $canRemove = $true
            }
        }
        
        if (-not $canRemove) { continue }
        
        # For unused_catch_stack, just remove the ', st' part on the same line
        if ($codes -contains 'unused_catch_stack') {
            $line = $lines[$idx]
            $newLine = $line -replace ',\s*st\b', ''
            if ($newLine -ne $line) {
                Write-Host "  Line $ln ($file): removed 'st' from catch"
                $lines[$idx] = $newLine
                $changed = $true
            }
            continue
        }
        
        # For unused_field and unused_local_variable, remove the whole line
        Write-Host "  Line $ln ($file): removing '$($lines[$idx].Trim())' [$($codes -join ',')]"
        $lines = $lines[0..($idx-1)] + $lines[($idx+1)..($lines.Count-1)]
        $linesRemoved++
        $changed = $true
    }
    
    if ($changed) {
        [System.IO.File]::WriteAllLines($fullPath, $lines, [System.Text.UTF8Encoding]::new($true))
        $filesFixed++
        Write-Host "Fixed: $file"
    }
}

Write-Host ""
Write-Host "Files fixed: $filesFixed, Lines removed: $linesRemoved"
