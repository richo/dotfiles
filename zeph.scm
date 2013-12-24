(require "code/ext/zephyros/libs/zephyros")

(define *modifier* '(shift ctrl))

(define movers (make-hash-table))
(define bind-and-register
  (lambda (name thunk)
    (hash-table-set! movers name thunk)
    (bind name *modifier* thunk)))


(define unpack-coords
  (lambda (frame thunk)
    (let ((x (cdr (assoc 'x frame)))
          (y (cdr (assoc 'y frame)))
          (w (cdr (assoc 'w frame)))
          (h (cdr (assoc 'h frame))))
      (thunk x y w h))))

(define pack-coords
  (lambda (x y w h)
    `((x . ,x) (y . ,y) (w . ,w) (h . ,h))))

(define push-current-to
  (lambda (transformer)
  (call/focused-window (lambda (win)
  (call/screen win (lambda (screen)
  (call/frame-without-dock-or-menu screen (lambda (frame)
    (set-frame win (apply pack-coords (unpack-coords frame transformer)))))))))))

(map (lambda (d)
  (let ((name (car d))
        (ds   (cdr d)))
    (bind-and-register name (lambda ()
      (push-current-to (lambda (x y w h)
        (list (+ x (* w (cdr (assoc 'x ds))))
              (+ y (* h (cdr (assoc 'y ds))))
              (* w (cdr (assoc 'w ds)))
              (* h (cdr (assoc 'h ds))))))))))
'(
;; Bind up hjkl
  ("H" . ((x . 0) (y . 0) (w . 0.5) (h . 1)))
  ("J" . ((x . 0) (y . 0.5) (w . 1) (h . 0.5)))
  ("K" . ((x . 0) (y . 0) (w . 1) (h . 0.5)))
  ("L" . ((x . 0.5) (y . 0) (w . 0.5) (h . 1)))
;; Bind up the rest of the nethack keys
  ("Y" . ((x . 0) (y . 0) (w . 0.5) (h . 0.5)))
  ("U" . ((x . 0.5) (y . 0) (w . 0.5) (h . 0.5)))
  ("B" . ((x . 0) (y . 0.5) (w . 0.5) (h . 0.5)))
  ("N" . ((x . 0.5) (y . 0.5) (w . 0.5) (h . 0.5)))
;; Helpers
  ("F" . ((x . 0) (y . 0) (w . 1) (h . 1)))
))

(map (lambda (d)
  (bind-and-register (car d) (lambda ()
    (call/focused-window (lambda (win)
    (call/screen win (lambda (screen)
    ((cdr d) screen (lambda (target)
    (call/frame-including-dock-and-menu target (lambda (dim)
      (let ((x (cdr (assoc 'x dim)))
            (y (cdr (assoc 'y dim))))
        (set-top-left win `((x . ,x) (y . ,y))))))))))))))
  )
  `(("]" . ,call/next-screen)
    ("[" . ,call/previous-screen)
    ))

(define (bind-super-keys!)
  (map (lambda (k)
    (bind k '() (lambda ()
                  ((hash-table-ref movers k))
                  (unbind-super-keys!))))
       (hash-table-keys movers)))

(define (unbind-super-keys!)
  (map (lambda (k) (unbind k '()))
       (hash-table-keys movers)))

;; Bind up my godkey
(bind "ESCAPE" '(cmd) bind-super-keys!)
