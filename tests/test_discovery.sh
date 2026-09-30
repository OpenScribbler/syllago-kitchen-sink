#!/usr/bin/env bash
# Suite: discovery
# Tests that "syllago add --from <provider>" (no positional arg) discovers expected content.

# -- Claude Code --
assert_output_contains "claude-code discovers security rule" \
  "security" \
  syllago add --from claude-code --no-input

assert_output_contains "claude-code discovers greeting skill" \
  "greeting" \
  syllago add --from claude-code --no-input

assert_output_contains "claude-code discovers code-reviewer agent" \
  "code-reviewer" \
  syllago add --from claude-code --no-input

assert_output_contains "claude-code discovers summarize command" \
  "summarize" \
  syllago add --from claude-code --no-input

# -- Gemini CLI --
assert_output_contains "gemini-cli discovers GEMINI rule" \
  "GEMINI" \
  syllago add --from gemini-cli --no-input

assert_output_contains "gemini-cli discovers greeting skill" \
  "greeting" \
  syllago add --from gemini-cli --no-input

assert_output_contains "gemini-cli discovers code-reviewer agent" \
  "code-reviewer" \
  syllago add --from gemini-cli --no-input

assert_output_contains "gemini-cli discovers summarize command" \
  "summarize" \
  syllago add --from gemini-cli --no-input

assert_output_contains "gemini-cli discovers hooks" \
  "Hooks" \
  syllago add --from gemini-cli --no-input

# -- Cursor --
assert_output_contains "cursor discovers security rule" \
  "security" \
  syllago add --from cursor --no-input

assert_output_contains "cursor discovers code-review rule" \
  "code-review" \
  syllago add --from cursor --no-input

assert_output_contains "cursor discovers greeting skill" \
  "greeting" \
  syllago add --from cursor --no-input

# Syllago dropped Cursor commands in 5f1ff631 (Cursor's docs now send command
# users to skills), so the summarize fixture must not be discovered.
cursor_out=$(syllago add --from cursor --no-input 2>&1) && cursor_rc=0 || cursor_rc=$?
if [[ $cursor_rc -ne 0 ]]; then
  fail "cursor does not discover summarize command (syllago exited $cursor_rc)"
elif [[ "$cursor_out" == *summarize* ]]; then
  fail "cursor does not discover summarize command (commands unsupported)"
else
  pass "cursor does not discover summarize command (commands unsupported)"
fi

assert_output_contains "cursor discovers hooks" \
  "Hooks" \
  syllago add --from cursor --no-input

assert_output_contains "cursor discovers code-reviewer agent" \
  "code-reviewer" \
  syllago add --from cursor --no-input

# -- Devin Desktop --
assert_output_contains "devin discovers rules" \
  "Rules" \
  syllago add --from devin --no-input

assert_output_contains "devin discovers greeting skill" \
  "greeting" \
  syllago add --from devin --no-input

# -- Codex --
assert_output_contains "codex discovers code-reviewer agent" \
  "code-reviewer" \
  syllago add --from codex --no-input

assert_output_contains "codex discovers greeting skill" \
  "greeting" \
  syllago add --from codex --no-input

# -- Copilot CLI --
assert_output_contains "copilot-cli discovers code-reviewer agent" \
  "code-reviewer" \
  syllago add --from copilot-cli --no-input

assert_output_contains "copilot-cli discovers summarize command" \
  "summarize" \
  syllago add --from copilot-cli --no-input

assert_output_contains "copilot-cli discovers greeting skill" \
  "greeting" \
  syllago add --from copilot-cli --no-input

# -- Zed --
assert_output_contains "zed discovers rules" \
  "Rules" \
  syllago add --from zed --no-input

# -- Cline --
assert_output_contains "cline discovers security rule" \
  "security" \
  syllago add --from cline --no-input

# -- Roo Code --
assert_output_contains "roo-code discovers security rule" \
  "security" \
  syllago add --from roo-code --no-input

assert_output_contains "roo-code discovers greeting skill" \
  "greeting" \
  syllago add --from roo-code --no-input

# -- OpenCode --
assert_output_contains "opencode discovers greeting skill" \
  "greeting" \
  syllago add --from opencode --no-input

assert_output_contains "opencode discovers code-reviewer agent" \
  "code-reviewer" \
  syllago add --from opencode --no-input

# -- Kiro --
assert_output_contains "kiro discovers security steering" \
  "security" \
  syllago add --from kiro --no-input

assert_output_contains "kiro discovers code-reviewer agent" \
  "code-reviewer" \
  syllago add --from kiro --no-input

# -- Negative tests --
assert_exit_nonzero "unknown provider fails" \
  syllago add --from nonexistent-provider --no-input
