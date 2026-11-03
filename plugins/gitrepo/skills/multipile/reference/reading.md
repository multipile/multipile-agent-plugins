# Reading a repository by pile

Reference. Read it before you read a repository that declares piles.
Needs: [piles](piles.md).
See next: [start-a-change](../workflows/start-a-change.md),
[read-a-change](../workflows/read-a-change.md), [links](links.md).

Git reads a repository by directory. Read by pile, it is a set of parts,
each with an intent that says what it is for. Every answer here comes from
the files and from git, so a person can get it with git alone.
`<skill>/piles.sh` gets each one in a command. `<skill>` is the directory
this skill is in. It needs `sh` and `git`, and writes nothing.

```sh
<skill>/piles.sh list                 # every pile: its name and its path
<skill>/piles.sh which <path>...      # the pile each path is in
<skill>/piles.sh show <pile>          # config, parent, children, intent
<skill>/piles.sh files <pile>         # the pile's own files
<skill>/piles.sh log <pile> [args]    # the commits that changed them
<skill>/piles.sh status               # what changed, by pile
<skill>/piles.sh check                # every pile, held to checks.md
<skill>/piles.sh id                   # a new id, for a new pile's config
```

A pile is given as `@name`, or as its path from the top of the repository.
A path is given from the top too, with or without `:/`.

## Start wide, then narrow

List the piles first. It is the cheapest way to see what the repository
declares: every `.pile/config` that git tracks or would track.

```sh
git ls-files -co --exclude-standard -- ':(top,glob)**/.pile/config'
```

Then find the pile a file is in: the nearest directory at or above it
that has a `.pile/config`. The path alone does not show it, because piles
nest. A file that does not exist yet is answered the same way. Then read
that pile: its config, its intent, and the `.toml` files in its `.pile/`.
Read the intent before you change the pile.

## Read a pile's own files, and its own history

`git ls-files <dir>` lists the files of every pile under the directory
too. A pile's own files leave out each pile it holds:

```sh
git ls-files -- packages/lib ':(exclude)packages/lib/vendor'
git log -- packages/lib ':(exclude)packages/lib/vendor'
```

`piles.sh files` and `piles.sh log` write those exclusions for you. Size
the files before you read them all: `wc -l` over the list says what
reading the pile will cost. The authors in the pile's own history are who
to ask about it.

## Follow a pile's links

A change at one end of a link may be owed at the other. A pile's links
are in three places ([links](links.md)): its own `.pile/`, links
elsewhere that name it, and links elsewhere that name a node at home in
it. Find all three, here for the pile `@lib` at `:/packages/lib`:

```sh
cat packages/lib/.pile/*.toml
git grep -n -F -e '"@lib"' -e '"<type>:<node>"' -- ':(top,glob)**/.pile/*.toml'
```

Give the second one `-e` for each `[[nodes]]` table the first shows. When
the other end is a pile, read it too before you change what the link says
one end relies on.

## Read what changed, by pile

`git status` and `git diff` list paths. Hold each path to the pile it is
in, and read status for the whole repository even when you changed one
pile: a change that crossed a boundary shows in both. A path moved from
one pile to another is in both piles' change. `git diff` is still how you
read the lines that changed.

## Without a shell

Where nothing can be run, read the files. Every `.pile/` directory that
holds a `config` is a pile. Each path is in the nearest one at or above
it. The config declares the pile. The intent, `.pile/intent.md`, says why
it exists. The `.toml` files in `.pile/` declare its nodes, links and
values. Nothing else declares anything.
