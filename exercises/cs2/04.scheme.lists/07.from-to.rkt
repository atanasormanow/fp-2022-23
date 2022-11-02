#lang racket
(require rackunit rackunit/text-ui)

;### Зад 7
; Връща списък `(a (+ a 1) (+ a 2) (+ a 3) ... b)`,
; тоест целите числа в интервала [`a`, `b`].
(define (from-to a b)
  'тук)


(define l1 '(1 2 3 4 5 6 7 8))
(define l2 '(0 (12 13) (21 22)))

(run-tests
  (test-suite "from-to tests"
    (check-equal? (from-to 1 8)
                  l1)
    (check-equal? (from-to 3 9)
                  '(3 4 5 6 7 8 9))
    (check-equal? (from-to 3 3)
                  '(3))
    (check-equal? (from-to 4 3)
                  '())
    (check-equal? (from-to 1.4 6)
                  '(1.4 2.4 3.4 4.4 5.4)))
  'verbose)