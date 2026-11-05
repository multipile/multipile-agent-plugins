# Where a pile's boundary goes

Reference. Read it when you decide whether a subtree is one pile, or
whether a boundary still holds.
Needs: [piles](piles.md), [intent](intent.md), [links](links.md).
See next: [adopt](../workflows/adopt.md), [refine](../workflows/refine.md),
[reshaping](reshaping.md), [reading](reading.md).

A pile is worth declaring when its intent serves whoever arrives at it. So
whether a subtree is a pile is decided by the sentence that says what it is
for, not by its size, and not by how its directories are laid out.

## A pile's shape outlasts its files

A pile's files change often. Its boundary, its intent and its links to
other piles should change rarely. An intent leaves out paths because they
go stale, and a link's title that names a file goes stale the same way. So
a stable layout has few dependencies between piles, and each is to a whole
pile, or to a part its intent claims, as a link's title says it
([links](links.md)).

Stability is a goal for the layout. It is not a reason to keep a boundary
that has stopped being true. Changing a boundary to make the layout more
stable is what [refine](../workflows/refine.md) is for, and
[reshaping](reshaping.md) says how.

## A pile has a lifecycle of its own

A pile is for something with its own lifecycle: something designed, built,
tested, reviewed, released, run or read on its own. It need not be all of
those. A log of decisions is read and reviewed, and never built. A design
is drafted, decided and superseded. Each of those is a lifecycle of its
own.

Two parts share a lifecycle when they are built and released as one unit,
like the modules of a library. Code, data, the schema for that data, and
documents are different kinds of thing. A schema, a folder of data and a
set of documents are never built, so they share no lifecycle with each
other or with a tool that reads them, even when none of them has a build
file.

Judge a lifecycle by what a part does: what it builds, runs or drives,
who runs it, and why it changes. Do not judge it by how the build files
are laid out today. One build file shared by two parts is a sign, not
proof: shared for convenience by parts that do different things, it is a
build file to copy ("A container's own files"), and the parts are two
piles. Changing in the same commits is not sharing a lifecycle either:
that is history, and history is only a sign.

Three rules below turn on whether two parts share a lifecycle: whether a
part another pile relies on stays or is split out, whether a part reached
past a pile's entry point is exposed or split, and whether a container's
shared build file is copied or kept once.

Some directories rarely have a reason of their own to give:

- tooling configuration, scratch directories, `scripts/` and `assets/`
  usually serve the pile around them;
- a generated or vendored directory has the reason of whatever produced it
  or pulled it in.

