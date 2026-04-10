#!/usr/bin/env bash
set -euo pipefail

STATS_FILE="${1:-reports/dashboard/statistics.json}"
MIN_THROUGHPUT="${2:-250}"
MAX_P90_MS="${3:-2000}"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required to evaluate thresholds." >&2
  exit 2
fi

if [ ! -f "$STATS_FILE" ]; then
  echo "Statistics file not found: $STATS_FILE" >&2
  exit 2
fi

THROUGHPUT=$(jq -r '.Total.throughput' "$STATS_FILE")
P90_MS=$(jq -r '.Total.pct1ResTime' "$STATS_FILE")
ERROR_PCT=$(jq -r '.Total.errorPct' "$STATS_FILE")

STATUS="FAILED"
if awk "BEGIN { exit !($THROUGHPUT >= $MIN_THROUGHPUT && $P90_MS < $MAX_P90_MS) }"; then
  STATUS="PASSED"
fi

echo "Throughput (req/s): $THROUGHPUT"
echo "p90 (ms): $P90_MS"
echo "Error (%): $ERROR_PCT"
echo "Thresholds: throughput >= $MIN_THROUGHPUT and p90 < $MAX_P90_MS"
echo "Status: $STATUS"

if [ "$STATUS" != "PASSED" ]; then
  exit 1
fi
