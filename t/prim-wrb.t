#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set bang-bits "00100001")
"00100001"

> (do (each c bang-bits
        (wrb c nil))
      (pr \lf)
      '(ignore return value))
!
(ignore return value)

> (set hello-bits (append "01101000"        ; h
                          "01100101"        ; e
                          "01101100"        ; l
                          "01101100"        ; l
                          "01101111"))      ; o
"0110100001100101011011000110110001101111"

> (set f (ops "temp9283" 'out))
<stream>

> (each c hello-bits
    (wrb c f))
!IGNORE: result of `each`

> (cls f)
<stream>

> (set f (ops "temp9283" 'in)
       read-bits '())
nil

> (til b (rdb f) (= b 'eof)
    (push b read-bits))
nil

> (cls f)
<stream>

> (= hello-bits (rev read-bits))
t

!END: unlink("temp9283");

