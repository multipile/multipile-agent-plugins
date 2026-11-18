---
name: pile-adopt
description: Lays out in piles a project that declares none. Use this skill when the user asks to adopt piles or multipile, to set a repository up with piles, to add `.pile/` directories to a project that has none, or to work out which parts of a codebase are piles. It is only for a repository with no `.pile/` directory. Where piles are declared already, use `pile-refine`.
---

# Lay a project out in piles

You find the boundaries the project already has. You are not designing it. Each boundary, each link and each intent is proposed, and a person approves it before it is committed.

## 1. Make sure `pile` is there

```sh
command -v pile
```

If it answers nothing, stop. Say that laying a project out in piles needs `pile`, and how to get it: `brew install multipile/tap/pile`, or https://github.com/multipile/pile-cli. Do not install it unasked.

## 2. Make sure no pile is declared yet

```sh
pile list
```

If it names piles, the project is laid out already: use the `pile-refine` skill instead.

## 3. Carry out the workflow

```sh
pile guide adopt
```

Follow it from the top, in order, and never from memory. It prints `pile guide boundaries` and `pile guide proposal` with it, and names the pages to print as you reach them: `pile guide leaves` for which directories are piles, `pile guide relies-on` for the links, `pile guide intent` for each draft.

## 4. Stop where it says to stop

The workflow stops twice for the person: once with the proposed layout, and once with the drafted intents. With nobody to answer, stop there, and commit nothing.
