# Aux piles

Reference. Read it before you make an aux pile, or change one.
Needs: [types](types.md).
See next: [declarations](declarations.md), [links](links.md).

An aux pile, an auxiliary pile, is a pile whose config says
`kind = auxiliary-gitpile`. It is the only place a type is created. A
repository that wants its own words, such as a type for what lives
outside it, holds an aux pile that declares them.

## Make one as you make any pile

Declare it as any pile ([reshaping](reshaping.md)), with
`kind = auxiliary-gitpile` in its config:

```
kind = auxiliary-gitpile
version = 1
id = <32 hex characters, from piles.sh id>
name = piles
```

Write its intent too ([write-an-intent](../workflows/write-an-intent.md)):
what words the aux pile gives the repository, and why.

## What it declares, and where

An aux pile creates a type with a `[[node-types]]` or `[[edge-types]]`
table in any `.toml` file in its `.pile/`, by convention `types.toml`
([types](types.md)). It may not create `pile`, write a type another aux
pile created, or change anything another aux pile declared.

No table declares the keys a node, a link or `[pile]` carries of its own
([declarations](declarations.md)). When the repository agrees on what one
holds, the aux pile's intent says so: "a pile's `labels` are `core`,
`docs` or `tooling`."

An aux pile is a pile, so it writes links as any pile does
([links](links.md)).

A `[[node-types]]` or `[[edge-types]]` table in a pile that is not an aux
pile declares nothing, and is a problem
([checks](checks.md)).
