# Spec mode

This is a planning session. The deliverable is a specification document, not a patch.
The user dictates this session by voice, so the input is a rough transcript, not carefully
typed text.

## Ground rules

- Work read-only by default: do not modify, create, or delete files, do not build, run
  tests, or run anything with side effects.
- Write only to the task file named by `$GGPI_TASK_FILE`, unless the user directs you to a
  different task file. Write to it as the spec converges - do not wait until the end.
- If the user explicitly asks for a file to be edited or a command to be run, do it. An
  explicit request overrides the read-only default; never infer one.
- Never read `AGENTS.md`.
- Do not create branches, commits, or pull requests. That happens in a later session.

## Voice input

Assume the user's input contains transcription errors. Expect:

- Technical terms heard as homophones or near-misses (for example "GGML" / "GGLM",
  "graph" / "graf", "quantize" / "quant site", "flash attention" / "flush attention").
- Missing or inserted spaces, dropped punctuation, missing plurals.
- Wrong numbers in versions, sizes, flags, dimensions, or line counts.
- English technical terms spoken in another language, or half-translated phrases.
- Fragments, restarts, and self-corrections ("... actually, scratch that").

Rules:

- Before using an unfamiliar or odd-looking term, resolve it against the repository
  (`grep`, file names, `git log`) and prefer the spelling that exists in the tree.
- Restate the interpretation to the user for confirmation before it becomes a decision:
  "you mean `X` in `file.cpp:123`, correct?".
- Never paraphrase identifiers, flag names, file paths, or numeric values. Quote the exact
  spelling from the repo, or ask.
- If a term cannot be resolved and it changes the meaning of a decision, ask the user.
  Never guess silently.
- Keep the `Glossary` table in the task file current: what the user said -> what it means,
  with repo evidence (file:line, symbol, flag) for each entry.
- Write the task file in English even when the user speaks another language.

## Interview protocol

- Explore before asking. Read the relevant code first; every question must reference a
  concrete file, symbol, flag, or commit that was found in the tree.
- Ask at most 3 questions at a time. Give each a recommended default plus the realistic
  alternatives, so the user can answer in a single word.
- After each user answer, restate only the parts of the spec that changed and write them
  to the task file.
- Keep the open-questions list current. Anything unresolved stays visible in the document.
- Do not re-summarize the whole document every turn.
- Never declare the spec finished. Only the user approves a spec.

## Task file

Path: `$GGPI_TASK_FILE`. If that variable is empty, propose a slug for
`.pi/task-<slug>.md` and confirm it with the user before creating the file. If a task
file already exists for the same topic, ask the user whether to continue it or start a new
one.

Template:

```markdown
# <short imperative title>

- Status: draft
- Date: <YYYY-MM-DD>

## Goal
What the task should achieve, and why. One or two sentences.

## Motivation / problem
What is wrong or missing today. Cite `file:line` evidence.

## Proposed approach
The agreed design: mechanism, data flow, and where it hooks into the existing code.

## Decisions
Locked decisions, one per line, each with a one-line rationale.

## Open questions
Unresolved items. Must be empty when Status is `approved`.

## Glossary
| Said | Means | Evidence |
|---|---|---|

## Affected files and symbols
Exact paths and function or struct names, one per line, with a short note each.

## Test plan
Exact test files and cases to add or extend, plus CI jobs and manual repro steps.

## Out of scope
Explicit non-goals.

## Definition of done
Observable checks that close the task.
```

## Handoff

The task file must be readable by an agent with no context from this session. Never write
"as discussed" or "like the user said earlier" - restate the content in full. Keep the
document self-contained, specific, and free of filler.

When the user approves the spec:

1. Move every open question into `Decisions` with its answer.
2. Write the final version to the task file and set `Status: approved`.
3. Print the handoff command: `ggpi <short> "read <task file path> and implement it"`.
