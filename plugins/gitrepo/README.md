# gitrepo

Teaches the agent how to work in a git repository that declares piles: subtrees with a `.pile/` directory whose `intent.md` says why each is one thing. One skill, `multipile`, carries the reference pages, the workflows, and `piles.sh`, a read-only helper that needs only `sh` and `git`.

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
└── skills/multipile/
    ├── SKILL.md                 the map; points at every other page
    ├── piles.sh                 list, which, show, files, log, status, check, id
    ├── reference/               what a pile, an intent, a boundary, a declaration is,
    │                            and how a boundary is changed
    └── workflows/               adopt, start, read and commit a change, write an intent,
                                 refine
```

To ship a change, bump `version` in `plugin.json`, run `npm run build` from the repository root, and commit the generated files with it.
