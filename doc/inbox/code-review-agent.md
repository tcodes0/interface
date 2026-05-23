# Code review agent

A subagent for Woody to call before committing to a plan or after producing a diff.

Current thinking: one agent, GPT-backed, broad/architectural focus.

- Checks consistency with project-wide patterns and AGENTS.md rules
- Catches cross-package impact (changed interface, missed downstream consumer)
- Structured output with severity levels — not all findings are equal

Future idea: two modes on the same agent — `broad` and `detail`.

- `broad`: architectural consistency, pattern adherence, cross-package impact
- `detail`: logic correctness, edge cases, specific AGENTS.md checklist
- Start with one agent, split only if the prompts grow apart under real use
