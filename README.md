# `Language::Bel`

![CI](https://github.com/masak/bel/workflows/CI/badge.svg)

A Perl 5 implementation of Paul Graham's [Bel](http://www.paulgraham.com/bel.html).
Bel is a self-hosting Lisp dialect, released October 2019.

There are many Lisp dialects in the world, but Bel distinguishes itself by
defining a complete stack of features on a metacircular foundation.
That includes the evaluator, the reader and printer, but also I/O, error
handling, and a numeric tower; these are all specified as Bel code in the
language itself. Bel is built on top of Bel; that's true of the language's
specification, and increasingly true of this implementation.

## Getting started

You need [Perl](https://www.perl.org/get.html) installed.

Right now, the way to install and run `Language::Bel` is via GitHub.

```sh
$ git clone https://github.com/masak/bel.git
Cloning into 'bel'...
[...]
done.
```

At some point soon, I'll also upload this distribution to CPAN.
Then you'll be able to install it using a CPAN installer, such as `cpanm`.

## Usage

After downloading Bel, you can run it like this:

```sh
$ perl -Ilib bin/bel
Language::Bel 0.64 -- darwin.
>
> ;; loops
> (set n (len (apply append prims)))
16
> (each word `(there are ,n primitives) (prn word))
there
are
16
primitives
(there are 16 primitives)
>
> ;; sorting and de-duplication
> (sort < '(3 2 8 6 18 12 2 19 13 19))
(2 2 3 6 8 12 13 18 19 19)
> (dedup (sort < '(3 2 8 6 18 12 2 19 13 19)))
(2 3 6 8 12 13 18 19)
>
> ;; templates and places
> (tem vec2d x 0 y 0)
((x lit clo nil nil 0) (y lit clo nil nil 0))
> (set robot (make vec2d))
(lit tab (x . 0) (y . 0))
> robot!y
0
> (zap [+ 5 _] robot!y)
5
> robot!y
5
> (++ robot!y)
6
> ((of list robot) 'x 'y)
(0 6)
>
> ;; arrays
> (set I (array '(3 3) 0))
(lit arr (lit arr 0 0 0) (lit arr 0 0 0) (lit arr 0 0 0))
> (def diag (m n) (m n n))
> (for n 1 3 (set (diag I n) 1))
nil
> I
(lit arr (lit arr 1 0 0) (lit arr 0 1 0) (lit arr 0 0 1))
```

## But is it feature-complete?

`Language::Bel` implements all of the global definitions from [the
specification](https://github.com/masak/bel/blob/master/pg/bel.bel).

However, there are still some non-negotiable features still waiting to be
completed:

* **Unicode**. The built-in `chars` global needs to be able to recognize
  unicode codepoints, not just ASCII. Source files and strings ought to
  be treated as being UTF-8-encoded by default.

* **Error messages**. A runtime error can usually be traced back to a
  specific point in source code, and given ample context and explanation.
  The goal is to give an account of what went wrong, in full sentences,
  and also to suggest what can be done to fix the problem. (Elm serves as
  the inspiration here.) Currently, an error consists of only one symbol,
  such as `mistype`.

* **Debugging**. The turnaround between authoring and running a program
  should be made as small as possible; specifically, when an error does
  happen, the REPL should put itself in a debugging mode where it's not
  only easy to inspect the current state of the program (including local
  variables and the stack) but also to modify things and resume without
  having to restart the whole program execution.

* **Printer bootstrap**. The Perl printer should be replaced by the Bel
  printer. When globals associated with the Bel printer are replaced, the
  effects on printing should be immediate.

* **Reader bootstrap**. The Perl reader should be replaced by the Bel
  reader. When globals associated with the Bel reader are replaced, the
  effects on reading should be immediate.

* **Evaluator boostrap**. The Perl code that evaluates Bel programs (that
  is, large parts of the module `Language::Bel` itself) should be replaced
  by the Bel evaluator `bel` from the Bel globals. By default, this new
  evaluator should be able to run at speeds comparable to the current Perl
  evaluator. When globals associated with the Bel evaluator are replaced,
  the effects on evaluation should be evident as soon as a `(bootstrap)`
  call is made.

* **Performance**. Everything needs to be faster. As a first step, there
  should be a set of concrete performance goals to aim for, maybe ten or
  so. These will almost certainly be achieved via compilation to a dedicated
  bytecode format.

* **Documentation**. The language needs to be thoroughly described, both at
  a high level with general concepts and techniques, and at a lower level
  with a complete reference of all the built-in functions and types. Some
  tradeoffs and design decisions of this particular implementation (yes,
  there are a few) need to be explained as well.

## Contributing

If you'd like to contribute, please fork the repository and make changes as you'd like.
Pull requests are warmly welcome.

## License and copyright

This software is Copyright (c) 2019-2022 by Carl Mäsak.

This project is licensed under the GNU GPL 3.0.
For details, see [`LICENSE`](https://github.com/masak/bel/blob/master/LICENSE).
