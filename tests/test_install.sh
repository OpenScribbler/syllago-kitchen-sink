#!/usr/bin/env bash
# Suite: install
# Tests that "syllago install --to <provider>" places files at correct locations.
#
# NOTE: syllago install writes to user-level paths ($HOME/...), NOT project-level.
# Project-scoped providers (zed, cline, roo-code, kiro rules) skip install.
# Agent install has a known bug (AGENT.md vs agent.md case mismatch).
# See test_convert.sh for comprehensive golden file format validation.
#
# Requires library to be populated (via add suite or --seed flag).

# Ensure library is populated
if [[ ! -d "$HOME/.syllago/content/rules" ]]; then
  echo "  Library not populated. Running add from claude-code first..."
  syllago add --all --from claude-code --force --no-input 2>/dev/null || true
fi

# -- Claude Code (user-level: ~/.claude/) --
syllago install security --to claude-code --type rules --method copy --no-input 2>/dev/null || true
assert_file_exists "install rule to claude-code" \
  "$HOME/.claude/rules/security/rule.md"
assert_file_contains "install rule to claude-code has body" \
  "$HOME/.claude/rules/security/rule.md" "validate user input"

syllago install greeting --to claude-code --type skills --method copy --no-input 2>/dev/null || true
assert_file_exists "install skill to claude-code" \
  "$HOME/.claude/skills/greeting/SKILL.md"
assert_file_contains "install skill to claude-code has body" \
  "$HOME/.claude/skills/greeting/SKILL.md" "greeting"

syllago install summarize --to claude-code --type commands --method copy --no-input 2>/dev/null || true
assert_file_exists "install command to claude-code" \
  "$HOME/.claude/commands/summarize/command.md"

# -- Cursor (user-level: ~/.cursor/) --
syllago install security --to cursor --type rules --method copy --no-input 2>/dev/null || true
assert_file_exists "install rule to cursor" \
  "$HOME/.cursor/rule.mdc"
assert_file_contains "install rule to cursor has body" \
  "$HOME/.cursor/rule.mdc" "validate user input"

# -- Windsurf (user-level: ~/.codeium/windsurf/) --
syllago install security --to windsurf --type rules --method copy --no-input 2>/dev/null || true
assert_file_exists "install rule to windsurf" \
  "$HOME/.codeium/windsurf/rule.md"
assert_file_contains "install rule to windsurf has body" \
  "$HOME/.codeium/windsurf/rule.md" "validate user input"

# -- Gemini CLI (user-level: ~/.gemini/) --
syllago install security --to gemini-cli --type rules --method copy --no-input 2>/dev/null || true
assert_file_exists "install rule to gemini-cli" \
  "$HOME/.gemini/rule.md"

syllago install greeting --to gemini-cli --type skills --method copy --no-input 2>/dev/null || true
assert_file_exists "install skill to gemini-cli" \
  "$HOME/.gemini/skills/greeting/SKILL.md"

# -- Codex (user-level: ~/.codex/) --
syllago install security --to codex --type rules --method copy --no-input 2>/dev/null || true
assert_file_exists "install rule to codex" \
  "$HOME/.codex/rule.md"

# -- Copilot CLI (user-level: ~/.copilot/) --
syllago install security --to copilot-cli --type rules --method copy --no-input 2>/dev/null || true
assert_file_exists "install rule to copilot-cli" \
  "$HOME/.copilot/rule.md"

syllago install summarize --to copilot-cli --type commands --method copy --no-input 2>/dev/null || true
assert_file_exists "install command to copilot-cli" \
  "$HOME/.copilot/commands/command.md"

# -- OpenCode (user-level: ~/.config/opencode/) --
syllago install greeting --to opencode --type skills --method copy --no-input 2>/dev/null || true
assert_file_exists "install skill to opencode" \
  "$HOME/.config/opencode/skill/greeting/SKILL.md"

syllago install summarize --to opencode --type commands --method copy --no-input 2>/dev/null || true
assert_file_exists "install command to opencode" \
  "$HOME/.config/opencode/commands/command.md"

# -- Negative tests --
assert_exit_nonzero "install to unknown provider fails" \
  syllago install security --to nonexistent-provider --type rules --method copy --no-input

assert_exit_nonzero "install nonexistent item fails" \
  syllago install nonexistent-item --to claude-code --type rules --method copy --no-input
