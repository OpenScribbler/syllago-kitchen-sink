#!/usr/bin/env bash
# Suite: roundtrip
# Tests that content survives a full round-trip:
#   canonical → convert to provider B → place as fixture → add from provider B → convert back to canonical
#
# Two comparison modes:
#   Full:      assert exact match (rules, commands — lossless formats)
#   Body-only: assert body text matches (agents — model metadata lost through some providers)
#
# Requires library to be populated (via add suite or --seed flag).

# Ensure library is populated
if [[ ! -d "$HOME/.syllago/content/rules" ]]; then
  echo "  Library not populated. Running add from claude-code first..."
  syllago add --all --from claude-code --force --no-input 2>/dev/null || true
fi

RT_TMP="$SANDBOX_DIR/roundtrip"
RT_FIXTURES="$SANDBOX_DIR/rt-fixtures"
mkdir -p "$RT_TMP" "$RT_FIXTURES"

# Capture baselines: convert each item to claude-code format
syllago convert security --to claude-code --output "$RT_TMP/baseline-rule.md" 2>/dev/null
syllago convert code-reviewer --to claude-code --output "$RT_TMP/baseline-agent.md" 2>/dev/null
syllago convert greeting --to claude-code --output "$RT_TMP/baseline-skill.md" 2>/dev/null
syllago convert summarize --to claude-code --output "$RT_TMP/baseline-command.md" 2>/dev/null

# Extract body text (everything after the closing --- of frontmatter, or the whole file if no frontmatter)
extract_body() {
  local file="$1"
  if head -1 "$file" | grep -q '^---'; then
    # Has frontmatter — skip it
    sed '1,/^---$/{ /^---$/!d; }' "$file" | sed '1d' | sed '/^[[:space:]]*$/d'
  else
    # No frontmatter — whole file is body
    sed '/^[[:space:]]*$/d' "$file"
  fi
}

# Full round-trip assertion: convert → place fixture → re-add → convert back → diff
assert_roundtrip() {
  local description="$1"
  local item="$2"
  local provider="$3"
  local fixture_path="$4"   # where to place the converted file in the project
  local add_type="$5"       # rules, agents, skills, commands
  local baseline="$6"       # baseline file to compare against

  local converted="$RT_TMP/${provider}-${item}-converted"
  local roundtripped="$RT_TMP/${provider}-${item}-roundtrip.md"

  # Convert to provider format
  if ! syllago convert "$item" --to "$provider" --output "$converted" 2>/dev/null; then
    fail "$description (convert to $provider failed)"
    return
  fi

  # Place as fixture file
  mkdir -p "$(dirname "$PROJECT_DIR/$fixture_path")"
  cp "$converted" "$PROJECT_DIR/$fixture_path"

  # Re-import from provider
  syllago add "$add_type" --from "$provider" --force --no-input --quiet 2>/dev/null || true

  # Convert back to claude-code
  if ! syllago convert "$item" --to claude-code --output "$roundtripped" 2>/dev/null; then
    fail "$description (convert back to claude-code failed)"
    return
  fi

  # Compare
  local baseline_norm roundtrip_norm
  baseline_norm=$(_normalize "$baseline")
  roundtrip_norm=$(_normalize "$roundtripped")

  if [[ "$baseline_norm" == "$roundtrip_norm" ]]; then
    pass "$description"
  else
    fail "$description (round-trip output differs)"
    echo "    --- expected (baseline)"
    echo "    +++ actual (round-tripped)"
    diff <(echo "$baseline_norm") <(echo "$roundtrip_norm") | head -15 | sed 's/^/    /'
  fi
}

