#!/bin/sh
set -eu

project_path=.
ref=main
repository=https://github.com/StarryXYJ/project-workflow-skills.git
names='project-workflow project-docs-sync project-lessons project-git-init'
update=false
from=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --project|--ref|--repository|--from)
            [ "$#" -ge 2 ] || { printf 'Missing value for %s\n' "$1" >&2; exit 2; }
            case "$1" in
                --project) project_path=$2 ;;
                --ref) ref=$2 ;;
                --repository) repository=$2 ;;
                --from) from=$2 ;;
            esac
            shift 2 ;;
        --update) update=true; shift ;;
        --help)
            printf 'Usage: sh install-project.sh [--update] [--from COMMIT] [--project DIR] [--ref REF] [--repository URL]\n'
            exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; exit 2 ;;
    esac
done
case "$ref" in ''|-*) printf 'Invalid ref\n' >&2; exit 2 ;; esac
command -v git >/dev/null 2>&1 || { printf 'Git is required.\n' >&2; exit 1; }
command -v diff >/dev/null 2>&1 || { printf 'diff is required.\n' >&2; exit 1; }
project=$(CDPATH= cd "$project_path" && pwd -P)
destination=$project/.agents/skills
version_file=$destination/.project-workflow-skills-version
if [ "$update" = true ]; then
    if [ -z "$from" ] && [ -f "$version_file" ]; then IFS= read -r from < "$version_file" || :; fi
    case "$from" in ''|*[!0-9a-f]*) printf 'Update needs the original full commit hash (--from) or a version file.\n' >&2; exit 1 ;; esac
    [ "${#from}" -eq 40 ] || { printf 'Original commit must be a full 40-character hash.\n' >&2; exit 1; }
else
    [ -z "$from" ] || { printf '%s\n' '--from requires --update.' >&2; exit 2; }
    [ ! -e "$version_file" ] && [ ! -L "$version_file" ] || { printf 'Version file already exists; use --update.\n' >&2; exit 1; }
    for name in $names; do
        if [ -e "$destination/$name" ] || [ -L "$destination/$name" ]; then
            printf 'Installation stopped: %s already exists in %s.\n' "$name" "$destination" >&2
            exit 1
        fi
    done
fi
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
if [ "$update" = true ]; then
    git -C "$temp_dir/repo" checkout --quiet --detach "$from" --
    for name in $names; do
        if [ ! -d "$destination/$name" ] || [ -L "$destination/$name" ] ||
           ! diff -r "$temp_dir/repo/skills/$name" "$destination/$name" >/dev/null 2>&1; then
            printf 'Update stopped: %s differs from the original installation or is missing.\n' "$name" >&2
            exit 1
        fi
    done
fi
git -C "$temp_dir/repo" checkout --quiet --detach "$ref" --
commit=$(git -C "$temp_dir/repo" rev-parse HEAD)
for name in $names; do
    [ -f "$temp_dir/repo/skills/$name/SKILL.md" ] || { printf 'Skill missing: %s\n' "$name" >&2; exit 1; }
    if [ "$update" = false ] && { [ -e "$destination/$name" ] || [ -L "$destination/$name" ]; }; then
        printf 'Installation stopped: %s appeared in %s.\n' "$name" "$destination" >&2
        exit 1
    fi
done
mkdir -p "$destination"
stage=$(mktemp -d "$destination/.project-workflow-skills-stage.XXXXXXXX")
replaced=''
finish_install() {
    if [ -n "$replaced" ]; then
        printf 'Installation interrupted; original files are backed up in %s\n' "$stage" >&2
    else
        rm -rf "$stage"
    fi
    cleanup
}
trap finish_install 0
for name in $names; do cp -R "$temp_dir/repo/skills/$name" "$stage/$name"; done
printf '%s\n' "$commit" > "$stage/version"
if [ "$update" = true ]; then
    mkdir "$stage/backup"
    for name in $names; do cp -R "$destination/$name" "$stage/backup/$name"; done
fi
for name in $names; do
    if [ "$update" = true ]; then
        replaced="$replaced $name"
        rm -rf "$destination/$name"
    fi
    mv "$stage/$name" "$destination/$name"
done
mv "$stage/version" "$version_file"
replaced=''
printf 'Installed 4 skills into %s\nSource commit: %s\n' "$destination" "$commit"
