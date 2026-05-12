# match_companies_house.ps1
# Matches sponsor names against Companies House bulk data locally.
# Outputs only matched records — small enough to import via Supabase Table Editor.

$sponsorPath = "C:\Users\Johns\Downloads\2026-05-08_-_Worker_and_Temporary_Worker.csv"
$chPath      = "C:\Users\Johns\Downloads\ch_active_filtered.csv"
$outputPath  = "C:\Users\Johns\Downloads\ch_matched_sponsors.csv"

function Normalize-Name($name) {
    $n = $name.ToUpper().Trim()
    # Strip trading-as suffix (everything after T/A, T/AS, trading as)
    $n = $n -replace '\s+T/AS?\s+.*$', ''
    $n = $n -replace '\s+TRADING AS\s+.*$', ''
    # Strip legal suffixes
    $n = $n -replace '\b(LIMITED|LTD|LLP|PLC|INC|CORP|CIC|CIO|UK)\b\.?', ''
    # Strip punctuation and normalize spaces
    $n = $n -replace '[^A-Z0-9 ]', ' '
    $n = $n -replace '\s+', ' '
    return $n.Trim()
}

Write-Host "Step 1: Loading sponsor names..."
$sponsorNames = @{}
$sponsorReader = [System.IO.StreamReader]::new($sponsorPath, [System.Text.Encoding]::UTF8)
$sponsorReader.ReadLine() | Out-Null # skip header
while (-not $sponsorReader.EndOfStream) {
    $line = $sponsorReader.ReadLine()
    # Extract organisation name (first CSV field, may be quoted)
    $raw = $line.Trim().TrimStart('"')
    $raw = ($raw -split '","')[0].TrimEnd('"').Trim()
    if ($raw) {
        $key = Normalize-Name $raw
        if ($key -and -not $sponsorNames.ContainsKey($key)) {
            $sponsorNames[$key] = $raw
        }
    }
}
$sponsorReader.Close()
Write-Host "  Loaded $($sponsorNames.Count) unique normalised sponsor names."

Write-Host "Step 2: Scanning Companies House data for matches..."
$writer = [System.IO.StreamWriter]::new($outputPath, $false, [System.Text.Encoding]::UTF8)
$writer.WriteLine("organisation_name,company_number,sic_text_1")

$chReader = [System.IO.StreamReader]::new($chPath, [System.Text.Encoding]::UTF8)
$chReader.ReadLine() | Out-Null # skip header

$matched = 0
$scanned = 0

while (-not $chReader.EndOfStream) {
    $line = $chReader.ReadLine()
    $scanned++

    # Parse the 4 fields: company_name, company_number, company_status, sic_text_1
    $fields = $line -split '","'
    if ($fields.Count -lt 4) { continue }

    $chName   = $fields[0].TrimStart('"').Trim()
    $chNum    = $fields[1].Trim()
    $chSic    = $fields[3].TrimEnd('"').Trim()

    $key = Normalize-Name $chName

    if ($sponsorNames.ContainsKey($key)) {
        $sponsorOrgName = $sponsorNames[$key].Replace('"','""')
        $chSicClean = $chSic.Replace('"','""')
        $writer.WriteLine("""$sponsorOrgName"",""$chNum"",""$chSicClean""")
        $matched++
    }

    if ($scanned % 1000000 -eq 0) {
        Write-Host "  Scanned $scanned CH rows, matched $matched so far..."
    }
}

$chReader.Close()
$writer.Close()

$sizeMB = [math]::Round((Get-Item $outputPath).Length / 1MB, 2)
Write-Host ""
Write-Host "Done. Matched $matched companies. Output: $sizeMB MB at $outputPath"
