# What an intent says

Reference. Read it before you write or change an intent.
Needs: [piles](piles.md).
See next: [write-an-intent](../workflows/write-an-intent.md),
[boundaries](boundaries.md), [links](links.md).

A pile's intent, its `.pile/intent.md`, says why the subtree is a pile.
Neither git nor any tool can work it out from the files, so only a person
can say it. An intent that is missing, empty, or still only a comment says
nothing, and the pile is broken until somebody writes it.

## An intent opens with its headline and ends with its closing pair

```markdown
One claim about what the pile is for. This paragraph is its headline.

What belongs in it, and what does not, if the headline needs more.

Read this pile to find out <X>. Change it when <Y>.
```

- **The headline** is the first paragraph of prose. It is what a reader
  sees beside the pile in every list. Make it a claim from which a
  stranger could say whether a new file belongs here, not a topic, an
  address or a list. It runs to the first blank line, or to a line that
  opens a block of its own: a heading, a rule, a bullet, a quote or a
  numbered item. Text inside `<!-- -->` is not prose.
- **What belongs** is the paragraphs between, if the headline needs them.
  Say what sort of thing does not belong ("anything that knows git"), and
  not which pile holds it. Name here, in a few words, each part that other
  piles rely on, so that a link's title may name it: "the parser that
  turns scripts into trees". It never goes in the headline.
- **The closing pair** is the last two sentences. The first names what a
  reader opens the pile to find out: a question somebody arrives with. The
  second names when the pile changes: an event somebody could see happen,
  not "when needed". The words are the pile's own, and nothing follows
  them.

## An intent has no heading

An intent starts with its headline. A heading usually names the pile or
its path, and a path written in the file goes stale when the pile moves.

## What an intent leaves out

- The piles it holds. They declare themselves.
- What it is to another pile, such as what it calls there. A link says
  that, at one of its ends ([links](links.md)).
- How the pile is built inside, and why. That goes in a document among
  the pile's own files, where a reader of the pile finds it. The intent
  does not name it.
- Anything that would change when the code does and the purpose does not:
  a file name, a function, a count.

## Hold a draft to four tests

- **The headline alone.** Read it with nothing else. A stranger can say
  from it whether a new file belongs. A headline that lists the
  directories under it fails: that subtree is a container, not a pile
  ([boundaries](boundaries.md)).
- **Placement.** Take four plausible changes: a new file, a new
  dependency, a feature somebody would ask for, and something that belongs
  in the parent. Each has a sentence that admits it or refuses it.
- **Survival.** No sentence needs editing when the code changes and the
  purpose does not.
- **The pair is the pile's.** Pasted under a sibling pile, it would be
  untrue there.

## Keep it true

Read a pile's intent before you change the pile. When a change makes the
intent untrue, rewrite it in the same commit. Replace the sentence that
became untrue, and do not add one beside it.

An intent many commits behind its pile is one to read again, asking
whether it is still true. `piles.sh show` counts those commits
([reading](reading.md)). The count is not a verdict.

## A person approves it

An intent is drafted, then handed back to a person, and committed only
once they approve it. A plausible sentence nobody approved is worse than
none: the file looks answered while it says nothing anyone decided.
[write-an-intent](../workflows/write-an-intent.md) is how a draft is made.
