(define (map f lst)
  (if (null? lst)
    '()
    (cons (f (car lst)) (map f (cdr lst)))))

(define (for-each f lst)
  (map f lst)
  'for-each-completed)

(define (append lst1 lst2)
  (if (null? lst1)
    lst2
    (cons (car lst1) (append (cdr lst1) lst2))))

(define (reverse lst)
  (if (null? lst)
    '()
    (append (reverse (cdr lst)) (list (car lst)))))

(define (iota_ n)
  (if (equal? n 0)
    '()
    (cons (sub1 n) (iota_ (sub1 n)))))
(define (iota n)
  (reverse (iota_ n)))

(define (error str x)
  (display (string-append (string-append str ": ")
	   (format "~A" x)))
  (exit -1))