Declare one anyway when it has a claim of its own ("A good pile is a
leaf").

## A good pile is a leaf

Look for the leaves of the project: the directories that are something,
like a package, a service, a tool or a body of documents. A directory that
only holds others, such as `packages/`, `apps/` or `libs/`, is there for
tidiness. Its sentence would be a list of its children. Don't make it a
pile. Its children are the piles, and its own few files belong to the
pile above it.

Go down through containers until you reach a directory with a claim of its
own. Inside a leaf, go deeper where a subdirectory has a claim of its own.

A subdirectory has a claim of its own when somebody arrives at it with a
question of its own. That is the question its intent's closing pair would
name: "Read this pile to find out …" ([intent](intent.md)). If you can
write that sentence for the subdirectory, and it would be untrue of the
leaf around it, the subdirectory is a pile, even when it serves the
leaf.

Three cases show such a question:

- The project builds or runs it on its own: it has its own build file,
  such as `package.json` or `Cargo.toml`, that a task, a CI step or a
  workspace builds, or a task that runs only it.
- It is a different kind of thing from its siblings: code, data, the
  schema for that data, or documents. Each kind has a lifecycle of its
  own, though none of them is built ("A pile has a lifecycle of its
  own"). A directory of test cases, the schema they follow, and the tool
  that checks them are three piles.
- People call it by a name of its own. A subject talked about as one
  thing, such as "the malleability design" or "the billing rules", whose
  files are proposed, decided and superseded together, is a leaf, even
  when its siblings are the same kind of thing. A design's drafted,
  decided, superseded cycle is a lifecycle of its own. Hold the name to
  the name test ([piles](piles.md)).

None of these is one: test fixtures and sample inputs that only the
leaf's own tests read, even with a build file; documents about how the
leaf is built inside; and `src/` and `tests/`. Nobody builds, runs or
reads them apart from the leaf, and nobody arrives at them with a
question the leaf's intent does not answer. A body of documents with a
subject of its own is not about how the leaf is built inside, even when
it sits inside the leaf: it is the third case.

## The test is one sentence

If one sentence cannot say what the subtree is for without turning into a
list, it is two piles, or one pile with its boundary in the wrong place. A
headline that needs "and" twice is the sign.

The test only splits. It never keeps two parts together. A sentence broad
enough to cover two kinds of thing, such as "the behavioral contract" over
a set of cases and the schema they follow, is a topic, not a claim
([intent](intent.md)). It is a reason to look closer, not to merge.

Many small piles are better than a few large ones. A small pile with a
sharp intent tells its reader more than a large one whose intent has to
stay vague to cover everything. Don't merge two piles only because each
is small.

## What another pile relies on

A pile relies on what another pile is for. That is a concept, not a file.
Code, build files and prose are the evidence of it:

- a path named in code or data outside a directory, and its relative
  forms, such as `../schema/`:
  `git grep -n -F '<dir>/' -- ':!<dir>'`;
- an import, a runtime read, or a path dependency in a build file;
- prose in a README, or in a link, that names a path inside another pile;
- a child pile that reads its parent's own files. That is relying on
  another pile too.

The top pile, CI files, and task runners such as `mise.toml` or a
`Makefile` are not dependents: they name nearly every directory. And
`git grep` misses code that searches for a path or takes it from a
variable, so read the code that loads files, not only the strings.

Evidence shows what a pile relies on, not what it should rely on, nor
what it is. Before you draft a link, rule out two kinds of evidence:

- **What a pile is judged by.** A link records what a pile uses. Prose
  that calls another pile "the contract" or "the spec", with no code that
  reads it, describes a process. When another pile enforces the contract,
  such as a runner that checks an implementation against a set of cases,
  the links go from that runner: to the cases, and to what it drives.
- **Coupling between piles meant to be independent.** Before you draft a
  link between siblings, ask whether they are meant to stand apart, such
  as alternative implementations of one contract. If they are, the
  evidence, even a comment like "ported from" or "mirrors" that names a
  path in the other, is coupling to remove. Hand it back as a question
  about code, not as a link.

Code that reaches a pile by its public name, such as a package name, its
entry point or its exports, or by its root, relies on the whole pile. Code
that needs a path below the root relies on a part.

### The test is the link's title

For each pile `@X` that relies on another, `@Y`, draft the title of the
link ([links](links.md)). Then ask, from `@X`'s side: if everything in
`@Y` changed except what this title names, would `@X` have to change? If
it would, `@X` relies on `@Y` as a whole, and the title names `@Y`. If
not, the title names a part of `@Y`, and the table decides. Read its rows
in order. The first that matches decides.

| The part | Then |
|---|---|
| is named in `@Y`'s intent, shares `@Y`'s lifecycle, and is reached through `@Y`'s entry point | keep the boundary; the title may name the part |
| is claimed by `@Y`'s intent and shares its lifecycle, but is not named, or is reached past the entry point | expose it: name it in `@Y`'s intent; publishing it in code is a question for the person |
| has a sentence of its own, or no lifecycle shared with `@Y` | split it out |
| is an internal detail nothing claims | ask the person whether `@X` should stop relying on it |

A part is claimed when a sentence of the intent covers it, and named when
the intent's paragraphs on what belongs mention it in words
([intent](intent.md)). The entry point is what `@Y` publishes: its
package name, its exports, or `lib.rs`. A change to code is never a
boundary to propose: hand it back as a question.

When you lay a project out, no intent exists yet. Hold the part to the
sentence you propose for `@Y` instead, with two outcomes. A part with a
sentence or a lifecycle of its own is split out. Any other part stays,
and the draft intent names it.

### In this order

1. Look first for the three cases "A good pile is a leaf" lists: a build
   file or a task, a kind of thing, and a name people use.
2. Hold what is left in each parent to the one-sentence test.
3. Draft the link titles between the piles you would propose.
4. For each title that names a part, read the table.
5. After a split, test again only the parent it left behind.

Make one pass, then propose to the person. Going again until nothing
changes risks a chain of splits nobody asked for. When two piles rely on
each other, or the repository has no history to read, say so, and put the
boundary to the person as a question.

The `src/` and `tests/` rule wins over a title that names a part. A parent
left holding only child piles and its own files is a container: it is not
declared, and its own files are held to "A container's own files". Any
other split that would leave the parent with no true sentence is not
proposed.

## Piles cover the repository

Every repository has a pile at its top, beside `.git`, so every file git
tracks is in a pile. The top pile holds what is about the whole
repository, and is where a container's own files land. Read the top
pile's own files with `<skill>/piles.sh files :/`. If any of them would have
a sentence of its own, it is a leaf nobody declared yet.

## A container's own files

Before a container's own file goes to the top pile, hold it to the
one-sentence test:

- Prose another pile relies on belongs in the pile whose intent claims
  it. Suggest moving it there, and leaving a short description of the
  folder behind.
- A build file in a container, shared by piles with separate lifecycles,
  is copied into each of them, so the container is not a pile. Shared by
  piles with one lifecycle, it is kept once, in a pile of its own or in the
  pile that holds them both.
- A build file at the top of the repository, such as a workspace lockfile
  or a base `tsconfig`, is about the whole repository, and stays in the
  top pile.

Suggest a move only for a file in a container or in the top pile that
another pile relies on, or a file whose content belongs to another pile's
intent. Show the layout before and after as two short trees, the link's
title before and after, every reference the move rewrites
(`git grep -n -F '<old path>'`), and for a copy, what it costs: two
lockfiles, two installs, and versions that can drift. A move is a change
of its own. Declaring a pile moves no file.

## Signs that a boundary has stopped being true

- The intent needs "and" twice to cover what is under it now.
- Two piles always change together in their history, and never apart.
  They may be one thing. This is a sign and not a verdict: two leaves
  with two true sentences stay two piles.
- Nobody arrives with the question the closing pair names.
- A link's title has to name a part of the pile at its other end
  ([What another pile relies on](#what-another-pile-relies-on)).
- Commits that change one pile keep having to rewrite another pile's
  intent or link titles. A stable layout has few.

## Report a boundary, don't move it

During an ordinary change, a boundary you find untrue is reported in a
boundary note in what you hand back, and never moved. Moving it is for
[refine](../workflows/refine.md), with the person's agreement.

Write a note when one of these holds, and for nothing else:

1. The change adds a path that points below another pile's root. Look in
   the lines it adds (`git diff HEAD -U0`, and any new file) with
   `grep -F '<the other pile's path>/'`.
2. A link's title or description would have to name a path inside another
   pile.
3. No sentence of the intent covers the change.
4. A directory the change touched has its own build file, or a task that
   runs only it, but is not a pile.

Only what you saw in files the change touched counts. Write at most one
note per pile in a hand-back, never write one into a `.pile/` file, and
write none when the task is itself a refine.

ALWAYS use this exact template:

```markdown
**Boundary note** — no boundary was changed; a person decides.

| | |
|---|---|
| **Piles** | `@<name>` `:/<path>`, `@<other>` `:/<path>` |
| **Sign** | <one of the four above> |
| **Evidence** | `<path:line>`, link or commit ids. Re-run: `<git command>` |
| **Intent strained** | "<quoted sentence>", or none, and why |
| **Would suggest** | split / merge / move / unmake / rename / declare → <names, paths, one-line draft intent> (sure / guess); or a question about code |
| **Cost** | <piles declared, ids minted or retired, files moved, references rewritten>, or none |
| **Decision** | <one yes/no question> |
| **Next** | run refine on `@<name>`, or none |
```

Fill it this way:

- Every row, in this order. Write "none" in a row that has nothing.
- One line per cell. Separate items with `;`, and put commands in inline
  backticks: a code block does not fit in a cell.
- Write a `|` inside a cell as `\|`.
- The note is complete on its own, because a hand-back is not carried
  into the next session.

For example, after a task "let a customer download every invoice as a
CSV file" that edited `services/billing/src/invoices.ts` and
`services/billing/export/csv.ts`:

**Boundary note** — no boundary was changed; a person decides.

| | |
|---|---|
| **Piles** | `@billing` `:/services/billing` |
| **Sign** | a directory the change touched has its own build file, but is not a pile |
| **Evidence** | `services/billing/export/package.json`, a workspace member in `package.json`. Re-run: `git ls-files services/billing/export` |
| **Intent strained** | "Charges each customer once a month and records it in `@ledger`." Writing export files is not that. |
| **Would suggest** | split → `@export` `:/services/billing/export`: "Turns an invoice into a file a customer can download." (guess) |
| **Cost** | one pile declared; one id minted; no links to rewrite |
| **Decision** | Should `:/services/billing/export` be its own pile? |
| **Next** | run refine on `@billing` |
