# libre issues and bugs

## needs patch

### Multiple fast tool calls render wrong

Tool calls in quick succession render a flashing tool icon with parameters and no output.
If there are many tool calls, one per second for example, they pile up and they all seem to be in progress.
However, if the command resolves instantaneously It makes me wonder if DUI is failing to "close" a command and display output.
causing the flashing road to be stuck in progress.

## patched and testing

### minor -- patch needs updates

The chat history tab will sometimes, randomly show blank entries that look like spaces. It goes away by itself. Reloading seems to help.
I noticed that the blanks are underneath the text that groups chat by how long ago they were created. "Previous X days".

### summarization

The chat appears to be stuck. There is indication of work. The stop button in the input. There is a spinner. But there is no summarization copy visible anywhere.
This happens when changing chats. If the current chat hits the summarization, a summarization book icon correctly shows, but changing to another chat and changing back hides the icon, and the chat appears stuck.

## disregard, needs scope

### memory injection is confusing

The text below is model thoughts and output.

```thoughts
The user is asking about adding a health check to make the setup more resilient. They shared their runtime context/memories which I should not comment on. Let me focus on the task.

The user asked "Want me to do that as a follow-up commit to the PR, or a separate one?" and they seem to want me to go ahead with it. But wait - they didn't explicitly say yes. Let me re-read.

Actually, looking at this message again - the user just pasted their memory context. There's no actual message asking me to do anything. This appears to be the system injecting memories into the conversation. The user's last actual question was asking whether to add health checks to the PR or as a separate commit.

I'm not sure if the user's message is just the memory context being injected, or if they accidentally sent it without additional text. I should clarify whether the restart worked and confirm they want me to proceed with adding the health check.
```

Looks like you may have accidentally sent your memory context without a message body, Thom. No worries!

Did the docker compose restart api work? Are the RAG file upload options showing up now in LibreChat?

### Stale input text

Even with the patches, this is still happening. After sending a message, the model will take a couple seconds to reply. The screen will apparently glitch and during that time, the message is both in the conversation and in the input.
I wonder if some type of definitive clear on the draft on send button would fix it.

Also, I noticed that coming back to a chat from another chat might show the input still populated by a message that was sent and replied to by the model. My intuition here is that there's just something out of sync in the current code.
You may want to just hammer it down whenever you send a message. Any draft or local storage completely cleared.

I also noticed that sent messages from another chat appeared in a totally different chat on this glitch.

Update. Current patch seems really good. I still see the input stale after submitting But I think I saw that reproducing in other websites, which would point to a browser bug.

### memory

Memory is kinda wasteful, It runs on every turn but it only saves things that I specifically say should be saved. Use custom memory server.
Models keep talking/thinking about memory injected into chat, needs some prompting to guide them. can be confusing for user if model talks, overall suboptimal.

Memory keeps logging in server: timeout after 3 seconds. value might be too low or model too slow

We could bypass Libra's memory feature completely by simply having the model insert memories directly into Mongo.

### default context is too low

Very strange issue when sending a large message with context files and a big prompt to a model provider never used before. Libre returns an error that the message exceeds the maximum context of 1024 tokens.

- Some configuration tweaks, but apparently no solution.
- If the first message is very short, like hi, Libre will talk to the API and automatically override the system value of 1024 maximum tokens with whatever the API said is the right value. After this it works?

### cannot organize chats by folder

- cannot organize chats by folder or project or in any way whatsoever, they just pile up in an endless scroll list. #4848 in libre.
  simple: drag and drop chats together to create a directory, right click a directory to rename it. Drag chats out to move. Zero chats: dir is deleted.
  nice to have: claude code organize, sort by, clone.

### cannot send a message while the model is working

- cannot send a message while the model is working on the previous message, even though the turn has already progressed to a tool call. This is supported in Cloud Code.

## not reproducible

### api logs

> this is not happening anymore, disregard for now.

This is likely a regression introduced by the patches.

api-1 | 2026-05-16 18:02:40 error: [api/server/controllers/agents/client.js #sendCompletion] Operation aborted {"type":"error","error":{"details":null,"type":"api_error","message":"Internal server error"},"request_id":"req_011Cb6gn6PkKdjfY1TDgaXWG"}
api-1 | 2026-05-16 18:02:40 error: [api/server/controllers/agents/client.js #sendCompletion] Unhandled error type {"type":"error","error":{"details":null,"type":"api_error","message":"Internal server error"},"request_id":"req_011Cb6gn6PkKdjfY1TDgaXWG"}

88d205f4-78ad-407e-850c-81b3997a8fea There's a conversation ID that has the bug and any message sent by the model triggers the bug.

### misc

when doing tool calls:

```
Something went wrong. Here's the specific error message we encountered: An error occurred while processing the request: 400 {"type":"error","error":{"type":"invalid_request_error","message":"messages.110: `tool_use` ids were found without `tool_result` blocks immediately after: toolu_01Rj8zcxzCXyNzLSnFu47vyz. Each `tool_use` block must have a corresponding `tool_result` block in the next message."},"request_id":"req_011Cb6gJGips4XtKDYu5t8Qd"} Troubleshooting URL: https://docs.langchain.com/oss/javascript/langchain/errors/INVALID_TOOL_RESULTS/
```
