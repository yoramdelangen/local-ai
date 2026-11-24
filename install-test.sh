#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
installer="$root/install.sh"
test_home="$(mktemp -d "${TMPDIR:-/tmp}/tricker-ai-test.XXXXXX")"

cleanup() {
  if [[ "${KEEP_TEST_HOME:-0}" == "1" ]]; then
    printf 'Test home kept at: %s\n' "$test_home"
  else
    rm -rf -- "$test_home"
  fi
}
trap cleanup EXIT

if [[ ! -x "$installer" ]]; then
  printf 'Missing executable installer: %s\n' "$installer" >&2
  exit 1
fi

check_source_link() {
  local link="$1"
  local expected="$2"
  if [[ ! -L "$link" || "$(readlink "$link")" != "$expected" ]]; then
    printf 'Expected source link: %s -> %s\n' "$link" "$expected" >&2
    exit 1
  fi
}

for name in cavecrew caveman caveman-commit caveman-compress caveman-help \
  caveman-review caveman-stats megacave ultracave; do
  check_source_link "$root/skills/$name" "../repositories/caveman/skills/$name"
done
check_source_link "$root/plugins/opencode/caveman" "../../repositories/caveman/src/plugins/opencode"
for command in "$root/commands/opencode"/*.md; do
  check_source_link "$command" "../../repositories/caveman/src/plugins/opencode/commands/$(basename "$command")"
done

mkdir -p "$test_home/.config"

printf 'Testing install.sh in isolated HOME: %s\n' "$test_home"
HOME="$test_home" "$installer"

check_link() {
  local link="$1"
  local target="$2"
  if [[ ! -L "$link" ]]; then
    printf 'Expected symlink: %s\n' "$link" >&2
    exit 1
  fi
  if [[ "$(readlink "$link")" != "$target" ]]; then
    printf 'Wrong link target for %s: %s\n' "$link" "$(readlink "$link")" >&2
    exit 1
  fi
  if [[ ! -e "$link" ]]; then
    printf 'Broken symlink: %s\n' "$link" >&2
    exit 1
  fi
}

check_link "$test_home/.config/opencode/AGENTS.md" "$root/INSTRUCTIONS.md"
check_link "$test_home/.claude/CLAUDE.md" "$root/INSTRUCTIONS.md"

for app in opencode claude; do
  if [[ "$app" == "opencode" ]]; then
    app_dir="$test_home/.config/opencode/agents"
  else
    app_dir="$test_home/.claude/agents"
  fi

  for agent in "$root/agents/$app"/*.md; do
    [[ -e "$agent" ]] || continue
    check_link "$app_dir/$(basename "$agent")" "$agent"
  done
done

for skill in "$root/skills"/*/SKILL.md; do
  [[ -e "$skill" ]] || continue
  name="$(basename "$(dirname "$skill")")"
  check_link "$test_home/.claude/skills/$name" "$root/skills/$name"
  check_link "$test_home/.config/opencode/skills/$name" "$root/skills/$name"
done

for repo_skills in "$root"/repositories/*/skills; do
  [[ -d "$repo_skills" ]] || continue
  for skill in "$repo_skills"/*/SKILL.md; do
    [[ -e "$skill" ]] || continue
    name="$(basename "$(dirname "$skill")")"
    [[ -e "$root/skills/$name/SKILL.md" ]] && continue
    check_link "$test_home/.claude/skills/$name" "$(dirname "$skill")"
    check_link "$test_home/.config/opencode/skills/$name" "$(dirname "$skill")"
  done
done

HOME="$test_home" "$installer"

collision="$test_home/.config/opencode/AGENTS.md"
rm "$collision"
printf 'keep this file\n' > "$collision"
if HOME="$test_home" "$installer" >/dev/null 2>&1; then
  printf 'Installer should refuse to replace an existing file.\n' >&2
  exit 1
fi
if [[ "$(cat "$collision")" != "keep this file" ]]; then
  printf 'Installer changed an existing file.\n' >&2
  exit 1
fi

printf 'Install smoke test passed.\n'
