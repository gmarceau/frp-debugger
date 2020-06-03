(module jdi-test-catch (lib "frp.ss" "frtime")
  (require "jdi.ss"
           (lib "26.ss" "srfi")
           (all-except "base-gm.ss" rec last))
  
  (printf "start\n")
  
  (define b (+ 2 (/ 10 (modulo (make-seconds) 3))))
  (define e (changes b))


  (monitor "monitor" b e)
  (monitor "raise" (raise 'catch-me))
  (monitor "idle" idle-e)
  
  (printf "yield\n")
  (now-done-constructing)
  (thread-suspend (current-thread)))
