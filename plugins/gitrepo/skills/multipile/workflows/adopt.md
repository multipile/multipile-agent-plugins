# Adopt piles

Workflow: bring piles to a project that declares none yet.
Needs: [boundaries](../reference/boundaries.md),
[intent](../reference/intent.md), [links](../reference/links.md),
[aux](../reference/aux.md).
See next: [write-an-intent](write-an-intent.md),
[commit-a-change](commit-a-change.md).

## When to use

A project that already exists, in a git repository, declares no pile, and
somebody has asked for it to be laid out in piles. You find the boundaries
the project already has, and the ones it would have after a few moves of
files. Where the layout of files hides a boundary, you propose two
layouts, and the person picks one. You change no file except for a move
they picked, each in a commit of its own.

Do not use it where piles are declared already. Use [refine](refine.md)
for those.

## What to have first

- The person who owns the project, to agree each boundary, each link and
  each intent. You stop twice to wait for them.
- The repository's own rules for a commit, in its AGENTS.md or wherever it
  keeps them.

## Steps

### 1. Make sure no pile is declared yet

```sh
<skill>/piles.sh list
```

Look for no line at all. If it names piles, stop: the project is laid out
already.

### 2. Find the boundaries the project already has

```sh
git ls-files
git log --stat -n 50
```

The evidence is in the project. Look for what moves together: a build file
such as `Cargo.toml` or `package.json`, a README of its own, and
directories the history changes together and apart. Look also for
directories that differ in kind: code, data, the schema for that data, and
documents each have a lifecycle of their own, with no build file at all.
A directory of test cases, the schema they follow, and the tool that
checks them are three candidates. Look also for a subject people call by
a name of its own, such as "the billing rules": documents proposed,
decided and superseded together are a candidate, even beside other
documents. Go down from the top. Skip each
directory that only groups others, and keep a candidate pile at each leaf.
Small and many is better than large and few. Hold each candidate to the
one-sentence test, which only splits
([boundaries](../reference/boundaries.md)).

Judge each lifecycle by what a part does, not by how its build files are
laid out today. A build file shared by parts that do different things is a
build file to copy, and a move to propose in step 4, not a reason to keep
the parts as one candidate.

With one commit or none, say that there is no history to read. History is
only a sign.

### 3. Draft the links, and test each boundary

```sh
git grep -n -F '<dir>/' -- ':!<dir>'
```

Run it for each candidate. Follow "What another pile relies on" in
[boundaries](../reference/boundaries.md), in its order, for one pass, and
hold a part to the sentence you propose, since no intent exists yet. For
each pair where one pile relies on another, draft the link's title and a
description ([links](../reference/links.md)).

Draft no link from what a pile is judged by, and none between siblings
meant to be independent: "What another pile relies on" says how to tell.
Look for a title and a description for every such pair, and none that
names a file or a path. A title that still has to name a part means a
candidate is wrong: split it, or keep the part and name it in the draft
sentence. A change to code that the test raises is a question for the
person, not a candidate.

### 4. List what other piles rely on outside them

```sh
git ls-files -- ':(exclude)<dir>' ':(exclude)<dir>' …
```

Exclude every candidate pile. What is left is what the top pile and each
container would hold. Follow "A container's own files" in
[boundaries](../reference/boundaries.md).

Look for each file there that another pile relies on, and each build file
shared by candidates with separate lifecycles. Each one is a move, shown
as "A container's own files" says, with its cost. Note which moves change
a boundary: a candidate that only exists after the move, or a link that
only the move makes name a whole pile.

### 5. Propose, and wait

When no move changes a boundary, propose one layout. Otherwise propose two,
side by side: **as it stands**, the piles the files hold today, and **after
the moves**, the piles once the moves are made, with each move and its
cost. The person picks one, and the rest of this step is about it. A move
that changes no boundary is listed under either, for the person to accept
or reject.

Propose one numbered list, in this order:

1. each move picked, as step 4 showed it;
2. the top pile, with the sentence it would claim;
3. each pile: its directory, its name, and the sentence it would claim;
4. an aux pile that holds the edge type `relies-on`, in a directory that
   does not exist yet: `:/piles` named `piles`, unless that is taken. The
   person may change the directory and the name;
5. each link, as `@source relies on @target: <title>`, with its description;
6. each question about code the test raised, such as coupling between
   piles meant to be independent.

The person accepts or rejects each item. If they reject an item that
other items assume, draft those items again against what they accepted,
and propose them again. If they reject the aux pile, no link is written:
hand the drafted titles and descriptions back as text.

Stop, and wait until they agree. With nobody to answer, stop here and
commit nothing.

