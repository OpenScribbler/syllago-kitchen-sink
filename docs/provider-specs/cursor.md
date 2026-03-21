# Cursor — Format Reference

Provider slug: `cursor`

Supports: Rules, Skills, Commands, Hooks, MCP

Sources: [Cursor docs](https://cursor.com/docs/context/rules), [Cursor MCP](https://cursor.com/docs/mcp), [Cursor Hooks](https://cursor.com/docs/hooks), [Cursor Skills](https://cursor.com/docs/context/skills), [Cursor Commands](https://cursor.com/docs/context/commands)

---

## Rules

**Location:** `.cursor/rules/*.md` or `.cursor/rules/*.mdc` (supports subdirectories)

**Legacy:** `.cursorrules` (project root, deprecated)

**Cross-provider:** `AGENTS.md` (project root and subdirectories)

**Format:** MDC (Markdown with metadata control) — YAML frontmatter + markdown body

**Frontmatter fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `description` | string | Conditional | Rule purpose; required for "Agent Requested" type |
| `alwaysApply` | bool | No | `true` = always active (default: `false`) |
| `globs` | string or string[] | No | File patterns for scoped activation |

**Activation model:**

| Mode | `alwaysApply` | `globs` | `description` | Behavior |
|------|---------------|---------|---------------|----------|
| Always | `true` | -- | optional | Active in every chat session |
| Auto-Attached | `false` | set | optional | Triggered when file patterns match |
| Agent Requested | `false` | -- | required | Agent evaluates description for relevance |
| Manual | `false` | -- | -- | User invokes via `@rule-name` in chat |

**Precedence:** Team Rules > Project Rules > User Rules

**Example:**

```markdown
---
description: React component patterns and TypeScript conventions
alwaysApply: false
globs:
  - "src/components/**/*.tsx"
  - "src/components/**/*.ts"
---

# React Components

1. Use functional components with hooks
2. Type props explicitly with TypeScript interfaces
3. Export components as named exports
4. Place tests in adjacent `__tests__/` directory
```

---

## Skills

**Location:** `.cursor/skills/<name>/SKILL.md` (project), `.agents/skills/<name>/SKILL.md` (cross-agent), or `~/.cursor/skills/<name>/SKILL.md` (user)

**Legacy compat:** `.claude/skills/` and `.codex/skills/` also scanned.

**Format:** YAML frontmatter + markdown body

**Frontmatter fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Lowercase, numbers, hyphens. Must match folder name. |
| `description` | string | Yes | What the skill does; drives auto-discovery |
| `license` | string | No | License name or reference |
| `disable-model-invocation` | bool | No | When `true`, skill is explicit slash command only |

**Directory structure:**

```
my-skill/
  SKILL.md          # Required: frontmatter + instructions
  scripts/          # Optional: executable code
  references/       # Optional: additional docs
  assets/           # Optional: templates, data files
```

**Invocation:** `/skill-name` in Agent chat (manual) or auto-invoked by agent when relevant.

**Migration:** Use `/migrate-to-skills` to convert existing rules and commands to skills format.

**Example:**

```markdown
---
name: deploy-app
description: Deploys the application to staging or production environments.
---

# Deploy Application

1. Run the test suite: `npm test`
2. Build the production bundle: `npm run build`
3. Execute deployment: `./scripts/deploy.sh <environment>`
```

---

## Commands

**Location:** `.cursor/commands/*.md` (project) or `~/.cursor/commands/*.md` (user)

**Format:** Markdown (no frontmatter documented)

**Naming:** Filename (minus `.md`) becomes the command name. Invoked via `/` in Agent chat.

**Note:** Commands are being superseded by Skills. `/migrate-to-skills` converts commands to skill format.

**Example:**

```markdown
# Code Review

Review the current changes with the following criteria:

1. Check for security vulnerabilities
2. Verify error handling is comprehensive
3. Ensure naming conventions are followed
4. Look for performance issues
```

---

## Hooks

**Location:** `.cursor/hooks.json` (project) or `~/.cursor/hooks.json` (user)

**Format:** JSON

**Schema:**

```json
{
  "version": 1,
  "hooks": {
    "<event-name>": [
      {
        "command": "./scripts/my-hook.sh",
        "type": "command",
        "timeout": 30,
        "failClosed": false,
        "matcher": "pattern"
      }
    ]
  }
}
```

**Hook definition fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `command` | string | Yes | -- | Script path or shell command |
| `type` | `"command"` or `"prompt"` | No | `"command"` | Execution method |
| `timeout` | number | No | platform default | Max seconds to execute |
| `failClosed` | bool | No | `false` | Block action when hook fails |
| `loop_limit` | number or null | No | `5` | Max auto follow-ups for `stop` hooks |
| `matcher` | string | No | -- | Filter pattern (tool name, command pattern, etc.) |

**Hook event types:**

| Event | Phase | Matcher matches on |
|-------|-------|--------------------|
| `sessionStart` | Lifecycle | -- |
| `sessionEnd` | Lifecycle | -- |
| `stop` | Lifecycle | `"Stop"` |
| `preToolUse` | Tool | Tool type (`"Shell"`, `"Read"`, `"Write"`, `"MCP:toolname"`) |
| `postToolUse` | Tool | Tool type |
| `postToolUseFailure` | Tool | Tool type |
| `subagentStart` | Subagent | Subagent type |
| `subagentStop` | Subagent | Subagent type |
| `beforeShellExecution` | Shell | Command pattern (e.g., `"curl\|wget"`) |
| `afterShellExecution` | Shell | Command pattern |
| `beforeMCPExecution` | MCP | MCP tool name |
| `afterMCPExecution` | MCP | MCP tool name |
| `beforeReadFile` | File | Tool type |
| `afterFileEdit` | File | Tool type |
| `preCompact` | Context | -- |
| `beforeSubmitPrompt` | Context | `"UserPromptSubmit"` |

**Exit codes:** `0` = success, `2` = block action, other = fail-open (unless `failClosed: true`)

**Key differences from Claude Code:**
- Requires `"version": 1` top-level field
- `failClosed` option for fail-closed behavior
- `loop_limit` for stop hooks
- Separate shell/MCP/file events in addition to generic tool events
- Timeout in seconds (not milliseconds)
- Prompt-based hooks (`type: "prompt"`) with LLM evaluation

**Example:**

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [
      {
        "command": "./hooks/format.sh",
        "matcher": "Write",
        "timeout": 10
      }
    ]
  }
}
```

---

## MCP Servers

**Location:** `.cursor/mcp.json` (project) or `~/.cursor/mcp.json` (user)

**Format:** JSON

**Server entry fields (STDIO):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | string | Yes | Executable name or path |
| `args` | string[] | No | Command-line arguments |
| `env` | object | No | Environment variables |
| `envFile` | string | No | Path to `.env` file |

**Server entry fields (Remote):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `url` | string | Yes | Endpoint URL (SSE or Streamable HTTP) |
| `headers` | object | No | Custom HTTP headers |
| `auth` | object | No | OAuth config (`CLIENT_ID`, `CLIENT_SECRET`, `scopes`) |

**Variable interpolation:** `${env:NAME}`, `${userHome}`, `${workspaceFolder}`

**Example:**

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path"],
      "env": { "NODE_ENV": "production" }
    },
    "remote-tools": {
      "url": "https://mcp.example.com/sse",
      "headers": {
        "Authorization": "Bearer ${env:MCP_TOKEN}"
      }
    }
  }
}
```

---

## Unsupported Content Types

| Type | Notes |
|------|-------|
| Agents (subagent definitions) | Cursor has built-in multi-agent support but no user-defined agent config files |
