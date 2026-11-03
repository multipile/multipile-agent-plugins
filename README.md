# Multipile plugin marketplace

A single repository that publishes the same plugins to **Claude Code** and **Codex**. Each plugin is a portable Agent Plugins package. Each host reads its own catalog file, and both catalogs are generated from one source of truth so they never drift.

```text
.
├── marketplace.config.json          source of truth: marketplace identity + plugin list
├── plugins/
│   └── gitrepo/
│       ├── plugin.json              portable Agent Plugins manifest (source of truth per plugin)
│       ├── .claude-plugin/plugin.json   generated
│       └── skills/multipile/        the skill, loaded by both hosts
├── .claude-plugin/marketplace.json  generated, read by Claude Code
├── .agents/plugins/marketplace.json generated, read by Codex
├── schemas/agent-plugins/1.0.0/     Agent Plugins JSON Schemas, for reference
├── scripts/
│   ├── validate-plugin.mjs          checks a plugin against the plugin and skill rules
│   ├── build-catalog.mjs            validates every plugin, then generates the outputs above
│   └── validate.sh                  runs both hosts' validators
└── .github/workflows/validate.yml   CI
```

## Install the marketplace

Claude Code:

```bash
claude plugin marketplace add https://github.com/multipile/multipile-agent-plugins.git
claude plugin install gitrepo@multipile
```

Codex:

```bash
codex plugin marketplace add https://github.com/multipile/multipile-agent-plugins.git
codex plugin add gitrepo@multipile
```

Both commands also accept a local checkout path instead of the URL, which is the quickest way to test changes.

Then open any repository that has a `.pile/` directory. The `multipile` skill loads on its own, or run `/gitrepo:multipile` in Claude Code.

## Plugins

| Plugin | What it does |
| :- | :- |
| [gitrepo](plugins/gitrepo/README.md) | How to work in a git repository that declares piles: read it pile by pile, scope and commit a change, write `.pile/` declarations. |

## Maintain the marketplace

| Task | Command |
| :- | :- |
| Check every plugin against the rules in CONTRIBUTING.md | `npm run lint` |
| Regenerate catalogs after editing any `plugin.json` or the config | `npm run build` |
| Check that generated files are current | `npm run check` |
| Full validation with both CLIs | `npm run validate` |

`npm run validate` runs `claude plugin validate` on the marketplace and every plugin, then adds the marketplace and installs every plugin into a throwaway Codex home under `.validate-codex-home/`. Your real `~/.claude` and `~/.codex` are not touched. CI runs the same script with both CLIs installed.

Generated files are committed so that hosts can read them straight from git. Never edit them by hand; CI fails if they are stale.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the plugin authoring rules and what each host reads.

## How the two formats map

| | Claude Code | Codex |
| :- | :- | :- |
| Catalog file | `.claude-plugin/marketplace.json` | `.agents/plugins/marketplace.json` |
| Required catalog fields | `name`, `owner`, `plugins[]` | `name`, `plugins[]` |
| Entry source | `"./plugins/<name>"` | `{ "source": "local", "path": "./plugins/<name>" }` |
| Entry extras | `description`, `category`, `tags`, display fields | `policy`, `category` |
| Plugin manifest | `.claude-plugin/plugin.json` (optional) | `plugin.json` at the plugin root |
| Install id | `<plugin>@multipile` | `<plugin>@multipile` |

`marketplace.config.json` carries the union. Host-specific escape hatches: a `claude` or `codex` object on an entry, or at the top level, is merged verbatim into that host's output.

## License

MIT. See [LICENSE](LICENSE).
