(import chicken.format)

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
      ((eq? op '*)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-expr (primcall-operand2 x) tmp2 env)
       (emit-call2 "prim_fixnum_mul" tmp1 tmp2 var))
      ((eq? op '/)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-expr (primcall-operand2 x) tmp2 env)
       (emit-call2 "prim_fixnum_div" tmp1 tmp2 var))
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
      ((eq? op 'list-ref)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-expr (primcall-operand2 x) tmp2 env)
       (emit-call2 "prim_list_ref" tmp1 tmp2 var))
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
    ; we can car the body because by now, everything
    ; should be wrapped by begin to give a single
    ; expression
    (emit-expr (car (let-body x)) var env)
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
  (debug (car body)) (debug-newline) (debug-newline)
  (if (not (null? body))
    (begin
      (emit-begin_ (cdr body) (unique-var) env)
      (emit-expr (car body) var env))))
(define (emit-begin x var env)
  (emit-begin_ (reverse (begin-body x)) var env))

(define (emit-c-env_ c-env-var free-vars n env)
  (let ((tmp1 (unique-var))
	(tmp2 (unique-var)))
    (if (null? free-vars)
      env
      (begin
	(emit-immediate n tmp1)
        (puts (format "  ~A = call i64 @prim_list_ref(i64 ~A, i64 ~A)" tmp2 c-env-var tmp1))
	(extend-env (car free-vars)
		    tmp2
		    (emit-c-env_ c-env-var
			         (cdr free-vars)
				 (add1 n)
				 env))))))
(define (emit-c-env c-env-var free-vars env)
  (emit-c-env_ c-env-var free-vars 0 env))

(define (emit-function x env)
  (let* ((name (function-name->ll-name (function-name x)))
         (args (function-args x))
	 (f-free-vars (function-free-vars x))
	 (vars (map (lambda (a) (unique-var)) args))
	 (ext-env_ (extend-env-many args vars env)))
    (puts (format "define i64 @~A(~A) {" name (args-string vars)))
    ; c-env is always the first arg
    (let ((ext-env (emit-c-env (car vars) f-free-vars ext-env_)))
      (emit-expr (function-body x) "%res" ext-env)
      (emit-return "%res")
      (puts "}"))))

(define (emit-global-var global-var)
  (puts (format "~A = global i64 0, align 8" global-var)))

(define (emit-env x var env)
  (debug "EMIT-ENV -- env = ") (debug env) (debug-newline)
  (if (null? x)
    (emit-immediate '() var)
    (let ((first-var (car x))
          (rest-vars (cdr x))
	  (tmp1 (unique-var))
          (tmp2 (unique-var)))
      (emit-fetch-var first-var tmp1 env)
      (if (null? rest-vars)
        (emit-immediate '() tmp2)
        (emit-env rest-vars tmp2 env))
      (emit-call2 "prim_pair_cons" tmp1 tmp2 var))))
(define (emit-closure x var env)
  ; emit a new closure with the function pointer to
  ; the corresponding function and the free variables
  ; set to the current values (when this code is called)
  ; in the environment
  (let* ((name (function-name->ll-name (closure-function x)))
	 (signature (args-signature (add1 (closure-arity x))))
	 (free-vars (closure-free-vars x))
	 (tmp1 (unique-var))
	 (tmp2 (unique-var)))
    (debug "EMIT-CLOSURE -- name = ") (debug name) (debug-newline)
    (debug "EMIT-CLOSURE -- free-vars = ") (debug free-vars) (debug-newline)
    (puts (format "  ~A = ptrtoint i64(~A)* @~A to i64"
		  tmp1
		  signature
		  name))
    (emit-env free-vars tmp2 env)
    (emit-call2 "prim_closure" tmp1 tmp2 var)))

; TODO: store quoted content
(define (emit-quote x var env)
  (let ((content (quote-content x)))
    (if (null? content)
      (emit-immediate '() var)
      #f)))

(define (emit-application x var env)
  (let* ((evaluated-list
	   (map (lambda (a)
	          (let ((arg-var (unique-var)))
		    (emit-expr a arg-var env)
		    arg-var))
	        x))
	 (closure-var (car evaluated-list))
	 (arg-vars (cdr evaluated-list))
	 (func-args-signature (args-signature (add1 (length arg-vars))))
	 (func-addr-var (unique-var))
	 (func-ptr-var (unique-var))
	 (func-env-var (unique-var))
	 (func-args (args-string (cons func-env-var arg-vars))))
    (debug "EMIT-APPLICATION -- x = ") (debug x) (debug-newline)
    (debug "EMIT-APPLICATION -- ev-list = ") (debug evaluated-list) (debug-newline)
    (debug "EMIT-APPLICATION -- env = ") (debug env) (debug-newline)
    (emit-call1 "prim_closure_func_addr" closure-var func-addr-var)
    (emit-call1 "prim_closure_env" closure-var func-env-var)
    (puts (format "  ~A = inttoptr i64 ~A to i64(~A)*" func-ptr-var func-addr-var func-args-signature))
    (puts (format "  ~A = call i64 ~A(~A)" var func-ptr-var func-args))))

(define (emit-fetch-var x var env)
  (debug "EMIT-FETCH-VAR -- x = ") (debug x) (debug-newline)
  (debug "EMIT-FETCH-VAR -- env = ") (debug env) (debug-newline)
  (let ((val (cdr (assoc x env))))
    (if (not (eq? val #f))
      (cond
	((local-ll-var? val)
	 (emit-copy var val))
	((global-ll-var? val)
	 (emit-load var val))
	(else (error "neither local nor global variable" val)))
      (error "no such variable in env" x))))

(define (emit-expr x var env)
  (debug "EMIT-EXPR -- x = ") (debug x) (debug-newline)
  (debug "EMIT-EXPR -- var = ") (debug x) (debug-newline)
  (debug "EMIT-EXPR -- env = ") (debug x) (debug-newline)
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
    ((quote? x)
     (emit-quote x var env))
    ((list? x)
     (emit-application x var env))
    ((var? x)
     (emit-fetch-var x var env))
    (else (error "no such expression"))))

(define (emit-main exprs)
  ; emit all global variable declarations
  (for-each
    (lambda (x)
      (emit-global-var (cdr x)))
    global-env)
  ; emit all function definitions
  ; TODO: they should be able to access to currently available
  ;       global-env
  (for-each
    (lambda (x) (emit-function x global-env))
    functions)
  (puts "define i64 @scheme_main() {")
  (let ((last-var #f))
    (for-each
      (lambda (x)
        (cond
	  ((define-var? x)
	   (debug "EMIT-MAIN (emitting define var) -- x = ") (debug x) (debug-newline)
           (let* ((tmp1 (unique-var))
  	          (global1-symbol (define-id x))
  	          (global1-name (symbol->string global1-symbol))
  	          (global1 (string-append "@" global1-name)))
	     ; we can car the body because by now, everything
	     ; should be wrapped by begin to give a single
	     ; expression
  	     (emit-expr (car (define-body x)) tmp1 global-env)
  	     (emit-store tmp1 global1)))
  	  (else
	    (set! last-var (unique-var))
	    (emit-expr x last-var global-env))))
      exprs)
    (emit-copy "%res" last-var))
  (emit-return "%res")
  (puts "}"))

(define (main)
  (let* ((ast (parse))
	 (p-ast (map preprocess ast)))
    (extract-global-vars p-ast)
    (let ((cp-ast (map lambdas->closures p-ast)))
      (debug functions) (debug-newline) (debug-newline)
      (debug ast) (debug-newline) (debug-newline)
      (debug p-ast) (debug-newline) (debug-newline)
      (debug cp-ast) (debug-newline) (debug-newline)
      (emit-main cp-ast))))

(main)

