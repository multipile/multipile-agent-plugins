---
name: pile-refine
description: Changes the piles a git repository already declares. It splits, merges, moves, renames, removes or adds a pile, or moves files from one pile to another. Use this skill when the user asks to refine, restructure or clean up the piles, says a pile is too big or a boundary is in the wrong place, wants to act on a boundary note, or asks to declare a new pile in a repository that already has some. For a project with no piles yet, use `pile-adopt`.
---

# Refine the piles a repository declares

This is the only workflow that moves a declared boundary. During an ordinary change, a boundary that looks untrue is reported in a boundary note (`pile guide boundary-note`), and not moved.

## 1. Make sure `pile` is there

```sh
command -v pile
```

If it answers nothing, stop. Say that refining piles needs `pile`, and how to get it: `brew install multipile/tap/pile`, or https://github.com/multipile/pile-cli. Do not install it unasked.

## 2. Carry out the workflow

```sh
pile guide refine
```

Follow it from the top, in order, and never from memory. It prints `pile guide boundaries` and `pile guide proposal` with it. Print the pages it names as you reach them: `pile guide relies-on` to test the layout, and `pile guide reshaping` and `pile guide split-and-merge` to make each item.

## 3. Stop for the person

Propose the items as one numbered list, and wait. The person accepts or rejects each one. Make only what they accepted, one commit each, with `pile doctor` exiting 0 before each. With nobody to answer, stop, and commit nothing.
