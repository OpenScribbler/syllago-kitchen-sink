# Copilot CLI — Format Reference

Provider slug: `copilot-cli`

Supports: Rules, Skills, Agents, Hooks, MCP

Sources: [GitHub Copilot Docs](https://docs.github.com/en/copilot), [Custom Agents](https://docs.github.com/en/copilot/reference/custom-agents-configuration), [Skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills), [Hooks](https://docs.github.com/en/copilot/reference/hooks-configuration)

---

## Rules

**Location:** `.github/copilot-instructions.md` (repo-wide), `.github/instructions/*.instructions.md` (path-specific), `AGENTS.md`/`CLAUDE.md`/`GEMINI.md` (agent instructions)

**Personal location:** `~/.copilot/copilot-instructions.md`

**Format:** Plain markdown; path-specific instructions use YAML frontmatter with `applyTo` glob

**Path-specific frontmatter fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `applyTo` | string | Yes | Glob pattern (e.g., `"**/*.py"`) |
| `excludeAgent` | string | No | `"code-review"` or `"coding-agent"` |

**Example (path-specific):**

```markdown
---
applyTo: "**/*.py"
---

Use type hints on all function signatures.
Prefer dataclasses over plain dicts for structured data.
```

---

## Skills

**Location:** `.github/skills/<name>/SKILL.md` (project) or `~/.copilot/skills/<name>/SKILL.md` (user)

**Cross-tool compatible:** `.claude/skills/<name>/SKILL.md` and `.agents/skills/<name>/SKILL.md` are also auto-discovered.

**Format:** YAML frontmatter + markdown body

**Frontmatter fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Lowercase, hyphens. Typically matches directory name. |
| `description` | string | Yes | What the skill does and when to use it |
| `license` | string | No | Applicable license |

**Invocation:** `/skill-name` in a prompt, or auto-loaded based on `description`.

**Example:**

```markdown
---
name: frontend-design
description: Use this skill when creating or modifying React UI components.
---

## Guidelines

1. Use the project's design tokens from `src/tokens/`
2. All interactive elements must have ARIA labels
3. Prefer CSS modules over inline styles
```

---

## Agents

**Location:** `.github/agents/<name>.agent.md` (project) or `.github-private/agents/<name>.agent.md` (org/enterprise)

**Naming:** `<agent-name>.agent.md` — filename constraints: `.`, `-`, `_`, `a-z`, `A-Z`, `0-9`

**Format:** YAML frontmatter + markdown body (max 30,000 characters)

**Frontmatter fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | Identifier (defaults to filename without `.agent.md`) |
| `description` | string | Yes | Brief explanation of agent capabilities |
| `tools` | string[] | No | Tool names/aliases. Omit for all tools. Empty `[]` disables all. |
| `mcp-servers` | object | No | MCP server config specific to this agent |
| `model` | string | No | AI model to use |
| `target` | string | No | `"vscode"` or `"github-copilot"` (runtime-only, safe to drop) |

**Tool references:** Built-in tools or MCP server tools: `["read", "edit", "search", "some-mcp-server/tool-1"]`

**Example:**

```markdown
---
name: api-reviewer
description: Reviews API endpoint implementations for REST conventions, error handling, and security.
tools: ["read", "search"]
model: gpt-4o
---

You are an API review specialist. When asked to review code:

1. Check REST naming conventions
2. Verify error responses use standard HTTP status codes
3. Ensure authentication middleware is applied
4. Flag any SQL injection or XSS vulnerabilities
```

---

## Hooks

**Location:** `.github/hooks/<name>.json` (CLI loads from cwd; coding agent loads from default branch)

**Format:** JSON

**Root schema:**

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [...],
    "sessionEnd": [...],
    "userPromptSubmitted": [...],
    "preToolUse": [...],
    "postToolUse": [...],
    "errorOccurred": [...]
  }
}
```

**Hook event types:**

| Event | Can Block | Description |
|-------|-----------|-------------|
| `sessionStart` | No | New/resumed session |
| `sessionEnd` | No | Session completes |
| `userPromptSubmitted` | No | User enters a prompt |
| `preToolUse` | Yes | Before tool execution (only blocking hook) |
| `postToolUse` | No | After tool execution |
| `errorOccurred` | No | Error during session |

**Hook definition fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `"command"` | Yes | Hook type |
| `bash` | string | Conditional | Script path or inline command (Linux/macOS) |
| `powershell` | string | Conditional | Script path or inline command (Windows) |
| `cwd` | string | No | Working directory for the script |
| `timeoutSec` | number | No | Timeout in seconds (default: 30) |
| `comment` | string | No | Human-readable description |

At least one of `bash` or `powershell` required.

**preToolUse output (blocking):**

```json
{
  "permissionDecision": "allow|deny|ask",
  "permissionDecisionReason": "Reason string"
}
```

**Key differences from Claude Code/Gemini CLI:**
- Separate JSON files in `.github/hooks/` (not embedded in settings.json)
- Requires `"version": 1` field
- Timeout in seconds (not milliseconds)
- `bash`/`powershell` instead of `command`
- No matcher support (hooks apply to all tools in an event)
- `preToolUse` is the only blocking hook; uses `permissionDecision` output format

**Example:**

```json
{
  "version": 1,
  "hooks": {
    "preToolUse": [
      {
        "type": "command",
        "bash": ".github/hooks/validate-tool.sh",
        "timeoutSec": 5,
        "comment": "Validate tool use before execution"
      }
    ]
  }
}
```

---

## MCP Servers

**Location:** `~/.copilot/mcp-config.json` (global) or `.copilot/mcp-config.json` (project)

**Session-only:** `--additional-mcp-config PATH` flag

**Format:** JSON

**Server entry fields (STDIO):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `"local"` or `"stdio"` | Yes | Transport type |
| `command` | string | Yes | Executable to start |
| `args` | string[] | No | Command arguments |
| `env` | object | No | Environment variables |
| `tools` | string or string[] | No | `"*"` for all, or specific tool names |

**Server entry fields (HTTP):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `"http"` | Yes | Transport type |
| `url` | string | Yes | Remote endpoint URL |
| `headers` | object | No | HTTP headers |
| `tools` | string or string[] | No | Tool filter |

**Tool name format:** `server/tool` (slash-separated, e.g., `github/search_repositories`)

**Example:**

```json
{
  "mcpServers": {
    "playwright": {
      "type": "local",
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "env": {},
      "tools": ["*"]
    },
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}
```

---

## Tool Name Mapping

| Copilot CLI | Claude Code | Gemini CLI |
|-------------|-------------|------------|
| `view` | `Read` | `read_file` |
| `apply_patch` | `Write` / `Edit` | `write_file` / `replace` |
| `shell` | `Bash` | `run_shell_command` |
| `glob` | `Glob` | `list_directory` |
| `rg` | `Grep` | `grep_search` |
| `task` | `Task` | -- |
