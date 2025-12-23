# Design OS Commands

Use this workflow when the user asks to run a specific Design OS command (e.g., `/product-vision`, `/design-screen`).

1. Identify the requested command from the message.
2. Locate the corresponding markdown file in `octolist-design/.claude/commands/design-os/`.
3. Follow the steps defined in that file sequentially, using the `task_boundary` and `notify_user` tools to manage the conversational flow as instructed.
