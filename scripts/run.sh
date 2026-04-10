#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-dev}"
SCENARIO="${2:-load}"
EVALUATE_THRESHOLD="${3:-false}"
ENV_FILE="env/${ENVIRONMENT}.properties"
RESULTS_DIR="results"
REPORT_DIR="reports/dashboard"

case "$SCENARIO" in
  load) TEST_PLAN="test-plans/scenarios/BlazeDemo_Load.jmx" ;;
  spike) TEST_PLAN="test-plans/scenarios/BlazeDemo_Spike.jmx" ;;
  *)
    echo "Invalid scenario: $SCENARIO (use: load|spike)" >&2
    exit 1
    ;;
esac

if [ ! -f "$ENV_FILE" ]; then
  echo "Environment file not found: $ENV_FILE" >&2
  exit 1
fi

mkdir -p "$RESULTS_DIR"
rm -rf "$REPORT_DIR"

jmeter -n \
  -t "$TEST_PLAN" \
  -q "$ENV_FILE" \
  -l "$RESULTS_DIR/results.jtl" \
  -e -o "$REPORT_DIR"

echo "Run completed"
echo "JTL: $RESULTS_DIR/results.jtl"
echo "Report: $REPORT_DIR/index.html"

if [ "$EVALUATE_THRESHOLD" = "true" ]; then
  bash scripts/check-threshold.sh "$REPORT_DIR/statistics.json"
fi
