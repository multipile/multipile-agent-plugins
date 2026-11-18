---
name: multipile
description: Guides work in a git repository that declares piles, subtrees with a `.pile/` directory whose `intent.md` says why each is one thing. Use this skill whenever a repository holds a `.pile/` directory, at the start of a session there, and before the first edit of any file, even if the user does not mention piles. Also use it when the user, an AGENTS.md or a task names piles, a pile's intent, a `.pile/` file, `pile` or multipile, or asks which pile a file is in or what a pile is for. For a commit, a review, an intent, or laying out or refining piles, use the `pile-` skill for that.
---

# Working in a repository of piles

A pile is a subtree of a git repository that has a `.pile/` directory, and says in its intent, `.pile/intent.md`, why it is one thing. Whoever arrives next, a person or an agent, reads a pile before they change it, and keeps its intent true.

`pile`, the multipile command line, carries the guide: every workflow and every reference page, each written for the `pile` that prints it. This skill holds no copy of them. It says when to run which command.

## Make sure `pile` is there

```sh
command -v pile
```

If it answers nothing, go to [Without `pile`](#without-pile).

## When a session starts

```sh
pile guide
```

Read what it prints whole. It says what a pile is, how to name one, and which page answers what.

## Before you write in a file

```sh
pile guide start-a-change
```

Carry it out from the top, before the first edit. It finds the pile each path is in with `pile which <path>`, and has you read that pile with `pile show <pile>` before you change it.

## Which command for what

| You are about to | Run | Skill |
|---|---|---|
| write in a file | `pile guide start-a-change` | this one |
| commit | `pile guide commit-a-change` | `pile-commit` |
| review a pull request or a branch, or read somebody's change | `pile guide review`, `pile guide read-a-change` | `pile-review` |
| write an intent, or fix one that is untrue | `pile guide write-an-intent` | `pile-intent` |
| lay a project with no piles out in piles | `pile guide adopt` | `pile-adopt` |
| improve the piles a repository declares | `pile guide refine` | `pile-refine` |
| decide whether a subtree is one pile | `pile guide boundaries` | |
| report a boundary that looks untrue | `pile guide boundary-note` | |
| write a link, a type, an aux pile or a diagram | `pile guide links`, `types`, `aux`, `diagrams` | |
| find out which command reads what | `pile guide reading` | |
| see every page | `pile guide --list` | |

## Carry a workflow out from what `pile` prints

A workflow is a page for accomplishing one thing. Print it, and follow it in order: each step's commands as the step gives them, then what the step says to look for. Never carry one out from memory, because the page changes with the `pile` that prints it.

An agent gets every answer as JSON. A workflow's parts are under `result.pages[0].workflow`: `when`, `first`, `steps`, `done_when` and `hand_back`, and each step has the commands to `run` and what to `look_for`. `--format text` prints what a person reads.

If `pile guide <page>` is refused as `unknown-page`, the `pile` installed is older than this skill. Say so, and that upgrading it fixes it.

## Without `pile`

Say that `pile` is not installed, and how to get it: `brew install multipile/tap/pile`, or https://github.com/multipile/pile-cli. Do not install it unasked.

Then go on with the work, by the one rule that needs no command: a path is in the pile whose `.pile/` directory is nearest at or above it. Read that pile's `.pile/intent.md` before you change the pile, and keep the intent true in the same commit. Say in what you hand back that the change was not checked with `pile`.
