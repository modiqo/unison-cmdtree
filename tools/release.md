# A release to Unison Share

Run from the repository root at a commit that passed CI, with UCM signed in to an account that may push to
`@conikeec` (`auth.login`): `rm -rf .release && tools/build.sh && ucm transcript -S .release tools/release.md`. It
loads the same files the build loads into a codebase of its own, runs the tests, pushes `main`, and drafts the
release named below; the draft is published on the project's page on Share. Change the version in both lines.

```ucm
scratch/main> project.create-empty cmdtree
cmdtree/main> lib.install @unison/base/releases/7.20.0
cmdtree/main> lib.install @unison/json/releases/1.4.2
cmdtree/main> delete.namespace lib.unison_base_7_20_0
cmdtree/main> fork #e6omqhuko7mr7usqp79ifs7gb1eabl1g7jbevd0l47ngvh6i47944glea2juqig30djumik9jkedssua9f2hi6ip5jg4bg2jup2vfv8 lib.unison_base_7_20_0
cmdtree/main> delete.namespace lib.unison_json_1_4_2
cmdtree/main> fork #js5o8plfinkmgsovi24hh2ddn46v94mnm4sirvrdtmcd5of1t7tembll9fbg9tlghlm2iglorj3mfborle06cbjkhbmb7uloe8uq170 lib.unison_json_1_4_2
cmdtree/main> load build/all.u
cmdtree/main> add
cmdtree/main> test
cmdtree/main> push @conikeec/cmdtree/main
cmdtree/main> release.draft 0.1.1
cmdtree/releases/drafts/0.1.1> push @conikeec/cmdtree/releases/drafts/0.1.1
```
