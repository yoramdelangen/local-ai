# Tricker AI

Personal, global setup for OpenCode and Claude Code.

- `skills/` contains 66 locally maintained skills and links to shared upstream skills.
- `repositories/` contains upstream skill repositories as Git submodules.
- `INSTRUCTIONS.md` is loaded by both apps.
- `agents/opencode/` and `agents/claude/` hold native per-app agents.
- `routing/opencode.json` and `routing/claude.json` remember skill-to-agent choices independently.
- `plugins/opencode/caveman/` is the OpenCode Caveman plugin.
- `commands/opencode/` holds OpenCode Caveman commands.

OpenCode references these paths from `~/.config/opencode/opencode.jsonc`.
Claude Code references the shared skills and instructions through symlinks in `~/.claude`.

Run `./install.sh` to initialize pinned submodules and install app links.
Run `./install.sh --update-submodules` to move submodules to upstream revisions.
Run `./install-test.sh` to test the install in a temporary home directory.
See [`SKILL-CATALOG.md`](SKILL-CATALOG.md) for every skill and OpenCode command.

## Adding a skill repository

Add upstream skill repositories as Git submodules under `repositories/`.

```bash
git submodule add https://github.com/OWNER/REPOSITORY.git repositories/NAME
```

Use a short, unique `NAME`. The repository should contain skills in
`skills/<skill-name>/SKILL.md`; `install.sh` discovers that layout and links
those skills into Claude Code and OpenCode.

If a new repository provides a skill already present in `skills/` or another
repository, choose one source of truth. Compare the copies and preserve any
local edits outside `skills/`. Then replace the duplicate local directory with
a relative symlink, for example:

```bash
rm -r skills/SKILL_NAME
ln -s ../repositories/NAME/skills/SKILL_NAME skills/SKILL_NAME
```

Do not keep two editable copies of the same skill. `install.sh` leaves an
existing local skill in place rather than silently replacing it.

Add the new repository's skill path to the `skills` array in
`~/.config/opencode/opencode.jsonc`:

```jsonc
"~/.config/tricker-ai/repositories/NAME/skills"
```

Claude Code's installer scans `repositories/*/skills` automatically. OpenCode
uses the explicit paths in its config, so add a path there for each new
repository.

Initialize and install the new repository:

```bash
./install.sh
./install-test.sh
```

To update all submodules to their upstream revisions, run:

```bash
./install.sh --update-submodules
```

Review and commit the `.gitmodules` and submodule pointer changes so another
clone receives the same revisions. Then restart the apps and check OpenCode
with `opencode debug config`.
