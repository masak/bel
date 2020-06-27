# `Language::Bel`, a Perl implementation of Bel [![Build Status](https://secure.travis-ci.org/masak/bel.svg?branch=master)](http://travis-ci.org/masak/bel)

A Perl 5 implementation of Paul Graham's [Bel](http://www.paulgraham.com/bel.html).
Bel is a self-hosting Lisp dialect, released October 2019.

## Installation

You need [Perl](https://www.perl.org/get.html) installed.

Only possible to install `Language::Bel` through GitHub right now.

```sh
$ git clone https://github.com/masak/bel.git
$ cd bel
```

At some point soon, I'll also upload this distribution to CPAN.
Then you'll be able to install it using a CPAN installer, such as `cpanm`.

After downloading Bel, you can run it like this:

```sh
$ perl -Ilib bin/bel
Language::Bel 0.34 -- msys.
> (+ 2 2)
4
> (append "Hello" '(\sp) "world!")
"Hello world!"
```

## State of completion

`Language::Bel` intends to be a complete implementation of the Bel spec.
It's not fully there yet, though it's under active development.

[The spec](https://github.com/masak/bel/blob/master/pg/bel.bel) contains 353 items.
`Language::Bel` currently defines 237 of them.

![237 of 353 definitions](images/definitions.svg)

A summary of the remaining big features:

* **Streams** are opaque objects created by the runtime when a file is opened
  for reading or writing. They read and write individual bits. Primarily I would like
  to mock everything to do with streams in the tests &mdash; but it might make sense
  to have an integration test file that uses real streams and real files, too.

* **ccc** (or `call-with-current-continuation`) is a control mechanism that allows the
  program to save a point in the execution, and to return to that point again later.
  Saving the execution state means saving the current evaluation stack, and being able
  to reinstate it when a continuation is invoked. The current Perl implementation uses
  a mutable Perl array for the evaluation stack, instead of a persistent Bel list; this
  means that unlike the Bel implementation of the evaluator, the Perl implementation
  has to defensively copy the whole stack both when taking the continuation and when
  invoking it. (Either that, or we modify the Perl evaluator to use a persistent
  Bel list too.)

* **Threads** (so called "green threads") allow execution of different evaluation
  stacks to be interleaved and executed in "round-robin" style. Therefore, threads
  can be seen as "parallel execution contexts". Dynamic and lexical variables are
  local to a thread; global variables are shared between all threads. It's possible
  to prevent the scheduler from de-scheduling the current thread by binding the
  dynamic `lock` variable. Failing to do this might result in unexpected interactions
  between threads. The concurrency is "co-operative", which means that any thread
  could block the others forever by never releasing the lock.

* **Evaluator**; there's a Bel evaluator written in Perl already. It hard-codes a
  number of behaviors that shouldn't be hard-coded, most of all _itself_. In Bel,
  any part of the evaluator could be overridden by a new function, at which point it
  takes effect immediately. In the long run, the Bel evaluator will replace the Perl
  evaluator. We might be able to write tests for parts of the Bel evaluator by
  intercepting the recursive call to `mev` inside of it.

* **Reader**; there's a reader written in Perl already. It hard-codes the syntactic
  forms it recognizes; these should in fact be extensible.

* **Backquotes** (or "quasiquoting"); there's a backquote expander written in Perl
  already. It runs earlier than it should. (It runs right after reading, before
  evaluation. It should run as a normal macro, and then be evaluated. There must be
  a conformance test that could expose this difference.) The main difficulty in
  getting rid of the Perl version and running backquotes in Bel is that the
  definition of the backquotes macro relies on working backquotes.

* **Printer**; there's a printer written in Perl already. It's largely
  feature-complete, but just like the evaluator and reader, it's not extensible
  enough. It also doesn't handle cyclic structures and named pairs, although it
  could do that.

* **chars**; this global definition contains a very long Bel list of charater
  encodings. Although it would be feasible to build the entire list
  for millions of characters in memory (or to compromise and only build it for,
  say the Latin-1 subset or characters), probably a saner approach would be to
  generate this list on-demand. (Edit: Actually trying this reveals that it is
  too slow to be practical. Recursing down this list totally kills performance,
  and also fills the memory with pairs. It's _necessary_ to intercept the `nchar`
  and `charn` functions, and do something more efficient than a linear scan.)

## Contributing

If you'd like to contribute, please fork the repository and make changes as you'd like.
Pull requests are warmly welcome.

## License

This project is licensed under the GNU GPL 3.0.
For details, see [`LICENSE`](https://github.com/masak/bel/blob/master/LICENSE).
