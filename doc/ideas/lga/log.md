# Project log

## Layer 0

Working on exploring LibreChat's configuration and features.

### memory

Native memory is very basic and the model that generates it can be customized, but it's all injected every single user message, which is not very elaborate.
It consumes a lot of tokens because it's constantly processing a slice of the conversation.
If you don't explicitly say remember this, it doesn't really set a memory.
I think this is the worst Libre feature.

### agents

Agents are basically a preset, it's very similar to a preset, but they are exposed through the API.
The docs say that agents can be used via API, so it might be possible to use the webhook from GitHub with an agent.

### File uploads.

This is a bit confusing, there's three options to upload a file, to provider as text and for file search.
For file search seems to be the RAG search, but it currently gives an error

### github

I got surprisingly far giving the model access to a token through an environment variable. Apparently it doesn't complain if it's in the environment, but it does complain if you feed it in the prompt.
The model can download the GH CLI, handle API calls to GitHub using the shell, even use the GraphQL API, all using the token.
I'm starting to think that I could just have a GitHub skill, a set of markdown instructions, and a very minimal MCP server just to remove the token from the context, which is a bad pattern.

## next steps layer 0

- [x] Fix RAG in libre
- [x] Fix image uploads
- [x] Libre artifacts
- [x] Investigate Sequential Thinking, MCP.
- [x] Work thru major issues in libre.

github

- [x] signed commits
- [x] branches, open PR
- [x] conventional commits and PR titles
- [ ] no tokens in context: Token is used to authenticate the GH CLI. It's currently injected through the jail environment. The model should not have access to tokens at all.
- [x] works with review comments, reads, closes after implementing
- [x] tested workflows
- [x] worktrees: are really important so my local doesn't conflict with the local agent. There is still a source of conflict because a work tree is tied to a branch that can only be checked out in a single work tree at any given time.
- [ ] worktree: better cleaning up of work trees after the PR is merged.
- [ ] look into skills, the current solution uses only prompting and librechat's agent design. a skill might be a way of formalizing what we've built so far.
- [ ] repo clone: might be a way to build a fully separate repo, might simplify worktrees. and clean up. And there's no risk of conflict because it's a separate clone.
