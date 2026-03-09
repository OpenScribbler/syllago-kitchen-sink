#!/usr/bin/env bash
# Kitchen Sink test library -- sourced by test scripts
# Provides: sandbox setup/teardown, assertion helpers, summary reporting

# -- State --

TESTS_PASSED=0
TESTS_FAILED=0
FAILURES=()
SANDBOX_DIR=""
PROJECT_DIR=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
GOLDEN_DIR="$SCRIPT_DIR/golden"

# -- Sandbox --

setup_sandbox() {
  SANDBOX_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ks-test-XXXXXX")"
  export HOME="$SANDBOX_DIR"
  PROJECT_DIR="$SANDBOX_DIR/project"
  mkdir -p "$PROJECT_DIR"

  # Copy fixture files into the sandbox project
  # Use rsync to preserve dotfiles and directory structure
  rsync -a --exclude='tests/' --exclude='docs/' --exclude='.git/' \
    "$REPO_DIR/" "$PROJECT_DIR/"

  cd "$PROJECT_DIR" || exit 1
  echo "Sandbox: $SANDBOX_DIR"
}

teardown_sandbox() {
  if [[ -n "$SANDBOX_DIR" && -d "$SANDBOX_DIR" ]]; then
    rm -rf "$SANDBOX_DIR"
  fi
}

seed_library() {
  echo "Seeding library from claude-code fixtures..."
  syllago add --from claude-code --all --force --quiet 2>/dev/null || {
    fail "seed_library: syllago add --from claude-code failed"
    return 1
  }
  echo "Library seeded."
}

# -- Assertions --

pass() {
  local description="$1"
  TESTS_PASSED=$((TESTS_PASSED + 1))
  printf "  \033[32m+\033[0m %s\n" "$description"
}

fail() {
  local description="$1"
  TESTS_FAILED=$((TESTS_FAILED + 1))
  FAILURES+=("$description")
  printf "  \033[31mX\033[0m %s\n" "$description"
}

assert_exit_zero() {
  local description="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    pass "$description"
  else
    fail "$description (exit code: $?)"
  fi
}

assert_exit_nonzero() {
  local description="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    fail "$description (expected non-zero exit, got 0)"
  else
    pass "$description"
  fi
}

assert_output_contains() {
  local description="$1"
  local expected="$2"
  shift 2
  local output
  output=$("$@" 2>&1) || true
  if echo "$output" | grep -qF "$expected"; then
    pass "$description"
  else
    fail "$description (expected output to contain: $expected)"
  fi
}

assert_file_exists() {
  local description="$1"
  local filepath="$2"
  if [[ -f "$filepath" ]]; then
    pass "$description"
  else
    fail "$description (file not found: $filepath)"
  fi
}

assert_file_contains() {
  local description="$1"
  local filepath="$2"
  local expected="$3"
  if [[ ! -f "$filepath" ]]; then
    fail "$description (file not found: $filepath)"
    return
  fi
  if grep -qF "$expected" "$filepath"; then
    pass "$description"
  else
    fail "$description (file does not contain: $expected)"
  fi
}

assert_json_key() {
  local description="$1"
  local filepath="$2"
  local key="$3"
  local expected="$4"
  if [[ ! -f "$filepath" ]]; then
    fail "$description (file not found: $filepath)"
    return
  fi
  local actual
  actual=$(jq -r "$key" "$filepath" 2>/dev/null) || {
    fail "$description (invalid JSON or key not found: $key)"
    return
  }
  if [[ "$actual" == "$expected" ]]; then
    pass "$description"
  else
    fail "$description (expected $key=$expected, got $actual)"
  fi
}

# Normalized diff: convert CRLF to LF, strip trailing whitespace,
# remove trailing blank lines
_normalize() {
  sed 's/\r$//' "$1" | sed 's/[[:space:]]*$//' | sed -e :a -e '/^\n*$/{$d;N;ba}'
}

assert_golden() {
  local description="$1"
  local actual_file="$2"
  local golden_file="$3"

  if [[ ! -f "$actual_file" ]]; then
    fail "$description (actual file not found: $actual_file)"
    return
  fi
  if [[ ! -f "$golden_file" ]]; then
    fail "$description (golden file not found: $golden_file)"
    return
  fi

  local actual_norm golden_norm
  actual_norm=$(_normalize "$actual_file")
  golden_norm=$(_normalize "$golden_file")

  if [[ "$actual_norm" == "$golden_norm" ]]; then
    pass "$description"
  else
    fail "$description (output differs from golden file)"
    echo "    --- expected (golden)"
    echo "    +++ actual"
    diff <(echo "$golden_norm") <(echo "$actual_norm") | head -20 | sed 's/^/    /' || true
  fi
}

# -- Summary --

print_summary() {
  local total=$((TESTS_PASSED + TESTS_FAILED))
  echo ""
  echo "==========================================="
  if [[ $TESTS_FAILED -eq 0 ]]; then
    printf "\033[32mPASSED: %d/%d\033[0m\n" "$TESTS_PASSED" "$total"
  else
    printf "\033[31mFAILED: %d/%d\033[0m\n" "$TESTS_FAILED" "$total"
    echo ""
    echo "Failures:"
    for f in "${FAILURES[@]}"; do
      echo "  - $f"
    done
  fi
  echo "==========================================="

  teardown_sandbox
  [[ $TESTS_FAILED -eq 0 ]]
}
