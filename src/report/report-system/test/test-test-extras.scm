(use-modules (gnucash report report-system test test-extras))
(use-modules (ice-9 streams))

(define (run-test)
  (and (logging-and #t)
       (logging-and)
       (not (logging-and #t #f))
       (test-pattern-streamer)
       (test-create-account-structure)))

(define (test-pattern-streamer)
  (and (test test-pattern-streamer-1)
       (test test-pattern-streamer-2)
       (test test-pattern-streamer-3)
       (test test-pattern-streamer-4)
       #t))

(define (test-pattern-streamer-1)
  (let* ((content (values-for-text "tbl row x 1 y 2 row x 3 y 4 ")))
    (format #t "Values: ~a ~a\n" content  (list (list 1 2) (list 3 4)))
    (equal? '((("1") ("2")) (("3") ("4"))) content)))

(define (test-pattern-streamer-2)
  (let* ((text "")
	 (content (values-for-text text)))
    (format #t "Values: ~a\n" content)
    (equal? (list) content)))

(define (values-for-text text)
  (let* ((content-stream (pattern-streamer "row" (list (list "x ([0-9]*) " 1)
						       (list "y ([0-9]*) " 1))
					  text))
	 (content (stream->list content-stream)))
    content))

(define (test-pattern-streamer-4)
  (let* ((text "tbl row x 11 v 12 v 13 row x 21 v 22 v 23 ")
	 (content-stream (pattern-streamer "row"
					   (list (list "x ([0-9]*) " 1)
						 (list "v ([0-9]*) " 1)
						 (list "v ([0-9]*) " 1))
					   text))
	 (content (stream->list content-stream)))
    (= 11 (tbl-ref->number content 0 0))
    (= 23 (tbl-ref->number content 1 2))))


(define stuff "<table>
<tr>
<th><string> Date</th>

<th><string> Auto</th>

<th><string> Groceries</th>

<th><string> Rent</th>

<th><string> Expenses</th>

<th><string> Grand Total</th>
</tr>

")
(define (test-pattern-streamer-3)
  (let ((columns (stream->list (pattern-streamer "<th>"
						 (list (list "<string> ([^<]*)</" 1))
						 stuff))))
    (format #t "columns ~a\n" columns)
    (= 6 (length columns))))

;;
;;
;;

;(use-modules (gnucash engine))
;(use-modules (gnucash main)) ;; FIXME: delete after we finish modularizing.
;(use-modules (gnucash printf))
;(use-modules (gnucash report report-system))
;(use-modules (gnucash app-utils))
;(use-modules (gnucash engine))
(use-modules (sw_engine))

(define (test-create-account-structure)
  (let ((env (create-test-env)))
    (let ((accounts (env-create-account-structure env (list "Assets"
							    (list (cons 'type ACCT-TYPE-ASSET))
							    (list "Bank Account")
							    (list "Savings"
								  (list "Instant")
								  (list "30 day notice"))))))
      (format #t "Accounts ~a\n" accounts)
      (and (= 3 (length accounts))
	   (equal? "Assets" (xaccAccountGetName (car accounts)))
	   ))))




