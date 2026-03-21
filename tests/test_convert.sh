#!/usr/bin/env bash
# Suite: convert
# Tests that "syllago convert <name> --to <provider>" produces correct output.
# Captures output via --output flag and diffs against golden files.
#
# This is the primary golden file test suite. Convert works for all providers
# and content types, making it the most reliable format validation.
#
# Requires library to be populated (via add suite or --seed flag).

# Ensure library is populated
if [[ ! -d "$HOME/.syllago/content/rules" ]]; then
  echo "  Library not populated. Running add from claude-code first..."
  syllago add --all --from claude-code --force --no-input 2>/dev/null || true
fi

CONVERT_TMP="$SANDBOX_DIR/convert-output"
mkdir -p "$CONVERT_TMP"

# Helper: convert to file, then assert_golden
convert_and_check() {
  local description="$1"
  local name="$2"
  local provider="$3"
  local golden="$4"
  local outfile="$CONVERT_TMP/${provider}-${name}"

  syllago convert "$name" --to "$provider" --output "$outfile" 2>/dev/null || true
  assert_golden "$description" "$outfile" "$golden"
}

# -- Rules to all providers --
convert_and_check "convert security rule to claude-code" \
  security claude-code "$GOLDEN_DIR/claude-code/rules/security.md"

convert_and_check "convert security rule to cursor" \
  security cursor "$GOLDEN_DIR/cursor/rules/security.mdc"

convert_and_check "convert security rule to windsurf" \
  security windsurf "$GOLDEN_DIR/windsurf/rules/security.md"

convert_and_check "convert security rule to zed" \
  security zed "$GOLDEN_DIR/zed/rules/security.md"

convert_and_check "convert security rule to cline" \
  security cline "$GOLDEN_DIR/cline/rules/security.md"

convert_and_check "convert security rule to roo-code" \
  security roo-code "$GOLDEN_DIR/roo-code/rules/security.md"

convert_and_check "convert security rule to kiro" \
  security kiro "$GOLDEN_DIR/kiro/steering/security.md"

convert_and_check "convert security rule to gemini-cli" \
  security gemini-cli "$GOLDEN_DIR/gemini-cli/rules/security.md"

convert_and_check "convert security rule to copilot-cli" \
  security copilot-cli "$GOLDEN_DIR/copilot-cli/rules/security.md"

convert_and_check "convert security rule to codex" \
  security codex "$GOLDEN_DIR/codex/rules/security.md"

convert_and_check "convert security rule to opencode" \
  security opencode "$GOLDEN_DIR/opencode/rules/security.md"

# -- Agents to providers that support them --
convert_and_check "convert code-reviewer agent to codex" \
  code-reviewer codex "$GOLDEN_DIR/codex/agents/code-reviewer.toml"

convert_and_check "convert code-reviewer agent to kiro" \
  code-reviewer kiro "$GOLDEN_DIR/kiro/agents/code-reviewer.md"

convert_and_check "convert code-reviewer agent to copilot-cli" \
  code-reviewer copilot-cli "$GOLDEN_DIR/copilot-cli/agents/code-reviewer.md"

convert_and_check "convert code-reviewer agent to opencode" \
  code-reviewer opencode "$GOLDEN_DIR/opencode/agents/code-reviewer.md"

convert_and_check "convert code-reviewer agent to claude-code" \
  code-reviewer claude-code "$GOLDEN_DIR/claude-code/agents/code-reviewer.md"

convert_and_check "convert code-reviewer agent to gemini-cli" \
  code-reviewer gemini-cli "$GOLDEN_DIR/gemini-cli/agents/code-reviewer.md"

convert_and_check "convert code-reviewer agent to cursor" \
  code-reviewer cursor "$GOLDEN_DIR/cursor/agents/code-reviewer.md"

# -- Skills to providers that support them --
convert_and_check "convert greeting skill to cursor" \
  greeting cursor "$GOLDEN_DIR/cursor/skills/greeting/SKILL.md"

convert_and_check "convert greeting skill to copilot-cli" \
  greeting copilot-cli "$GOLDEN_DIR/copilot-cli/skills/greeting/SKILL.md"

convert_and_check "convert greeting skill to kiro" \
  greeting kiro "$GOLDEN_DIR/kiro/steering/greeting.md"

convert_and_check "convert greeting skill to opencode" \
  greeting opencode "$GOLDEN_DIR/opencode/skills/greeting/SKILL.md"

convert_and_check "convert greeting skill to gemini-cli" \
  greeting gemini-cli "$GOLDEN_DIR/gemini-cli/skills/greeting/SKILL.md"

convert_and_check "convert greeting skill to claude-code" \
  greeting claude-code "$GOLDEN_DIR/claude-code/skills/greeting/SKILL.md"

convert_and_check "convert greeting skill to windsurf" \
  greeting windsurf "$GOLDEN_DIR/windsurf/skills/greeting/SKILL.md"

convert_and_check "convert greeting skill to roo-code" \
  greeting roo-code "$GOLDEN_DIR/roo-code/skills/greeting/SKILL.md"

convert_and_check "convert greeting skill to codex" \
  greeting codex "$GOLDEN_DIR/codex/skills/greeting/SKILL.md"

# -- Commands to providers that support them --
convert_and_check "convert summarize command to cursor" \
  summarize cursor "$GOLDEN_DIR/cursor/commands/summarize.md"

convert_and_check "convert summarize command to copilot-cli" \
  summarize copilot-cli "$GOLDEN_DIR/copilot-cli/commands/summarize.md"

convert_and_check "convert summarize command to gemini-cli" \
  summarize gemini-cli "$GOLDEN_DIR/gemini-cli/commands/summarize.toml"

convert_and_check "convert summarize command to claude-code" \
  summarize claude-code "$GOLDEN_DIR/claude-code/commands/summarize.md"

convert_and_check "convert summarize command to opencode" \
  summarize opencode "$GOLDEN_DIR/opencode/commands/summarize.md"

# -- Negative tests --
assert_exit_nonzero "convert nonexistent item fails" \
  syllago convert nonexistent-item --to cursor
