---
name: ideas-inbox
description: Use when your operator mentions "the inbox", gives you a random idea or explicitly says "add this to the inbox"
---

# The inbox

The inbox is this directory on project interface: `doc/ideas/inbox`
This is a place to drop ideas without wasting too much time thinking about them.
Everything gets organized later through the tracker.
This directory is meant for only markdown files.
Each markdown file captures an idea.
You are free to flesh out a bare bones idea given by the operator, just capture everything neatly in a file.

## The tracker

On the Interface project, this is the tracker file: doc/ideas/00-tracker.md
This is a file that collects references to all ideas, so they can be numbered, prioritized and sized up.
The file is organized in sections separated by HTML comments and markdown titles, ideas are organized chronologically.
This is the format for an entry in the tracker:

> - [ ] **[UNIQUE NUMBER] [IMPORTANCE] [POINTS]** [file-if-large](../file-if-large.md) \<description\>

For more information see the header of the tracker file.

## How to add ideas

Follow the GitHub skill to obtain a clone of the interface repository.
If the idea is fairly complete as a one liner, you can add it straight to the tracker.
If you think a markdown file is appropriate, create one in the inbox directory.
After creating a file for the idea, add it to the tracker using markdown links.
Some information, such as importance and points, may not be provided by the operator. In that case it's okay to fill them in.
Ideas can be pushed straight to the Dev branch without a PR.
