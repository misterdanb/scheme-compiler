(define in-port #f)

(define current-line 1)
(define current-char #f)
(define (next-char)
  (let ((new-char (read-char in-port)))
    (if (eq? new-char #\newline)
      (set! current-line (add1 current-line))
      'ok)
    (set! current-char new-char)
    new-char))
(define (next-chars n)
  (if (not (eq? n 0))
    (begin
      (next-char)
      (next-chars (- n 1)))
    current-char))
(define (skip-line)
  (let ((first-char (next-char)))
    (if (or (eq? first-char #\newline)
            (eof-object? first-char))
      (next-char)
      (skip-line))))

(define (read-token)
  (let ((first-char current-char)
        (second-char (next-char)))
    (cond ((whitespace? first-char)
           (read-token))
          ((eq? first-char #\;)
           (skip-line)
           (read-token))
          ((eq? first-char #\()
           'left-parenthesis-token)
          ((eq? first-char #\))
           'right-parenthesis-token)
          ((eq? first-char #\')
           'quote-token)
          ((eq? first-char #\`)
           'quasiquote-token)
          ((eq? first-char #\,)
           'unquote-token)
          ((eq? first-char #\#)
           (cond ((eq? second-char #\t)
                  (next-char)
                  (list 'boolean-token #t))
                 ((eq? second-char #\f)
                  (next-char)
                  (list 'boolean-token #f))
                 ; TODO: special number types such as #o #h
                 ((eq? second-char #\\)
                  (list 'named-character-token (read-named-character)))
                 (else
                   (error (format "line ~A, illegal #-value detected -- READ-TOKEN" (list current-line)) first-char))))
          ((numeric? first-char)
           (list 'integer-token
             (read-number 0 first-char 10)))
          ((and (eq? first-char #\+)
                (numeric? second-char))
           (next-char)
           (list 'integer-token
             (read-number 0 second-char 10)))
          ((and (eq? first-char #\-)
                (numeric? second-char))
           (next-char)
           (list 'integer-token
             (* -1 (read-number 0 second-char 10))))
          ((eq? first-char #\")
           (list 'string-token (read-string "")))
          ((or (alphabetic? first-char)
               (special? first-char))
           (list 'identifier-token
             (read-identifier (char->string first-char)
                              second-char)))
          (else
            (error (format "line ~A, illegal token start detected -- READ-TOKEN" (list current-line)) first-char)))))

(define (parse in-file)
  (set! in-port (open-input-file in-file))
  (next-char)
  (parse-real '()))

(define (parse-real collector)
  (cond ((eof-object? current-char)
         (reverse collector))
        ((whitespace? current-char)
         (next-char)
         (parse-real collector))
        ((eq? current-char #\;)
         (skip-line)
         (parse-real collector))
        (else
          (parse-real (cons (parse-expr) collector)))))

(define (left-parenthesis? token) (eq? token 'left-parenthesis-token))
(define (right-parenthesis? token) (eq? token 'right-parenthesis-token))
(define (quoted? token) (eq? token 'quote-token))
(define (quasiquoted? token) (eq? token 'quasiquote-token))
(define (unquoted? token) (eq? token 'unquote-token))
(define (boolean-token? token)
  (if (and (list? token) (not (null? token)))
    (eq? (car token) 'boolean-token)
    #f))
(define (integer-token? token)
  (if (and (list? token) (not (null? token)))
    (eq? (car token) 'integer-token)
    #f))
(define (named-character-token? token)
  (if (and (list? token) (not (null? token)))
    (eq? (car token) 'named-character-token)
    #f))
(define (identifier? token)
  (if (and (list? token) (not (null? token)))
    (eq? (car token) 'identifier-token)
    #f))
(define (string-token? token)
  (if (and (list? token) (not (null? token)))
    (eq? (car token) 'string-token)
    #f))

(define (parse-expr)
  (let ((next-token (read-token)))
    (cond ((left-parenthesis? next-token)
           (parse-list '()))
          ((quoted? next-token)
           (list 'quote (parse-expr)))
          ((quasiquoted? next-token)
           (list 'quasiquote (parse-expr)))
          ((unquoted? next-token)
           (list 'unquote (parse-expr)))
          ((boolean-token? next-token)
           (cadr next-token))
          ((named-character-token? next-token)
           (cadr next-token))
          ((integer-token? next-token)
           (cadr next-token))
          ((identifier? next-token)
           (string->symbol (cadr next-token)))
          ((string-token? next-token)
           (cadr next-token))
          (else
            (error (format "line ~A, unknown token -- PARSE-EXPR" (list current-line)) next-token)))))

(define (parse-list collector)
  (let ((next-token (read-token)))
    (cond ((left-parenthesis? next-token)
           (parse-list
             (cons (parse-list '())
                   collector)))
          ((right-parenthesis? next-token)
           (reverse collector))
          ((quoted? next-token)
           (parse-list
             (cons (list 'quote (parse-expr))
                   collector)))
          ((quasiquoted? next-token)
           (parse-list
             (cons (list 'quasiquote (parse-expr))
                   collector)))
          ((unquoted? next-token)
           (parse-list
             (cons (list 'unquote (parse-expr))
                   collector)))
          ((boolean-token? next-token)
           (parse-list
             (cons (cadr next-token)
                   collector)))
          ((named-character-token? next-token)
           (parse-list
             (cons (cadr next-token)
                   collector)))
          ((integer-token? next-token)
           (parse-list
             (cons (cadr next-token)
                   collector)))
          ((identifier? next-token)
           (parse-list
             (cons (string->symbol (cadr next-token))
                   collector)))
          ((string-token? next-token)
           (parse-list
             (cons (cadr next-token)
                   collector)))
          (else
            (error (format "line ~A, unknown token -- PARSE-LIST" (list current-line)) next-token)))))

(define (whitespace? char)
  (or (eq? char #\newline)
      (or (eq? char #\tab)
          (eq? char #\space))))

(define (alphabetic? char)
  (let ((val (char->fixnum char)))
    (or (and (>= val (char->fixnum #\a)) (<= val (char->fixnum #\z)))
        (and (>= val (char->fixnum #\A)) (<= val (char->fixnum #\Z))))))

(define (numeric? char)
  (let ((val (char->fixnum char)))
    (and (>= val (char->fixnum #\0))
         (<= val (char->fixnum #\9)))))

(define (special? char)
  (or (eq? char #\*)
      (eq? char #\/)
      (eq? char #\+)
      (eq? char #\-)
      (eq? char #\>)
      (eq? char #\<)
      (eq? char #\=)
      (eq? char #\?)
      (eq? char #\!)
      (eq? char #\_)
      (eq? char #\\)))

(define escape-symbols
  (list (cons #\n #\newline)
        (cons #\t #\tab)
        (cons #\" #\")
        (cons #\\ #\\)))

(define (char->string char)
  (list->string (list char)))

(define (read-named-character)
  (let ((first-char (next-char))
        (second-char (next-char)))
    ; TODO: check full strings
    (cond ((and (eq? first-char #\n)
                (eq? second-char #\e))
           (next-chars 6)
           #\newline)
          ((and (eq? first-char #\t)
                (eq? second-char #\a))
           (next-chars 2)
           #\tab)
          ((and (eq? first-char #\s)
                (eq? second-char #\p))
           (next-chars 4)
           #\space)
          ((and (eq? first-char #\r)
                (eq? second-char #\e))
           (next-chars 5)
           #\return)
          ; this works, since the next char is already consumed and can be
          ; read for the next token
          (else first-char))))

(define (read-number accumulator first-char base)
  (if (numeric? current-char)
    (let ((second-char current-char))
      (next-char)
      (read-number
        (+ (* accumulator base)
           (- (char->fixnum first-char) (char->fixnum #\0)))
        second-char base))
    (+ (* accumulator base)
       (- (char->fixnum first-char) (char->fixnum #\0)))))

(define (read-string collector)
  (let ((first-char current-char))
    (cond ((eq? first-char #\\)
           (let* ((escaped-char (next-char))
		  (real-char-pair (assoc escaped-char escape-symbols)))
	     (cond
	       ((not (eq? real-char-pair #f))
                (read-string
                  (string-append collector
                                 (char->string (cdr real-char-pair)))))
	       ((eq? escaped-char #\x)
		(error "not implemented" escaped-char)))))
          ((eq? first-char #\")
           (next-char)
           collector)
          (else
           (next-char)
           (read-string
             (string-append collector
                            (char->string first-char)))))))

; TODO: replace second-char wtih current-char?
(define (read-identifier collector second-char)
  (if (or (alphabetic? second-char)
          (or (numeric? second-char)
              (special? second-char)))
    (read-identifier (string-append collector
                                    (char->string second-char))
                     (next-char))
    collector))

(define (print-ast ast indent)
  (for-each
    (lambda (x)
      (if (list? x)
        (begin
          (debug indent)
          (debug " \\")
          (debug-newline)
          (print-ast x (string-append indent " ")))
        (begin
          (debug indent)
          (debug "| ")
          (debug x)
          (debug-newline))))
    ast))


