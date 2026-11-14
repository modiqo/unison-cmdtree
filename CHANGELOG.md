# Changelog

## Unreleased

## 0.1.2 — 2026-11-14

- A call that mixes the options of two forms names both options. The options given pick a form in the order given,
  each keeping the forms that take it; the first option that form does not take is refused with the option that
  picked the form: `run --circuit X --from-session S --dry` says `run: --dry goes with another form than
  --from-session: run --circuit TEXT [--dry]` (it named `--from-session` alone, the wrong option). The other form
  shown is the one, among those that take the refused option, that the options given pick.
- `Refusal.OptionOfAnotherForm` has a field more: `OptionOfAnotherForm path flag by other`, where `by` is the
  option that picked the form. A program that matches on it adds one field to the pattern.
- The word after an option that takes a value is no longer its value when it names an option of the command:
  `--model --where` is refused as `MissingValue` (`--model needs a value`), as `--model` with nothing after it is.
  A word that names no option is still a value, even one that begins with `--`, and `--model=--where` gives any
  word as the value.
- `cmdtree.Form.takes`: whether a form takes an option, by name; `cmdtree.attached` splits `--name=value`.

## 0.1.1 — 2026-11-12

- `example/Notes.u`: a whole program built with cmdtree (`cmdtree.example.main`), which the README shows running,
  and a test that holds each refusal the README quotes.
- `Refusal.say` reads plainer: `--format xml: it is not one of text, json` (was `--format takes a choice, and xml:
  …`) and `2 is one word too many` (was `2 is past the last argument`).
- The README says what the library saves a program and how to use it.

## 0.1.0 — 2026-11-12

The first release, on Unison Share as `@conikeec/cmdtree`, licensed MIT OR Apache-2.0.

- The tree: `Node`, `Form`, `Flag`, `Arg` and `Kind`, with builders (`command`, `form`, `option`, `switch`, `arg`,
  `optionalArg`, `required`, `repeated`, `short`, `rest`, `why`, `examples`).
- `parse`: subcommands first, then the command's options and arguments; `--name=value` and `--name value`, `-c`,
  `--` to end the options, `--help` and `-h` anywhere before it. A form is chosen by the options given.
- `Refusal`: unknown command or option with the nearest name, a missing subcommand, value or required option or
  argument, a bad value with why, too many arguments, an option given twice, an option of another form with its
  synopsis, and `NotFound` for a handler.
- `faults`: a tree whose forms cannot be told apart, or with any of nine other faults, is named.
- `audit`: every example calls its form, a call made of a form's samples parses back to it, and wrong calls made
  from each form are refused for the right reason.
- `help` (plain text: usage, options, arguments, subcommands by group, examples), `toDoc` (the same as a `Doc`),
  `markdown` (every command on one page, `|` escaped in its tables), `Refusal.say` (plain English) and `export`
  (the tree as JSON, version 1, each kind with a sample value and each form with its synopsis).
- The build loads every file into a codebase holding only the pinned dependencies and runs every test; CI runs it
  with UCM 1.5.0 checked against its sha256.
