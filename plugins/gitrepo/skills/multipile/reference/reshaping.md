# Changing where a pile's boundary is

Reference. Read it before you change where a pile's boundary is.
Needs: [boundaries](boundaries.md), [links](links.md).
See next: [refine](../workflows/refine.md), [checks](checks.md).

[boundaries](boundaries.md) says where a boundary goes. This page says how
to move one: declare, move, unmake, split, merge and rename a pile, and
move files from one pile to another. Each is made of the first three.

## One change at a time

Every operation is proposed as a numbered item, and the person who owns
the repository accepts or rejects each one. An intent the operation needs
goes through [write-an-intent](../workflows/write-an-intent.md) and is
approved before its commit, because an intent that is only a comment
fails check. Make the accepted items one per commit, with
`<skill>/piles.sh check` exiting 0 before each. Then `git revert` undoes
the last one cleanly, and an earlier one if nothing later builds on it.
With nobody to answer, make nothing.

## Find the references to a pile

```sh
git grep -n -F -e '"@<name>"' -e '"<type>:<node>"' -- ':(top,glob)**/.pile/*.toml'
git grep -n -w -F '@<name>'
```

The first finds the links that name the pile, with one `-e` for each
`[[nodes]]` table in its `.pile/`. The second finds the prose that names
it, such as another pile's intent. Run them before you rename a pile, or
remove a pile or a node. Check then reports each link left naming no
pile, but not a link to a node that is gone, and not the prose.

## Declare a pile

Propose a boundary to whoever owns the repository before you declare it.
Then write its two files:

```sh
mkdir -p packages/lib/.pile
cat > packages/lib/.pile/config <<EOF
kind = gitpile
version = 1
id = $(<skill>/piles.sh id)
name = lib
EOF
```

Then write `packages/lib/.pile/intent.md` ([intent](intent.md)). Until a
person has said what the pile is for, write the question in a comment,
`<!-- Why does this pile exist? -->`, so that nobody mistakes it for an
answer. Commit both files together.

Declaring a pile moves no file. Inside another pile, the new pile is that
pile's child, and its paths leave the parent. Check that the name is not
one another pile already has.

## Move a pile

Move a pile with `git mv` of its directory. Its id and name go with it,
so every reference to it still holds. Never copy a `.pile/` to make a new
pile: two piles with one id are both broken. Mint a new id for the copy.

## Unmake a pile

A pile is unmade by hand, and never on your call alone. The top pile is
never moved or unmade.

1. Find the references to the pile and its nodes.
2. Read what its `.pile/` holds. An unread file may be there. Every table
   there goes with the pile. In an aux pile its types go too, so every
   node and link of those types stops being read.
3. For each table, the person chooses: remove it, or move it to another
   pile, usually the parent, as [links](links.md) says a link is moved.
4. For each link elsewhere that names the pile, the person chooses:
   remove it, or point it at another pile.
5. Remove the directory: `git rm -r packages/lib/.pile`.

The pile's paths are its parent's again. Its id is gone for good: declared
again, the directory is a new pile with a new id.

## Split a pile

1. A part that is a set of files, not one directory, is first moved into
   a directory of its own, as an item of its own.
2. Find the references to the parent.
3. Declare the child, with a new id.
4. Move into the child's `.pile/` each `[[edges]]` and `[[nodes]]` table
   about what the child is for, as [links](links.md) says a link is
   moved.
5. Read each `"@parent"` reference's title, or its description and type
   when it has no title. Where it is about what the child is for, point it
   at `"@child"` instead.
6. Rewrite the parent's intent: replace what became untrue, and add
   nothing beside it.
7. Draft the child's intent.

Both intents are approved before the commit.

## Merge two piles

The person picks the id and name that survive. Find the references to the
other pile. When the two are siblings, first `git mv` the other's files
into the survivor, as a move of files. Move every `[[nodes]]` and
`[[edges]]` table in the other's `.pile/` into the survivor's. Here an end
left out should come to mean the survivor, so it stays left out. Merge its
`[pile]` values into the survivor's, with each key written once. Then
unmake the other pile, and point every reference to it at the survivor.
Remove any link from the survivor to itself, and any edge now written
twice ([links](links.md)). Rewrite the survivor's intent.

## Rename a pile

Find the references to the old name first, in links and in prose. Change
`name` in the pile's config, and rewrite every `"@old"` and every `@old`
in the same commit.

## Move files between piles

What to propose is in "A container's own files" in
[boundaries](boundaries.md). To make the move:

```sh
git mv <old path> <new path>
git grep -n -F '<old path>'
```

Rewrite every reference the proposal listed, then search again: the
search must find nothing. Run check, and commit.
