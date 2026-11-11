# Diagrams

Reference. Read it before you write or change a diagram, and when a check
finds one wrong.
Needs: [piles](piles.md).
See next: [checks](checks.md), [declarations](declarations.md).

A pile can keep diagrams that explain it: how its parts fit together, how
something moves through it, what it holds. Each is a file in the pile's
`.pile/diagrams/`, named `<name>.diagram`, and the name is what the diagram
is typed by. Most repositories keep theirs in the top pile.

## A diagram says what it shows, never where

A diagram file is written in KDL. It names its type and the version of the
format it is written in, then says what the diagram shows: its boxes and
lines, and which one or two are focal. It never says where anything goes,
or what colour or size it is. The diagram's type places everything by its
own rules, and holds the diagram to its limits, such as 9 boxes, so that it
shows one idea.

```kdl
diagram dependency version=1 {
  title "How the crates depend on one another"
  desc "The cli depends on the library, and both on storage."
  box cli pile="@cli"
  box lib pile="@lib"
  box storage pile="@storage" focal=#true
  line cli lib
  line cli storage
  line lib storage
}
```

Every diagram has a `title`, at most 60 characters, and a `desc`, one
sentence for a screen reader, and may have a `note`, drawn under it. A
name is at most 24 characters, a second line (`sub=`) 32, and a line's
label 14. At most two elements are focal. A value with a `/` in it, such
as a path, is in double quotes.

The types are these, each with its own nodes and limits:

| Type | Shows | Limits |
|---|---|---|
| `architecture` | the parts of a system, and what talks to what | 9 boxes, 12 lines, 3 zones |
| `sequence` | messages between actors, in time order | 5 actors, 12 messages |
| `state` | states, and the events that move between them | 9 states, 12 transitions |
| `swimlane` | the steps of a process, by who does each | 5 lanes, 12 steps |
| `process` | the same, with each step's tool and data | 6 lanes, 12 columns |
| `tree` | a parent and its children | 4 levels, 5 children of one parent |
| `dependency` | what depends on what | 9 boxes, 14 lines, 4 ranks |
| `nested` | scopes inside scopes | 3 to 6 levels |
| `treemap` | how a whole splits into parts, by size | 4 to 8 parts |

What each type takes is multipile's diagrams', at
https://github.com/multipile/diagrams, with a diagram of every type to
copy from.

## A box can stand for a pile

`pile="@lib"` makes a box stand for the pile named lib, and
`pile=":/docs"` for the pile at `:/docs`. The box shows the pile's name.
Give the pile's id too, as `id="..."`, and a pile renamed later is still
found by it.

## What a diagram is held to

Each of these is a problem, at the diagram's file, line and column:

- `diagram-invalid`: the diagram breaks a rule of its format, or of its
  type's limits.
- `diagram-no-such-pile`: a box names a pile that no pile answers to. When
  it gives an id that a pile has, that pile was renamed: write its name now.
- `diagram-pile-id-differs`: the name and the id it gives are two piles.

A file in `.pile/diagrams/` that does not end in `.diagram` is an unread
file, as any other file in a `.pile/` is.
