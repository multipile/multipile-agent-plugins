# AGENTS.md

This repository is the multipile plugin marketplace. It publishes the same plugins to Claude Code and Codex. Right now it holds one plugin, `gitrepo`, which carries the `multipile` skill: how an agent works in a git repository that declares piles.

[README.md](README.md) explains the layout and the commands. [CONTRIBUTING.md](CONTRIBUTING.md) has the rules every plugin is held to. Read both before you change anything.

## Before a commit

- Run `npm run validate`. It must pass. It lints every plugin, checks that the generated catalogs are current, and validates the marketplace with the real Claude Code and Codex CLIs, which it does not install for you.
- If you changed any `plugin.json` or `marketplace.config.json`, run `npm run build` and commit the regenerated files with the change.
- Never edit generated files by hand: `.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json` and `plugins/<name>/.claude-plugin/plugin.json`. CI fails when they are stale.
- A change that users should receive bumps `version` in that plugin's `plugin.json`, followed by `npm run build`. Both hosts cache by version, so without a bump nobody gets the change.

## The multipile skill

The skill lives in `plugins/gitrepo/skills/multipile/`. `SKILL.md` is the entry point, `reference/` has one page per concept, `workflows/` has step-by-step tasks, and `piles.sh` is a small checker and helper.

- The skill stands on its own. It needs no `pile` binary and names no `pile` command, and `piles.sh` does what the skill needs.
- The `reference/` pages describe the same `.pile/` format the `pile` binary reads: configs, intents, declarations, links, types and the rules piles are held to. When that format changes, the pages and `piles.sh` change with it, so the skill and the binary never disagree.
- Keep `SKILL.md` frontmatter valid: `name` equals the directory name, and `description` is 1 to 1024 characters. `npm run lint` checks this.
