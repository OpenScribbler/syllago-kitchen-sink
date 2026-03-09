# Codex (OpenAI) — Format Reference

Provider slug: `codex`

Supports: Rules, Commands

Sources: [OpenAI Codex docs](https://developers.openai.com/codex), [GitHub](https://github.com/openai/codex)

---

## Rules

**Location:** `AGENTS.md` (project root)

**Format:** Plain markdown (no frontmatter)

**Schema:** Single-file, no structured metadata. All content is always-active. No support for conditional activation, globs, or per-rule descriptions.

**Example:**

```markdown
# Project Standards

## Code Style
- Use TypeScript strict mode
- Run `npm run lint` before committing
- Maximum line length: 100

## Testing
- Write tests for all new features
- Maintain >80% code coverage
- Use Jest for unit tests
```

**Converter notes:** Only `alwaysApply: true` rules survive export to Codex. Non-always rules are excluded with a warning.

---

## Commands

**Location:** `.codex/commands/` directory

**Format:** Markdown (YAML frontmatter + body) — follows the emerging Agent Skills standard

**Status:** Limited public documentation. Format inferred from repository examples and Open Agent Skills standard.

**Frontmatter fields (estimated):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Command identifier |
| `description` | string | Yes | What the command does |

**Body:** Markdown instructions for the command.

**Note:** Codex also supports a `agents/openai.yaml` metadata file alongside skills/commands for UI integration:

```yaml
interface:
  display_name: "Human-Readable Name"
  short_description: "Brief description for UI"
  default_prompt: |
    Default instructions
```

---

## Unsupported Content Types

Codex does not support Skills (as a separate concept from commands), Agents, Hooks, or MCP configuration through file-based formats.
