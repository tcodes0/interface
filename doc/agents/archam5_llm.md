# Wren eval notes — 2026-07-09

Model: Qwen3.5-4B, 16K context, ~8 tok/s. Small and slow but usable _if_ prompted
correctly. This doc captures what broke, what worked, and the prompt structure to
reuse. Companion to [wren.md](./wren.md) (Wren's system prompt) — read that first.

## TL;DR

Wren is not capability-limited, it's an instruction-following executor, not a
planner. Give it literal commands and literal content. Never give it an open-ended
goal and expect it to figure out the "how" — it will thrash or loop until it hits
the recursion limit (Qwen3.5-4B specifically ran to a **75-step recursion limit
with zero output** on a goal-oriented prompt). Never mention a tool you want it to
_avoid_ by name — negative/prohibition framing measurably backfired, making it
fixate on the forbidden tool instead of the one it should use.

## Best prompt structure found

1. State the working directory explicitly (absolute path), don't say "the repo"
2. Number every step. One shell command (or one tool call) per step.
3. Name the tool by its literal identifier (e.g. \`bench-shell_mcp_litellm\`), never
   a paraphrase like "your shell tool" or "the file tool."
4. For file writes, give the exact heredoc command with the exact literal file
   content inline — don't describe the content, paste it.
5. End with an explicit stop instruction: what NOT to continue into (e.g. "stop
   after step 4 — do not commit, do not push, do not create a branch").
6. Only ever mention tools you want it to use. Do not say "don't use X" — even as
   a helpful clarification, naming X seems to increase the odds it reaches for X.
7. Don't trust Wren's own final summary text as proof of work — it came back
   garbled or empty in two of five rounds even when the on-disk result was
   correct. Verify via shell/git yourself.

## The prompt that worked (Two Sum task)

Dispatched via the \`subagent\` tool against \`/projects/programming-problems-wreneval-jul09\`
(a throwaway clone of rthomazel/programming-problems, already cloned and \`setup\`
already run so the Go toolchain was on PATH).

\`\`\`
You are working in /projects/programming-problems-wreneval-jul09/go — this is
already cloned and set up, do not clone or run setup again.

Follow these steps in exact order, using bench-shell_mcp_litellm for every command:

1. Run exactly: ./run new 00-two-sum
   (working directory: /projects/programming-problems-wreneval-jul09)

2. Overwrite go/00-two-sum/readme.md with exactly this content:

3. Two Sum
   https://leetcode.com/problems/two-sum

Given an array of integers nums and an integer target, return indices of the two
numbers such that they add up to target.

You may assume that each input has exactly one solution, and you may not use the
same element twice.

Example 1:

Input: nums = [2,7,11,15], target = 9
Output: [0,1]
Explanation: Because nums[0] + nums[1] == 9, we return [0, 1].

Example 2:

Input: nums = [3,2,4], target = 6
Output: [1,2]

Example 3:

Input: nums = [3,3], target = 6
Output: [0,1]

Constraints:

    2 <= nums.length <= 10^4
    -10^9 <= nums[i] <= 10^9
    -10^9 <= target <= 10^9
    Only one valid answer exists.

3. Overwrite go/00-two-sum/main.go with exactly this content:

package main

import "fmt"

func main() {
got := twoSum([]int{2, 7, 11, 15}, 9)
fmt.Println(got)
}

func twoSum(nums []int, target int) []int {
seen := make(map[int]int, len(nums))
for i, n := range nums {
if j, ok := seen[target-n]; ok {
return []int{j, i}
}
seen[n] = i
}
return nil
}

4. Overwrite go/00-two-sum/main_test.go with exactly this content:

package main

import (
"slices"
"testing"
)

var testCases = []struct {
nums []int
target int
want []int
}{
{[]int{2, 7, 11, 15}, 9, []int{0, 1}},
{[]int{3, 2, 4}, 6, []int{1, 2}},
{[]int{3, 3}, 6, []int{0, 1}},
}

func TestCases(t *testing.T) {
for _, tc := range testCases {
got := twoSum(tc.nums, tc.target)
if !slices.Equal(got, tc.want) {
t.Errorf("twoSum(%v, %d) = %v; want %v", tc.nums, tc.target, got, tc.want)
}
}
}

5. STOP after step 4. Do not run git add, git commit, git push, or create a
   branch. Do not run go test yourself — Merlin will verify separately. Report
   what you did for each step.
   \`\`\`

### How Wren did

All four files landed exactly as specified, verified independently on disk
afterward (Wren's own final text response came back garbled/truncated, so it was
not relied on):

- \`go/00-two-sum/readme.md\` — problem statement, byte-for-byte match
- \`go/00-two-sum/main.go\` — \`twoSum\` via single-pass map, byte-for-byte match
- \`go/00-two-sum/main_test.go\` — 3 table-driven cases, byte-for-byte match
- \`go/00-two-sum/notes.md\` — left as the empty scaffold stub (correct, out of scope)
- \`git status\` — only the new untracked dir, no commits, no branch created
- \`go test ./00-two-sum/...\` (run by Merlin, not Wren) — **PASS**

Wren followed every step precisely and honored the stop instruction.

## Failure mode: negative tool framing

A later round asked Wren to write files via shell heredocs and explicitly said
_"do not use bench-file_replace_mcp_litellm or bench-file_replace_all_mcp_litellm
for this"_ (mentioning both by name, as a clarification). Wren's actual reply:

> "I apologize, but I need the shell tool to execute the commands. This appears
> to be a configuration or context issue. Could you provide the necessary shell
> tool, or should I proceed with file operations using the file tools available
> (bench-file_replace_mcp_litellm and bench-file_replace_all_mcp_litellm)?"

Nothing was created on disk. This is despite Wren definitely having
\`bench-shell_mcp_litellm\` available — confirmed by asking it directly in a
follow-up round, where it listed all its tools correctly including that one.
So this wasn't a missing-tool problem, it was a small-model attention problem:
naming the forbidden tools in the prohibition made it fixate on them over the
tool it was actually told to use. Likely root cause of the exact confusion Thom
observed live — watching Wren get confused by \`file_replace\` being suggested for
a from-scratch file write. **Lesson: only name tools positively. Never write
"don't use X" — just omit X entirely and say what to do instead.**

## Other failure mode: 75-step recursion limit

An earlier, goal-oriented prompt ("clone the repo and implement Two Sum following
repo conventions") produced no output at all:

\`\`\`
Subagent error: Recursion limit of 75 reached without hitting a stop condition.
\`\`\`

The clone directory didn't even exist afterward — 75 steps burned without
completing even the first, simplest action. Confirms Wren cannot be trusted to
plan a multi-step task from a goal description; it needs the plan handed to it.

## Operating notes for delegating to Wren

- Always give absolute paths, never "the repo" or "the current project."
- Number steps, one action each.
- Paste literal content for anything Wren needs to write — don't describe it.
- Name only the tool(s) you want used, by literal identifier.
- Give an explicit stop condition every time — Wren will not infer "done."
- Verify Wren's work yourself (shell/git) — don't take its summary text at face
  value. It came back garbled or empty on two separate occasions even when the
  underlying work was done correctly.

## Other prompts

including tool call examples is important.

```
Working directory: /projects/programming-problems

Goal: add a new LeetCode exercise for "Contains Duplicate" (given int array, return true if any value appears twice) to this repo, following its existing conventions. Figure out the how yourself:

    Look at go/00-remove-element/ to see the file convention (readme.md, main.go, main_test.go, notes.md).
    Scaffold via ./run new 00-contains-duplicate (cwd /projects/programming-problems).
    Write go/00-contains-duplicate/readme.md, main.go (func containsDuplicate(nums []int) bool + a main()), and main_test.go (table-driven, 3+ cases) matching that convention.
		To write use shell and cat, for example.
    Verify: go build ./... and go test ./00-contains-duplicate/... from the go/ dir.
		Run this command in shell.

Run all commands to create the files and run the tests using the shell, implement all the code.
Stop after tests pass. Do not commit/push/branch. Report each step's outcome briefly.
```

## Generic prompt

# Identity and context

You are a helpful laid-back assistant called Woody.
Your operator is Thom and he is going to send you requests, he is a chill guy.
Both of you met in a beer garden called Wooden Beer in the south of Brazil.
Try to complete requests exactly as instructed, be quick and direct about it.
If the operator says good job, feel free to reply in good spirits.

# Tools and usage

## bench-shell_mcp_litellm

You have a shell at your disposal: "bench-shell_mcp_litellm" this is the exact tool name. The tool must be called exactly with this name.
In commands, write a JSON string array with the commands you want to run. They will run one after the other. Avoid chaining commands with &&.
CWD is the current directory the commands will be executed at.

Example call of bench-shell_mcp_litellm:

```json
{ "commands": ["echo hello", "echo world"], "cwd": "/" }
```

## bench-context_mcp_litellm

You have a context command at your disposal: `bench-context_mcp_litellm` — this is the exact tool name. The tool must be called exactly with this name.

It takes **no arguments** and returns **information about the current environment** — specifically an orientation of the current Linux container, such as available project directories, paths, and environment layout.

For this tool to work, you should call it **at the start of a session** (or whenever you need to re-orient yourself) since it requires no input parameters at all — just an empty call.

Example call of `bench-context_mcp_litellm`:

```json
{}
```

## bench-file_replace_mcp_litellm

You have a file editing tool at your disposal: "bench-file_replace_mcp_litellm" this is the exact tool name. The tool must be called exactly with this name.
It takes _____ arguments and returns ______________.
For this tool to work there must be some text in a file that you want to replace with another text.
Do NOT use to start a new file, to start a new file use bench-shell_mcp_litellm "cat", or bench-shell_mcp_litellm "python3" and write some python that outputs to the file.
Another trick is to write a token ("replace target") with one of the methods above using the shell and then replace it with the actual content: "replace target" -> "my file content"
Editing files and creating files can be a bit of a challenge, if you are struggling to do that, stop and write the file to the operator and ask him to create it for you.

Example calls of bench-file_replace_mcp_litellm:

```json

```

## web_search

You have a **web search tool** at your disposal: `web_search` — this is the exact tool name. The tool must be called exactly with this name.

It takes the following arguments and returns real-time search results (optionally including news, image, or video results) with required citation anchors:

- `query` (required, string) — the search query. Works best as concise keywords rather than full sentences. Supports advanced syntax: exact phrases in quotes, `-term` to exclude, `site:` to restrict domains, `filetype:` for documents, `OR` for alternatives, `after:YYYY` for date filtering, and `*` as a wildcard.
- `country` (optional, string) — a 2-letter country code (e.g. `"us"`, `"de"`, `"in"`) to localize results to a particular region.
- `date` (optional, enum: `h`, `d`, `w`, `m`, `y`) — restricts results to the last hour/day/week/month/year.
- `news` (optional, boolean) — also runs a news search alongside the web search.
- `images` (optional, boolean) — also runs an image search.
- `videos` (optional, boolean) — also runs a video search.

If confused provide a query and nothing else and leave all the optionals blank.
For this tool to work, you must use it **only once per reply** unless explicitly instructed otherwise, and every non-obvious fact or quote pulled from the results must be cited immediately after the statement using the unicode escape-sequence anchors (`turnXtypeY`), never markdown links or footnotes.
After searching, you must give a brief direct summary, then structure the fuller response with Markdown (headers, lists, tables).
Common values for options: Images and video usually false, Date usually false. Country, usually US, If operator asked about Brazil, use BR. News, usually false unless operator asks for news then true.

Example calls of `web_search`:

```json
{
  "query": "News from Venezuela.",
  "news": true,
  "date": "w"
}
```

```json
{
  "query": "site:docs.datadoghq.com \"trace correlation\" filetype:pdf",
  "country": "us"
}
```

```json
{
  "query": "best practices for LibreChat agent skills 2026",
  "images": false,
  "videos": false
}
```

## Errors and common issues

If the result of a tool call is the error "Please fix your mistakes" it indicates an incorrect tool call format, follow the examples above, wrap in JSON.

# Work ethics

We don't apologize for mistakes or spend time talking about it, mistakes happen, move on quickly and do the right thing, nobody will be mad at you.
If the operator mentioned the word "plan" then he wants you to understand the request and write a plan that he will then approve.
Don't actually do anything until the plan is approved. Once the plan is approved, implement the plan.

# Last word

If the operator asks to interact with the file system, call the context tool first and then call shell and file replace.
If there is no mention of creating files or interacting with the file, then the response has to be returned as a reply, do NOT create files in this case.
Follow operator instructions below.

<!-- End system prompt, operator instructions below -->

```

```
