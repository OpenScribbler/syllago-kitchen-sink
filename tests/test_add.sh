#!/usr/bin/env bash
# Suite: add
# Tests that "syllago add <type> --from <provider>" writes content to the library.
#
# Library structure:
#   rules/<provider>/<name>/rule.md        (provider-scoped, named subdir)
#   rules/<provider>/rule.md               (provider-scoped, flat — windsurf/zed)
#   agents/<name>/agent.md                 (global)
#   skills/<name>/SKILL.md                 (global)
#   commands/<provider>/<name>/command.md   (provider-scoped)

LIBRARY="$HOME/.syllago/content"

# -- Claude Code (most content types) --
syllago add --all --from claude-code --force --no-input 2>/dev/null || true

assert_file_exists "claude-code: security rule in library" \
  "$LIBRARY/rules/claude-code/security/rule.md"
assert_file_contains "claude-code: security rule has body" \
  "$LIBRARY/rules/claude-code/security/rule.md" "validate user input"

assert_file_exists "claude-code: greeting skill in library" \
  "$LIBRARY/skills/greeting/SKILL.md"
assert_file_contains "claude-code: greeting skill has body" \
  "$LIBRARY/skills/greeting/SKILL.md" "greeting"

assert_file_exists "claude-code: code-reviewer agent in library" \
  "$LIBRARY/agents/code-reviewer/agent.md"
assert_file_contains "claude-code: agent has body" \
  "$LIBRARY/agents/code-reviewer/agent.md" "security vulnerabilities"

assert_file_exists "claude-code: summarize command in library" \
  "$LIBRARY/commands/claude-code/summarize/command.md"

# -- Cursor (rules only, .mdc conversion) --
syllago add rules --from cursor --force --no-input 2>/dev/null || true

assert_file_exists "cursor: security rule in library" \
  "$LIBRARY/rules/cursor/security/rule.md"
assert_file_contains "cursor: rule body survived mdc conversion" \
  "$LIBRARY/rules/cursor/security/rule.md" "validate user input"

# -- Windsurf (single concatenated rule → flat file) --
syllago add rules --from windsurf --force --no-input 2>/dev/null || true

assert_file_exists "windsurf: rule in library" \
  "$LIBRARY/rules/windsurf/rule.md"

# -- Codex --
syllago add --all --from codex --force --no-input 2>/dev/null || true

assert_file_exists "codex: agent in library" \
  "$LIBRARY/agents/code-reviewer/agent.md"
assert_file_exists "codex: AGENTS rule in library" \
  "$LIBRARY/rules/codex/AGENTS/rule.md"

# -- Copilot CLI --
syllago add --all --from copilot-cli --force --no-input 2>/dev/null || true

assert_file_exists "copilot-cli: agent in library" \
  "$LIBRARY/agents/code-reviewer/agent.md"
assert_file_exists "copilot-cli: command in library" \
  "$LIBRARY/commands/copilot-cli/summarize/command.md"
assert_file_exists "copilot-cli: rule in library" \
  "$LIBRARY/rules/copilot-cli/copilot-instructions/rule.md"

# -- Cline --
syllago add rules --from cline --force --no-input 2>/dev/null || true

assert_file_exists "cline: security rule in library" \
  "$LIBRARY/rules/cline/security/rule.md"

# -- Roo Code --
syllago add rules --from roo-code --force --no-input 2>/dev/null || true

assert_file_exists "roo-code: security rule in library" \
  "$LIBRARY/rules/roo-code/security/rule.md"

# -- OpenCode --
syllago add --all --from opencode --force --no-input 2>/dev/null || true

assert_file_exists "opencode: skill in library" \
  "$LIBRARY/skills/greeting/SKILL.md"
assert_file_exists "opencode: agent in library" \
  "$LIBRARY/agents/code-reviewer/agent.md"

# -- Kiro --
syllago add --all --from kiro --force --no-input 2>/dev/null || true

assert_file_exists "kiro: agent in library" \
  "$LIBRARY/agents/code-reviewer/agent.md"
assert_file_exists "kiro: security rule in library" \
  "$LIBRARY/rules/kiro/security/rule.md"

# -- Gemini CLI --
syllago add --all --from gemini-cli --force --no-input 2>/dev/null || true

assert_file_exists "gemini-cli: GEMINI rule in library" \
  "$LIBRARY/rules/gemini-cli/GEMINI/rule.md"
assert_file_exists "gemini-cli: skill in library" \
  "$LIBRARY/skills/greeting/SKILL.md"

# -- Zed (single concatenated rule → flat file) --
syllago add rules --from zed --force --no-input 2>/dev/null || true

assert_file_exists "zed: rule in library" \
  "$LIBRARY/rules/zed/rule.md"

# -- Negative tests --
assert_exit_nonzero "add from unknown provider fails" \
  syllago add --all --from nonexistent-provider --force --no-input
