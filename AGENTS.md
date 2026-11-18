# AGENTS.md

## Piles

This repository declares piles: subtrees that each have a `.pile/` directory whose `intent.md` says why they are one thing. Read a pile's intent before you change the pile, and keep it true in the same commit. `pile`, the multipile command line, says how: start with `pile guide`, and `pile doctor` must exit 0 before a commit.

## Working in this repository

This repository is the multipile plugin marketplace. It publishes the same plugins to Claude Code and Codex. Right now it holds one plugin, `gitrepo`, which carries the multipile skills: what sends an agent to `pile` in a git repository that declares piles.

[README.md](README.md) explains the layout and the commands. [CONTRIBUTING.md](CONTRIBUTING.md) has the rules every plugin is held to. Read both before you change anything.

## Before a commit

- Run `npm run validate`. It must pass. It lints every plugin, checks that the generated catalogs are current, and validates the marketplace with the real Claude Code and Codex CLIs, which it does not install for you.
- If you changed any `plugin.json` or `marketplace.config.json`, run `npm run build` and commit the regenerated files with the change.
- Never edit generated files by hand: `.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json` and `plugins/<name>/.claude-plugin/plugin.json`. CI fails when they are stale.
- A change that users should receive bumps `version` in that plugin's `plugin.json`, followed by `npm run build`. Both hosts cache by version, so without a bump nobody gets the change.

## The multipile skills

The skills are the pile `@multipile`. Read its intent first.

- A skill holds no workflow and no reference page. `pile guide` carries them, each written for the `pile` that prints it. A skill says when it applies, which `pile guide` page to print, and which commands that page has the agent run.
- A skill's `description` is its trigger: both hosts read it to decide when the skill loads. Write it as the moments the skill is for, in the words a user or a task would use.
- What a skill adds around a workflow stays small: how to get to the workflow's first step, where to stop for a person, and what to do where `pile` is not installed. A step of a workflow that only a skill says belongs in `pile guide` instead, in [multipile/pile-cli](https://github.com/multipile/pile-cli).
- Every `pile` command and every page a skill names has to exist in the released `pile`. When a page is renamed or dropped there, the skill changes with it.
