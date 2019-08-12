(import chicken.format)

(define (extend-env var val env)
  (cons (cons var val) env))

(define (emit-immediate x var)
  (emit-copy var (fixnum->string (immediate-rep x))))

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
       ; needs to be generalized (in ir) to other
       ; types
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
    ; consequence branch
    (emit-label conseq-label)
    (emit-expr (if-conseq x) tmp3 env)
    (emit-store tmp3 tmp-res)
    (emit-br1 result-label)
    ; alternative branch
    (emit-label altern-label)
    (emit-expr (if-altern x) tmp4 env)
    (emit-store tmp4 tmp-res)
    (emit-br1 result-label)
    ; final result
    (emit-label result-label)
    (emit-load var tmp-res)))

(define (emit-let_ x bindings var env)
  (if (null? bindings)
    (emit-expr (let-body x) var env)
    (let* ((b (car bindings))
	   (b-var (let-binding-var b))
	   (b-val (let-binding-val b))
           (tmp1 (unique-var)))
      (emit-expr b-val tmp1 env)
      (emit-let_ x
		 (cdr bindings)
		 var
		 (extend-env b-var tmp1 env)))))
(define (emit-let x var env)
  (emit-let_ x (let-bindings x) var env))

(define (emit-begin_ body var env)
  (if (not (null? body))
    (begin
      (emit-begin_ (cdr body) (unique-var) env)
      (emit-expr (car body) var env))))
(define (emit-begin x var env)
  (emit-begin_ (reverse (begin-body x)) var env))

(define (emit-function x env)
  ...)

(define (emit-env x var env)
  ; since x should be a list of symbols in the environment
  ; it will be emitted through primcalls and fetches of
  ; the environment variables from the heap
  (emit-expr x var env))
(define (emit-closure x var env)
  ; emit a new closure with the function pointer to
  ; the corresponding function and the free variables
  ; set to the current values (when this code is called)
  ; in the environment
  (let* ((function-name
	   (function-name->ll-name (closure-function x)))
	 (signature
	   (args-signature (add1 (closure-arity x))))
	 (free-vars (closure-free-vars))
	 (tmp1 (unique-var))
	 (tmp2 (unique-var)))
    (puts (format "  ~A = ptrtoint i64 (~A)* @~A to i64"
		  tmp1
		  signature,
		  function-name))
    (emit-env free-vars tmp2 env)
    (emit-call3 "prim_closure" tmp1 tmp2 var)))

(define (emit-fetch-var x var env)
  (let ((val (cdr (assoc x env))))
    (if (not (eq? val #f))
      (cond
	((local-var? val)
	 (emit-copy var val))
	((global-var? val)
	 (emit-load var val))
	(else (error "neither local nor global variable" val)))
      (error "no such variable in env" x))))

(define (emit-expr x var env)
  (cond
    ((immediate? x)
     (emit-immediate x var))
    ((primcall? x)
     (emit-primcall x var env))
    ((if? x)
     (emit-if x var env))
    ((let? x)
     (emit-let x var env))
    ((begin? x)
     (emit-begin x var env))
    ((closure? x)
     (emit-closure x var env))
    ((list? x)
     (error "list? should not trigger at the moment" x))
    ((var? x)
     (emit-fetch-var x var env))
    (else (error "no such expression"))))

(define (emit-main exprs)
;  (for-each emit-global-variable (table-get 'global-variables))
  (for-each
    (lambda (x) (emit-function x global-env))
    functions)
  (puts "define i64 @scheme_main() {")
  (emit-expr exprs "%res" '())
  (emit-return "%res")
  (puts "}"))

(define (main)
  (let* ((ast (parse))
	 (p-ast (preprocess (make-begin ast))))
    (emit-main p-ast)))

;(main)
