# Contributing a plugin

## Add a plugin

```bash
npm run new -- my-plugin --description "What it does" --category Productivity
```

This copies `templates/plugin/` to `plugins/my-plugin/`, adds the entry to `marketplace.config.json`, and regenerates the catalogs. Then:

1. Edit `plugins/my-plugin/plugin.json`. Keep `name` equal to the directory name.
2. Replace the starter skill in `plugins/my-plugin/skills/`.
3. Run `npm run validate`.
4. Commit the plugin together with the regenerated files under `.claude-plugin/`, `.agents/`, and `plugins/my-plugin/.claude-plugin/`.

## Rules the build enforces

`npm run lint` (and every build) checks each plugin with `scripts/validate-plugin.mjs` against these rules:

- `plugin.json` is a closed schema: only `$schema`, `name`, `version`, `description`, `author`, `homepage`, `repository`, `license`, `keywords`, `extensions`. Anything else is an error. Client-specific data goes under `extensions.<reverse-domain>`.
- `name` is 1 to 64 characters of lowercase letters, digits, `-` and `.`, alphanumeric at both ends, with no `--` or `..`, and equal to the directory name. Both hosts key installs on it.
- `version` and `description` are required: hosts use `version` for update checks, and `description` is what the catalog shows.
- `author`, when present, has only `name`, `email`, `url`, and Claude Code requires `name`.
- Nothing in the package may resolve outside the plugin root, including through symlinks.
- Every `skills/<name>/SKILL.md` has frontmatter whose `name` equals the directory, is lowercase with single hyphens, and whose `description` is 1 to 1024 characters. A `SKILL.md` deeper than one level is never discovered and is reported.
- `mcp.json`, when present, matches the 1.0.0 MCP schema: every server has a `type` of `stdio`, `streamable-http` or `sse` and only the fields that type allows. A stdio `command` is one executable token, either a bare name or a `./` path inside the plugin, never a shell string; `env` has no reserved `PLUGIN_ROOT` or `PLUGIN_DATA`; `cwd` is rooted at `./`, `${PLUGIN_ROOT}` or `${PLUGIN_DATA}`. A remote `url` is absolute HTTPS, or HTTP only on localhost, with no user info or fragment.
- Every plugin ships at least one component: `skills/`, `mcp.json`, `.mcp.json`, `hooks/`, `commands/`, or `agents/`.
- Every catalog entry has a `category` and a Codex install `policy`. The defaults in `marketplace.config.json` cover most plugins.

The build cannot check what a value means, so one rule is yours to keep: MCP `headers` never carry secrets.

The repository is MIT licensed and the template sets `"license": "MIT"`. A plugin that drops the field gets a warning, not an error.

## What is portable and what is host-specific

The Agent Plugins format covers the package only: `plugin.json`, `skills/`, `mcp.json`, and reverse-domain extensions. Catalogs and installation belong to each host. So:

| In this repo | What it is |
| :- | :- |
| `plugins/<name>/plugin.json`, `skills/`, `mcp.json` | The portable core, read by Codex. |
| `extensions.com.openai` in `plugin.json` | Codex's extension namespace. Other hosts ignore it. |
| `plugins/<name>/.claude-plugin/plugin.json`, `.mcp.json`, `hooks/`, `commands/`, `agents/` | Claude Code's own format. Claude Code does not read `plugin.json`. |
| `.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json` | Catalog files for one host each. |

The schemas under `schemas/agent-plugins/` are the exact contract the build checks against.

## What each host reads

| Component | Claude Code | Codex | Shared? |
| :- | :- | :- | :- |
| Identity (name, version, description, author, ...) | `.claude-plugin/plugin.json` (generated) | `plugin.json` | Yes, via the build |
| Skills | `skills/<name>/SKILL.md` | `skills/<name>/SKILL.md` | Yes |
| MCP servers | `.mcp.json` | `mcp.json` (Agent Plugins format, each server has a `type`) | No, write both |
| Hooks | `hooks/hooks.json` | `hooks/hooks.json` (not trusted on install) | Same file, different behaviour |
| Commands, agents, output styles, LSP | `commands/`, `agents/`, `output-styles/`, `.lsp.json` | ignored | No |
| Store listing | `.claude-plugin/plugin.json` listing fields | `extensions.com.openai.interface` in `plugin.json` | No |

Skills are the portable unit. Build a plugin around skills first, and add host-specific files only when you need them.

Claude-only manifest keys (`hooks`, `mcpServers`, `userConfig`, `commands`, ...) go in `.claude-plugin/plugin.json`. The build overwrites only the identity fields in that file and keeps everything else.

## Ship an update

Bump `version` in `plugin.json` and run `npm run build`. Claude Code pins installed plugins to the manifest version, so without a bump users never receive the change. Codex caches by version too.

## Rename or remove a plugin

Removing an entry from `marketplace.config.json` stops new installs but leaves existing Claude Code installs in place. To uninstall it on users' machines, or to rename a plugin without breaking their install, set the top-level `claude` passthrough in `marketplace.config.json`:

```json
"claude": { "forceRemoveDeletedPlugins": true, "renames": { "old-name": "new-name" } }
```

Both keys are copied verbatim into `.claude-plugin/marketplace.json`. Codex has no equivalent; users remove the plugin themselves.
