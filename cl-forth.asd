(in-package #:asdf/user)

(defsystem #:cl-forth
  :description "Forth interpreter"
  :version "0.9"
  :serial t
  :components ((:file "packages")
               (:file "exceptions")
               (:file "strings")
               (:file "numbers")
               (:file "memory")
               (:file "stacks")
               (:file "words")
               (:file "files")
               (:file "execution-tokens")
               (:file "system")
               (:file "helpers")
               (:module "forth-words"
                  :serial nil
                  :components ((:file "core")
                               (:file "environment")
                               (:file "files")
                               (:file "tools")
                               (:file "double")
                               #+ignore (:file "float")
                               (:file "strings")
                               (:file "exceptions")
                               (:file "search")
                               (:file "facility")
                               #+ignore (:file "memory")
                               (:file "extensions")))
               ;;---*** TODO: Temporary
               (:file "test"))
  :in-order-to ((test-op (test-op #:cl-forth/test))))

(defsystem #:cl-forth/application
  )

(defsystem #:cl-forth/test
  :description "Test Forth interpreter"
  :version "0.9"
  :pathname "tests/src"
  :perform (test-op (o c)
             (let ((tests-dir (component-pathname c)))
               (uiop:with-current-directory (tests-dir)
                 (with-input-from-string (text #.(format nil "The quick brown fox jumped over the lazy red dog.~%"))
                   (let ((*standard-input* text)
                         (fs (make-instance (find-symbol "FORTH-SYSTEM" "FORTH"))))
                     (symbol-call '#:forth '#:toplevel
                                  fs :evaluate "WARNING OFF S\" runtests.fth\" INCLUDED BYE")))))))
