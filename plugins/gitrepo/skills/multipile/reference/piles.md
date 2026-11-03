# What a pile is

Reference. Read it first, whole, before any other page.
See next: [intent](intent.md), [boundaries](boundaries.md),
[reading](reading.md), [declarations](declarations.md).

A pile is a subtree of a git repository that has a `.pile/` directory, and
says why it is one thing. Piles are the parts a repository is talked about
in. Whoever arrives next, a person or an agent, reads a pile before they
change it.

## A `.pile/` directory declares a pile

A pile's `.pile/` directory holds two files:

- `config`, the pile's config. Its being there declares the pile. Nothing
  else lists the piles.
- `intent.md`, the pile's intent: why the subtree is a pile
  ([intent](intent.md)).

A pile may add `.toml` files, which declare nodes, types, links and the
pile's own values ([declarations](declarations.md)). Any other file in a
`.pile/`, such as `notes.md`, is an unread file. It declares nothing, and
it is allowed.

## The config says which pile it is

```
kind = gitpile
version = 1
id = 9f8e7d6c5b4a39281706f5e4d3c2b1a0
name = lib
```

A config is one `key = value` a line, and `#` starts a comment. It holds
these four keys, and no other:

- `kind` says which format the pile is written in: `gitpile`, or
  `auxiliary-gitpile` for an aux pile ([aux](aux.md)). `version` is `1`.
- `id` is 32 lowercase hex characters, minted once when the pile is
  declared, and never changed. It says a pile is the same pile after a
  move. Nobody types it. Mint one with `<skill>/piles.sh id`, or with
  `od -An -tx1 -N16 /dev/urandom | tr -d ' \n'`.
- `name` is the word the pile is referred to by, chosen by a person:
  `lib`, written `@lib` in a reference. It is a word: lowercase letters,
  digits and hyphens, starting with a letter
  ([declarations](declarations.md)).
  No two piles share a name, and no two share an id.

A pile without a name can only be referred to by its path, and no link
can name it. So give every pile a name. Renaming a pile breaks every
reference to the old name, and each one has to be rewritten.

A config is committed like any other file. Git is what carries a pile to
a clone, so a pile nobody committed is a pile only in your working copy.

## A path is in the nearest pile at or above it

Piles nest. A path is in the nearest pile at or above it, and in no other.

- Every repository has a pile at its top, beside `.git`. So every path is
  in a pile. A path in no pile means the top pile is missing: say so.
- A pile's parent is the nearest pile above it. Its children are the piles
  whose parent it is, and it holds them.
- A pile's own files are its directory, less every pile it holds.
- Declaring a pile inside another moves no file. The paths under the new
  pile are in it from then on, and no longer in its parent.

A file that does not exist yet is in a pile too: the one it would be in.

## Write each pile and path explicitly

When you write about a pile, or to a person about one, name it so that it
can be read only one way:

- `@lib` is the pile named `lib`. A reference in a file always uses it.
- `:/packages/lib` is a path from the top of the repository, as git writes
  one, and `:/` is the top. It means the same from any directory.
- `packages/lib`, with no prefix, is a path from the directory you are in.
  `piles.sh` is the exception: it reads every path from the top, with or
  without `:/` ([reading](reading.md)).

Never guess which pile a word meant. If a name or a path names no pile,
say so.

## Git keeps everything else

Piles are a way to read a repository, and not a way to store it. Git
keeps the versions, the content and the history. A pile inside another is
in the same repository, with the same commits and branches. So a boundary
between piles changes what a reader is told, and nothing in storage.
