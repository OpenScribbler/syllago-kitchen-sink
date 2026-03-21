# Kiro — Format Reference

Provider slug: `kiro`

Supports: Rules, Agents, Hooks, MCP, Skills (Powers)

Sources: [Kiro docs](https://kiro.dev/docs/), [Kiro MCP config](https://kiro.dev/docs/mcp/configuration/), [Kiro hooks](https://kiro.dev/docs/hooks/), [Kiro subagents](https://kiro.dev/docs/chat/subagents/), [Kiro Powers](https://kiro.dev/docs/powers/create/), [Kiro Steering](https://kiro.dev/docs/steering/)

---

## Rules (Steering Files)

**Location:** `.kiro/steering/*.md` (workspace) or `~/.kiro/steering/*.md` (global)

**Format:** Markdown with optional YAML frontmatter

**Inclusion modes:**

| Mode | Frontmatter | Behavior |
|------|-------------|----------|
| **Always** (default) | `inclusion: always` | Loaded in every interaction |
| **File Match** | `inclusion: fileMatch` + `fileMatchPattern` | Included when working with matching files |
| **Manual** | `inclusion: manual` | On-demand via `#steering-file-name` in chat |
| **Auto** | `inclusion: auto` + `name` + `description` | Included when request matches description |

**Frontmatter fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `inclusion` | string | No | `always`, `fileMatch`, `manual`, `auto` (default: `always`) |
| `fileMatchPattern` | string or string[] | For `fileMatch` | Glob pattern(s) for file matching |
| `name` | string | For `auto` | Identifier for auto-matching |
| `description` | string | For `auto` | Description for auto-matching |

**File references:** `#[[file:path/to/file.ext]]` to reference live project files.

**AGENTS.md support:** Kiro reads `AGENTS.md` files as steering (always included, no inclusion modes).

**Default steering files** (created by `Kiro: Setup Steering for Project`):
- `product.md` — product vision, features, target users
- `structure.md` — project directory organization
- `tech.md` — technology stack and development tools

**Example:**

```markdown
---
inclusion: fileMatch
fileMatchPattern: "components/**/*.tsx"
---

# React Component Conventions

- Use functional components with hooks
- Type props explicitly with TypeScript interfaces
```

---

## Agents

**Location:** `.kiro/agents/*.md` (workspace) or `~/.kiro/agents/*.md` (global)

**Format:** Markdown with YAML frontmatter (body becomes system prompt)

**Frontmatter fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Agent identifier |
| `description` | string | Yes | What the agent does |
| `tools` | string[] | No | Tool allowlist: `["read", "write", "shell", "@git"]` |
| `model` | string | No | Model ID (e.g., `claude-sonnet-4`) |
| `includeMcpJson` | bool | No | Include project MCP servers |
| `includePowers` | bool | No | Include Powers |

**Tool names:** `read`, `write`, `shell`, `@git`, `@git/status`, `@git/diff`, `@builtin`, `fs_write`, `*`

**Note:** Kiro also supports JSON agent format (`.kiro/agents/*.json`) for programmatic configuration. The JSON format uses `"prompt": "file://./prompts/agent.md"` to reference external markdown prompts. Both formats coexist.

**Example (markdown):**

```markdown
---
name: code-reviewer
description: Expert code review assistant
tools: ["read", "@context7"]
model: claude-sonnet-4
includeMcpJson: true
---

You are a senior code reviewer. Focus on:
- Code clarity and readability
- Security vulnerabilities
- Performance issues
- Test coverage
```

**Example (JSON):**

```json
{
  "name": "aws-rust-agent",
  "description": "Specialized agent for AWS and Rust development",
  "prompt": "file://./prompts/aws-rust-expert.md",
  "model": "claude-sonnet-4",
  "tools": ["read", "write", "shell", "@git"],
  "resources": ["file://README.md"],
  "includeMcpJson": true
}
```

---

## Hooks

**Location:** `.kiro/hooks/` (workspace, IDE-managed) or embedded in agent JSON files

**Five hook events:**

| Event | Trigger | Can Block? | Description |
|-------|---------|------------|-------------|
| `agentSpawn` | Agent starts | No | Run setup commands |
| `userPromptSubmit` | User sends prompt | No | Pre-processing |
| `preToolUse` | Before tool runs | Yes (exit code 2) | Validate/block tool calls |
| `postToolUse` | After tool completes | No | Post-processing |
| `stop` | Agent finishes | No | Cleanup |

**Hook config fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | string | Yes | Shell command to execute |
| `matcher` | string | No | Tool filter: `"fs_write"`, `"read"`, `"shell"`, `"@git"`, `"*"`, `"@builtin"` |
| `timeout_ms` | int | No | Max execution time (default: 30000) |
| `cache_ttl_seconds` | int | No | Cache results for this duration |

**Hook I/O:** Receives JSON on stdin with tool name, input, and context. For `preToolUse`: exit code 0 = allow, exit code 2 = block.

---

## MCP Servers

**Location:** `.kiro/settings/mcp.json` (workspace) or `~/.kiro/settings/mcp.json` (global)

**Format:** JSON

**Server entry fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | string | Conditional | Executable for stdio transport |
| `args` | string[] | No | Arguments for command |
| `env` | object | No | Environment variables (supports `${VAR_NAME}` expansion) |
| `url` | string | Conditional | Endpoint for remote transport |
| `headers` | object | No | HTTP headers |
| `disabled` | bool | No | Disable without removing |
| `autoApprove` | string[] | No | Tools to auto-approve |
| `disabledTools` | string[] | No | Tools to disable |

**Priority:** Agent config `mcpServers` (highest) > workspace `.kiro/settings/mcp.json` > global `~/.kiro/settings/mcp.json` (lowest).

**Example:**

```json
{
  "mcpServers": {
    "web-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-bravesearch"],
      "env": { "BRAVE_API_KEY": "${BRAVE_API_KEY}" },
      "disabled": false,
      "autoApprove": ["brave_search"]
    }
  }
}
```

---

## Skills (Powers)

**Purpose:** Pre-packaged bundles of MCP servers, steering files, and hooks from Kiro partners. Installed in one click.

**Components:** A Power can include MCP servers, steering files, and hooks.

Powers activate automatically based on keyword detection in conversation context.

---

## Specs (Unique Feature)

**Location:** `.kiro/specs/`

Kiro's Spec-Driven Development (SDD) system:
- `requirements.md` — EARS-format requirements
- `design.md` — Technical design
- `tasks.md` — Implementation task breakdown

Not directly mappable to syllago content types.

---

## Syllago Provider Mapping

| syllago ContentType | Kiro Equivalent | Path |
|-------------------|-----------------|------|
| `Rules` | Steering files | `.kiro/steering/*.md` |
| `MCP` | MCP config | `.kiro/settings/mcp.json` (JSON merge) |
| `Hooks` | Agent hooks | `.kiro/agents/*.json` hooks section |
| `Agents` | Agent configs | `.kiro/agents/*.md` (markdown + YAML frontmatter) |
| `Skills` | Powers / steering (auto mode) | Powers system (complex mapping) |
| `Commands` | Not supported | -- |

---

## Key Differences from Similar Tools

- **Dual agent format**: Markdown (YAML frontmatter + body) and JSON (with `file://` prompt references)
- **Steering inclusion modes**: Four modes (always, fileMatch, manual, auto) vs binary always/glob in other tools
- **Hook caching**: Unique `cache_ttl_seconds` feature to avoid re-running expensive checks
- **Blocking hooks**: `preToolUse` hooks can return exit code 2 to prevent tool execution
- **Spec-driven development**: Built-in requirements/design/tasks workflow (unique to Kiro)
- **Powers**: Self-contained capability bundles with auto-activation
- **Env var expansion**: Uses `${VAR}` syntax in MCP configs
