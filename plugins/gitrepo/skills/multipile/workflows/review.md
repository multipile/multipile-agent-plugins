# Review a pull request

Workflow: review a pull request by pile, against its task and each intent.
Needs: [reading](../reference/reading.md), [intent](../reference/intent.md).
See next: [read-a-change](read-a-change.md), [links](../reference/links.md),
[boundaries](../reference/boundaries.md).

## When to use

A branch is to be merged into another, through a pull request or not yet,
and you are to review it. A list of paths says which files changed. This
review says which piles changed, what each is for, and whether each
belongs to the task the branch was made for. It fixes nothing.

## What to have first

- The branch, checked out, with the history it shares with its base. A
  checkout of one commit, as CI often makes, has no merge base.
- The task the branch was made for: the pull request's title and
  description, or the issue it closes. Without one, ask for it.

## Steps

### 1. Find the base

```sh
gh pr view --json title,body,baseRefName
git fetch origin <base>
```

Look for the branch the change is to merge into, and the task. In GitHub
Actions, `$GITHUB_BASE_REF` names the base too. With no pull request, the
base is the branch the work goes into, such as `main`.

### 2. See which piles the branch changed

```sh
git diff --name-status -M origin/<base>...HEAD
<skill>/piles.sh which <path>...
```

Look for the pile each path is in, and list the paths under it, each with
its letter. Three dots compare from where HEAD left the base, so what
reached the base since is not part of the change. A path that moved from
one pile to another is in both: give `which` both of its paths. A path in
no pile is named as such.

### 3. Hold each pile to the task and to its intent

```sh
<skill>/piles.sh show <pile>
```

Look for the sentence of the intent each part of the change is held to,
and quote it. Then give each changed pile one verdict:

- **In the task**: the task needs this pile to change.
- **Not in the task**: nothing in the task needs it. It is a question for
  the author, not a verdict that the change is wrong.
- **Intent untrue**: the change made a sentence untrue, and did not
  rewrite it.

Read the pile at the other end of each link whose title the change
touches ([links](../reference/links.md)).

### 4. Read the lines

```sh
git diff origin/<base>...HEAD -- <path>
```

Look for what each change does, a pile at a time, now that you know what
the pile is for and whether the task asked for it.

### 5. Check every pile

```sh
<skill>/piles.sh check
```

Look for its exit code, and for problems in the piles the change touched.

## Done when

- Every changed pile was read whole, and has one verdict.
- Each part of the change is held to a quoted sentence of its intent.
- Every path in no pile, and every path that crossed a boundary, is named.

## What to hand back

A table of the changed piles: each pile's name, its path, the headline of
its intent, and how many paths it changed, then each pile's paths under
it. Then a line per changed pile: its verdict, and the sentence of its
intent the change is held to, quoted, with the piles not in the task and
the intents made untrue first. Then each link the change touched, the
paths in no pile, the paths that crossed a boundary, and what the check
reported. Change nothing, and post the review only where you were asked
to.
