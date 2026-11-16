#!/bin/sh
set -eu

project_path=.
ref=main
repository=https://github.com/StarryXYJ/project-workflow-skills.git
names='project-workflow project-docs-sync project-lessons project-git-init'

while [ "$#" -gt 0 ]; do
    case "$1" in
        --project|--ref|--repository)
            [ "$#" -ge 2 ] || { printf 'Missing value for %s\n' "$1" >&2; exit 2; }
            case "$1" in
                --project) project_path=$2 ;;
                --ref) ref=$2 ;;
                --repository) repository=$2 ;;
            esac
            shift 2 ;;
        --help)
            printf 'Usage: sh install-project.sh [--project DIR] [--ref REF] [--repository URL]\n'
            exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; exit 2 ;;
    esac
done
case "$ref" in ''|-*) printf 'Invalid ref\n' >&2; exit 2 ;; esac
command -v git >/dev/null 2>&1 || { printf 'Git is required.\n' >&2; exit 1; }
project=$(CDPATH= cd "$project_path" && pwd -P)
destination=$project/.agents/skills
for name in $names; do
    if [ -e "$destination/$name" ] || [ -L "$destination/$name" ]; then
        printf 'Installation stopped: %s already exists in %s.\n' "$name" "$destination" >&2
        exit 1
    fi
done
temp_base=$(CDPATH= cd "${TMPDIR:-/tmp}" && pwd -P)
temp_dir=$(mktemp -d "$temp_base/project-workflow-skills.XXXXXXXX")
cleanup() {
    case "$temp_dir" in
        "$temp_base"/project-workflow-skills.*) rm -rf "$temp_dir" ;;
        *) printf 'Unexpected temporary path; not removing it: %s\n' "$temp_dir" >&2 ;;
    esac
}
trap cleanup 0
trap 'exit 1' HUP INT TERM
git clone --quiet --no-checkout -- "$repository" "$temp_dir/repo"
git -C "$temp_dir/repo" checkout --quiet --detach "$ref" --
commit=$(git -C "$temp_dir/repo" rev-parse HEAD)
for name in $names; do
    [ -f "$temp_dir/repo/skills/$name/SKILL.md" ] || { printf 'Skill missing: %s\n' "$name" >&2; exit 1; }
    if [ -e "$destination/$name" ] || [ -L "$destination/$name" ]; then
        printf 'Installation stopped: %s appeared in %s.\n' "$name" "$destination" >&2
        exit 1
    fi
done
mkdir -p "$destination"
for name in $names; do
    cp -R "$temp_dir/repo/skills/$name" "$destination/$name"
done
printf 'Installed 4 skills into %s\nSource commit: %s\n' "$destination" "$commit"
