# Codex (OpenAI) — Format Reference

Provider slug: `codex`

Supports: Rules, Skills, Agents, MCP

Sources: [OpenAI Codex docs](https://developers.openai.com/codex), [GitHub](https://github.com/openai/codex)

---

## Rules

**Location:** `AGENTS.md` (project root), subdirectories, or `~/.codex/AGENTS.md` (global)

**Format:** Plain markdown (no frontmatter)

**Discovery:** Codex walks root-to-leaf, checking `AGENTS.override.md` then `AGENTS.md` at each level. Files concatenate; closer files take higher priority. Global scope checked at `~/.codex/`.

**Config knobs (in `config.toml`):**

```toml
project_doc_fallback_filenames = ["TEAM_GUIDE.md", ".agents.md", "CONTRIBUTING.md"]
project_doc_max_bytes = 32768
```

**Example:**

```markdown
# Project Standards

## Code Style
- Use TypeScript strict mode
- Run `npm run lint` before committing

## Testing
- Write tests for all new features
- Maintain >80% code coverage
```

**Converter notes:** Only `alwaysApply: true` rules survive export to Codex. Non-always rules are excluded with a warning.

---

## Skills

**Location:** `.agents/skills/<name>/SKILL.md` (project) or `~/.agents/skills/<name>/SKILL.md` (user)

**Format:** YAML frontmatter + markdown body

**Frontmatter fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Skill identifier |
| `description` | string | Yes | When this skill should/should not trigger |

**Directory structure:**

```
my-skill/
  SKILL.md              # Required: frontmatter + instructions
  scripts/              # Optional: executable scripts
  references/           # Optional: reference documents
  assets/               # Optional: icons, images
  agents/
    openai.yaml         # Optional: UI metadata and policy
```

**agents/openai.yaml:** Optional metadata file for UI integration and behavior:

```yaml
interface:
  display_name: "Human-Readable Name"
  short_description: "Brief description for UI"
  default_prompt: |
    Default instructions
policy:
  allow_implicit_invocation: true
```

**Activation:** Explicit via `/skills` or `$skill-name`, or implicit auto-matching based on description (disable with `allow_implicit_invocation: false` in openai.yaml).

**Example:**

```markdown
---
name: draft-pr
description: >
  Drafts a pull request description from staged changes.
  Use when the user asks to create or draft a PR.
---

## Instructions

1. Run `git diff --cached` to see staged changes
2. Summarize the changes into a PR title and description
3. Use conventional commit style for the title
```

---

## Agents

**Location:** `.codex/agents/<name>.toml` (project) or `~/.codex/agents/<name>.toml` (global)

**Format:** TOML (standalone files, one per agent)

**Agent TOML fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Identifier for spawning (source of truth, not filename) |
| `description` | string | Yes | Guidance on when to use this agent |
| `developer_instructions` | string | Yes | Core behavioral directives (system prompt) |
| `nickname_candidates` | string[] | No | Display names for spawned instances |
| `model` | string | No | LLM selection override |
| `model_reasoning_effort` | enum | No | `minimal`, `low`, `medium`, `high`, `xhigh` |
| `sandbox_mode` | enum | No | `read-only`, `workspace-write`, `danger-full-access` |

Agents can also include `[mcp_servers]` and `[skills.config]` sub-tables to scope tools and skills to that agent.

**Built-in agents:** `default`, `worker`, `explorer` (can be overridden by placing a file with the matching name).

**Example:**

```toml
name = "pr_explorer"
description = "Read-only codebase explorer for gathering evidence before changes are proposed."
developer_instructions = """
You explore codebases to gather evidence. Do not make changes.
Focus on understanding architecture, dependencies, and patterns.
"""

model = "gpt-5.3-codex-spark"
model_reasoning_effort = "medium"
sandbox_mode = "read-only"
```

---

## MCP Servers

**Location:** `config.toml` under `[mcp_servers.<id>]` tables — `~/.codex/config.toml` (global) or `.codex/config.toml` (project)

**Format:** TOML

**STDIO transport fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | string | Yes | Launcher command |
| `args` | string[] | No | Command arguments |
| `cwd` | string | No | Working directory |
| `env` | map | No | Environment key/value pairs |
| `env_vars` | string[] | No | Forward named vars from parent environment |
| `enabled` | bool | No | Disable without removing config (default: true) |
| `enabled_tools` | string[] | No | Tool allowlist |
| `disabled_tools` | string[] | No | Tool denylist |
| `startup_timeout_sec` | number | No | Startup timeout in seconds (default: 10) |
| `tool_timeout_sec` | number | No | Per-tool timeout in seconds (default: 60) |

**HTTP transport fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `url` | string | Yes | Streamable HTTP endpoint |
| `bearer_token_env_var` | string | No | Env var sourcing bearer token |
| `http_headers` | map | No | Static request headers |
| `env_http_headers` | map | No | Headers sourced from env vars |

**Example:**

```toml
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]

[mcp_servers.context7.env]
MY_ENV_VAR = "MY_ENV_VALUE"

[mcp_servers.figma]
url = "https://mcp.figma.com/mcp"
bearer_token_env_var = "FIGMA_OAUTH_TOKEN"
http_headers = { "X-Figma-Region" = "us-east-1" }
```

---

## Unsupported Content Types

| Type | Notes |
|------|-------|
| Commands | Deprecated; replaced by Skills |
| Hooks | Not supported |
