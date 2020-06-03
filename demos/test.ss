(read-case-sensitive #t)
(require "../jdb.ss")
(require "../jdi-symbol-table.ss")

(define-connect-vm c "localhost" 8001)
(set-trigger! (not (catcher-val-b (jclass c Foobar))))

(list 'trigger trigger)
(list 'here here)
(list 'kCnt (v (jval here kCnt)))
(list 'breakpoints breakpoints)
(list 'counts (map second breakpoints))
(break (((jclass c Foobar) . jdot . spin) . jloc . entry))
(break (((jclass c Foobar) . jdot . foo) . jloc . entry))

(resume)
