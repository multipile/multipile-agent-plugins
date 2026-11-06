# AGENTS.md

## Piles

This repository declares piles: subtrees that each have a `.pile/` directory whose `intent.md` says why they are one thing. Read a pile's intent before you change the pile, and keep it true in the same commit. The `multipile` skill in this repository says how: start with its `SKILL.md`, and check with its `piles.sh check` before a commit.

## Working in this repository

This repository is the multipile plugin marketplace. It publishes the same plugins to Claude Code and Codex. Right now it holds one plugin, `gitrepo`, which carries the `multipile` skill: how an agent works in a git repository that declares piles.

[README.md](README.md) explains the layout and the commands. [CONTRIBUTING.md](CONTRIBUTING.md) has the rules every plugin is held to. Read both before you change anything.

## Before a commit

- Run `npm run validate`. It must pass. It lints every plugin, checks that the generated catalogs are current, and validates the marketplace with the real Claude Code and Codex CLIs, which it does not install for you.
- If you changed any `plugin.json` or `marketplace.config.json`, run `npm run build` and commit the regenerated files with the change.
- Never edit generated files by hand: `.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json` and `plugins/<name>/.claude-plugin/plugin.json`. CI fails when they are stale.
- A change that users should receive bumps `version` in that plugin's `plugin.json`, followed by `npm run build`. Both hosts cache by version, so without a bump nobody gets the change.

## The multipile skill

The skill lives in `plugins/gitrepo/skills/multipile/`. `SKILL.md` is the entry point, `reference/` has one page per concept, `workflows/` has step-by-step tasks, and `piles.sh` is a small checker and helper.

- The skill stands on its own, for an agent with no `pile` command line. Only `SKILL.md` names `pile`: when it is installed, it sends the agent to `pile guide`, which carries the same workflows. No other page names a `pile` command, so nothing here has to follow the cli's commands, and `piles.sh` does what every workflow needs.
- A workflow both carry, such as `review`, says the same thing in both, in the same words where the commands allow.
- The `reference/` pages describe the same `.pile/` format the `pile` binary reads: configs, intents, declarations, links, types and the rules piles are held to. When that format changes, the pages and `piles.sh` change with it, so the skill and the binary never disagree.
- Keep `SKILL.md` frontmatter valid: `name` equals the directory name, and `description` is 1 to 1024 characters. `npm run lint` checks this.
