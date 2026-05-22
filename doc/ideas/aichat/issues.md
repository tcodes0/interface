# libre issues and bugs

## needs patch

## patched and testing

There is a scrub bar on the right hand side of the chat window. It is meant to allow quick preview and navigation of the chat.
However, clicking it is challenging because the elements are too small and the click has to be pixel perfect.
Using this element should be easier.

### Last thought always open — patch 017 v2

v1 kept thoughts open when followed by a tool call (`nextType === TOOL_CALL`). This caused
EVERY thought in a reasoning chain (THINK -> TOOL_CALL -> THINK -> ...) to auto-open since
each intermediate thought is followed by a tool call.

v2 fix: `isLastActiveThought = isLatestMessage && isLast` with no `nextType` exception.
Only the absolute last content part of the latest AI message auto-opens.
Anything after the thought (tool call, text, another thought) closes it.
User toggle and reset-on-new-turn behavior unchanged.

### minor -- patch needs updates

The chat history tab will sometimes, randomly show blank entries that look like spaces. It goes away by itself. Reloading seems to help.
I noticed that the blanks are underneath the text that groups chat by how long ago they were created. "Previous X days".

### summarization

The chat appears to be stuck. There is indication of work. The stop button in the input. There is a spinner. But there is no summarization copy visible anywhere.
This happens when changing chats. If the current chat hits the summarization, a summarization book icon correctly shows, but changing to another chat and changing back hides the icon, and the chat appears stuck.

## disregard, needs scope

### Stale input text

Even with the patches, this is still happening. After sending a message, the model will take a couple seconds to reply. The screen will apparently glitch and during that time, the message is both in the conversation and in the input.
I wonder if some type of definitive clear on the draft on send button would fix it.

Also, I noticed that coming back to a chat from another chat might show the input still populated by a message that was sent and replied to by the model. My intuition here is that there's just something out of sync in the current code.
You may want to just hammer it down whenever you send a message. Any draft or local storage completely cleared.

I also noticed that sent messages from another chat appeared in a totally different chat on this glitch.

Update. Current patch seems really good. I still see the input stale after submitting But I think I saw that reproducing in other websites, which would point to a browser bug.

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
