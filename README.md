# `Language::Bel`, a Perl implementation of Bel

A Perl 5 implementation of Paul Graham's [Bel](http://www.paulgraham.com/bel.html).
Bel is a thoughtful Lisp, released October 2019.

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
Language::Bel 0.26 -- msys.
> (+ 2 2)
4
> (let sp " " (append "Hello" sp "world!"))
"Hello world!"
```

## State of completion

`Language::Bel` intends to be a full implementation of the Bel spec.
It's not fully there yet, though it's under active development.

[The spec](https://github.com/masak/bel/blob/master/pg/bel.bel) contains 353 items.
`Language::Bel` currently defines 113 of them.

## Contributing

If you'd like to contribute, please fork the repository and make changes as you'd like.
Pull requests are warmly welcome.

## License

This project is licensed under the GNU GPL 3.0.
For details, see [`LICENSE`](https://github.com/masak/bel/blob/master/LICENSE).