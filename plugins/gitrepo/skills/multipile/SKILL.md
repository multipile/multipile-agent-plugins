---
name: multipile
description: How to work in a git repository that declares piles, subtrees with a `.pile/` directory whose `intent.md` says why each is one thing. Says what a pile is, how to read a repository pile by pile, how to scope, read and commit a change, where a boundary goes, how to write an intent and keep it true, and how to write the `.toml` declarations, links, types and aux piles in a `.pile/`. Use it whenever a repository holds a `.pile/` directory, or the user, an AGENTS.md or a task names piles, an intent, a `.pile/` file or multipile, and before you lay a project out in piles or refine the piles it declares.
---

# Working in a repository of piles

A pile is a subtree of a git repository that has a `.pile/` directory, and
says in its intent, `.pile/intent.md`, why it is one thing. Piles are the
parts a repository is talked about in. Whoever arrives next, a person or an
agent, reads a pile before they change it, and keeps its intent true.

This file is the map. Each fact has one page as its home, and this file
only points to it.

## How the skill is laid out

- `reference/` says what something is. Read a page when it applies.
- `workflows/` each accomplish one thing: when to use it, what to have
  first, the steps with the commands to run and what to look for, when it
  is done, and what to hand back. Carry one out from the top, in order,
  and never from memory.
- Under its title, each page names the pages it **needs**, which you read
  with it, and the pages to **see next**, which you may want after it.
- `piles.sh` reads a repository by pile with `sh` and `git` alone, and
  writes nothing. A page writes it as `<skill>/piles.sh`, where `<skill>`
  is the directory this file is in. Where nothing can be run, every page
  still says how to get the same answer by reading the files.

## Start here

Read these two whole, before anything else:

- [What a pile is](reference/piles.md): the `.pile/` directory, the
  config, the id and the name, and how piles nest.
- [Reading a repository by pile](reference/reading.md): which pile a path
  is in, a pile's own files and history, its links, and `piles.sh`.

## Pick the workflow for what you are about to do

| You are about to | Carry out |
|---|---|
| write in a repository that declares piles | [start-a-change](workflows/start-a-change.md) |
| commit, in such a repository | [commit-a-change](workflows/commit-a-change.md) |
| review or hand on somebody's change | [read-a-change](workflows/read-a-change.md) |
| write an intent, or fix one that is untrue | [write-an-intent](workflows/write-an-intent.md) |
| lay a project with no piles out in piles | [adopt](workflows/adopt.md) |
| improve the piles a repository already declares | [refine](workflows/refine.md) |

## What holds in every piece of work

Each rule is said whole on the page it links.

- **Read a pile before you change it.** Find the pile each path is in,
  and read its intent before you write there.
  [start-a-change](workflows/start-a-change.md)
- **Name each pile and path explicitly.** `@lib` is a pile's name, and
  `:/packages/lib` a path from the top of the repository. Never guess which
  pile a word meant. [piles](reference/piles.md)
- **An intent is a claim, not a topic.** Its headline lets a stranger say
  whether a new file belongs. Its closing pair names the question somebody
  arrives with, and an event that changes the pile. A path, a file name or
  a count goes stale, so it stays out. [intent](reference/intent.md)
- **One sentence decides a boundary.** Build files, kinds of thing (code,
  data, a schema, documents), a name people call a subject by, history,
  and what other piles read show where to look. A subdirectory somebody
  arrives at with a question of its own is a pile. Size and layout do not. A headline that needs "and"
  twice is two piles, or a boundary in the wrong place. The test only
  splits: a sentence that covers two kinds is a reason to look closer.
  [boundaries](reference/boundaries.md)
- **Piles are leaves, and they cover the repository.** Declare the
  directories that are something, not the ones that group them. Small and
  many is better than large and few. A pile sits at the top, beside
  `.git`, so every file is in a pile. [boundaries](reference/boundaries.md)
- **A pile's shape outlasts its files.** Files inside a pile change often,
  and its boundary, its intent and its links should not need to. So a link
  names a whole pile or node, never a file ([links](reference/links.md)). When a
  change keeps making another pile's intent or links untrue, the boundary
  is in the wrong place. [boundaries](reference/boundaries.md)
- **You draft, and a person decides.** Each boundary and each intent is
  proposed, and approved before it is committed. A plausible intent that
  nobody approved is worse than none. A boundary you find untrue during a
  change is reported in a boundary note, and not moved
  ([boundaries](reference/boundaries.md)).
  [write-an-intent](workflows/write-an-intent.md)
- **Keep the intent true in the same commit.** When a change makes it
  untrue, replace the sentence that became untrue, and do not add one
  beside it. The same holds for a link's title. [intent](reference/intent.md)
- **A change may be owed at the other end of a link.** Read the pile there
  before you change what the link says one end relies on.
  [links](reference/links.md)
- **No problem is committed past.** Every pile is checked, not only the
  ones you changed, and git makes the commit.
  [checks](reference/checks.md)

## Reference pages

- [piles](reference/piles.md): what a pile is: its `.pile/` directory,
  config, id and name, and nesting
- [reading](reference/reading.md): how to read a repository by pile, and
  what `piles.sh` answers
- [intent](reference/intent.md): what an intent says, the shape it takes,
  and how it is kept true
- [boundaries](reference/boundaries.md): whether a subtree is one pile,
  and what other piles rely on of it
- [reshaping](reference/reshaping.md): declaring, splitting, merging,
  renaming, moving and unmaking a pile, and moving files between piles
- [checks](reference/checks.md): what must hold of every pile before a
  commit, and how bad each break is
- [declarations](reference/declarations.md): the `.toml` files in a
  `.pile/`, and what each `[[nodes]]`, `[[edges]]`, `[pile]` and type
  table declares
- [links](reference/links.md): what a link is, where it is written, and
  how it names its ends
- [types](reference/types.md): node types and edge types, and when a type
  exists
- [aux](reference/aux.md): what an aux pile is, how to make one, and
  what it may declare
