(require "code/ext/zephyros/libs/zephyros")

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
  (call/frame-including-dock-and-menu screen (lambda (frame)
    (set-frame win (apply pack-coords (unpack-coords frame transformer)))))))))))

(define *modifier*
  '(shift ctrl))
(map (lambda (d)
  (let ((name (car d))
        (ds   (cdr d)))
    (bind name *modifier* (lambda ()
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
))
