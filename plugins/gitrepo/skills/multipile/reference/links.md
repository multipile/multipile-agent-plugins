# Links between piles

Reference. Read it before you write a link, or change a pile at either end
of one.
Needs: [declarations](declarations.md).
See next: [types](types.md), [intent](intent.md).

A link says what one node is to another. Most often one end is a pile,
and the other is a pile it calls, a pile that runs it, or something
outside the repository it relies on. A link is an `[[edges]]` table, and
it declares one edge: from a source node, of one edge type, to a target
node. A change at one end of an edge may be owed at the other, so read a
pile's links before you change the pile.

## A link says its type and its ends

```toml
# services/billing/.pile/links.toml
version = "gitpile/1"

[[edges]]
type = "uses"
target = "@ledger"
title = "records every charge in"
description = """
Every charge is written through the ledger's API, so billing never writes
to the database itself.
"""

[[edges]]
type = "uses"
target = "external:postgres"
title = "keeps its invoices in"

[[edges]]
type = "runs"
source = "external:cron"
title = "starts each monthly run"
```

- `type` is the edge type, by its name ([types](types.md)). It is
  required. Every link is of an edge type an aux pile creates.
- `source` and `target` each name a node, by a reference. A link gives at
  least one of them.
- An end left out is short for `"@<name>"` of the pile whose `.pile/`
  holds the link. So the first link is the edge from `@billing` to
  `@ledger`, and the last the edge from `external:cron` to `@billing`.
  It is the only thing a link takes from where it is written: before a
  link moves to another pile, write that end out.
- Each end is of a node type its edge type allows. The `uses` type in
  [types](types.md) allows only a pile as its source, so `external:cron`
  is never the source of a `uses` link.

`runs`, `replicates-to` and `exercises`, on this page, stand for edge
types an aux pile of the repository has created.

A link that gives both ends joins two nodes, and neither has to be the
pile that writes it. That is how two nodes that are not piles are joined:

```toml
# infra/.pile/links.toml
version = "gitpile/1"

[[edges]]
type = "replicates-to"
source = "external:pg-primary"
target = "external:pg-replica"
```

## A reference names a node by its name

- `"@ledger"` is the pile named `ledger`. A pile is never `pile:ledger`.
- `"external:postgres"` is the node of type `external` named `postgres`,
  wherever it is declared.

A reference is written in double quotes, so that a search for `"@ledger"`
finds every one. It is never a path or an id, and it is resolved across
the whole repository, so moving a pile or a node's table breaks none. A
pile with no name cannot be referred to: give it one first. Renaming a
pile, or removing one or a node, breaks every reference to it
([reshaping](reshaping.md)).

## Each edge is written once

An edge is its source, its type and its target, and is written once
([declarations](declarations.md)). Write it in the pile a reader needs it
in: usually the pile that uses, calls or relies on the other. Two edge
types between the same two nodes are two edges. A link never joins a node
to itself.

## A pile's links

A pile's links are every `[[edges]]` table in its `.pile/`, whatever its
ends, and every link elsewhere whose end is the pile or a node at home in
it. [reading](reading.md) says how to find them all.

## What a link table takes

A link table takes `type`, `source`, `target`, `title` and `description`.
It may carry keys of its own too, such as `through`
([declarations](declarations.md)):

```toml
# e2e/.pile/links.toml
version = "gitpile/1"

[[edges]]
type = "exercises"
target = "@billing"
through = "http"
```

A description is never required. When a link has one, its edge type's
`do` and `dont` say what it must name, and what it must not.

## A title says what one end relies on

A link's title says what one end relies on of the other. It names the node
at the other end, never a file or a path. When that end is a pile, the
title may name a part its intent claims. A title that has to name a part
is a sign the boundary is in the wrong place ([boundaries](boundaries.md)).
A change that makes a title untrue is owed at both ends: read the pile at
the other end, and rewrite the title in the same commit. A link added,
changed or removed can also make a sentence of either pile's intent untrue
([intent](intent.md)).
