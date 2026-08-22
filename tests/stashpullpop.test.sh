#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STASHPULLPOP="$SCRIPT_DIR/../scripts/.local/bin/stashpullpop"
TEST_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TEST_DIR"
}

trap cleanup EXIT

git init --bare --quiet "$TEST_DIR/origin.git"
git clone --quiet "$TEST_DIR/origin.git" "$TEST_DIR/repository"
git -C "$TEST_DIR/repository" config user.name "Test User"
git -C "$TEST_DIR/repository" config user.email "test@example.com"

printf 'base\n' > "$TEST_DIR/repository/tracked.txt"
git -C "$TEST_DIR/repository" add tracked.txt
git -C "$TEST_DIR/repository" commit --quiet -m "initial"
git -C "$TEST_DIR/repository" push --quiet --set-upstream origin HEAD

printf 'pre-existing stash\n' > "$TEST_DIR/repository/tracked.txt"
git -C "$TEST_DIR/repository" stash push --quiet -m "pre-existing"
printf 'untracked working tree\n' > "$TEST_DIR/repository/untracked.txt"

"$STASHPULLPOP" "$TEST_DIR/repository"

stash_subjects="$(git -C "$TEST_DIR/repository" stash list --format='%gs')"

if [[ "$(git -C "$TEST_DIR/repository" stash list --format='%H' | wc -l)" -ne 1 ]] \
    || [[ "$stash_subjects" != *": pre-existing" ]]; then
    echo "Expected the pre-existing stash to remain untouched" >&2
    exit 1
fi

if [[ ! -f "$TEST_DIR/repository/untracked.txt" ]]; then
    echo "Expected the invocation's untracked file to be restored" >&2
    exit 1
fi

if [[ "$(< "$TEST_DIR/repository/tracked.txt")" != "base" ]]; then
    echo "Expected the pre-existing stash contents to remain unapplied" >&2
    exit 1
fi
