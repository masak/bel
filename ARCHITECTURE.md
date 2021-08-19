Here is a high-level overview of Language::Bel's architecture:

```
bin/bel, test suite, globals generator
--------------------------------------
         Bel (the evalutaor)
--------------------------------------
      Reader, Printer, Globals
--------------------------------------
     Pair extensions, Primitives
--------------------------------------
                Core
```

From the bottom up:

* `Language::Bel::Core` contains all four basic data types, and the operations
  that act on them. These used to be spread out in different module files,
  but it was soon realized that they were all imported together, and belong
  together.
* "Pair extensions" are an open set of types which extend normal pairs, such
  as numbers, strings, and lists of characters. Their reason for existing is
  usually to speed things up while at the same time maintaining the illusion
  that nothing is different. They all reside under the `Language::Bel::Pair`
  namespace.
* `Language::Bel::Primitives` contains all the primitive function in Bel,
  those that are defined in terms of host language code instead of Bel code.
* `Language::Bel::Reader` defines the reader in Perl. It will eventually go
  away, to be replaced by a call to `read` in Bel itself.
* `Language::Bel::Printer` defines the printer in Perl. It will eventually go
  away, to be replaced by a call to `print` in Bel itself.
* `Language::Bel::Globals` is full of definitions that populate the global
  environment when Bel starts up. It might not ever go away, but maybe one
  dares hope that it could be smaller.
* The Bel evaluator, `Language::Bel`, uses most or all of the layers below,
  directly or indirectly. It will eventually go away, to be replaced by a
  call to `bel` in Bel itself.
* Finally, on the top level, three clients that use the Bel evaluator:
    * The script `bin/bel` that runs a Bel REPL or a Bel source file.
    * The test suite in `t`, mostly powered by `Language::Bel::Test` and
      `Language::Bel::Test::DSL`.
    * The module `Language::Bel::Globals::Generator`, whose job it is to
      re-generate the global definitions now and then.