### 6. Make each accepted move

```sh
git mv <old path> <new path>
git grep -n -F '<old path>'
```

Make each move as "Move files between piles" in
[reshaping](../reference/reshaping.md) says, one commit each, before any
pile is declared. Run the project's own build and tests before each
commit. With no move accepted, skip this step.

### 7. Declare each agreed pile, the top first

```sh
mkdir -p <dir>/.pile
printf 'kind = gitpile\nversion = 1\nid = %s\nname = %s\n' \
  "$(<skill>/piles.sh id)" <name> > <dir>/.pile/config
```

Then the aux pile, with the same command and `kind = auxiliary-gitpile`.
Its `.pile/types.toml` holds the edge type every link here is of:

```toml
version = "gitpile/1"

[[edge-types]]
name = "relies-on"
title = "one pile relies on what another is for"
source = ["pile"]
target = ["pile"]
do = "say what the source relies on, in words of the target's intent"
dont = "name a file or a path"
```

Look for a distinct id and a distinct name in each config, and a pile at
the top of the repository, beside `.git`, first. Give each pile an intent
that is the question in a comment, until it is answered:
`<!-- Why does this pile exist? -->`.

### 8. Draft each intent, and hand the drafts back

```sh
<skill>/piles.sh show <pile>
```

Write a draft in each `.pile/intent.md` ([intent](../reference/intent.md)),
and read each headline alone. Name in it each part another pile relies
on. The aux pile's intent says what words it gives the repository: how its
piles say what they rely on of each other. Hand the drafts back, saying
which sentences you are sure of and which you guessed. Stop, and wait
until the person approves them.

### 9. Write the links

```sh
$EDITOR <source>/.pile/links.toml
```

Write each accepted link at its source, naming its target. The file
starts with its version ([declarations](../reference/declarations.md)):

```toml
version = "gitpile/1"

[[edges]]
type = "relies-on"
target = "@<target>"
title = "<what the source relies on>"
description = """
<what it relies on, in words of the target's intent>
"""
```

Look for no title or description that names a file or a path.

### 10. Tell the next session about the piles

```sh
$EDITOR <rules file>
```

Write a `## Piles` section into each of the project's rules files. A
rules file is a file the project's agents read at the start of every
session, and which one depends on the agent:

- `AGENTS.md`, which most agents read, Codex among them;
- `CLAUDE.md` for Claude Code, and `GEMINI.md` for Gemini CLI;
- `.github/copilot-instructions.md` for GitHub Copilot;
- a rule in `.cursor/rules/` for Cursor, with `alwaysApply: true`.

The project's rules files are each of these it already keeps, and the
one the agent you are reads. A file that only points to another, such as
a `CLAUDE.md` that holds `@AGENTS.md`, is not one: the file it points to
is. Put the section near the start of each, where an agent reads it
before much else: at the top if the person agrees, and always in the
first 100 lines. If a rules file has a `## Piles` section already, leave
it. Write this section. Its heading is undated on purpose: the multipile
command line, once installed, replaces an undated section with its own,
whose heading carries the date its text last changed.

```markdown
## Piles

This repository uses piles to organize itself, with their metadata in
`.pile/` directories. Each pile's `.pile/intent.md` says why it is one
thing.
- Read a pile's intent before you change the pile, and keep it true in
  the same commit.
- Learn more at https://multipile.dev.
```

### 11. Check, and make one commit

```sh
<skill>/piles.sh check
<skill>/piles.sh status
```

Look for every pile the person agreed to, and for check to exit 0
([checks](../reference/checks.md)). Check also finds a link that names no
pile. Status should show only the `.pile/` directories and the rules
files as changed. Commit them with git, in one commit, as the repository's
rules say.

## Done when

- Every pile declared is one the person agreed to, and every intent is one
  they approved.
- Every link's title and description names a whole pile, or a part its
  intent claims, and never a file or a path.
- A pile sits at the top of the repository, and its own files are only
  ones about the whole repository, or ones you list as a move.
- No existing file was changed, except by a move the person accepted, in
  a commit of its own.
- No pile breaks a rule of [checks](../reference/checks.md) as a problem.
- Each rules file holds the `## Piles` section in its first 100 lines.
- One commit holds every `.pile/` directory and the rules files, after
  the commits of the moves.

## What to hand back

The piles, each with its name, its path and its headline. The links, each
with its title. The layout the person picked, each move made with its
commit's id, and each move not made, for [refine](refine.md). Each
question about code the test raised. The sentences you guessed at, and
any boundary the person left undecided. If the person rejected the aux
pile, the drafted titles and descriptions. The commit's id.
