# Node types and edge types

Reference. Read it before you write a type.
Needs: [declarations](declarations.md).
See next: [aux](aux.md), [links](links.md).

A type names what a node or an edge is. A **node type** is a name. An
**edge type** also says which node types each end of its edges may be.

## A type exists while an aux pile declares it

A type exists while exactly one table declares it, in an aux pile whose
kind is `auxiliary-gitpile` ([aux](aux.md)). The one exception is `pile`:
the format itself creates it, and its nodes are exactly the piles, each
declared by its config and referred to as `@name`.

## A type is a `[[node-types]]` or `[[edge-types]]` table

```toml
# .pile/types.toml, in an aux pile
version = "gitpile/1"

[[node-types]]
name = "external"
title = "something outside the repository that a pile relies on"

[[edge-types]]
name = "uses"
title = "one pile relies on another, or on something outside the repository"
source = ["pile"]
target = ["pile", "external"]
do = "say what the source relies on"
dont = "list functions"
```

A type table takes `name`, `title` and `description`. An edge type also
takes:

- `source` and `target`, each a list of the node types that end may be.
  Both are required. An edge goes from its source to its target.
- `do` and `dont`: what a link's description has to name, and what it
  must not.

A type table takes no other key. A type says nothing about the keys a
node or a link carries of its own ([declarations](declarations.md)).

## A type's name is one word

A type's `name` is a word ([declarations](declarations.md)), such as
`external` or `service`. Types are not namespaced: one name is one type
across the whole repository, whichever aux pile created it, and is
written once.
