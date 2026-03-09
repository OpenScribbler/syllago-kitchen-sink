# OpenCode — Format Reference

Provider slug: `opencode`

Supports: Rules, Commands, Agents, Skills, MCP

Sources: [OpenCode config docs](https://opencode.ai/docs/config/), [OpenCode MCP](https://opencode.ai/docs/mcp-servers/), [OpenCode rules](https://opencode.ai/docs/rules/), [OpenCode agents](https://opencode.ai/docs/agents/), [azat-io/ai-config](https://github.com/azat-io/ai-config)

---

## Rules

**Location:** `<project>/AGENTS.md` (primary) or `~/.config/opencode/AGENTS.md` (global)

**Format:** Markdown

**Additional instructions:** The `instructions` field in `opencode.json` supports additional instruction sources:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "CONTRIBUTING.md",
    "docs/guidelines.md",
    ".cursor/rules/*.md",
    "https://raw.githubusercontent.com/org/rules/main/style.md"
  ]
}
```

- Glob patterns supported for local files
- Remote URLs supported (5-second fetch timeout)
- Falls back to `CLAUDE.md` and `~/.claude/CLAUDE.md` for Claude Code migration compatibility

**Example:**

```markdown
# Project Rules

Use Go 1.25 with standard library where possible.
All exported functions must have doc comments.
Tests use table-driven patterns.
```

---

## Commands

**Location:** `<project>/.opencode/commands/` or `~/.config/opencode/commands/`

**Format:** Markdown (filename becomes command name)

Structure follows a similar pattern to Claude Code commands.

---

## Agents

**Location:** `<project>/.opencode/agents/` or `~/.config/opencode/agents/` (markdown files, filename becomes agent name)

**Also configurable in `opencode.json`:**

```jsonc
{
  "agent": {
    "coder": {
      "model": "anthropic/claude-sonnet-4-5",
      "reasoningEffort": "high",
      "description": "Specialized coding agent",
      "temperature": 0.3,
      "tools": { "my-mcp*": true }
    }
  },
  "default_agent": "coder"
}
```

**Agent config fields (JSONC):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `model` | string | No | Model ID in `provider/model` format |
| `reasoningEffort` | string | No | `"low"`, `"medium"`, `"high"` |
| `description` | string | No | Agent description |
| `temperature` | float | No | Sampling temperature |
| `tools` | object | No | Tool enable/disable map: `{ "mcp-name*": true }` |

**Built-in agents:** Build, Plan (primary); General, Explore (subagents)

**Markdown agents:** Markdown files in agents directory with filename as agent name. Format similar to Claude Code agents.

---

## Skills

**Location:** `<project>/.opencode/skill/` (per azat-io/ai-config reference)

**Format:** Markdown

Limited documentation available. The azat-io/ai-config project creates skills in this directory for OpenCode.

---

## MCP Servers

**Location:** `<project>/opencode.json` under `"mcp"` key, or `~/.config/opencode/opencode.json`

**Format:** JSONC (JSON with comments)

**Key differences from other providers:**
- Explicit `type` field: `"local"` (stdio) or `"remote"` (HTTP)
- `command` is an **array** (not separate command + args)
- Uses `environment` key (not `env`)
- Variable substitution: `{env:VAR}` and `{file:path}` syntax
- Built-in OAuth support for remote servers

**Server entry fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | Yes | `"local"` (stdio) or `"remote"` (HTTP) |
| `command` | string[] | Conditional | Command as array (local type): `["npx", "-y", "package"]` |
| `environment` | object | No | Environment variables |
| `enabled` | bool | No | Enable/disable (default: true) |
| `timeout` | int | No | Timeout in milliseconds |
| `url` | string | Conditional | Endpoint URL (remote type) |
| `headers` | object | No | HTTP headers |
| `oauth` | object | No | OAuth config for remote servers |

**Example:**

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "local-server": {
      "type": "local",
      "command": ["npx", "-y", "my-mcp-command"],
      "environment": { "API_KEY": "value" },
      "enabled": true,
      "timeout": 5000
    },
    "remote-server": {
      "type": "remote",
      "url": "https://mcp.example.com",
      "headers": { "Authorization": "Bearer {env:API_KEY}" },
      "oauth": {},
      "enabled": true
    }
  }
}
```

---

## Config File

**Location:** `<project>/opencode.json` or `opencode.jsonc` (project), `~/.config/opencode/opencode.json` (global)

**Format:** JSONC (JSON with Comments)

**Schema validation:** `$schema` field supported for IDE autocompletion

**Config precedence (later overrides earlier):**
1. Remote config (`.well-known/opencode`) — organizational defaults
2. Global config (`~/.config/opencode/opencode.json`)
3. Custom config (`OPENCODE_CONFIG` env var)
4. Project config (`opencode.json` in project root)
5. `.opencode` directories
6. Inline config (`OPENCODE_CONFIG_CONTENT` env var)

**Config merging:** All config sources are merged (not replaced). Non-conflicting settings from all sources are preserved.

---

## Unsupported Content Types

| Type | Notes |
|------|-------|
| Hooks | Not supported |

---

## Detection

Detection signals:
- `opencode.json` or `opencode.jsonc` exists in project root
- `.opencode/` directory exists
- `~/.config/opencode/` global config directory exists
- `opencode` command available in PATH

---

## Syllago Provider Mapping

| syllago ContentType | OpenCode Equivalent | Path |
|-------------------|---------------------|------|
| `Rules` | `AGENTS.md` + instructions array | `<project>/AGENTS.md` |
| `MCP` | `mcp` in `opencode.json` | JSONC merge |
| `Commands` | `.opencode/commands/` | Markdown |
| `Agents` | `.opencode/agents/` or config | Markdown or JSONC |
| `Skills` | `.opencode/skill/` | Markdown |
| `Hooks` | Not supported | — |

---

## Key Differences from Similar Tools

- **JSONC format**: Full comment support with `$schema` validation (unique among providers)
- **Command as array**: MCP `command` field is `["cmd", "arg1"]` not separate `command` + `args`
- **`environment` not `env`**: Different key name for env vars in MCP config
- **`{env:VAR}` syntax**: Variable substitution uses different syntax than `${VAR}`
- **OAuth built-in**: Native OAuth flow for authenticated remote MCP servers
- **Claude Code migration**: Automatic fallback to `CLAUDE.md` and `~/.claude/`
- **Remote instructions**: Instructions array supports URLs with 5-second fetch timeout
- **Config merging**: All config layers merge (not override), unlike most tools
- **`type` field**: MCP entries require explicit `"local"` or `"remote"` type
