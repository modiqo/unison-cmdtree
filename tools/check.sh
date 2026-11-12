#!/bin/sh
# The repository's limits, checked without UCM:
#
#   a Unison file is at most 80 source lines (a source line is neither blank nor only a comment), so each file reads
#   in one screen and says one thing;
#   no line is wider than 120 characters (tools/deps.md and tools/release.md are left out: a namespace hash is
#   one word of 128 characters);
#   no file under src names a program that uses the library (the library is for anyone).
set -eu
cd "$(dirname "$0")/.."
fail=0
for f in $(find src example test -name '*.u' | sort); do
  n=$(grep -cvE '^[[:space:]]*(--.*)?$' "$f" || true)
  if [ "$n" -gt 80 ]; then echo "check: $f has $n source lines; at most 80" >&2; fail=1; fi
done
wide=$(find src example test tools README.md CHANGELOG.md -type f \( -name "*.u" -o -name "*.md" -o -name "*.sh" \) \
  ! -name deps.md ! -name release.md \
  -exec awk 'length > 120 { print FILENAME ":" FNR ": " length " characters" }' {} +)
if [ -n "$wide" ]; then echo "$wide" >&2; echo "check: lines over 120 characters" >&2; fail=1; fi
if grep -rniE '\bolki\b' src >/dev/null 2>&1; then
  grep -rniE '\bolki\b' src >&2; echo "check: the library names a program that uses it" >&2; fail=1
fi
[ "$fail" = 0 ] && echo "check: $(find src example test -name '*.u' | wc -l | tr -d ' ') Unison files within the limits"
exit "$fail"
