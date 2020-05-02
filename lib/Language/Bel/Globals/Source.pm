package Language::Bel::Globals::Source;

use 5.006;
use strict;
use warnings;

1;
__DATA__
(def no (x)
  (id x nil))

(def atom (x)
  (no (id (type x) 'pair)))

(def all (f xs)
  (if (no xs)      t
      (f (car xs)) (all f (cdr xs))
                   nil))

(def some (f xs)
  (if (no xs)      nil
      (f (car xs)) xs
                   (some f (cdr xs))))

(def reduce (f xs)
  (if (no (cdr xs))
      (car xs)
      (f (car xs) (reduce f (cdr xs)))))

(def cons args
  (reduce join args))

(def append args
  (if (no (cdr args)) (car args)
      (no (car args)) (apply append (cdr args))
                      (cons (car (car args))
                            (apply append (cdr (car args))
                                          (cdr args)))))

(def snoc args
  (append (car args) (cdr args)))

(def list args
  (append args nil))

(def map (f . ls)
  (if (no ls)       nil
      (some no ls)  nil
      (no (cdr ls)) (cons (f (car (car ls)))
                          (map f (cdr (car ls))))
                    (cons (apply f (map car ls))
                          (apply map f (map cdr ls)))))

(mac fn (parms . body)
  (if (no (cdr body))
    `(list 'lit 'clo scope ',parms ',(car body))
    `(list 'lit 'clo scope ',parms '(do ,@body))))

(set vmark (join))

(def uvar ()
  (list vmark))

(mac do args
  (reduce (fn (x y)
            (list (list 'fn (uvar) y) x))
          args))

(mac let (parms val . body)
  `((fn (,parms) ,@body) ,val))

(mac macro args
  `(list 'lit 'mac (fn ,@args)))

(mac def (n . rest)
  `(set ,n (fn ,@rest)))

(mac mac (n . rest)
  `(set ,n (macro ,@rest)))

(mac or args
  (if (no args)
      nil
      (let v (uvar)
        `(let ,v ,(car args)
           (if ,v ,v (or ,@(cdr args)))))))

(mac and args
  (reduce (fn es (cons 'if es))
          (or args '(t))))

(def = args
  (if (no (cdr args))  t
      (some atom args) (all [id _ (car args)] (cdr args))
                       (and (apply = (map car args))
                            (apply = (map cdr args)))))

(def symbol (x) (= (type x) 'symbol))

(def pair   (x) (= (type x) 'pair))

(def char   (x) (= (type x) 'char))

; not doing `stream` right now; waiting until we have streams

(def proper (x)
  (or (no x)
      (and (pair x) (proper (cdr x)))))

(def string (x)
  (and (proper x) (all char x)))

(def mem (x ys (o f =))
  (some [f _ x] ys))

(def in (x . ys)
  (mem x ys))

(def cadr  (x) (car (cdr x)))

(def cddr  (x) (cdr (cdr x)))

(def caddr (x) (car (cddr x)))

(mac case (expr . args)
  (if (no (cdr args))
      (car args)
      (let v (uvar)
        `(let ,v ,expr
           (if (= ,v ',(car args))
               ,(cadr args)
               (case ,v ,@(cddr args)))))))

(mac iflet (var . args)
  (if (no (cdr args))
      (car args)
      (let v (uvar)
        `(let ,v ,(car args)
           (if ,v
               (let ,var ,v ,(cadr args))
               (iflet ,var ,@(cddr args)))))))

(mac aif args
  `(iflet it ,@args))

(def find (f xs)
  (aif (some f xs) (car it)))

(def begins (xs pat (o f =))
  (if (no pat)               t
      (atom xs)              nil
      (f (car xs) (car pat)) (begins (cdr xs) (cdr pat) f)
                             nil))

(def caris (x y (o f =))
  (begins x (list y) f))

(def hug (xs (o f list))
  (if (no xs)       nil
      (no (cdr xs)) (list (f (car xs)))
                    (cons (f (car xs) (cadr xs))
                          (hug (cddr xs) f))))

(mac with (parms . body)
  (let ps (hug parms)
    `((fn ,(map car ps) ,@body)
      ,@(map cadr ps))))

(def keep (f xs)
  (if (no xs)      nil
      (f (car xs)) (cons (car xs) (keep f (cdr xs)))
                   (keep f (cdr xs))))

(def rem (x ys (o f =))
  (keep [no (f _ x)] ys))

(def get (k kvs (o f =))
  (find [f (car _) k] kvs))

(def put (k v kvs (o f =))
  (cons (cons k v)
        (rem k kvs (fn (x y) (f (car x) y)))))

(def rev (xs)
  (if (no xs)
      nil
      (snoc (rev (cdr xs)) (car xs))))

(def snap (xs ys (o acc))
  (if (no xs)
      (list acc ys)
      (snap (cdr xs) (cdr ys) (snoc acc (car ys)))))

(def udrop (xs ys)
  (cadr (snap xs ys)))

(def idfn (x)
  x)

(def is (x)
  [= _ x])

; skipping `eif`, `onerr`, `safe`; these require overriding `err` dynamically, and `ccc`

(def literal (e)
  (or (in e t nil o apply)
      (in (type e) 'char 'stream)
      (caris e 'lit)
      (string e)))

(def variable (e)
  (if (atom e)
      (no (literal e))
      (id (car e) vmark)))

(def isa (name)
  [begins _ `(lit ,name) id])

; skipping the evaluator for now

(set virfns nil)

(mac vir (tag . rest)
  `(set virfns (put ',tag (fn ,@rest) virfns)))

; back to skipping the evaluator

(def function (x)
  (find [(isa _) x] '(prim clo)))

(def con (x)
  (fn args x))

(def compose fs
  (reduce (fn (f g)
            (fn args (f (apply g args))))
          (or fs (list idfn))))

(def combine (op)
  (fn fs
    (reduce (fn (f g)
              (fn args
                (op (apply f args) (apply g args))))
            (or fs (list (con (op)))))))

(set cand (combine and)
     cor  (combine or))

(def foldl (f base . args)
  (if (or (no args) (some no args))
      base
      (apply foldl f
                   (apply f (snoc (map car args) base))
                   (map cdr args))))

(def foldr (f base . args)
  (if (or (no args) (some no args))
      base
      (apply f (snoc (map car args)
                     (apply foldr f base (map cdr args))))))

(def of (f g)
  (fn args (apply f (map g args))))

(def upon args
  [apply _ args])

(def pairwise (f xs)
  (or (no (cdr xs))
      (and (f (car xs) (cadr xs))
           (pairwise f (cdr xs)))))

(def fuse (f . args)
  (apply append (apply map f args)))

(mac letu (v . body)
  (if ((cor variable atom) v)
      `(let ,v (uvar) ,@body)
      `(with ,(fuse [list _ '(uvar)] v)
         ,@body)))

(mac pcase (expr . args)
  (if (no (cdr args))
      (car args)
      (letu v
        `(let ,v ,expr
           (if (,(car args) ,v)
               ,(cadr args)
               (pcase ,v ,@(cddr args)))))))

(def match (x pat)
  (if (= pat t)                t
      (function pat)           (pat x)
      (or (atom x) (atom pat)) (= x pat)
                               (and (match (car x) (car pat))
                                    (match (cdr x) (cdr pat)))))

(def split (f xs (o acc))
  (if ((cor atom f:car) xs)
      (list acc xs)
      (split f (cdr xs) (snoc acc (car xs)))))

(mac when (expr . body)
  `(if ,expr (do ,@body)))

(mac unless (expr . body)
  `(when (no ,expr) ,@body))

(set i0  nil
     i1  '(t)
     i2  '(t t)
     i10 '(t t t t t t t t t t)
     i16 '(t t t t t t t t t t t t t t t t))

(set i< udrop)

(def i+ args
  (apply append args))

(def i- (x y)
  (if (no x) (list '- y)
      (no y) (list '+ x)
             (i- (cdr x) (cdr y))))

(def i* args
  (foldr (fn (x y) (fuse (con x) y))
         i1
         args))

(def i/ (x y (o q))
  (if (no x)   (list q nil)
      (i< x y) (list q x)
               (i/ (udrop y x) y (i+ q i1))))

(def i^ (x y)
  (foldr i* i1 (map (con x) y)))

(def r+ ((xn xd) (yn yd))
  (list (i+ (i* xn yd) (i* yn xd))
        (i* xd yd)))

(def r- ((xn xd) (yn yd))
  (let (s n) (i- (i* xn yd) (i* yn xd))
    (list s n (i* xd yd))))

(def r* ((xn xd) (yn yd))
  (list (i* xn yn) (i* xd yd)))

(def r/ ((xn xd) (yn yd))
  (list (i* xn yd) (i* xd yn)))

(set srzero (list '+ i0 i1)
     srone  (list '+ i1 i1))

(def sr+ ((xs . xr) (ys . yr))
  (if (= xs '-)
      (if (= ys '-)
          (cons '- (r+ xr yr))
          (r- yr xr))
      (if (= ys '-)
          (r- xr yr)
          (cons '+ (r+ xr yr)))))

(def sr- (x y)
  (sr+ x (srinv y)))

(def srinv ((s n d))
  (list (if (and (= s '+) (~= n i0)) '- '+)
        n
        d))

(def sr* ((xs . xr) (ys . yr))
  (cons (if (= xs '-)
            (case ys - '+ '-)
            ys)
        (r* xr yr)))

(def sr/ (x y)
  (sr* x (srrecip y)))

(def srrecip ((s (t n [~= _ i0]) d))
  (list s d n))

(def sr< ((xs xn xd) (ys yn yd))
  (if (= xs '+)
      (if (= ys '+)
          (i< (i* xn yd) (i* yn xd))
          nil)
      (if (= ys '+)
          (~= xn yn i0)
          (i< (i* yn xd) (i* xn yd)))))

(set srnum cadr
     srden caddr)

(def c+ ((xr xi) (yr yi))
  (list (sr+ xr yr) (sr+ xi yi)))

(def c* ((xr xi) (yr yi))
  (list (sr- (sr* xr yr) (sr* xi yi))
        (sr+ (sr* xi yr) (sr* xr yi))))

(def litnum (r (o i srzero))
  (list 'lit 'num r i))

(def number (x)
  (let r (fn (y)
           (match y (list [in _ '+ '-] proper proper)))
    (match x `(lit num ,r ,r))))

(set numr car:cddr
     numi cadr:cddr)

(set rpart litnum:numr
     ipart litnum:numi)

(def real (x)
  (and (number x) (= (numi x) srzero)))

(def inv (x)
  (litnum (srinv:numr x) (srinv:numi x)))

(def abs (x)
  (litnum (cons '+ (cdr (numr x)))))

(def simplify ((s n d))
  (if (= n i0) (list '+ n i1)
      (= n d)  (list s i1 i1)
               (let g (apply i* ((of common factor) n d))
                 (list s (car:i/ n g) (car:i/ d g)))))

(def factor (x (o d i2))
  (if (i< x d)
      nil
      (let (q r) (i/ x d)
        (if (= r i0)
            (cons d (factor q d))
            (factor x (i+ d i1))))))

(def common (xs ys)
  (if (in nil xs ys)
      nil
      (let (a b) (split (is (car xs)) ys)
        (if b
            (cons (car xs)
                  (common (cdr xs) (append a (cdr b))))
            (common (cdr xs) ys)))))

(set buildnum (of litnum simplify))

(def recip (x)
  (with (r (numr x)
         i (numi x))
    (let d (sr+ (sr* r r) (sr* i i))
      (buildnum (sr/ r d)
                (sr/ (srinv i) d)))))

(def + ns
  (foldr (fn (x y)
           (apply buildnum ((of c+ cddr) x y)))
         0
         ns))

(def - ns
  (if (no ns)       0
      (no (cdr ns)) (inv (car ns))
                    (+ (car ns) (inv (apply + (cdr ns))))))

(def * ns
  (foldr (fn (x y)
           (apply buildnum ((of c* cddr) x y)))
         1
         ns))

(def / ns
  (if (no ns)
      1
      (* (car ns) (recip (apply * (cdr ns))))))

(def inc (n) (+ n 1))

(def dec (n) (- n 1))

(def pos (x ys (o f =))
  (if (no ys)        nil
      (f (car ys) x) 1
                     (aif (pos x (cdr ys) f) (+ it 1))))

(def len (xs)
  (if (no xs) 0 (inc:len:cdr xs)))

(def charn (c)
  (dec:pos c chars caris))

(def < args
  (pairwise bin< args))

(def > args
  (apply < (rev args)))

(def list< (x y)
  (if (no x) y
      (no y) nil
             (or (< (car x) (car y))
                 (and (= (car x) (car y))
                      (< (cdr x) (cdr y))))))

(def bin< args
  (aif (all no args)                    nil
       (find [all (car _) args] comfns) (apply (cdr it) args)
                                        (err 'incomparable)))

(set comfns nil)

(def com (f g)
  (set comfns (put f g comfns)))

(com real (of sr< numr))

(com char (of < charn))

(com string list<)

(com symbol (of list< nom))

(def int (n)
  (and (real n) (= (srden:numr n) i1)))

(def whole (n)
  (and (int n) (~< n 0)))

(def pint (n)
  (and (int n) (> n 0)))

(def yc (f)
  ([_ _] [f (fn a (apply (_ _) a))]))

(mac rfn (name . rest)
  `(yc (fn (,name) (fn ,@rest))))

(mac afn args
  `(rfn self ,@args))

(def wait (f)
  ((afn (v) (if v v (self (f))))
   (f)))

(def runs (f xs (o fon (and xs (f (car xs)))))
  (if (no xs)
      nil
      (let (as bs) (split (if fon ~f f) xs)
        (cons as (runs f bs (no fon))))))

(def whitec (c)
  (in c \sp \lf \tab \cr))

(def tokens (xs (o break whitec))
  (let f (if (function break) break (is break))
    (keep ~f:car (runs f xs))))

(def dups (xs (o f =))
  (if (no xs)                   nil
      (mem (car xs) (cdr xs) f) (cons (car xs)
                                      (dups (rem (car xs) (cdr xs) f) f))
                                (dups (cdr xs) f)))

(set simple (cor atom number))

(mac do1 args
  (letu v
    `(let ,v ,(car args)
       ,@(cdr args)
       ,v)))

(def gets (v kvs (o f =))
  (find [f (cdr _) v] kvs))

(def consif (x y)
  (if x (cons x y) y))

(mac check (x f (o alt))
  (letu v
    `(let ,v ,x
       (if (,f ,v) ,v ,alt))))

(mac withs (parms . body)
  (if (no parms)
      `(do ,@body)
      `(let ,(car parms) ,(cadr parms)
         (withs ,(cddr parms) ,@body))))

(mac bind (var expr . body)
  `(dyn ,var ,expr (do ,@body)))

(mac atomic body
  `(bind lock t ,@body))

(def tail (f xs)
  (if (no xs) nil
      (f xs)  xs
              (tail f (cdr xs))))

(set dock rev:cdr:rev)

(def lastcdr (xs)
  (if (no (cdr xs))
      xs
      (lastcdr (cdr xs))))

(set last car:lastcdr)

(def newq ()
  (list nil))

(def enq (x q)
  (atomic (xar q (snoc (car q) x)))
  q)

(def deq (q)
  (atomic (do1 (car (car q))
               (xar q (cdr (car q))))))

(mac set args
  (cons 'do
        (map (fn ((p (o e t)))
               (letu v
                 `(atomic (let ,v ,e
                            (let (cell loc) (where ,p t)
                              ((case loc a xar d xdr) cell ,v))))))
             (hug args))))

(mac zap (op place . args)
  (letu (vo vc vl va)
    `(atomic (with (,vo       ,op
                    (,vc ,vl) (where ,place)
                    ,va       (list ,@args))
               (case ,vl
                 a (xar ,vc (apply ,vo (car ,vc) ,va))
                 d (xdr ,vc (apply ,vo (cdr ,vc) ,va))
                   (err 'bad-place))))))

(mac ++ (place (o n 1))
  `(zap + ,place ,n))

(mac -- (place (o n 1))
  `(zap - ,place ,n))

(mac push (x place)
  (letu v
    `(let ,v ,x
       (zap [cons ,v _] ,place))))

(mac pull (x place . rest)
  (letu v
    `(let ,v ,x
       (zap [rem ,v _ ,@rest] ,place))))

; we are here currently, implementing things

(def drop (n xs)    ; n|whole xs
  (if (= n 0)
      xs
      (drop (- n 1) (cdr xs))))

(def nth (n|pint xs|pair)
  (if (= n 1)
      (car xs)
      (nth (- n 1) (cdr xs))))

(vir num (f args)
  `(nth ,f ,@args))

; skip

(mac pop (place)
  `(let (cell loc) (where ,place)
     (let xs ((case loc a car d cdr) cell)
       ((case loc a xar d xdr) cell (cdr xs))
       (car xs))))

; skip

(def err args)

(mac comma args
  '(err 'comma-outside-backquote))

(mac comma-at args
  '(err 'comma-at-outside-backquote))

(mac splice args
  '(err 'comma-at-outside-list))
