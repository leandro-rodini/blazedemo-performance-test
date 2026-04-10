param(
    [string]$StatisticsFile = "reports/dashboard/statistics.json",
    [double]$MinThroughput = 250,
    [double]$MaxP90Ms = 2000
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $StatisticsFile)) {
    throw "Statistics file not found: $StatisticsFile"
}

$stats = Get-Content -Path $StatisticsFile -Raw | ConvertFrom-Json
$throughput = [double]$stats.Total.throughput
$p90Ms = [double]$stats.Total.pct1ResTime
$errorPct = [double]$stats.Total.errorPct

$status = "FAILED"
if (($throughput -ge $MinThroughput) -and ($p90Ms -lt $MaxP90Ms)) {
    $status = "PASSED"
}

Write-Host "Throughput (req/s): $throughput"
Write-Host "p90 (ms): $p90Ms"
Write-Host "Error (%): $errorPct"
Write-Host "Thresholds: throughput >= $MinThroughput and p90 < $MaxP90Ms"
Write-Host "Status: $status"

if ($status -ne "PASSED") {
    exit 1
}
