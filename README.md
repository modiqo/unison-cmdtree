# cmdtree

Declare a command line once, as a typed tree, and get everything else from it: the parser, refusals that name the
wrong word and the nearest right one, help, a Markdown page, a `Doc` for UCM and Unison Share, a JSON export for
programs in other languages, and a test of the whole command line.

```ucm
myproject/main> lib.install @conikeec/cmdtree/releases/0.1.2
```

## What it saves you

A command line has three readers: the parser turns words into values, the help tells a person what to type, and the
handlers use the values. Written in three places, they drift: the help lists an option the parser refuses, a typo
reaches a handler as a value, a subcommand works that no help mentions. With cmdtree the command line is one value,
and the parser, the help and the docs are all read from it, so they cannot disagree.

- **Wrong words never reach your code.** Every value is checked against its kind (a number, a day, one of a list, a
  span of time, JSON, or a kind of your own) before a handler runs. A wrong call is a `Refusal` value naming the
  command, the word, and, for a typo, the nearest right name.
- **Help that is always true.** Usage lines, options, arguments, subcommands and examples are rendered from the same
  value the parser walks.
- **One test for the whole command line.** `cmdtree.audit` checks that every example you wrote calls the form it
  illustrates, that a call made of each form's sample values parses back to it, that wrong calls made from each form
  are refused for the right reason, and that no two forms of a command can be confused.
- **Other languages read the same grammar.** `cmdtree.export` gives the tree as JSON, so a launcher in Rust or a
  shell completion script is built from it instead of written a second time.

## A whole program

`example/Notes.u` is a complete program: a `notes` command that lists, shows and adds notes. Its command line is
one value; here is one of its three commands, `show`, which has two forms told apart by `--last`:

```unison
showing =
  one = examples ["notes show 2"] (form [] [arg "ID" Natural "The note's number."] byId)
  newest = examples ["notes show --last 2"] (form [required (option "last" Natural "How many.")] [] last)
  command "show" "Read" "Show one note, or the newest." [] [one, newest]
```

A form's last part is what runs it, here a handler of type `cmdtree.Parsed ->{IO, Exception} ()` that reads its
values by name (`cmdtree.Parsed.nat "ID" p`). The program's `main` is the same for any tree:

```unison
cmdtree.example.main : '{IO, Exception} ()
cmdtree.example.main = do
  match cmdtree.parse cmdtree.example.notes (getArgs()) with
    Right (cmdtree.Call.Run _ _ form parsed) -> cmdtree.Form.run form parsed
    Right (cmdtree.Call.Help path) -> printLine (Optional.getOrElse "" (cmdtree.help cmdtree.example.notes path))
    Left refusal -> printLine (cmdtree.Refusal.say refusal)
```

Run with `ucm run cmdtree/main:.cmdtree.example.main -- WORDS`, it answers as below. Every line is the program's
own output (`notes` stands for the `ucm run` line):

```text
$ notes --help
notes: Keep short notes.

Read:
  list  List the notes.
  show  Show one note, or the newest.

Write:
  add  Add a note.

$ notes show --help
notes show: Show one note, or the newest.

Usage:
  notes show ID
  notes show --last NAT

Options:
  --last NAT  How many.

Arguments:
  ID  The note's number.

Examples:
  notes show 2
  notes show --last 2

$ notes show 2
Call the dentist
$ notes show --last 2
Call the dentist
Fix the bike
$ notes list -n 2 --format json
["Buy milk","Call the dentist"]
$ notes add buy bread --tag shop --tag home --pin
added: buy bread #shop #home (pinned)

$ notes lst
notes: unknown command lst; did you mean list?
$ notes show --lsat 2
notes show: unknown option --lsat; did you mean --last?
$ notes list --format xml
notes list: --format xml: it is not one of text, json
$ notes add
notes add: TEXT is required
$ notes show 2 --last 1
notes show: 2 is one word too many
$ notes show 9
no note 9
```

The last line is the handler's own refusal: `9` is a number, so the parser passed it, but there is no ninth note, so
the handler answers with `cmdtree.Refusal.NotFound "note" "9"`, said the same way.

## Test the command line

One test holds the whole tree to everything above:

```unison
test> myapp.tests.commandLine = test.verify do ensureEqual (cmdtree.audit myapp.commandLine) []
```

A failure names the form and the call, such as
``notes show (form 1): `notes show 7 --zz-none` was not refused as an unknown option``.

## The parts

| Part | What it is |
|---|---|
| `Node`, `Form`, `Flag`, `Arg` | a command, one way to call it, an option, an argument by its place |
| `command`, `form`, `option`, `switch`, `arg` | builders, with `required`, `repeated`, `short`, `rest`, `examples` |
| `Kind` | what a value is read as: text, `Nat`, `Int`, one of a list, a span, a day, JSON, or your own |
| `parse` | words to `Run path index form values`, `Help path`, or a `Refusal` |
| `Refusal`, `Refusal.say` | why a call was refused, as a value and in plain English |
| `faults`, `audit` | what is wrong with a tree; the whole test of a command line |
| `help`, `toDoc`, `markdown` | a command's help as text or as a `Doc`; every command on one Markdown page |
| `export` | the tree as JSON (`@unison/json`), each form with its synopsis |

Forms of one command are told apart by their options: one form requires an option the other does not take, as
`--last` does above. `faults` refuses a tree that breaks this, so a call never matches two forms. A call that mixes
the options of two forms is refused naming both, the option that picked one form and the option that belongs to the
other: `run: --dry goes with another form than --from-session: run --circuit TEXT [--dry]`. The word after an option
that takes a value is its value unless it names an option of the command: `--model --where` is refused as
`--model needs a value`, and `--model=--where` gives the value. Help text has one markup: a blank line between
paragraphs, and code in backticks.

## Building from source

The repository holds Unison source files: the library in `src/`, the example in `example/`, the tests in `test/`.
A build loads them into a fresh codebase that holds only the pinned dependencies (`@unison/base` 7.20.0 and
`@unison/json` 1.4.2, each pinned by its namespace hash in `tools/deps.md`):

```sh
tools/check.sh    # limits: a Unison file at most 80 source lines, no line over 120 characters
tools/build.sh    # load every file with UCM 1.5.0, then run every test
```

`tools/release.md` is the release: the same files loaded, tested, and pushed to Unison Share.

## License

Licensed under either of the [Apache License, Version 2.0](LICENSE-APACHE) or the [MIT license](LICENSE-MIT), at your
option. A contribution you submit for inclusion is licensed the same way, without any other terms or conditions.
