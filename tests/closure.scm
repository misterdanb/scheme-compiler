(define own-true (lambda (consequence alternative) (consequence)))
(define own-false (lambda (consequence alternative) (alternative)))

(define (own-if boolean consequence alternative)
  (boolean consequence alternative))

(define (own-cons x y)
  (lambda (m)
    (own-if m
      (lambda () x)
      (lambda () y))))
(define (own-car z) (z own-true))
(define (own-cdr z) (z own-false))

(define own-pair (own-cons 23 42))

(define has-correct-values
  (and (equal? (own-car own-pair) 23)
       (equal? (own-cdr own-pair) 42)))

(display "Nested lambdas work? (constructing own cons, car and cdr)")
(display has-correct-values)
(newline)

(define display-inside-lambda
  (lambda ()
    (display "Does it compile?")
    #f
    #t))
(define display-inside-lambda-works
  (display-inside-lambda))

(display "Display call inside a lambda works?")
(display display-inside-lambda-works)
(newline)

(and has-correct-values
     display-inside-lambda)
