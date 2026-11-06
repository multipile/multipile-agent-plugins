# The `.toml` files in a `.pile/`

Reference. Read it before you write or read a `.toml` file in a `.pile/`.
Needs: [piles](piles.md).
See next: [links](links.md), [types](types.md), [aux](aux.md),
[checks](checks.md).

Every `.toml` file in a pile's `.pile/` is a declaration file, whatever its
name. A table says what it declares by its header, so the file it sits in
decides nothing. By convention an aux pile writes its types in
`types.toml`, and a pile writes its nodes in `nodes.toml`, its links in
`links.toml` and its own values in `pile.toml`.

What a repository declares is a graph. Each pile is a **node**, and a pile
may declare other nodes, such as something outside the repository it
relies on. An **edge** joins one node to another, and is written as a
**link**. Every node and every edge has a **type**, which an aux pile
creates.

A **word**, wherever these pages ask for one, is lowercase letters, digits
and hyphens, starting with a letter: `postgres`, `relies-on`.

## Every file starts with its version

```toml
version = "gitpile/1"
```

The first key of every declaration file is `version`, before any table. It
names the format the file is written in. `gitpile/1` is the only version
so far. A file with no
`version`, or with a version other than `gitpile/1`, is not read. It is
not the config's `version`, which says the format of the config
([piles](piles.md)).

## A table's header says what it declares

| Table | Declares | In |
|---|---|---|
| `[[nodes]]` | a node, at home in this pile | any pile |
| `[[edges]]` | an edge, written as a link ([links](links.md)) | any pile |
| `[pile]` | this pile's own values; one table, not an array | any pile |
| `[[node-types]]` | a node type ([types](types.md)) | an aux pile |
| `[[edge-types]]` | an edge type | an aux pile |

A file may hold any of them, each as many times as it needs. No header
holds a name: what a table is about is in its keys.

## A node is a `[[nodes]]` table in its home

```toml
# .pile/nodes.toml
version = "gitpile/1"

[[nodes]]
type = "external"
name = "postgres"
title = "the database every invoice is kept in"

[[nodes]]
type = "service"
name = "web"
title = "the site the customers see"
port = 443
```

The pile whose `.pile/` holds the table is the node's home. A node table
takes:

- `type`, the node's type, by its name ([types](types.md)). It is
  required, and is never `pile`: a pile is declared by its config.
- `name`, a word. It is required.
- `title` and `description`.
- keys of its own, such as `port` (below).

A node is referred to as `"external:postgres"`: its type and its name
([links](links.md)).

A list is a TOML array, and a paragraph is written between `"""`.

## `[pile]` gives a pile's own values

```toml
# lib/.pile/pile.toml
version = "gitpile/1"

[pile]
title = "the parser"
labels = ["core"]
```

`[pile]` takes `title`, `description`, and keys of its own, such as
`labels`. A title sits beside the intent's headline, and does not replace
it. A pile's id and name stay in its config.

## A node, a link or `[pile]` may carry keys of its own

Beyond the keys it takes, a `[[nodes]]`, `[[edges]]` or `[pile]` table may
carry any key named by a word, with any TOML value: `port = 443`,
`labels = ["core"]`, `through = "http"`. No type declares these keys, and
nothing checks their values. When a repository agrees on what one holds,
its aux pile's intent says so ([aux](aux.md)).

Such a value is never a reference: `owner = "@ledger"` is a string, not a
link to `@ledger`. To join one node to another, write a link.

## Each thing is written once

Each thing is written once, anywhere in the repository:

- a node, named by its type and its name;
- a type, named by its name, whether node type or edge type;
- an edge, named by its source, its type and its target;
- a key of `[pile]`, which may be split across the pile's files.

Two tables or keys that name one thing are both unread, until one is
removed.
