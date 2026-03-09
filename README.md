# syllago-kitchen-sink

E2E test repo for [syllago](https://github.com/OpenScribbler/syllago). A "polyglot AI project" with all 11 providers configured simultaneously, used to validate the full content lifecycle: discovery, add, install, export, and convert.

## Quick Start

```bash
# Requires: syllago binary in PATH
./tests/run.sh
```

## What This Tests

This repo contains fixture files for every AI coding tool provider that syllago supports, each in their native format:

| Provider | Content Types |
|----------|--------------|
| Claude Code | Rules, skills, agents, commands, hooks, MCP |
| Gemini CLI | Rules, skills, agents, commands, MCP |
| Cursor | Rules (.mdc) |
| Windsurf | Rules (.windsurfrules) |
| Codex | Agents (TOML), shared AGENTS.md |
| Copilot CLI | Rules, agents, commands, hooks, MCP |
| Zed | Rules (.rules) |
| Cline | Rules (.clinerules) |
| Roo Code | Rules (mode-specific), MCP |
| OpenCode | Skills, agents, commands, MCP (JSONC) |
| Kiro | Steering (rules+skills), agents (JSON), MCP |

## Test Suites

| Suite | What it tests |
|-------|--------------|
| `test_discovery.sh` | Discovery mode finds expected items per provider |
| `test_add.sh` | Adding content from each provider populates the library |
| `test_install.sh` | Installing to each provider produces correct native format |
| `test_convert.sh` | Converting between formats produces correct output |

## Running Tests

```bash
./tests/run.sh                        # Full lifecycle, all suites
./tests/run.sh --seed                  # Pre-seed library for faster install/convert tests
./tests/run.sh --suite discovery       # Run a single suite
./tests/run.sh --seed --suite install  # Combine flags
```

## Golden Files

The `tests/golden/` directory contains expected output for each provider, sourced from official provider documentation (not from syllago output). Provider format specs are documented in `docs/provider-specs/`.

When a test fails, the diff shows exactly what syllago produced vs. what the provider spec says it should produce.

## Provider Specs

Each provider's format specification is documented in `docs/provider-specs/<provider>.md` with cited source URLs. These serve as the ground truth for both fixture files and golden files.
