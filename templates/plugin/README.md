# __NAME__

__DESCRIPTION__

| Host | Invoke |
| :- | :- |
| Claude Code | `/__NAME__:hello` |
| Codex | pick `hello` from `/skills` |

Edit `plugin.json` for identity fields. Put skills under `skills/<name>/SKILL.md`. Run `npm run build` from the repository root after changes; it regenerates `.claude-plugin/plugin.json` and both catalogs.
