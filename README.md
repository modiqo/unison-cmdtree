# cmdtree

A command line declared once, as a typed tree, for Unison. The parser, its refusals, the help and a JSON export all
come from that one value, so they cannot disagree.

Status: in development, not released. The parser, the refusals, the tree check, the audit, the help, the JSON export,
Markdown and `toDoc` are written and tested. The first release goes to Unison Share as `@modiqo/cmdtree`.

## Why a tree

A command line has three readers: the parser turns words into values, the help tells a person what to type, and the
handlers use the values. When each reads the grammar from its own place, they drift: the help lists an option the
parser refuses, or a subcommand works that no help mentions. Here the grammar is one value, and every reader is
derived from it. A program can also export it as JSON, so a program in another language (a shell completion, a
launcher written in Rust with `clap`) builds its view from the same value.

## A program in one value

```unison
notes : cmdtree.Node Text
notes =
  use cmdtree arg command examples form option required switch
  use cmdtree.Kind Natural Plain
  byId = examples ["notes show 12"] (form [] [arg "ID" Natural "The note."] "byId")
  last = examples ["notes show --last 2"] (form [required (option "last" Natural "The newest ones.")] [] "last")
  show = command "show" "Read" "Show notes." [] [byId, last]
  add = command "add" "Write" "Add a note." [] [form [switch "pin" "Keep it at the top."] [arg "TEXT" Plain ""] "add"]
  command "notes" "" "Keep notes." [add, show] []
```

`cmdtree.parse notes ["show", "--last", "2"]` gives `Right (Run ["notes", "show"] 1 form parsed)`: the path, the
form's index, the form (its `run` is whatever the program put there) and the values by name
(`cmdtree.Parsed.nat "last" parsed` is `Some 2`). A wrong call gives a `Refusal`, a value the program says in its own
words: `cmdtree.parse notes ["show", "--lsat", "2"]` is
`Left (UnknownOption ["notes", "show"] "--lsat" (Some "--last"))`. The tests hold every line of this example
(`test/Readme.u`).

## The parts

| Part | What it is |
|---|---|
| `Node`, `Form`, `Flag`, `Arg` | a command, one way to call it, an option, an argument by its place |
| `Kind` | what a value is read as: text, `Nat`, `Int`, one of a list, a span, a day, JSON, or the program's own |
| `parse` | words to `Run path index form values`, `Help path`, or a `Refusal` |
| `Refusal` | why a call was refused, naming the command, the word, and the nearest right one for a typo |
| `faults` | what is wrong with a tree: two forms a call cannot tell apart, an option with two shapes, … |
| `audit` | a program's whole test of its tree: faults, examples, a sample call of each form, wrong calls |
| `help`, `toDoc` | a command's help as plain text, or as a `Doc` for UCM and Unison Share |
| `Refusal.say` | a refusal in plain English, for a program with no words of its own |
| `export` | the tree as JSON (`@unison/json`), each form with its synopsis, for programs in other languages |
| `markdown` | the whole tree as one Markdown page |

Help text has one markup: a blank line between paragraphs, and code in backticks.

Forms of one command are told apart by their options: one form requires an option the other does not take. `faults`
refuses a tree that breaks this, so the parser never has two forms to choose between, and `clap` can express every
tree.

## Building

The repository holds Unison source files; a build loads them into a fresh codebase that holds only the pinned
dependencies (`@unison/base` 7.20.0 and `@unison/json` 1.4.2, each pinned by its namespace hash in `tools/deps.md`).

```sh
tools/check.sh    # limits: a Unison file at most 80 source lines, no line over 120 characters
tools/build.sh    # load every file in src/ and test/ with UCM 1.5.0, then run every test
```

Each source file says one thing in at most 80 lines; a definition's documentation is its `{{ }}` block.

## License

Licensed under either of the [Apache License, Version 2.0](LICENSE-APACHE) or the [MIT license](LICENSE-MIT), at your
option. A contribution you submit for inclusion is licensed the same way, without any other terms or conditions.
