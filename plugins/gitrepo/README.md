# gitrepo

Teaches the agent how to work in a git repository that declares piles: subtrees with a `.pile/` directory whose `intent.md` says why each is one thing. One skill, `multipile`, carries the reference pages, the workflows, and `piles.sh`, a read-only helper that needs only `sh` and `git`. Where the [`pile`](https://github.com/multipile/pile-cli) command line is installed, the skill sends the agent to its own guide, `pile guide`, instead.

| Host | Install | Invoke |
| :- | :- | :- |
| Claude Code | `claude plugin install gitrepo@multipile` | `/gitrepo:multipile`, or automatically when a repository holds a `.pile/` directory |
| Codex | `codex plugin add gitrepo@multipile` | automatically when piles, an intent or a `.pile/` file come up, or pick `multipile` from `/skills` |

Both assume the Multipile marketplace is already added; see the repository README.

## Layout

```text
gitrepo/
├── plugin.json                  portable manifest (edit this one)
├── .claude-plugin/plugin.json   generated from plugin.json
└── skills/multipile/          the skill; its SKILL.md is the map of the rest
```

To ship a change, bump `version` in `plugin.json`, run `npm run build` from the repository root, and commit the generated files with it.
