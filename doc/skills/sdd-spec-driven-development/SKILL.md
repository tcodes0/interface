---
name: sdd-spec-driven-development
description: Use when the operator requests a specification or asks to plan and implement non-trivial software work using spec-driven development.
---

# SDD: Spec-Driven Development

Spec-driven development (SDD) is an engineering practice in which specifications
describe engineering intent and guide implementation by both agents and people.
The work is recorded in Markdown, written in English, structured with OKF
frontmatter, and kept in Git alongside the code.

- **Markdown** is the representation.
- **English** is the human- and agent-readable content.
- **OKF** provides lightweight structure and metadata.
- **Git** provides persistence, history, review, and collaboration.
- **`SPC/`** is the location for specifications and related SDD artifacts.

A specification describes intended behavior and engineering intent. It is not a
report reconstructed from an existing implementation. Humans and agents may
write, refine, and maintain specifications; the operator resolves unresolved
questions of intent and scope.

## Workflow

Move through these steps in order:

```text
Read AGENTS.md
→ Specify
→ Plan
→ Task
→ Code
→ Ship
```

### 1. Read `AGENTS.md`

For SDD purposes, the project constitution is the repository's `AGENTS.md`.
It contains the high-level guidelines, constraints, conventions, and
expectations that govern work across the project.

Read it before doing SDD work. Pay particular attention to:

- engineering and quality guidelines;
- repository structure and conventions;
- testing and review expectations;
- OKF frontmatter rules;
- `SPC/` organization; and
- branch, pull request, and merge requirements.

If `AGENTS.md` does not exist, create the project's constitution before
proceeding. Establish the project's high-level guidelines and SDD/OKF
conventions first.

### 2. Specify

This is the discussion and investigation phase. Work with the operator to
understand, explore, and record the intended change before implementation.

When exploring the current system, start with its existing specifications and
documentation. Then inspect the relevant code, tests, configuration, and
observed behavior. Existing artifacts provide context and may reveal
constraints, gaps, or contradictions that need to be resolved.

Together, the agent and operator should:

- understand the desired intent;
- explore the current system and its constraints;
- identify affected components;
- examine existing specifications and documentation;
- clarify scope and non-goals;
- resolve ambiguities;
- define acceptance criteria;
- record decisions;
- identify risks and open questions; and
- create or update the specification.

For new work, create a feature directory under `SPC/`:

```text
SPC/<feature-name>/
```

Choose a clear, stable feature name and place the specification and related
SDD artifacts there. Inspect `SPC/` first to avoid creating a duplicate
feature directory.

All meaningful discussion and investigation should happen in this step. Later
steps execute and verify the results rather than silently reopening the same
discovery process. If implementation exposes a requirement conflict or a
change in intent, stop and return to the operator.

### 3. Plan

Capture the output of the discussion and investigation in a durable plan. The
plan is not a generic formula: it records the selected design, important
decisions, affected areas, dependencies, constraints, testing approach,
compatibility concerns, risks, and other conclusions that should guide
execution.

Check the plan against the specification before creating tasks.

### 4. Task

Break the plan into coherent units of work. Each task should be small enough
to review and merge independently where practical. Each task should become a
pull request.

Create a Markdown checklist in the feature directory, for example:

```text
SPC/<feature-name>/tasks.md
```

Each checklist item must be followed by a short description of the work it
represents. Keep the checklist synchronized with the actual work and check
items off as they are completed.

```markdown
# Tasks

- [ ] Add the recovery data model — Store the token and expiry required by the recovery flow.
- [ ] Implement the recovery endpoint — Accept a verified email and issue a time-limited link.
- [ ] Add behavior tests — Cover successful recovery, expiry, reuse, and invalid addresses.
- [ ] Update documentation — Record the user-visible behavior and operational constraints.
- [ ] Open and review the pull requests — Submit each task as a focused PR and address review feedback.
```

### 5. Code

Implement the tasks according to the approved specification and plan.

- Follow the task checklist.
- Keep changes scoped to the specification.
- Add or update tests.
- Update the checklist as tasks are completed.
- Create the corresponding pull request for each task.
- Follow the project's normal review workflow.

This is an execution-focused step, not a second investigation phase. Do not
silently redesign the work. If the intended behavior must change, return to
the operator and update the specification and plan before continuing.

### 6. Ship

This step is primarily verification and wrap-up. Verify the implementation
against the specification and acceptance criteria, run relevant tests and
checks, inspect the final diff, and confirm that the task checklist is
accurate.

Before wrapping up:

- update affected documentation;
- update the specification when approved behavior changed;
- record unresolved follow-ups;
- confirm review and QA status; and
- ensure the SDD artifacts describe the work that was actually completed.

Shipping may happen later as a separate follow-up after implementation has
been merged, reviewed, and QA'd. The initial SDD workflow does not require
final production deployment.

## OKF frontmatter

SDD artifacts use OKF-style YAML frontmatter. The only required fields are:

```yaml
---
id: account-recovery
type: feature-spec
description: Describes account recovery behavior for members who cannot sign in.
author: merlin
---
```

- `id` is the stable identifier for the artifact.
- `type` is free text for now.
- `description` briefly states what the artifact represents.
- `author` identifies who or what created the artifact.

`reviewed-by` and `reverse-engineered` are optional. Frontmatter may contain
any additional key/value pairs needed by the project. Do not add software
relationship fields unless the project later adopts them.

## Specification example

A specification can be short when the behavior is simple:

````markdown
---
id: account-recovery
type: feature-spec
description: Describes account recovery behavior for members who cannot sign in.
author: merlin
reviewed-by: []
---

# Account recovery

A member can request a recovery link using their verified email address. The
link expires after one hour and can be used only once.

## Changelog

```yaml
- date: 2026-04-20
  type: created
  summary: Initial account recovery specification
  refs: []
```
````

````

## Documentation from existing implementation

A specification cannot be reliably reverse-engineered from code. Intent is
known before implementation; a document produced from code describes current
behavior and is documentation, not a specification.

When documenting an existing implementation:

1. Read the relevant specifications and documentation first.
2. Create or update the feature directory under `SPC/`:

   ```text
   SPC/<feature-name>/
````

Create the directory if it does not exist. 3. Inspect the code, tests, configuration, and observed behavior. 4. Describe what the system currently does. 5. Mark the artifact as reverse-engineered when applicable:

```yaml
reverse-engineered: true
```

6. Do not present inferred intent as fact.
7. Request review and keep the documentation conceptually separate from a
   forward-looking specification.

## Staleness and drift

Incorrect documentation is worse than no documentation. When specifications,
documentation, and implementation disagree, the disagreement is a defect that
must be resolved.

Start by reading. Finish by updating.

At the beginning of work, read `AGENTS.md` and the relevant specifications and
documentation. At the end of work:

- check whether existing artifacts still describe reality;
- treat contradictions and missing documentation as defects;
- update affected specifications and documentation;
- keep the task checklist synchronized with actual work;
- record approved changes in the specification's changelog; and
- do not leave silent drift between intent, artifacts, and implementation.
