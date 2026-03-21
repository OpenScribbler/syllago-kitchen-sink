# Windsurf — Format Reference

Provider slug: `windsurf`

Supports: Rules, Skills, Workflows (Commands), Hooks, MCP

Sources: [Windsurf docs](https://docs.windsurf.com), [Memories & Rules](https://docs.windsurf.com/windsurf/cascade/memories), [Skills](https://docs.windsurf.com/windsurf/cascade/skills), [Workflows](https://docs.windsurf.com/windsurf/cascade/workflows), [Hooks](https://docs.windsurf.com/windsurf/cascade/hooks), [MCP](https://docs.windsurf.com/windsurf/cascade/mcp)

---

## Rules

**Location:** `.windsurf/rules/*.md` (workspace) or `~/.codeium/windsurf/memories/global_rules.md` (global)

**System location (Linux/WSL):** `/etc/windsurf/rules/*.md`

**Legacy:** `.windsurfrules` (project root)

**Cross-provider:** `AGENTS.md` (root = always-on; subdirectory = auto-scoped to `<directory>/**`)

**Format:** YAML frontmatter + markdown body

**Frontmatter fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `trigger` | string | Yes | Activation mode (see below) |
| `description` | string | No | Rule purpose; used for `model_decision` activation |
| `globs` | string | Only for `glob` | File pattern (comma-separated, e.g., `"src/api/**/*.ts, src/services/**/*.ts"`) |

Note: `globs` is a single comma-separated string, not an array.

**Trigger types:**

| Trigger | Behavior |
|---------|----------|
| `always_on` | Rule applies to every session |
| `model_decision` | Agent evaluates description/content for relevance |
| `glob` | Applies when `globs` patterns match active files |
| `manual` | User invokes via `@rule-name` mention in chat |

**Default behavior:** If no frontmatter is present, rule is treated as `always_on`.

**Example:**

```markdown
---
trigger: glob
description: TypeScript API layer patterns
globs: "src/api/**/*.ts, src/services/**/*.ts"
---

# API Conventions

1. Validate all inputs at layer boundary
2. Use consistent error handling with custom error types
3. Return typed responses for all endpoints
```

---

## Skills

**Location:** `.windsurf/skills/<name>/SKILL.md` (workspace), `~/.codeium/windsurf/skills/<name>/SKILL.md` (global)

**System location (Linux/WSL):** `/etc/windsurf/skills/`

**Cross-agent compat:** `.agents/skills/` and `.claude/skills/` also scanned.

**Format:** YAML frontmatter + markdown body (`SKILL.md` required)

**Frontmatter fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Unique identifier. Lowercase letters, numbers, hyphens. |
| `description` | string | Yes | Helps Cascade decide when to auto-invoke. |

**Activation:** Automatic (description match) or manual (`@skill-name`).

**Example:**

```markdown
---
name: deploy-to-production
description: Guides the deployment process to production with safety checks
---

## Steps

1. Run pre-deployment checks...
2. Build the release artifact...
3. Deploy to staging first...
```

---

## Workflows (Commands)

**Location:** `.windsurf/workflows/*.md` (workspace) or `~/.codeium/windsurf/global_workflows/*.md` (global)

**Format:** Plain markdown (title + steps)

**Character limit:** 12,000 characters per file

**Activation:** Manual only via `/workflow-name` slash command.

Workflows can invoke other workflows (nested invocation).

**Example:**

```markdown
# Run Tests and Fix

Run the test suite, analyze failures, and fix them.

## Steps

1. Run the full test suite with `npm test`
2. Parse any failing test output
3. For each failure, identify the root cause
4. Apply the fix and re-run the failing test
5. Confirm all tests pass
```

---

## Hooks

**Location:** `.windsurf/hooks.json` (workspace) or `~/.codeium/windsurf/hooks.json` (user)

**System location (Linux/WSL):** `/etc/windsurf/hooks.json`

**Format:** JSON (merged from system > user > workspace)

**Schema:**

```json
{
  "hooks": {
    "<hook_type>": [
      {
        "command": "bash /path/to/script.sh",
        "show_output": true,
        "working_directory": "/optional/path"
      }
    ]
  }
}
```

**Hook entry fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | string | Yes | Shell command to execute |
| `show_output` | bool | No | Display stdout/stderr in Cascade UI |
| `working_directory` | string | No | Execution directory (default: workspace root) |

**Hook types (12 total):**

Pre-hooks (can block with exit code 2):
- `pre_read_code`, `pre_write_code`, `pre_run_command`, `pre_mcp_tool_use`, `pre_user_prompt`

Post-hooks (informational):
- `post_read_code`, `post_write_code`, `post_run_command`, `post_mcp_tool_use`, `post_cascade_response`, `post_cascade_response_with_transcript`, `post_setup_worktree`

**Exit codes:** `0` = success, `2` = block (pre-hooks only), other = non-blocking error

**Key differences from Claude Code/Gemini CLI:**
- Snake_case event names (not CamelCase)
- Simpler hook fields (`command`, `show_output`, `working_directory`)
- No matcher field; event types are more granular (separate `pre_read_code`, `pre_write_code`, `pre_run_command`)
- `show_output` instead of `statusMessage`
- No timeout field documented

**Example:**

```json
{
  "hooks": {
    "pre_write_code": [
      {
        "command": "python3 /scripts/validate-write.py",
        "show_output": true
      }
    ],
    "post_cascade_response": [
      {
        "command": "bash /scripts/log-response.sh",
        "show_output": false
      }
    ]
  }
}
```

---

## MCP Servers

**Location:** `~/.codeium/windsurf/mcp_config.json` (user-global only)

**Note:** No workspace-level MCP configuration documented.

**Format:** JSON

**Server entry fields (STDIO):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | string | Yes | Executable to run |
| `args` | string[] | No | Command arguments |
| `env` | object | No | Environment variables |

**Server entry fields (HTTP):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `serverUrl` | string | Yes | HTTP endpoint URL |
| `headers` | object | No | Custom HTTP headers |

**Server entry fields (SSE):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `url` | string | Yes | SSE endpoint URL |
| `headers` | object | No | Custom HTTP headers |

**Variable interpolation:** `${env:VARIABLE_NAME}` syntax

**Constraint:** 100 total tools across all connected MCP servers.

**Example:**

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_TOKEN}"
      }
    },
    "remote-api": {
      "serverUrl": "https://api.example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${env:AUTH_TOKEN}"
      }
    }
  }
}
```

---

## Unsupported Content Types

| Type | Notes |
|------|-------|
| Agents | Cascade is the single built-in agent; no user-defined agent configs |
