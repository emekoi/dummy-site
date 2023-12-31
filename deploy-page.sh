#!/usr/bin/sh -e

head="$(git rev-parse --abbrev-ref HEAD)"

site_branch="${1:-gh-pages}"
build_dir="${2:-build}"

setup_branch() {
  git switch --orphan "$site_branch"
  git commit --allow-empty -m"init"
  git switch "$head"
}

build_page() {
  . ./build-commands.sh
  git -C "$build_dir" add --all
  git -C "$build_dir" commit -m "deploy from $(git rev-parse "$head")"
  git -C "$build_dir" push origin "$site_branch"
}

build_page_clean() {
  [ -d "$build_dir" ] && [ -f "$build_dir"/.git ] && git worktree remove "$build_dir"
  [ -d "$build_dir" ] && rm -r "$build_dir"
  git worktree add "$build_dir" "$site_branch"
  build_page
  git worktree remove "$build_dir"
}

build_page_dirty() {
  [ -d "$build_dir" ] && [ ! -f "$build_dir"/.git ] && rm -r "$build_dir"
  [ ! -d "$build_dir" ] && git worktree add "$build_dir" "$site_branch"
  build_page
}

git rev-parse --verify "$site_branch" >/dev/null 2>&1 || setup_branch
([ -z "$DIRTY" ] && build_page_clean) || build_page_dirty
