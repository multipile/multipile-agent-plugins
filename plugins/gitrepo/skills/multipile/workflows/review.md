# Review a pull request

Workflow: review a pull request by pile, against its task and each intent.
Needs: [reading](../reference/reading.md), [quality](../reference/quality.md).
See next: [read-a-change](read-a-change.md), [links](../reference/links.md),
[boundaries](../reference/boundaries.md), [intent](../reference/intent.md).

## When to use

A branch is to be merged into another, through a pull request or not yet,
and you are to review it. A list of paths says which files changed. This
review says, for each pile the branch changed, whether the task needed it
and whether its intent admits it, and reports only what the author has to
act on. It fixes nothing.

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
its letter. A pile whose `.pile/intent.md` changed had its intent
rewritten, and one whose `.pile/*.toml` changed had its links rewritten.
Three dots compare from where HEAD left the base. A path that moved
between piles is in both: give `which` both of its paths. A path in no
pile is named as such.

### 3. Read each changed pile, and answer for it

```sh
<skill>/piles.sh show <pile>
git diff origin/<base>...HEAD -- <path>
```

Look for the sentence of the intent each part of the change is held to,
and quote it. Then give the pile its two answers. Read the lines a pile at
a time, now that you know what the pile is for.

### 4. Compare what the branch rewrote

```sh
git show origin/<base>:<pile path>/.pile/intent.md
git diff origin/<base>...HEAD -- '<pile path>/.pile/*.toml'
```

For a pile whose intent was rewritten, look for whether the new intent is
worse than this one ([quality](../reference/quality.md)). For one whose
links were rewritten, look for each link the branch added, removed or
retitled.

### 5. Hold the links

```sh
cat <pile path>/.pile/*.toml
git grep -n -F -e '"@<name>"' -- ':(top,glob)**/.pile/*.toml'
```

Look for each link to or from a changed pile, and hold it to what the
change did. Each link names its type: the aux pile that creates it holds
an `[[edge-types]]` table with its `do` and `dont`. Where the change makes
one pile use another, look for a link that says so.

### 6. Check every pile

```sh
<skill>/piles.sh check
```

Look for its exit code, and for problems in the piles the change touched.

## Done when

- Every changed pile was read whole, and has its two answers.
- Each part of the change is held to a quoted sentence of its intent.
- Every rewritten intent was compared with its base, and every link to or
  from a changed pile was held to its type.

## What to hand back

Findings, and nothing else, in the shape [quality](../reference/quality.md)
shows. A pile with no finding is not listed. Leave out a table of the
changed piles, posted on its own where CI makes one, and the check unless
it found something. Change nothing, and post only where you were asked to.
