(define (emit-immediate x var)
  (emit-copy var (fixnum->string (immediate-rep x))))

(define (emit-primcall x var env)
  (let ((op (primcall-operator x))
        (tmp1 (unique-var))
        (tmp2 (unique-var))
        (tmp3 (unique-var)))
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
      ((eq? op 'and)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-expr (primcall-operand2 x) tmp2 env)
       (emit-call2 "prim_bool_and" tmp1 tmp2 var))
      ((eq? op 'or)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-expr (primcall-operand2 x) tmp2 env)
       (emit-call2 "prim_bool_or" tmp1 tmp2 var))
      ((eq? op 'not)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_bool_not" tmp1 var))
      ((eq? op 'equal?)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-expr (primcall-operand2 x) tmp2 env)
       (emit-call2 "prim_generic_equal" tmp1 tmp2 var))
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
      ((eq? op 'vector-init)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_vector_init" tmp1 var))
      ((eq? op 'vector-ref)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-expr (primcall-operand2 x) tmp2 env)
       (emit-call2 "prim_vector_ref" tmp1 tmp2 var))
      ((eq? op 'vector-set!)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-expr (primcall-operand2 x) tmp2 env)
       (emit-expr (primcall-operand3 x) tmp3 env)
       (emit-call3 "prim_vector_set" tmp1 tmp2 tmp3 var))
      ((eq? op 'string-length)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_string_length" tmp1 var))
      ((eq? op 'string-append)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-expr (primcall-operand2 x) tmp2 env)
       (emit-call2 "prim_string_append" tmp1 tmp2 var))
      ((eq? op 'fixnum->string)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_fixnum_to_string" tmp1 var))
      ((eq? op 'any->string)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_any_to_string" tmp1 var))
      ((eq? op 'char->fixnum)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_char_to_fixnum" tmp1 var))
      ((eq? op 'boolean?)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_is_bool" tmp1 var))
      ((eq? op 'null?)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_is_null" tmp1 var))
      ((eq? op 'fixnum?)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_is_fixnum" tmp1 var))
      ((eq? op 'char?)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_is_char" tmp1 var))
      ((eq? op 'pair?)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_is_pair" tmp1 var))
      ((eq? op 'list?)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_is_list" tmp1 var))
      ((eq? op 'null?)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_is_null" tmp1 var))
      ((eq? op 'string?)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_is_string" tmp1 var))
      ((eq? op 'symbol?)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_is_symbol" tmp1 var))
      ((eq? op 'display)
       (emit-expr (primcall-operand1 x) tmp1 env)
       (emit-call1 "prim_display" tmp1 var))
      ((eq? op 'newline)
       (emit-call0 "prim_newline" var))
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
  (debug "EMIT-LET -- body = ") (debug (car (let-body x))) (debug-newline)
  (emit-let_ x (let-bindings x) var env))

(define (emit-begin_ body var env)
  (debug "EMIT-BEGIN -- rest of body = ") (debug body) (debug-newline) (debug-newline)
  (if (not (null? body))
    (begin
      (emit-begin_ (cdr body) (unique-var) env)
      (emit-expr (car body) var env))
    'no-more-expressions))
(define (emit-begin x var env)
  (debug "EMIT-BODY -- body = ") (debug (begin-body x)) (debug-newline)
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

(define (emit-string_ bytes var)
  (let ((tmp1 (unique-var))
	(tmp2 (unique-var))
	(tmp3 (unique-var))
	(tmp4 (unique-var)))
    (emit-alloca tmp1)
    (puts (format "  ~A = bitcast i64* ~A to i8*" tmp2 tmp1))
    (for-each
      (lambda (i)
        (let ((tmp-for (unique-var))
  	      (byte (char->integer (list-ref bytes i))))
          (puts (format "  ~A = getelementptr i8, i8* ~A, i64 ~A" tmp-for tmp2 i))
          (puts (format "  store i8 ~A, i8* ~A" byte tmp-for))))
      (iota (min (length bytes) 8)))
    (if (< (length bytes) 8)
      (begin
        (puts (format "  ~A = getelementptr i8, i8* ~A, i64 ~A" tmp4 tmp2 (length bytes)))
        (puts (format "  store i8 ~A, i8* ~A" 0 tmp4)))
      'last-block)
    (emit-load tmp3 tmp1)
    (puts (format "  ~A = call i64 @___reserved_heap_store_i64(i64 ~A)" var tmp3))
    (if (>= (length bytes) 8)
      (emit-string_ (drop bytes 8) (unique-var))
      'not-yet-last-block)))
(define (emit-string x var env)
  (let ((bytes (string->list x))
	(tmp1 (unique-var))
	(tmp2 (unique-var)))
    (emit-string_ bytes tmp1)
    (puts (format "  ~A = load i64, i64* @prim_string_tag" tmp2))
    (puts (format "  ~A = or i64 ~A, ~A" var tmp1 tmp2))))

(define (emit-vector x var env)
  (let* ((vector-elems (cdr x))
	 (vector-len (length vector-elems))
	 (tmp1 (unique-var)))
    (emit-expr vector-len tmp1 env)
    (emit-call1 "prim_vector_init" tmp1 var)
    (for-each
      (lambda (i)
	(let ((tmp2 (unique-var))
	      (tmp3 (unique-var))
	      (tmp4 (unique-var)))
	  ; emit the index to set
	  (emit-expr i tmp2 env)
	  ; emit the value to set
	  (emit-expr (list-ref vector-elems i) tmp3 env)
	  (emit-call3 "prim_vector_set" var tmp2 tmp3 tmp4)))
      (iota vector-len))))

(define (emit-symbol x var env)
  (let ((tmp1 (unique-var)))
    (emit-string (symbol->string x) tmp1 env)
    (emit-call1 "prim_string_to_symbol" tmp1 var)))

(define (emit-quote x var env)
  (let ((content (quote-content x)))
    (if (null? content)
      (emit-immediate '() var)
      ; we simply emit a symbol, preprocessing has eliminated
      ; all deeper levels of quotation (this is still to do)
      (emit-symbol content var env))))

(define (emit-global-set! x var env)
  (let ((var-ll-var (assoc (set!-var x) env)))
    (if (not (eq? var-ll-var #f))
      (let ((ll-var (cdr var-ll-var))
	    (new-val (set!-val x))
	    (tmp1 (unique-var)))
        (cond
	  ((local-ll-var? ll-var)
	   (error "local ll variable assignment is not possible" x))
	  ((global-ll-var? ll-var)
	   (emit-expr new-val tmp1 env)
	   (emit-store tmp1 ll-var)
	   ; just to have something valid returned
	   (emit-expr #t var env))
	  (else (error "neither local nor global variable" ll-var))))
      (error "no such variable in env" x))))

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
  (let ((var-val (assoc x env)))
    (if (not (eq? var-val #f))
      (let ((val (cdr var-val)))
        (cond
	  ((local-ll-var? val)
	   (emit-copy var val))
	  ((global-ll-var? val)
	   (emit-load var val))
	  (else (error "neither local nor global variable" val))))
      (error "no such variable in env" x))))

(define (emit-expr x var env)
  (debug "EMIT-EXPR -- x = ") (debug x) (debug-newline)
  (debug "EMIT-EXPR -- var = ") (debug var) (debug-newline)
  (debug "EMIT-EXPR -- env = ") (debug env) (debug-newline)
  (cond
    ((immediate? x)
     (emit-immediate x var))
    ((string? x)
     (emit-string x var env))
    ((vector-primcall? x)
     (emit-vector x var env))
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
    ((set!? x)
     (emit-global-set! x var env))
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
  (let* ((in-file (list-ref (argv) 1))
	 (ast (parse in-file))
	 (p-ast (map preprocess ast)))
    (extract-global-vars p-ast)
    (let ((cp-ast (map lambdas->closures p-ast)))
      (debug "FUNCTIONS: ") (debug-newline)
      (debug functions) (debug-newline) (debug-newline)
      (debug "AST: ") (debug-newline)
      (debug ast) (debug-newline) (debug-newline)
      (debug "PREPROCESSED AST: ") (debug-newline)
      (debug p-ast) (debug-newline) (debug-newline)
      (debug "CLOSURE CONVERTED AND PREPROCESSED AST: ") (debug-newline)
      (debug cp-ast) (debug-newline) (debug-newline)
      (emit-main cp-ast))))

(main)

