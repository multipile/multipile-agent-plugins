#!/bin/sh
# Read a git repository by pile, with git alone. It needs only sh and git, and
# writes nothing. reference/reading.md says when to reach for each command.
#
#   piles.sh list                 every pile: its path, and its name if it has one
#   piles.sh which <path>...      the pile each path is in, or (in no pile)
#   piles.sh show <pile>          a pile's config, parent, children and intent
#   piles.sh files <pile>         a pile's own files: less every pile it holds
#   piles.sh log <pile> [args]    the commits that changed a pile's own files
#   piles.sh status               what changed since the last commit, by pile
#   piles.sh id                   a new id, for the config of a new pile
#   piles.sh check                every pile, held to reference/checks.md;
#                                 exits 1 on a problem
#
# A pile is given as @name, or as its path from the top of the repository,
# with or without a leading :/ (`:/crates/lib`, `crates/lib`, `:/` for the
# top). A path is given from the top too. Every path printed is a :/ path.
set -eu

self=$(cd "$(dirname "$0")" && pwd)/$(basename "$0")
top=$(git rev-parse --show-toplevel) || exit 2
cd "$top"

# Every pile's directory, from the top, `.` for the top itself.
piles() {
  git ls-files -co --exclude-standard -- ':(glob)**/.pile/config' |
    sed 's|/*\.pile/config$||; s|^$|.|' | sort
}

# The value of one key in a pile's config, or nothing.
key() {
  sed -n "s/^[[:space:]]*$2[[:space:]]*=[[:space:]]*//p" "$1/.pile/config" |
    sed 's/[[:space:]]*$//' | head -n 1
}

colon() { [ "$1" = . ] && echo ":/" || echo ":/$1"; }

# A path as typed, as a path from the top: `.` for the top.
plain() {
  p=${1#:/}
  p=${p#./}
  p=${p%/}
  [ -n "$p" ] && echo "$p" || echo .
}

# The pile a path is in: the nearest directory at or above it with a config.
which_pile() {
  d=$(plain "$1")
  while :; do
    if [ -f "$d/.pile/config" ]; then echo "$d"; return; fi
    if [ "$d" = . ]; then return; fi
    d=$(dirname "$d")
  done
}

# A pile, as @name or a path, as its directory from the top.
resolve() {
  case $1 in
    @*)
      for p in $(piles); do
        if [ "$(key "$p" name)" = "${1#@}" ]; then echo "$p"; return; fi
      done
      echo "no pile is named ${1#@}" >&2; exit 2 ;;
    *)
      p=$(plain "$1")
      if [ ! -f "$p/.pile/config" ]; then
        echo "$(colon "$p") is not a pile: it has no .pile/config" >&2; exit 2
      fi
      echo "$p" ;;
  esac
}

# The piles a pile holds, at any depth.
under() {
  piles | awk -v p="$1" '$0 != p && (p == "." || index($0, p "/") == 1)'
}

# The pathspecs of a pile's own files: its directory, less each pile it holds.
own() {
  echo "$1"
  under "$1" | sed 's|^|:(exclude)|'
}

label() {
  n=$(key "$1" name)
  if [ -n "$n" ]; then echo "@$n  $(colon "$1")"; else colon "$1"; fi
}

