param(
    [ValidateSet("dev", "hml", "prod")]
    [string]$Environment = "dev",
    [ValidateSet("load", "spike")]
    [string]$Scenario = "load",
    [switch]$EvaluateThreshold
)

$ErrorActionPreference = "Stop"

$testPlanMap = @{
    load = "test-plans/scenarios/BlazeDemo_Load.jmx"
    spike = "test-plans/scenarios/BlazeDemo_Spike.jmx"
}

$testPlan = $testPlanMap[$Scenario]
$envFile = "env/$Environment.properties"
$resultsDir = "results"
$reportDir = "reports/dashboard"

if (-not (Test-Path $envFile)) {
    throw "Environment file not found: $envFile"
}

New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null
if (Test-Path $reportDir) {
    Remove-Item -Path $reportDir -Recurse -Force
}

jmeter -n `
  -t $testPlan `
  -q $envFile `
  -l "$resultsDir/results.jtl" `
  -e -o $reportDir

Write-Host "Run completed"
Write-Host "JTL: $resultsDir/results.jtl"
Write-Host "Report: $reportDir/index.html"

if ($EvaluateThreshold) {
    & ./scripts/check-threshold.ps1 -StatisticsFile "$reportDir/statistics.json"
}
