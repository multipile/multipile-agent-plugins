---
name: pile-intent
description: Writes or fixes a pile's intent, the `.pile/intent.md` that says why a subtree of a git repository is one thing. Use this skill when an intent is missing or still a question, when a pile was just declared, when `pile doctor` reports `intent-unanswered`, when a change has made an intent untrue, or when the user asks to write, rewrite, sharpen or check an intent, or to say what a pile is for.
---

# Write a pile's intent

An intent is a claim, not a topic or a role: its headline says what the pile owns or hides, so that a stranger can say whether a new file belongs. You draft it, and a person decides. A plausible intent that nobody approved is worse than none.

## 1. Make sure `pile` is there

```sh
command -v pile
```

If it answers nothing, say that `pile` is not installed, and how to get it: `brew install multipile/tap/pile`, or https://github.com/multipile/pile-cli. Do not install it unasked, and do not draft the intent from memory: stop, or draft it only if the user asks you to go on without the guide.

## 2. Carry out the workflow

```sh
pile guide write-an-intent
```

Follow it from the top, in order. It prints `pile guide intent` with it: what an intent says, the shape it takes, and the tests a draft is held to. Its steps read the pile with `pile show <pile>` and `pile files <pile>`, and check the draft with `pile doctor`.

## 3. Stop for the person

Hand the draft back, saying which sentences you are sure of and which you guessed. Do not commit an intent nobody approved. `pile doctor` asks only whether an intent says something, never what it says, so a draft that passes doctor is not an approved one.