# Body-only round-trip: same flow but only compares body text (ignores metadata loss)
assert_roundtrip_body() {
  local description="$1"
  local item="$2"
  local provider="$3"
  local fixture_path="$4"
  local add_type="$5"
  local baseline="$6"

  local converted="$RT_TMP/${provider}-${item}-converted"
  local roundtripped="$RT_TMP/${provider}-${item}-roundtrip.md"

  if ! syllago convert "$item" --to "$provider" --output "$converted" 2>/dev/null; then
    fail "$description (convert to $provider failed)"
    return
  fi

  mkdir -p "$(dirname "$PROJECT_DIR/$fixture_path")"
  cp "$converted" "$PROJECT_DIR/$fixture_path"
  syllago add "$add_type" --from "$provider" --force --no-input --quiet 2>/dev/null || true

  if ! syllago convert "$item" --to claude-code --output "$roundtripped" 2>/dev/null; then
    fail "$description (convert back to claude-code failed)"
    return
  fi

  # Compare body text only
  local baseline_body roundtrip_body
  baseline_body=$(extract_body "$baseline")
  roundtrip_body=$(extract_body "$roundtripped")

  if [[ "$baseline_body" == "$roundtrip_body" ]]; then
    pass "$description"
  else
    fail "$description (body text differs after round-trip)"
    echo "    --- expected body"
    echo "    +++ actual body"
    diff <(echo "$baseline_body") <(echo "$roundtrip_body") | head -15 | sed 's/^/    /'
  fi
}

# -- Rules: full round-trip through all providers (lossless) --
assert_roundtrip "rule round-trip through cursor" \
  security cursor ".cursor/rules/security.mdc" rules "$RT_TMP/baseline-rule.md"

assert_roundtrip "rule round-trip through windsurf" \
  security windsurf ".windsurfrules" rules "$RT_TMP/baseline-rule.md"

assert_roundtrip "rule round-trip through cline" \
  security cline ".clinerules/security.md" rules "$RT_TMP/baseline-rule.md"

assert_roundtrip "rule round-trip through roo-code" \
  security roo-code ".roo/rules/security.md" rules "$RT_TMP/baseline-rule.md"

assert_roundtrip "rule round-trip through kiro" \
  security kiro ".kiro/steering/security.md" rules "$RT_TMP/baseline-rule.md"

assert_roundtrip "rule round-trip through gemini-cli" \
  security gemini-cli "GEMINI.md" rules "$RT_TMP/baseline-rule.md"

assert_roundtrip "rule round-trip through copilot-cli" \
  security copilot-cli ".github/copilot-instructions.md" rules "$RT_TMP/baseline-rule.md"

assert_roundtrip "rule round-trip through zed" \
  security zed ".rules" rules "$RT_TMP/baseline-rule.md"

# -- Commands: full round-trip (lossless) --
assert_roundtrip "command round-trip through copilot-cli" \
  summarize copilot-cli ".copilot/commands/summarize.md" commands "$RT_TMP/baseline-command.md"

assert_roundtrip "command round-trip through gemini-cli" \
  summarize gemini-cli ".gemini/commands/summarize.toml" commands "$RT_TMP/baseline-command.md"

assert_roundtrip "command round-trip through opencode" \
  summarize opencode ".opencode/commands/summarize.md" commands "$RT_TMP/baseline-command.md"

# -- Skills: full round-trip where lossless --
assert_roundtrip "skill round-trip through kiro" \
  greeting kiro ".kiro/steering/greeting.md" rules "$RT_TMP/baseline-skill.md"

# -- Agents: body-only round-trip (model metadata lost through markdown providers) --
assert_roundtrip_body "agent body round-trip through copilot-cli" \
  code-reviewer copilot-cli ".copilot/agents/code-reviewer.agent.md" agents "$RT_TMP/baseline-agent.md"

assert_roundtrip_body "agent body round-trip through opencode" \
  code-reviewer opencode ".opencode/agents/code-reviewer.md" agents "$RT_TMP/baseline-agent.md"

assert_roundtrip_body "agent body round-trip through gemini-cli" \
  code-reviewer gemini-cli ".gemini/agents/code-reviewer.md" agents "$RT_TMP/baseline-agent.md"

# NOTE: Codex agent round-trip skipped — syllago outputs multi-agent TOML format
# that the single-agent importer can't parse back (known bug).
# NOTE: Kiro agent round-trip skipped — JSON file:// prompt references and
# parse errors on re-import (known bug).
