# gitrepo

Skills for working in a git repository that declares piles: subtrees with a `.pile/` directory whose `intent.md` says why each is one thing. The skills hold no workflow of their own. Each says when it applies, and sends the agent to [`pile`](https://github.com/multipile/pile-cli), the multipile command line, whose guide, `pile guide`, carries every workflow and reference page.

So the plugin needs `pile`:

```bash
brew install multipile/tap/pile
```

Without it, a skill says that `pile` is missing and how to install it, and installs nothing itself.

## The skills

| Skill | When it applies | What it runs |
| :- | :- | :- |
| `multipile` | a repository holds a `.pile/` directory, or piles, an intent or multipile come up; before the first edit | `pile guide`, `pile guide start-a-change` |
| `pile-commit` | before every commit | `pile guide commit-a-change` |
| `pile-review` | a pull request or a branch is to be reviewed, or a change read, pile by pile | `pile gitdiff`, `pile guide review` |
| `pile-intent` | an intent is missing, still a question, or untrue | `pile guide write-an-intent` |
| `pile-adopt` | a project with no piles is to be laid out in piles | `pile guide adopt` |
| `pile-refine` | the piles a repository declares are to be improved | `pile guide refine` |

`pile-review` makes locally the review that the GitHub Action [`generate-pile-diff-action`](https://github.com/multipile/generate-pile-diff-action) asks an agent for on every pull request. It hands the review back in the session, and posts it only when asked.

## Install and invoke

| Host | Install | Invoke |
| :- | :- | :- |
| Claude Code | `claude plugin install gitrepo@multipile` | automatically, each skill when it applies, or by name: `/gitrepo:multipile`, `/gitrepo:pile-review` |
| Codex | `codex plugin add gitrepo@multipile` | automatically, each skill when it applies, or pick one from `/skills` |

Both assume the Multipile marketplace is already added; see the repository README.

## Layout

```text
gitrepo/
├── plugin.json                  portable manifest (edit this one)
├── .claude-plugin/plugin.json   generated from plugin.json
└── skills/<skill>/SKILL.md      the skills, one directory each
```

To ship a change, bump `version` in `plugin.json`, run `npm run build` from the repository root, and commit the generated files with it.