cmd=${1:-}
[ $# -gt 0 ] && shift
case $cmd in
  list)
    for p in $(piles); do label "$p"; done ;;
  which)
    for path in "$@"; do
      p=$(which_pile "$path")
      if [ -n "$p" ]; then
        echo "$(colon "$(plain "$path")")  in  $(label "$p")"
      else
        echo "$(colon "$(plain "$path")")  (in no pile)"
      fi
    done ;;
  show)
    p=$(resolve "$1")
    echo "== $(label "$p")"
    cat "$p/.pile/config"
    if [ "$p" != . ]; then
      parent=$(which_pile "$(dirname "$p")")
      if [ -n "$parent" ]; then echo "parent: $(label "$parent")"; fi
    fi
    for c in $(under "$p"); do
      if [ "$(which_pile "$(dirname "$c")")" = "$p" ]; then echo "child: $(label "$c")"; fi
    done
    for f in "$p"/.pile/*; do
      case $f in */config | */intent.md) ;; *) if [ -f "$f" ]; then echo "also: $(colon "${f#./}")"; fi ;; esac
    done
    last=$(git log -1 --format=%H -- "$p/.pile/intent.md")
    if [ -n "$last" ]; then
      # shellcheck disable=SC2046
      n=$(git rev-list --count "$last..HEAD" -- $(own "$p"))
      echo "written: $n commits have changed the pile since its intent"
    else
      echo "written: the intent is not committed"
    fi
    echo "== intent"
    cat "$p/.pile/intent.md" 2>/dev/null || echo "(no intent.md)" ;;
  files)
    p=$(resolve "$1")
    # shellcheck disable=SC2046
    git ls-files -co --exclude-standard -- $(own "$p") | sed 's|^|:/|' ;;
  log)
    p=$(resolve "$1")
    shift
    # shellcheck disable=SC2046
    git log "$@" -- $(own "$p") ;;
  status)
    git status --porcelain=v1 --untracked-files=all | while IFS= read -r line; do
      path=${line#???}
      path=${path#* -> }
      p=$(which_pile "$path")
      if [ -n "$p" ]; then echo "$(label "$p")	${line%"$path"}:/$path"
      else echo "(in no pile)	${line%"$path"}:/$path"; fi
    done | sort ;;
  id)
    od -An -tx1 -N16 /dev/urandom | tr -d ' \n'
    echo ;;
  check)
    found=$(mktemp)
    trap 'rm -f "$found"' EXIT
    say() {
      case $1 in problem) o=1 ;; warning) o=2 ;; *) o=3 ;; esac
      printf '%s %-8s %s  %s\n' "$o" "$1" "$2" "$3" >>"$found"
    }
    for p in $(piles); do
      at=$(colon "$p")
      c="$p/.pile/config"
      if [ -L "$c" ]; then say problem "$at" "the config is a symbolic link"; fi
      bad=$(awk '
        /^[[:space:]]*(#|$)/ { next }
        !/^[[:space:]]*(kind|version|id|name)[[:space:]]*=[[:space:]]*[^[:space:]]/ {
          print "line " NR " is not kind, version, id or name = a value"; next
        }
        { k = $0; sub(/^[[:space:]]*/, "", k); sub(/[[:space:]]*=.*/, "", k)
          if (seen[k]++) print "line " NR " gives " k " again" }
      ' "$c")
      if [ -n "$bad" ]; then
        printf '%s\n' "$bad" | while IFS= read -r b; do
          say problem "$at" "config: $b"
        done
      fi
      kind=$(key "$p" kind)
      case $kind in
        gitpile | auxiliary-gitpile) ;;
        *) say problem "$at" "config: kind is '$kind'" ;;
      esac
      [ "$(key "$p" version)" = 1 ] || say problem "$at" "config: version is not 1"
      key "$p" id | grep -Eqx '[0-9a-f]{32}' ||
        say problem "$at" "config: id is not 32 hex characters"
      name=$(key "$p" name)
      if [ -z "$name" ]; then
        say warning "$at" "no name: no link can name it"
      elif ! printf '%s' "$name" | grep -Eqx '[a-z][a-z0-9-]*'; then
        say problem "$at" "config: name '$name' is not lowercase letters, digits and hyphens"
      fi
      git ls-files --error-unmatch -- "$c" >/dev/null 2>&1 ||
        say note "$at" "the config is not committed: a clone has no such pile"
      i="$p/.pile/intent.md"
      if [ ! -e "$i" ]; then
        say problem "$at" "no intent.md: nothing says why the pile exists"
      elif [ -L "$i" ]; then
        say problem "$at" "the intent is a symbolic link"
      else
        what=$(awk '
          { s = s $0 "\n" }
          END {
            while ((i = index(s, "<!--")) > 0) {
              j = index(substr(s, i + 4), "-->")
              if (j == 0) { print "unclosed"; s = substr(s, 1, i - 1); break }
              s = substr(s, 1, i - 1) substr(s, i + 4 + j + 2)
            }
            n = split(s, line, "\n")
            for (k = 1; k <= n; k++) if (line[k] ~ /[^[:space:]]/) {
              print (line[k] ~ /^[[:space:]]*#/ ? "heading" : "prose"); exit
            }
            print "nothing"
          }
        ' "$i")
        case $what in *unclosed*) say problem "$at" "intent: a <!-- is never closed" ;; esac
        case $what in
          *nothing) say problem "$at" "intent: no headline yet, it says nothing" ;;
          *heading) say warning "$at" "intent: opens with a heading, not its headline" ;;
        esac
      fi
      for f in "$p"/.pile/* "$p"/.pile/.[!.]*; do
        [ -e "$f" ] || continue
        case ${f##*/} in config | intent.md | *.toml) ;;
          *) say note "$at" "unread file: ${f##*/}" ;; esac
      done
    done
    for k in id name; do
      for p in $(piles); do v=$(key "$p" "$k"); if [ -n "$v" ]; then echo "$v $p"; fi; done |
        sort | awk -v k="$k" '$1 == last { print k " " $1 }  { last = $1 }' | sort -u |
        while read -r _ v; do
          for p in $(piles); do
            if [ "$(key "$p" "$k")" = "$v" ]; then
              say problem "$(colon "$p")" "config: another pile has the $k $v"
            fi
          done
        done
    done
    git ls-files -co --exclude-standard -- ':(glob)**/.pile/**' |
      sed 's|/\.pile/.*||; s|^\.pile/.*|.|' | sort -u | while read -r p; do
        if [ ! -f "$p/.pile/config" ]; then
          say note "$(colon "$p")" "a .pile/ with no config: not a pile"
        fi
      done
    # Every .toml file opens with version = "gitpile/1". Every "@name" in a
    # source or target line names a pile.
    names=$(for p in $(piles); do key "$p" name; done)
    for p in $(piles); do
      for f in "$p"/.pile/*.toml; do
        [ -f "$f" ] || continue
        awk -v q="'" '
          BEGIN { re = "[\"" q "]@[^\"" q "]*[\"" q "]" }
          !seen && !/^[[:space:]]*(#|$)/ {
            seen = 1
            ok = $0 ~ /^version[[:space:]]*=[[:space:]]*"gitpile\/1"[[:space:]]*(#.*)?$/
          }
          END { if (!ok) print 0, "!version" }
          /^[[:space:]]*(source|target)[[:space:]]*=/ {
            line = $0
            while (match(line, re)) {
              print NR, substr(line, RSTART + 2, RLENGTH - 3)
              line = substr(line, RSTART + RLENGTH)
            }
          }
        ' "$f" | while read -r ln ref; do
          if [ "$ref" = "!version" ]; then
            say problem "$(colon "$p")" "${f#./}: does not open with version = \"gitpile/1\""
            continue
          fi
          printf '%s\n' "$names" | grep -qxF -- "$ref" ||
            say problem "$(colon "$p")" "${f#./}:$ln: \"@$ref\" names no pile"
        done
      done
    done
    sort -s -k1,1n "$found" | cut -c3-
    n=$(grep -c '^1 ' "$found" || true)
    total=$(piles | wc -l | tr -d ' ')
    [ "$total" -eq 1 ] && ps=pile || ps=piles
    [ "$n" -eq 1 ] && ns=problem || ns=problems
    echo "$total $ps, $n $ns." \
      "The .toml files are checked by hand, except their version line and" \
      "the \"@name\" in each source and target (reference/checks.md)."
    [ "$n" -eq 0 ] ;;
  *)
    sed -n '2,/^set -eu/s/^# \{0,1\}//p' "$self" >&2
    exit 2 ;;
esac
