---
name: pile-commit
description: Checks a change before it is committed, in a git repository that declares piles (it holds a `.pile/` directory). Use this skill before every `git commit` in such a repository, even if the user only says "commit this" or "wrap it up". Also use it when the user asks whether a change is ready to commit, asks to run doctor, or a check reports a problem with a pile.
---

# Commit a change, in a repository of piles

`pile` makes no commit. It says whether the change is ready for one: no pile has a problem, the change touched only the piles it meant to, and each changed pile's intent is still true.

## 1. Make sure `pile` is there

```sh
command -v pile
```

If it answers nothing, say that `pile` is not installed, and how to get it: `brew install multipile/tap/pile`, or https://github.com/multipile/pile-cli. Do not install it unasked. Read the `.pile/intent.md` of each pile the change touched, rewrite any sentence the change made untrue, and say in what you hand back that the commit was not checked with `pile`.

## 2. Carry out the workflow

```sh
pile guide commit-a-change
```

Follow it from the top, in order, and never from memory. Its steps run these, and say what to look for in each answer:

```sh
pile doctor
pile status --all --brief
pile show <pile>
```

`pile doctor` must exit 0 before the commit. A problem in a pile you did not touch is one to raise, not to commit past. The last step commits with git, as the repository's own rules say.

## 3. Hand back what the workflow asks for

The commit's id, the piles it changed, what doctor still reports, and each boundary note (`pile guide boundary-note`).
