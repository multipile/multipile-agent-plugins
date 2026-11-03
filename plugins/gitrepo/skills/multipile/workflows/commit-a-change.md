# Commit a change

Workflow: commit a change once the checks, the piles it touched and each
intent say it is ready.
Needs: [checks](../reference/checks.md), [reading](../reference/reading.md).
See next: [write-an-intent](write-an-intent.md),
[read-a-change](read-a-change.md), [start-a-change](start-a-change.md).

## When to use

A change is ready to commit, in a repository that declares piles, whoever
made it. The last step makes the commit with git, as the repository's own
rules say.

## What to have first

- The change, in the working copy.
- The repository's own rules for a commit, in its AGENTS.md or wherever it
  keeps them.

## Steps

### 1. Check every pile

```sh
<skill>/piles.sh check
git status --short -- ':(top,glob)**/.pile/*.toml'
```

Look for its exit code. 1 means a problem: fix each one as its line says,
and check again until it exits 0. Then read each `.toml` file the change
wrote against the rules in [checks](../reference/checks.md). A problem in
a pile you did not touch is one to raise, not to commit past.

### 2. See which piles the change touched

```sh
<skill>/piles.sh status
```

Look for the piles you meant to change, and no others. A pile changed that
nobody meant to touch is a boundary somebody crossed. A path that moved
from one pile to another counts in both: commit both halves together.

```sh
git diff HEAD -U0
```

Look in the lines the change adds, and in any new file. If they add a path
that points below another pile's root, or the change touched a directory
with its own build file, or a task that runs only it, that is not a pile,
write a boundary note ([boundaries](../reference/boundaries.md)).

### 3. Read each changed pile's intent again

```sh
<skill>/piles.sh show <pile>
```

Look for a sentence the change made untrue. If there is one, rewrite it in
this commit ([write-an-intent](write-an-intent.md)), and say so in the
message. If no sentence of the intent covers the change, write a boundary
note, and do not change the boundary.

Where the change added, changed or removed a link, read the pile at each
end of it. Look for a sentence of either intent that the link now
contradicts, and for a link title the change made untrue. A link whose
title or description would have to name a path inside another pile is a
boundary note too.

### 4. Commit with git

```sh
git add <path>
git commit
```

Look for git's own answer. In the message, say which piles the change
touched when it touched more than one, and why it was not split.

## Done when

- No pile breaks a rule of [checks](../reference/checks.md) as a problem.
- Status showed only the piles meant to change.
- Every changed pile's intent is still true, or rewritten in the commit.
- The intents at both ends of every changed link are still true.
- A path that crossed a boundary is committed whole, both halves together.

## What to hand back

The commit's id, the piles it changed, and every warning or note that is
still there, with why it stays. Then each boundary note.
