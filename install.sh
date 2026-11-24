#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
home="${HOME:?HOME must be set}"
update_submodules=0

case "${1:-}" in
  "") ;;
  --update-submodules) update_submodules=1 ;;
  --help)
    printf 'Usage: %s [--update-submodules]\n' "${0##*/}"
    exit 0
    ;;
  *)
    printf 'Unknown option: %s\nUsage: %s [--update-submodules]\n' "$1" "${0##*/}" >&2
    exit 2
    ;;
esac

link_path() {
  local source="$1"
  local target="$2"
  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    if [[ "$(readlink "$target")" == "$source" ]]; then
      return
    fi
    printf 'Refusing to replace existing symlink: %s -> %s\n' \
      "$target" "$(readlink "$target")" >&2
    exit 1
  fi
  if [[ -e "$target" ]]; then
    printf 'Refusing to replace existing path: %s\n' "$target" >&2
    exit 1
  fi
  ln -s "$source" "$target"
}

if [[ -f "$root/.gitmodules" ]]; then
  if [[ "$update_submodules" == "1" ]]; then
    git -C "$root" submodule update --init --recursive --remote --merge
  else
    git -C "$root" submodule update --init --recursive
  fi
fi

link_path "$root/INSTRUCTIONS.md" "$home/.config/opencode/AGENTS.md"
link_path "$root/INSTRUCTIONS.md" "$home/.claude/CLAUDE.md"

for app in opencode claude; do
  case "$app" in
    opencode) app_dir="$home/.config/opencode/agents" ;;
    claude) app_dir="$home/.claude/agents" ;;
  esac
  for agent in "$root/agents/$app"/*.md; do
    [[ -e "$agent" ]] || continue
    link_path "$agent" "$app_dir/$(basename "$agent")"
  done
done

for command in "$root/commands/opencode"/*.md; do
  [[ -e "$command" ]] || continue
  link_path "$command" "$home/.config/opencode/commands/$(basename "$command")"
done

for skill_file in "$root/skills"/*/SKILL.md; do
  [[ -e "$skill_file" ]] || continue
  skill_dir="$(dirname "$skill_file")"
  link_path "$skill_dir" "$home/.claude/skills/$(basename "$skill_dir")"
  link_path "$skill_dir" "$home/.config/opencode/skills/$(basename "$skill_dir")"
done

for repo_skills in "$root"/repositories/*/skills; do
  [[ -d "$repo_skills" ]] || continue
  for skill_file in "$repo_skills"/*/SKILL.md; do
    [[ -e "$skill_file" ]] || continue
    skill_dir="$(dirname "$skill_file")"
    skill_name="$(basename "$skill_dir")"
    if [[ -e "$root/skills/$skill_name/SKILL.md" ]]; then
      continue
    fi
    link_path "$skill_dir" "$home/.claude/skills/$skill_name"
    link_path "$skill_dir" "$home/.config/opencode/skills/$skill_name"
  done
done

printf 'Installed Tricker AI links from %s\n' "$root"
