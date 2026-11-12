#!/bin/sh
# Load every source and test file into a codebase that holds only the pinned dependencies, then run every test.
#
#   tools/build.sh          build and test; exit 1 on a load error or a failing test
#
# The dependencies are installed once into .codebase by tools/deps.md and never changed after: each build forks that
# codebase (transcript.fork), so nothing from an earlier build can be left behind in it. Delete .codebase to install
# the dependencies again, as after a change to tools/deps.md.
set -eu
cd "$(dirname "$0")/.."
want="release/1.5.0"
have=$(ucm --version 2>/dev/null | sed -n 's/.*version: \([^ ]*\).*/\1/p')
[ "$have" = "$want" ] || { echo "build: needs UCM $want, found ${have:-none}" >&2; exit 1; }
mkdir -p build
if [ ! -d .codebase ] || [ tools/deps.md -nt .codebase/deps.stamp ]; then
  rm -rf .codebase
  cp tools/deps.md build/deps.md
  ucm transcript -S .codebase build/deps.md > build/deps.log 2>&1 || {
    echo "build: installing the dependencies failed; see build/deps.log and build/deps.output.md" >&2; exit 1; }
  touch .codebase/deps.stamp
fi
# One file, sources first and tests after, each in path order: UCM resolves names within one load in any order.
: > build/all.u
for f in $(find src test -name '*.u' | sort); do
  printf -- '-- %s\n' "$f" >> build/all.u
  cat "$f" >> build/all.u
  printf '\n' >> build/all.u
done
cat > build/build.md <<'EOF'
```ucm
cmdtree/main> load build/all.u
cmdtree/main> add
cmdtree/main> test
```
EOF
# A failing test stops the transcript as a load error does; the output says which.
rm -f build/build.output.md
if ucm transcript.fork -c .codebase build/build.md > build/build.log 2>&1; then ok=1; else ok=0; fi
# A failed transcript keeps its forked codebase in the temporary folder for a look; this build has no use for it.
kept=$(sed -n 's/.*unison --codebase \([^`]*\)`.*/\1/p' build/build.log | tail -1)
case $kept in "${TMPDIR:-/tmp}"*/transcript-*|/tmp/transcript-*|/var/folders/*/transcript-*) rm -rf "$kept" ;; esac
if grep -q 'test(s) failing' build/build.output.md 2>/dev/null; then
  echo "build: a test failed; see build/build.output.md" >&2
  grep -B1 -A3 '✗' build/build.output.md >&2 || true
  exit 1
fi
if [ "$ok" = 0 ]; then
  echo "build: the load failed; see build/build.output.md" >&2
  sed -n '/The error is:/,$p' build/build.output.md >&2 2>/dev/null || tail -20 build/build.log >&2
  exit 1
fi
passed=$(sed -n 's/.*✅ \([0-9]*\) test(s) passing.*/\1/p' build/build.output.md | tail -1)
echo "build: $(find src -name '*.u' | wc -l | tr -d ' ') source files, ${passed:-0} tests passing"
