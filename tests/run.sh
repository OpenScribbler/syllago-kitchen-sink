#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# -- Parse flags --

SEED=false
SUITE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --seed)  SEED=true; shift ;;
    --suite) SUITE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: run.sh [--seed] [--suite <name>]"
      echo ""
      echo "Flags:"
      echo "  --seed          Pre-seed library (skip add tests for faster runs)"
      echo "  --suite <name>  Run only one suite: discovery, add, install, convert"
      exit 0
      ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
done

# -- Setup --

echo "Kitchen Sink E2E Tests"
echo "==========================================="

setup_sandbox

if [[ "$SEED" == "true" ]]; then
  seed_library
fi

# -- Run suites --

run_suite() {
  local name="$1"
  local file="$SCRIPT_DIR/test_${name}.sh"
  if [[ ! -f "$file" ]]; then
    echo "Suite not found: $file"
    exit 1
  fi
  echo ""
  echo "-- Suite: $name --"
  source "$file"
}

if [[ -z "$SUITE" ]]; then
  run_suite discovery
  run_suite add
  run_suite install
  run_suite convert
else
  run_suite "$SUITE"
fi

# -- Summary --

print_summary
