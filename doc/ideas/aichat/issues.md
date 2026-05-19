# bugs

# minor

The chat history tab will sometimes, randomly show blank entries that look like spaces. It goes away by itself. Reloading seems to help. 

## memory

Memory is kinda wasteful, It runs on every turn but it only saves things that I specifically say should be saved. Use custom memory server.
Models keep talking/thinking about memory injected into chat, needs some prompting to guide them. can be confusing for user if model talks, overall suboptimal.

After a memory is deleted the row stays in the chat.

A memory row in chat is created with title and content equal to "placeholder"

Memory keeps logging in server: timeout after 3 seconds. value might be too low.

## default context is too low

Very strange issue when sending a large message with context files and a big prompt to a model provider never used before. Libre returns an error that the message exceeds the maximum context of 1024 tokens.

- Some configuration tweaks, but apparently no solution.
- If the first message is very short, like hi, Libre will talk to the API and automatically override the system value of 1024 maximum tokens with whatever the API said is the right value. After this it works?

## api logs

> this is not happening anymore, disregard for now.

This is likely a regression introduced by the patches.

api-1 | 2026-05-16 18:02:40 error: [api/server/controllers/agents/client.js #sendCompletion] Operation aborted {"type":"error","error":{"details":null,"type":"api_error","message":"Internal server error"},"request_id":"req_011Cb6gn6PkKdjfY1TDgaXWG"}
api-1 | 2026-05-16 18:02:40 error: [api/server/controllers/agents/client.js #sendCompletion] Unhandled error type {"type":"error","error":{"details":null,"type":"api_error","message":"Internal server error"},"request_id":"req_011Cb6gn6PkKdjfY1TDgaXWG"}

88d205f4-78ad-407e-850c-81b3997a8fea There's a conversation ID that has the bug and any message sent by the model triggers the bug.

## misc

when doing tool calls:

```
Something went wrong. Here's the specific error message we encountered: An error occurred while processing the request: 400 {"type":"error","error":{"type":"invalid_request_error","message":"messages.110: `tool_use` ids were found without `tool_result` blocks immediately after: toolu_01Rj8zcxzCXyNzLSnFu47vyz. Each `tool_use` block must have a corresponding `tool_result` block in the next message."},"request_id":"req_011Cb6gJGips4XtKDYu5t8Qd"} Troubleshooting URL: https://docs.langchain.com/oss/javascript/langchain/errors/INVALID_TOOL_RESULTS/
```

# personal preferences, complex, other

- cannot organize chats by folder or project or in any way whatsoever, they just pile up in an endless scroll list. #4848 in libre.
  simple: drag and drop chats together to create a directory, right click a directory to rename it. Drag chats out to move. Zero chats: dir is deleted.
  nice to have: claude code organize, sort by, clone.
- cannot send a message while the model is working on the previous message, even though the turn has already progressed to a tool call. This is supported in Cloud Code.
