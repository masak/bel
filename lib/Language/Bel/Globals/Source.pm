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

(mac set (v e)
  `(do
     (xdr globe (cons (cons ',v ,e) (cdr globe)))
     t))

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

; we are here currently, implementing things

(def err args)

(mac comma args
  '(err 'comma-outside-backquote))

(mac comma-at args
  '(err 'comma-at-outside-backquote))

(mac splice args
  '(err 'comma-at-outside-list))
