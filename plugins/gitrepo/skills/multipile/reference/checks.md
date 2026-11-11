# What must hold before a commit

Reference. Read it before every commit, and when a pile looks broken.
Needs: [piles](piles.md).
See next: [commit-a-change](../workflows/commit-a-change.md),
[declarations](declarations.md).

These are the rules every pile in a repository is held to. Check them over
the whole repository, not only the piles you changed: a broken pile you did
not touch is one to raise with whoever owns it, and not to commit past.

`<skill>/piles.sh check` checks the rules below for the config and the
intent, except those marked *by reading*. The script cannot check those:
check them yourself, by reading the files they name. Of the `.toml` rules it checks
two: each file's `version`, and that each `"@name"` in a `source` or
`target` line is in double quotes and names a pile. It exits 1 when it finds a problem
([reading](reading.md)). Check every other rule by reading.

Each rule has a severity:

- A **problem** stops the piles working. Do not commit while one is there.
- A **warning** is something to put right that breaks nothing yet.
- A **note** is something to know. It asks for nothing unless it
  surprises you.

## Problems: the config

- Every `.pile/config` reads: one `key = value` a line, comment lines
  starting with `#`, and only `kind`, `version`, `id` and `name`. Each is
  given once.
- `kind` is `gitpile` or `auxiliary-gitpile`, and `version` is `1`.
- `id` is 32 lowercase hex characters, and no two piles have one id. Two with one id
  are a copied subtree: mint a new id in the copy.
- `name`, when given, is a word ([declarations](declarations.md)). No two
  piles have one name. A name two piles claim names
  neither.
- `config` and `intent.md` are files, not symbolic links.
- A `.pile/config` inside another `.pile/` declares nothing: move it.
- A `.pile` is a directory. *By reading.*

## Problems: the intent

- Every pile has `.pile/intent.md`.
- It holds a headline: prose outside a comment. An intent that is empty,
  or only the comment the question was written in, says nothing.
- Every `<!--` is closed by a `-->`, or it hides the rest of the file.
- It is UTF-8 text. *By reading.*

## Problems: the `.toml` files

Each `.pile/*.toml` file is held to [declarations](declarations.md),
[links](links.md) and [types](types.md):

- The file is TOML that reads, and its first key is
  `version = "gitpile/1"`. Nothing in a file that does not is read.
- Each table's header is one [declarations](declarations.md) names. Each
  key is one its table takes, or a key of its own named by a word.
- Each type named exists ([types](types.md)).
- Nothing is written twice ([declarations](declarations.md)).
- Each node has a `type` other than `pile`, and a `name` that is a word.
- Each link has a `type` and gives at least one end. Each reference is in
  double quotes and names a node. Each end is of a node type its edge type
  allows, and no link joins a node to itself ([links](links.md)).
- Type tables are written only in an aux pile. A type's name is a word,
  never `pile`, and an edge type has `source` and `target`.

## Problems: the diagrams

Each `.pile/diagrams/<name>.diagram` file is held to
[diagrams](diagrams.md). *By reading.*

- It is KDL that reads, holding one `diagram` node that names its type and
  `version=1`, and it keeps every rule of its format and every limit of its
  type.
- Each pile a box names, by `@name` or by its `:/` path, is a pile. An id
  a box gives is that pile's id.

## Warnings

- A pile with no name. Give it one.
- An intent that opens with a heading. Remove it: the headline is first.

## Notes

- A file in a `.pile/` that is not the config, the intent, a `.toml` file
  or a diagram in `.pile/diagrams/`. It declares nothing.
- A config that is not committed. A clone would not have the pile yet.
- A `.pile/` with no config. It is not a pile: declare it, or remove it.
- Another repository inside a pile, which none of its piles reads.

## Checked is not approved

These rules ask only whether an intent says something, never what it
says. An intent that passes them is not one a person approved
([intent](intent.md)).
