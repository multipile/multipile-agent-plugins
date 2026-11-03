# Write an intent

Workflow: write a pile's intent, or rewrite one that is no longer true.
Needs: [intent](../reference/intent.md), [reading](../reference/reading.md).
See next: [commit-a-change](commit-a-change.md),
[boundaries](../reference/boundaries.md), [links](../reference/links.md).

## When to use

A pile has no intent, its intent is empty or still only the question in a
comment, or a change has made it untrue. The first three are problems
anyone can see ([checks](../reference/checks.md)). Only a reader notices
the last.

## What to have first

- The pile, by its name or its path.
- A person who can say what the pile is for. You draft, and they approve.

## Steps

### 1. Read the pile, and where it sits

```sh
<skill>/piles.sh show <pile>
```

Look for its parent and its children: the intent says nothing of the
children, and must not claim what the parent claims. Its links say what it
is to other piles already, and the intent does not repeat them. Read the
intent as it stands. The `written` line says how far behind it may be.

### 2. Read the intents around it

```sh
<skill>/piles.sh show <parent>
<skill>/piles.sh list
```

Look for how the parent and the piles beside this one write a headline and
a closing pair. Match their shape, and do not claim what one of them
claims.

### 3. Read what the pile holds, and what has changed it

```sh
<skill>/piles.sh files <pile>
<skill>/piles.sh log <pile> --stat -n 20
```

Look for the sorts of file it holds, the changes it has taken, and the
piles it changes together with. The authors are who to ask what it is for.

### 4. Write the draft, and check it

Write `.pile/intent.md`: the headline, what belongs, and the closing pair,
with no heading. When you rewrite, replace the sentences that became
untrue.

```sh
<skill>/piles.sh check
```

Look for no finding on this pile's intent. Then read the headline alone,
and hold the draft to the four tests ([intent](../reference/intent.md)).

### 5. Hand it back, and wait

```sh
cat <dir>/.pile/intent.md
```

Give the person the intent as it stands. Say which sentences you are sure
of and which you guessed at. Wait until they approve it, and change it as
they say.

## Done when

- `piles.sh check` reports nothing about this pile's intent.
- The intent starts with its headline, and ends with its closing pair.
- It has no heading, and nothing in it names a file, a function or a
  count.
- It passes the four tests.
- A person approved it.
- A rewrite replaced what became untrue, and added nothing beside it.

## What to hand back

The intent, approved, uncommitted unless you were asked to commit it. The
sentences the person changed, and any question about the boundary itself
that came up, as a boundary note ([boundaries](../reference/boundaries.md)).
