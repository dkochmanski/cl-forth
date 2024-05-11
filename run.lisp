(in-package #:forth)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require '#:prefixed-stream)
  (require '#:timestamped-stream))

(defun announce-forth (fs asdf-system)
  (let ((me (asdf:find-system asdf-system)))
    (format t "~&~A ~A~%Running under ~A ~A~%~@[~A~%~]" (asdf:system-long-name me) (asdf:component-version me)
            (lisp-implementation-type) (lisp-implementation-version) (forth-system-announce-addendum fs))))

(defun run (&key (asdf-system '#:cl-forth) template evaluate trace)
  (let ((fs (make-instance 'forth-system :template template)))
    (flet ((runner ()
             (announce-forth fs asdf-system)
             (forth-toplevel fs :evaluate evaluate)))
      (if trace
          (with-open-file (trace-stream trace :direction :output :element-type 'character :if-exists :supersede
                                              #+CCL :sharing #+CCL  :lock)
            (let* ((timestamped-trace-stream (make-timestamped-stream trace-stream))
                   (traced-input (make-prefixed-stream "IN: " timestamped-trace-stream))
                   (traced-output (make-prefixed-stream "OUT: " timestamped-trace-stream))
                   (*standard-input* (make-echo-stream *standard-input* traced-input))
                   (*standard-output* (make-broadcast-stream *standard-output* traced-output)))
              (add-auto-flush-stream trace-stream)
              (unwind-protect
                   (runner)
                (remove-auto-flush-stream trace-stream))))
          (runner)))))

(defun run-forth-process (template &key (asdf-system '#:cl-forth) name evaluate trace)
  (multiple-value-bind (remote-input local-output)
      (make-piped-streams)
    (multiple-value-bind (local-input remote-output)
        (make-piped-streams)
      (add-auto-flush-stream local-output)
      (add-auto-flush-stream remote-output)
      (let ((system (asdf:find-system asdf-system))
            (local-io (make-two-way-stream local-input local-output)))
        (process-run-function (or name (asdf:system-long-name system))
                                  #'(lambda ()
                                      (unwind-protect
                                           (let ((*standard-input* remote-input)
                                                 (*standard-output* remote-output))
                                             (run :asdf-system asdf-system :template template :evaluate evaluate :trace trace))
                                        (remove-auto-flush-stream local-output)
                                        (remove-auto-flush-stream remote-output)
                                        (close remote-input)
                                        (close remote-output)
                                        (close local-input)
                                        (close local-output)
                                        (close local-io))))
        local-io))))
