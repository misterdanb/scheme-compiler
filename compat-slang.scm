(define (caar x) (car (car x)))
(define (cadr x) (car (cdr x)))
(define (cdar x) (cdr (car x)))
(define (cddr x) (cdr (cdr x)))

(define (cdddr x) (cdr (cdr (cdr x))))
(define (caddr x) (car (cdr (cdr x))))
(define (cdadr x) (cdr (car (cdr x))))
(define (cddar x) (cdr (cdr (car x))))
(define (caadr x) (car (car (cdr x))))
(define (cadar x) (car (cdr (car x))))
(define (cdaar x) (cdr (car (car x))))
(define (caaar x) (car (car (car x))))

(define (cddddr x) (cdr (cdr (cdr (cdr x)))))
(define (cdaddr x) (cdr (car (cdr (cdr x)))))
(define (cddadr x) (cdr (cdr (car (cdr x)))))
(define (cdddar x) (cdr (cdr (cdr (car x)))))
(define (cdaadr x) (cdr (car (car (cdr x)))))
(define (cdadar x) (cdr (car (cdr (car x)))))
(define (cddaar x) (cdr (cdr (car (car x)))))
(define (cdaaar x) (cdr (car (car (car x)))))
(define (cadddr x) (car (cdr (cdr (cdr x)))))
(define (caaddr x) (car (car (cdr (cdr x)))))
(define (cadadr x) (car (cdr (car (cdr x)))))
(define (caddar x) (car (cdr (cdr (car x)))))
(define (caaadr x) (car (car (car (cdr x)))))
(define (caadar x) (car (car (cdr (car x)))))
(define (cadaar x) (car (cdr (car (car x)))))
(define (caaaar x) (car (car (car (car x)))))

(define (cdddddr x) (cdr (cdr (cdr (cdr (cdr x))))))
(define (cddaddr x) (cdr (cdr (car (cdr (cdr x))))))
(define (cdddadr x) (cdr (cdr (cdr (car (cdr x))))))
(define (cddddar x) (cdr (cdr (cdr (cdr (car x))))))
(define (cddaadr x) (cdr (cdr (car (car (cdr x))))))
(define (cddadar x) (cdr (cdr (car (cdr (car x))))))
(define (cdddaar x) (cdr (cdr (cdr (car (car x))))))
(define (cddaaar x) (cdr (cdr (car (car (car x))))))
(define (cdadddr x) (cdr (car (cdr (cdr (cdr x))))))
(define (cdaaddr x) (cdr (car (car (cdr (cdr x))))))
(define (cdadadr x) (cdr (car (cdr (car (cdr x))))))
(define (cdaddar x) (cdr (car (cdr (cdr (car x))))))
(define (cdaaadr x) (cdr (car (car (car (cdr x))))))
(define (cdaadar x) (cdr (car (car (cdr (car x))))))
(define (cdadaar x) (cdr (car (cdr (car (car x))))))
(define (cdaaaar x) (cdr (car (car (car (car x))))))
(define (caddddr x) (car (cdr (cdr (cdr (cdr x))))))
(define (cadaddr x) (car (cdr (car (cdr (cdr x))))))
(define (caddadr x) (car (cdr (cdr (car (cdr x))))))
(define (cadddar x) (car (cdr (cdr (cdr (car x))))))
(define (cadaadr x) (car (cdr (car (car (cdr x))))))
(define (cadadar x) (car (cdr (car (cdr (car x))))))
(define (caddaar x) (car (cdr (cdr (car (car x))))))
(define (cadaaar x) (car (cdr (car (car (car x))))))
(define (caadddr x) (car (car (cdr (cdr (cdr x))))))
(define (caaaddr x) (car (car (car (cdr (cdr x))))))
(define (caadadr x) (car (car (cdr (car (cdr x))))))
(define (caaddar x) (car (car (cdr (cdr (car x))))))
(define (caaaadr x) (car (car (car (car (cdr x))))))
(define (caaadar x) (car (car (car (cdr (car x))))))
(define (caadaar x) (car (car (cdr (car (car x))))))
(define (caaaaar x) (car (car (car (car (car x))))))

(define (map f lst)
  (if (null? lst)
    '()
    (cons (f (car lst)) (map f (cdr lst)))))

(define (filter f lst)
  (if (null? lst)
    '()
    (if (f (car lst))
      (cons (car lst) (filter f (cdr lst)))
      (filter f (cdr lst)))))

(define (foldr f lst)
  (cond
    ((eq? (length lst) 2) (f (car lst) (cadr lst)))
    ((eq? (length lst) 1) (car lst))
    (else (f (car lst) (foldr f (cdr lst))))))

(define (assoc x lst)
  (let ((filtered-lst (filter (lambda (p) (equal? x (car p))) lst)))
    (if (eq? filtered-lst '())
      #f
      (car filtered-lst))))

(define (for-each f lst)
  (map f lst)
  'for-each-completed)

(define (append lst1 lst2)
  (if (null? lst1)
    lst2
    (cons (car lst1) (append (cdr lst1) lst2))))

(define (length lst)
  (if (null? lst)
    0
    (add1 (length (cdr lst)))))

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

(define (format_ str-lst lst)
  (cond
    ((< (length str-lst) 2) str-lst)
    ((null? lst) str-lst)
    (else
      (let ((first-char (car str-lst))
	    (second-char (cadr str-lst))
	    (rest-str-lst (cddr str-lst)))
        (if (and (equal? first-char #\~)
	         (or (equal? second-char #\A)
		     (equal? second-char #\a)))
          (append (string->list (any->string (car lst)))
	          (format_ rest-str-lst (cdr lst)))
	  (cons (car str-lst)
	        (format_ (cdr str-lst) lst)))))))
(define (format str lst)
  (list->string (format_ (string->list str) lst)))

(define (error str x)
  (display (string-append (string-append str ": ")
	   (format "~A" (list x))))
  (exit -1))

(define (string->list_ str n)
  (if (eq? n 0)
    (cons (string-ref str n) '())
    (cons (string-ref str n) (string->list_ str (sub1 n)))))
(define (string->list str)
  (reverse (string->list_ str (sub1 (string-length str)))))

(define (list->string lst)
  (if (eq? lst '())
    ""
    (string-append (any->string (car lst))
		   (list->string (cdr lst)))))
    
(define (min x y) (if (< x y) x y))
(define (max x y) (if (> x y) x y))

