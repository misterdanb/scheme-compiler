(import chicken.format)

(define (tagged-list? x tag)
  (if (list? x)
    (eq? (car x) tag)
    #f))

(define (immediate? x)
  (cond
    ((fixnum? x) #t)
    ((char? x) #t)
    ((boolean? x) #t)
    ((null? x) #t)
    (else #f)))
(define (emit-immediate x var)
  (emit-copy var (fixnum->string (immediate-rep x))))

(define (primcall-operator x) (car x))
(define (primcall-operand1 x) (cadr x))
(define (primcall-operand2 x) (caddr x))
(define (primcall? x)
  (let ((op (primcall-operator x)))
    (or
      (eq? op 'add1)
      (eq? op 'sub1)
      (eq? op '+)
      (eq? op '-)
      (eq? op 'equal?)
      (eq? op 'cons)
      (eq? op 'car)
      (eq? op 'cdr))))
(define (emit-primcall x var env)
  (let ((op (primcall-operator x))
        (tmp1 (unique-var))
        (tmp2 (unique-var)))
    (cond
      ((eq? op 'add1)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_fixnum_add1" tmp1 var))
      ((eq? op 'sub1)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_fixnum_sub1" tmp1 var))
      ((eq? op '+)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-expr (primcall-operand2 x) tmp2 env)
       (emit-call2 "prim_fixnum_add" tmp1 tmp2 var))
      ((eq? op '-)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-expr (primcall-operand2 x) tmp2 env)
       (emit-call2 "prim_fixnum_sub" tmp1 tmp2 var))
      ((eq? op 'equal?)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-expr (primcall-operand2 x) tmp2 env)
       (emit-call2 "prim_fixnum_equal" tmp1 tmp2 var))
      ((eq? op 'cons)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-expr (primcall-operand2 x) tmp2 env)
       (emit-call2 "prim_pair_cons" tmp1 tmp2 var))
      ((eq? op 'car)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_pair_car" tmp1 var))
      ((eq? op 'cdr)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_pair_cdr" tmp1 var))
      (else (error "no such primcall")))))

(define (if? x)
  (tagged-list? x 'if))
(define (if-test x) (cadr x))
(define (if-conseq x) (caddr x))
(define (if-altern x) (cadddr x))
(define (emit-if x var env)
  (let ((conseq-label (unique-label "conseq"))
	(altern-label (unique-label "altern"))
	(result-label (unique-label "result"))
	(tmp-res (unique-var))
	(tmp1 (unique-var))
	(tmp2 (unique-var))
	(tmp3 (unique-var))
	(tmp4 (unique-var)))
    (emit-alloca tmp-res)
    (emit-expr (if-test x) tmp1 env)
    (emit-cmp "eq" tmp1 (immediate-rep #t) tmp2)
    (emit-br2 tmp2 conseq-label altern-label)

    (emit-label conseq-label)
    (emit-expr (if-conseq x) tmp3 env)
    (emit-store tmp3 tmp-res)
    (emit-br1 result-label)

    (emit-label altern-label)
    (emit-expr (if-altern x) tmp4 env)
    (emit-store tmp4 tmp-res)
    (emit-br1 result-label)

    (emit-label result-label)
    (emit-load var tmp-res)))

(define (let? x)
  (tagged-list? x 'let))
(define (let-bindings x)
  (cadr x))
(define (let-binding-var x)
  (car x))
(define (let-binding-val x)
  (cadr x))
(define (let-body x)
  (cddr x))
(define (emit-let_ x bindings var env)
  ...)
(define (emit-let x var env)
  ...)

(define (emit-expr x var env)
  (cond
    ((immediate? x)
     (emit-immediate x var))
    ((primcall? x)
     (emit-primcall x var env))
    ((if? x)
     (emit-if x var env))
    (else (error "no such expression"))))

(define (emit-main exprs)
;  (for-each emit-global-variable (table-get 'global-variables))
;  (for-each emit-lambda (table-get 'lambdas))
  (puts "define i64 @scheme_main() {")

;  (puts (format "%res = or i64 0, ~A" (immediate-rep 42)))
;  (puts (format "%res = or i64 0, ~A" (immediate-rep '())))
  (emit-expr exprs "%res" '())
  (emit-return "%res")
  (puts "}"))

(define (main)
  (let ((ast (parse)))
    (emit-main (car ast))))

(main)
