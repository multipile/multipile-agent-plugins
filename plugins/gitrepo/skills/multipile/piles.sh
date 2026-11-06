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

nl='
'
tab=$(printf '\t')

# Paths as git lists them, one a line and unquoted, whatever they hold.
ls_files() { git ls-files -z -co --exclude-standard -- "$@" | tr '\0' '\n'; }

# Every .pile/config, from the top, and each one inside another .pile/,
# which declares nothing.
configs() { ls_files ':(glob)**/.pile/config'; }
nested() { configs | grep -E '(^|/)\.pile/(.*/)?\.pile/config$' || true; }

# Every pile's directory, from the top, `.` for the top itself.
piles() {
  configs | grep -Ev '(^|/)\.pile/(.*/)?\.pile/config$' |
    sed 's|/*\.pile/config$||; s|^$|.|' | sort
}

# Whether a directory is inside a .pile/, where a config declares nothing.
in_pile_dir() {
  case /$1/ in */.pile/*) return 0 ;; *) return 1 ;; esac
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
    if [ -f "$d/.pile/config" ] && ! in_pile_dir "$d"; then echo "$d"; return; fi
    if [ "$d" = . ]; then return; fi
    d=$(dirname "$d")
  done
}

# A pile, as @name or a path, as its directory from the top.
resolve() {
  case $1 in
    @*)
      p=$(piles | while IFS= read -r p; do
        if [ "$(key "$p" name)" = "${1#@}" ]; then echo "$p"; break; fi
      done)
      if [ -n "$p" ]; then echo "$p"; return; fi
      echo "no pile is named ${1#@}" >&2; exit 2 ;;
    *)
      p=$(plain "$1")
      if in_pile_dir "$p"; then
        echo "$(colon "$p") is not a pile: it is inside a .pile/" >&2; exit 2
      elif [ ! -f "$p/.pile/config" ]; then
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
  echo ":(literal)$1"
  under "$1" | sed 's|^|:(exclude,literal)|'
}

# Runs a git command on a pile's own files: the command, then `--` and the
# pathspecs, each one argument whatever it holds.
on_own() {
  specs=$(own "$1")
  shift
  IFS=$nl
  set -f
  # shellcheck disable=SC2086
  "$@" -- $specs
  set +f
  unset IFS
}

label() {
  n=$(key "$1" name)
  if [ -n "$n" ]; then echo "@$n  $(colon "$1")"; else colon "$1"; fi
}

cmd=${1:-}
[ $# -gt 0 ] && shift
case $cmd in
  list)
    piles | while IFS= read -r p; do label "$p"; done ;;
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
    under "$p" | while IFS= read -r c; do
      if [ "$(which_pile "$(dirname "$c")")" = "$p" ]; then echo "child: $(label "$c")"; fi
    done
    for f in "$p"/.pile/*; do
      case $f in */config | */intent.md) ;; *) if [ -f "$f" ]; then echo "also: $(colon "${f#./}")"; fi ;; esac
    done
    last=$(git log -1 --format=%H -- "$p/.pile/intent.md")
    if [ -n "$last" ]; then
      n=$(on_own "$p" git rev-list --count "$last..HEAD")
      echo "written: $n commits have changed the pile since its intent"
    else
      echo "written: the intent is not committed"
    fi
    echo "== intent"
    cat "$p/.pile/intent.md" 2>/dev/null || echo "(no intent.md)" ;;
  files)
    p=$(resolve "$1")
    on_own "$p" ls_files | sed 's|^|:/|' ;;
  log)
    p=$(resolve "$1")
    shift
    on_own "$p" git log "$@" ;;
  status)
    # With -z, git quotes no path, and a rename's old path follows its new one.
    git status --porcelain=v1 -z --untracked-files=all | tr '\0' '\n' |
      awk '
        from { print xy "\t" path "\t" $0; from = 0; next }
        { xy = substr($0, 1, 2); path = substr($0, 4) }
        xy ~ /[RC]/ { from = 1; next }
        { print xy "\t" path "\t" }
      ' | while IFS=$tab read -r xy path was; do
        p=$(which_pile "$path")
        if [ -n "$was" ]; then what="$xy :/$was -> :/$path"; else what="$xy :/$path"; fi
        if [ -n "$p" ]; then echo "$(label "$p")	$what"
        else echo "(in no pile)	$what"; fi
      done | sort ;;
  id)
    od -An -tx1 -N16 /dev/urandom | tr -d ' \n'
    echo ;;
  check)
    found=$(mktemp)
    list=$(mktemp)
    trap 'rm -f "$found" "$list"' EXIT
    piles >"$list"
    say() {
      case $1 in problem) o=1 ;; warning) o=2 ;; *) o=3 ;; esac
      printf '%s %-8s %s  %s\n' "$o" "$1" "$2" "$3" >>"$found"
    }
    while IFS= read -r p; do
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
    done <"$list"
    for k in id name; do
      while IFS= read -r p; do
        v=$(key "$p" "$k")
        if [ -n "$v" ]; then printf '%s\t%s\n' "$v" "$p"; fi
      done <"$list" |
        awk -F '\t' '{ v[NR] = $1; p[NR] = $2; n[$1]++ }
          END { for (i = 1; i <= NR; i++) if (n[v[i]] > 1) print v[i] "\t" p[i] }' |
        while IFS=$tab read -r v p; do
          say problem "$(colon "$p")" "config: another pile has the $k $v"
        done
    done
    nested | while IFS= read -r c; do
      say problem "$(colon "${c%/.pile/config}")" \
        "a .pile/config inside another .pile/ declares nothing: move it"
    done
    ls_files ':(glob)**/.pile/**' |
      sed 's|^\.pile/.*|.|; s|/\.pile/.*||' | sort -u | while IFS= read -r p; do
        if [ ! -f "$p/.pile/config" ]; then
          say note "$(colon "$p")" "a .pile/ with no config: not a pile"
        fi
      done
    # Every .toml file opens with version = "gitpile/1". Every "@name" in a
    # source or target line is in double quotes, and names a pile.
    names=$(while IFS= read -r p; do key "$p" name; done <"$list")
    while IFS= read -r p; do
      for f in "$p"/.pile/*.toml; do
        [ -f "$f" ] || continue
        awk -v q="'" '
          !seen && !/^[[:space:]]*(#|$)/ {
            seen = 1
            ok = $0 ~ /^version[[:space:]]*=[[:space:]]*"gitpile\/1"[[:space:]]*(#.*)?$/
          }
          END { if (!ok) print 0, "!version" }
          /^[[:space:]]*(source|target)[[:space:]]*=/ {
            if (index($0, q "@")) print NR, "!single"
            line = $0
            while (match(line, /"@[^"]*"/)) {
              print NR, substr(line, RSTART + 2, RLENGTH - 3)
              line = substr(line, RSTART + RLENGTH)
            }
          }
        ' "$f" | while read -r ln ref; do
          case $ref in
            !version)
              say problem "$(colon "$p")" "${f#./}: does not open with version = \"gitpile/1\"" ;;
            !single)
              say problem "$(colon "$p")" "${f#./}:$ln: a reference in single quotes: write it in double quotes" ;;
            *)
              printf '%s\n' "$names" | grep -qxF -- "$ref" ||
                say problem "$(colon "$p")" "${f#./}:$ln: \"@$ref\" names no pile" ;;
          esac
        done
      done
    done <"$list"
    sort -s -k1,1n "$found" | cut -c3-
    n=$(grep -c '^1 ' "$found" || true)
    total=$(wc -l <"$list" | tr -d ' ')
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
