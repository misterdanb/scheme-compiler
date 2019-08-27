(import srfi-13)

(define (tagged-list? x tag)
  (if (and (list? x) (not (null? x)))
    (eq? (car x) tag)
    #f))

(define (immediate? x)
  (cond
    ((fixnum? x) #t)
    ((char? x) #t)
    ((boolean? x) #t)
    ((null? x) #t)
    (else #f)))

(define (primcall-operator x) (car x))
(define (primcall-operand1 x) (cadr x))
(define (primcall-operand2 x) (caddr x))
(define (primcall? x)
  (if (list? x)
    (let ((op (primcall-operator x)))
      (or
        (eq? op 'add1)
        (eq? op 'sub1)
        (eq? op '+)
        (eq? op '-)
        (eq? op 'equal?)
        (eq? op 'cons)
        (eq? op 'car)
        (eq? op 'cdr)
        (eq? op 'list-ref)))
    #f))

(define (if? x) (tagged-list? x 'if))
(define (if-test x) (cadr x))
(define (if-conseq x) (caddr x))
(define (if-altern x) (cadddr x))

(define (make-body x) (cons x '()))

(define (let? x) (tagged-list? x 'let))
(define (let-bindings x) (cadr x))
(define (let-binding-var x) (car x))
(define (let-binding-val x) (cadr x))
(define (let-bindings-vars x)
  (map let-binding-var (let-bindings x)))
(define (let-bindings-vals x)
  (map let-binding-val (let-bindings x)))
(define (let-body x) (cddr x))
(define (make-let bindings body)
  (cons 'let (cons bindings body)))

(define (begin? x) (tagged-list? x 'begin))
(define (begin-body x) (cdr x))
(define (make-begin body)
  (cond
    ((null? body) (error "begin body must not be empty"))
    ((null? (cdr body)) (car body))
    (else (cons 'begin body))))

(define (cond? x) (tagged-list? x 'cond))
(define (cond-clauses x) (cdr x))
(define (cond-clause-test x) (car x))
(define (cond-clause-body x) (cdr x))

(define (function? x) (tagged-list? x 'function))
(define (function-name x) (cadr x))
(define (function-args x) (caddr x))
(define (function-body x) (cdddr x))
(define (make-function name args body)
  (cons 'function (cons name (cons args body))))

(define (function-name->ll-name x)
  (string-append "function_" x))

(define (lambda? x) (tagged-list? x 'lambda))
(define (lambda-args x) (cadr x))
(define (lambda-body x) (cddr x))
(define (make-lambda args body)
  (cons 'lambda (cons args body)))

(define (closure? x) (tagged-list? x 'closure))
(define (closure-function x) (cadr x))
(define (closure-arity x) (caddr x))
(define (closure-free-vars x) (cadddr x))
(define (make-closure name arity free-vars)
  (list 'closure name arity free-vars))

(define (args-signature n)
  (cond
    ((eq? n 0) "")
    ((eq? n 1) "i64")
    (else (string-append "i64, "
			 (args-signature (- n 1))))))

(define (args-string arg-vars)
  (cond
    ((null? arg-vars) "")
    ((eq? (length arg-vars) 1) (format "i64 ~A" (car arg-vars)))
    (else (string-append (format "i64 ~A, " (car arg-vars))
			 (args-string (cdr arg-vars))))))

(define (var? x) (symbol? x))

(define (ll-var-name x) (string-drop x 1))
(define (local-ll-var? x) (eq? (string-ref x 0) #\%))
(define (global-ll-var? x) (eq? (string-ref x 0) #\%))
(define (make-ll-local-var str) (string-append "%" str))
(define (make-ll-global-var str) (string-append "@" str))

(define (quote? x) (tagged-list? x 'quote))
(define (quote-content x) (cdr x))

(define (quasiquote? x) (tagged-list? x 'quasiquote))
(define (unquote? x) (tagged-list? x 'unquote))

(define (set!? x) (tagged-list? x 'set!))
(define (set!-id x) (cadr x))
(define (set!-expr x) (cddr x))

(define (set-car!? x) (tagged-list? x 'set-car!))
(define (set-car!-id x) (cadr x))
(define (set-car!-expr x) (cddr x))

(define (set-cdr!? x) (tagged-list? x 'set-cdr!))
(define (set-cdr!-id x) (cadr x))
(define (set-cdr!-expr x) (cddr x))

(define (define? x) (tagged-list? x 'define))
(define (define-id x) (cadr x))
(define (define-function? x) (list? (define-id x)))
(define (define-function-name x) (car (define-id x)))
(define (define-function-args x) (cdr (define-id x)))
(define (define-var? x) (symbol? (define-id x)))
(define (define-body x) (cddr x))
(define (make-define id body)
  (cons 'define (cons id body)))
(define (make-define-function-id name args)
  (cons name args))
(define (make-define-function name args body)
  (make-define (make-define-function-head name args) body))
(define (make-define-var name body)
  (make-define name body))
