# Refine piles

Workflow: improve the piles a repository already declares, so that its
layout is more stable.
Needs: [boundaries](../reference/boundaries.md),
[reshaping](../reference/reshaping.md), [links](../reference/links.md).
See next: [write-an-intent](write-an-intent.md),
[commit-a-change](commit-a-change.md).

## When to use

The repository declares piles, and somebody asked for its layout to be
refined: one pile they name, or the whole repository. This is the only
workflow that moves a declared boundary, and, with [adopt](adopt.md), the
only one that moves a file. During an ordinary change you report a
boundary that looks untrue, and do not move it.

Do not use it where no pile is declared. Use [adopt](adopt.md) for those.

## What to have first

- The person who owns the repository, to accept or reject each item and to
  approve each intent. You stop to wait for them.
- The repository's own rules for a commit, in its AGENTS.md or wherever it
  keeps them.
- Nothing changed already:

  ```sh
  <skill>/piles.sh status
  ```

## Steps

### 1. Scope the refine

```sh
<skill>/piles.sh list
<skill>/piles.sh show <pile>
```

For the whole repository, every pile list names. For one pile, that pile,
its parent, its children, and the pile at the other end of each of its
links, found as [reading](../reference/reading.md) says.

### 2. Read the evidence

```sh
<skill>/piles.sh files <pile>
<skill>/piles.sh log <pile> --stat -n 50
git grep -n -F '<dir>/' -- ':!<dir>'
```

Look for what [boundaries](../reference/boundaries.md) counts as evidence:
build files, what other piles read, and what the history changes together
and apart. With no history to read, say so.

### 3. Test the layout

Follow "What another pile relies on" in
[boundaries](../reference/boundaries.md), starting from the piles the
repository declares, with every row of its table. Read each link's title,
and draft the title of each link that is missing. Check the signs that a
boundary has stopped being true. Hold every pile's own files, not only the
top pile's, to the one-sentence test, to find a leaf nobody declared.

Check that each edge type the links are of exists
([types](../reference/types.md)). This lists the edge types declared:

```sh
git grep -n -A1 -F '[[edge-types]]' -- ':(top,glob)**/.pile/*.toml'
```

If the repository has no aux pile at all, one holding `relies-on` is an
item to propose, as [adopt](adopt.md) step 5 does, declared as adopt step
7 says.

### 4. Propose, and wait

Propose one numbered list. Each item names its operation (split, merge,
move a pile, move files, rename, unmake or declare), the piles and paths,
the sign and the evidence that call for it, and what it costs: ids minted
or retired, files moved, references rewritten. A change to code that the
test raised is a question for the person, not an item.

The person accepts or rejects each item. If they reject an item that
other items assume, draft those items again against what they accepted,
and propose them again.

Stop, and wait until they agree. With nobody to answer, stop here and
commit nothing.

### 5. Make each accepted item

```sh
<skill>/piles.sh check
```

Make each item as [reshaping](../reference/reshaping.md) says, one commit
each. Each intent it needs goes through
[write-an-intent](write-an-intent.md) first. Look for check to exit 0
before each commit.

## Done when

- Only the items the person accepted were made, each in a commit of its
  own.
- No pile breaks a rule of [checks](../reference/checks.md) as a problem.
- Every intent written or rewritten was approved, and replaced what became
  untrue instead of adding beside it.
- No link's title names a file or a path.

## What to hand back

Each item, accepted or not, with its commit's id. Each question about code
the test raised, and each question the person left open.
