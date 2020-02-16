;;;* Author: Aaron Chen
;;;* Last modified: 2020-02-16

(in-package :primecount)

(deftype u64 () '(unsigned-byte 64))
(deftype u128 () '(unsigned-byte 128))

(defun prime-count (n)
  (declare (optimize (speed 3) (safety 0))
           (type u64 n))
  (let* ((sq (isqrt n))
         (pis (make-array (+ sq 1) :element-type 'u64))
         (pil (make-array (+ sq 1) :element-type 'u64)))
    (declare (type u64 sq)
             (type (simple-array u64) pis pil))
    (setf (aref pis 0) 0 (aref pil 0) 0)
    (loop for i of-type u64 from 1 to sq
       do (setf (aref pis i) (- i 1)
                (aref pil i) (- (floor n i) 1)))
    (loop for p of-type u64 from 2 to sq
       if (/= (aref pis p) (aref pis (- p 1)))
       do (let ((pc (aref pis (- p 1))) (p2 (* p p)))
            (declare (type u64 pc p2))
            (loop for i of-type u64 from 1 to (min sq (floor n p2))
               for d of-type u64 = (* i p)
               if (<= d sq)
               do (decf (aref pil i) (the u64 (- (aref pil d) pc)))
               else
               do (decf (aref pil i)
                        (the u64 (- (aref pis (floor n d)) pc))))
            (loop for i of-type u64 downfrom sq to p2
               do (decf (aref pis i)
                        (the u64 (- (aref pis (floor i p)) pc))))))
    (the fixnum (aref pil 1))))

(defun prime-sum (n)
  (declare (optimize (speed 3) (safety 0))
           (type u64 n)
           #+sbcl(sb-ext:muffle-conditions sb-ext:compiler-note))
  (let* ((r (isqrt n)) (ndr (floor n r)) (size (+ r ndr -1))
         (v (make-array size :element-type 'u64))
         (s (make-array size :element-type 'u128)))
    (declare (type u64 r ndr size)
             (type (simple-array u64) v)
             (type (simple-array u128) s))
    (labels ((check (v n ndr size)
               (declare (type u64 v n ndr size))
               (if (< v ndr) (- size v) (- (floor n v) 1))))
      (declare (inline check))
      (loop for i below r do (setf (aref v i) (floor n (+ i 1))))
      (loop for i from r
         for j downfrom (- (aref v (- r 1)) 1) above 0
         do (setf (aref v i) j))
      (loop for i below size
         do (setf (aref s i)
                  (- (floor (* (aref v i) (+ (aref v i) 1)) 2) 1)))
      (loop for p from 2 to r
         if (> (aref s (- size p)) (aref s (- size p -1)))
         do (let ((sp (aref s (- size p -1))) (p2 (* p p)))
              (declare (type u64 sp p2))
              (loop for i below size
                 until (< (aref v i) p2)
                 do (decf (aref s i)
                          (* p
                             (- (aref s (check (floor (aref v i) p) n ndr size))
                                sp))))))
      (aref s 0))))

(defun prime-count-mod4 (n)
  "Count primes of the forms 4m+1 and 4m+3 no larger than n."
  (declare (optimize (speed 3) (safety 0))
           (type u64 n))
  (let* ((r (isqrt n))
         (ndr (floor n r))
         (size (- (the u64 (+ r ndr)) 1))
         (v (make-array size :element-type 'u64))
         (s1 (make-array size :element-type 'u64))
         (s3 (make-array size :element-type 'u64)))
    (declare (type u64 r ndr size)
             (type (simple-array u64) v s1 s3))
    (flet ((check (v)
             (declare (type u64 v))
             (if (< v ndr) (- size v) (the u64 (- (floor n v) 1)))))
      (declare (inline check))
      (loop for i below r do (setf (aref v i) (floor n (+ i 1))))
      (loop for i from r
         for j downfrom (the u64 (- (aref v (- r 1)) 1)) above 0
         do (setf (aref v i) j))
      (loop for i below size
         do (setf (aref s1 i) (floor (the u64 (- (aref v i) 1)) 4)
                  (aref s3 i) (floor (the u64 (+ (aref v i) 1)) 4)))
      (loop for p from 3 to r by 2 do
           (if (= 1 (logand p 3))
               (when (> (aref s1 (- size p)) (aref s1 (- size p -1)))
                 (let ((sp (aref s1 (- size p -1)))
                       (sp3 (aref s3 (- size p -1)))
                       (p2 (* p p)))
                   (declare (type u64 sp sp3 p2))
                   (loop for i below size
                      for tmp of-type u64 = (check (floor (aref v i) p))
                      until (< (aref v i) p2) do
                        (decf (aref s1 i)
                              (the u64 (- (aref s1 tmp) sp)))
                        (decf (aref s3 i)
                              (the u64 (- (aref s3 tmp) sp3))))))
               (when (> (aref s3 (- size p)) (aref s3 (- size p -1)))
                 (let ((sp (aref s1 (- size p -1)))
                       (sp3 (aref s3 (- size p -1)))
                       (p2 (* p p)))
                   (declare (type u64 sp sp3 p2))
                   (loop for i below size
                      for tmp of-type u64 = (check (floor (aref v i) p))
                      until (< (aref v i) p2) do
                        (decf (aref s1 i)
                              (the u64 (- (aref s3 tmp) sp3)))
                        (decf (aref s3 i)
                              (the u64 (- (aref s1 tmp) sp))))))))
      (values (the fixnum (aref s1 0))
              (the fixnum (aref s3 0))))))
