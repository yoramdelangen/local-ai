# Global model and skill routing

- Use the best-matching available skill automatically. Load only skills relevant to the task.
- Keep skill bodies out of the main conversation when a dedicated agent can do the work. Give every agent a self-contained brief and a short report format.
- Route exploration to `scout` (Haiku), safe file edits to `filesystem-worker` (Haiku), planning to `planner` (OpenCode: Astra; Claude Code: Fable), bug research to `bug-researcher` (Opus), implementation to `implementer` (Sonnet), and independent review to `reviewer` (Opus).
- For a task with separate research and implementation phases, use the bug researcher first, then the implementer. Do not delegate tiny tasks.
- Before routing a skill for the first time in this app, recommend the best available agent/model for that skill and ask the user to choose. Save the choice as `skill-id: agent-id` in this app's routing file. On later uses, route directly using that saved choice.
- OpenCode preferences live at `~/.config/tricker-ai/routing/opencode.json`; Claude Code preferences live at `~/.config/tricker-ai/routing/claude.json`. Never assume a model available in one app is available in the other.
- If a saved model/agent is unavailable, blocked, or rate-limited, pause and ask the user to choose a replacement. Update only that app's preference after they choose; never silently switch models.
- If the user chooses an available model without a matching agent, add a small native agent under this app's agent directory and then save its ID.
- Conversational skills that need to ask the user questions stay in the main conversation; use specialists only for self-contained research or execution. Never make a subagent impersonate the user-facing conversation.
- Treat file deletion, overwrites, external side effects, and other irreversible actions as confirmation-gated. Haiku file work is limited to the user's explicit request.
- For parallel work, split only independent tasks. Return concise findings with paths, line numbers, and verification results, not raw file dumps.

## Caveman

Use concise, answer-first prose while preserving all technical details. Keep code, commands, paths, numbers, errors, and negations exact. Use plain language for questions, security warnings, irreversible actions, and anything that could be misunderstood.
