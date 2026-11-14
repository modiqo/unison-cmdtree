# A release to Unison Share

Run from the repository root at a commit that passed CI, with UCM signed in to an account that may push to
`@conikeec` (`auth.login`): `rm -rf .release && tools/build.sh && ucm transcript -S .release tools/release.md`.

It clones the project from Share, so the release continues its history, with the dependencies the project already
pins (`tools/deps.md`'s hashes, checked below). It deletes the library's code and loads the files the build loads, so
what is pushed is exactly the repository's files: a definition removed from the files leaves the project too. It runs
the tests, pushes `main`, and drafts the release; the draft is published on the project's Releases page on Share.
Change the version in its two lines. (The first release, 0.1.0, had no project to clone: it was made with
`project.create-empty` and the installs of `tools/deps.md`.)

```ucm
scratch/main> clone @conikeec/cmdtree/main cmdtree/main
```

```ucm
cmdtree/main> history lib.unison_base_7_20_0
cmdtree/main> history lib.unison_json_1_4_2
cmdtree/main> delete README
cmdtree/main> delete.namespace cmdtree
cmdtree/main> load build/all.u
cmdtree/main> add
cmdtree/main> test
cmdtree/main> push @conikeec/cmdtree/main
cmdtree/main> release.draft 0.1.2
cmdtree/releases/drafts/0.1.2> push @conikeec/cmdtree/releases/drafts/0.1.2
```
