(in-package #:forth)

;;; Paragraph numbers refer to the Forth Programmer's Handbook, 3rd Edition

;;; 1.1.6 Numeric input

(define-state-word base)

(define-word decimal ()
  "Change the system base to decimal"
  (setf base 10.))

(define-word hex ()
  "Change the system base to hexadecimal"
  (setf base 16.))


;;; 1.4.1 Comments

(define-word comment (:word "(")
  "Ignore all text up to and including the next close parenthesis"
  (word files #\)))

(define-word displayed-comment (:word ".(")
  "Display without interpretation all text up to the next close parenthesis on the console"
  (let ((comment (word files #\))))
    (write-line comment)))

(define-word rest-of-line-comment (:word "\\")
  "Ignore all text on the rest of the line"
  (flush-input files))


;;; 2.1.2 Data Stack Manipulation

;;; 2.1.2.1 Single-Item Operators

(define-word stack-?dup (:word "?DUP")
  "( x - 0 | x x )"
  "Conditionally duplicate the top of the data stack if it is non-zero"
  (stack-?dup data-stack))

(define-word stack-depth (:word "DEPTH")
  "( - +n )"
  "Pushes the current depth of the data stack onto the data stack"
  (stack-push data-stack (stack-depth data-stack)))

(define-word stack-drop (:word "DROP")
  "( x - )"
  "Remove the top entry from the data stack"
  (stack-drop data-stack))

(define-word stack-dup (:word "DUP")
  "( x - x x )"
  "Duplicate the top of the data stack"
  (stack-dup data-stack))

(define-word stack-nip (:word "NIP")
  "( x1 x2 - x2 )"
  "Drop the second item on the data stack, leaving the top unchanged"
  (stack-nip data-stack))

(define-word stack-over (:word "OVER")
  "( x1 x2 - x1 x2 x1 )"
  "Place a copy of X1 onto the top of the data stack"
  (stack-over data-stack))

(define-word stack-pick (:word "PICK")
  "( +n - x )"
  "Place a copy of the Nth stack item onto the top of the data stack"
  (let ((n (stack-pop data-stack)))
    (when (minusp n)
      (forth-error :invalid-numeric-argument "Pick count can't be negative"))
    (stack-pick data-stack n)))

(define-word stack-rot (:word "ROT")
  "( x1 x2 x3 - x2 x3 x1 )"
  "Rotate the top three items on the stack"
  (stack-rot data-stack))

(define-word stack-swap (:word "SWAP")
  "( x1 x2 - x2 x1 )"
  "Exchange the top two items on the data stack"
  (stack-swap data-stack))

(define-word stack-tuck (:word "TUCK")
  "( x1 x2 - x2 x1 x2 )"
  "Place a copy of the top item on the data stack below the second item on the stack"
  (stack-tuck data-stack))

;;; 2.1.2.2 Two-Item Operators

(define-word stack-2drop (:word "2DROP")
  "( x1 x2 - )"
  "Remove the top pair of cells from the data stack"
  (stack-2drop data-stack))

(define-word stack-2dup (:word "2DUP")
  "( x1 x2 - x1 x2 x1 x2 )"
  "Duplicate the top cell pair on the data stack"
  (stack-2dup data-stack))

(define-word stack-2over (:word "2OVER")
  "( x1 x2 x3 x4 - x1 x2 x3 x4 x1 x2 )"
  "Copy cell pair X1 X2 to the top of the data stack"
  (stack-2over data-stack))

(define-word stack-2rot (:word "2ROT")
  "( x1 x2 x3 x4 x5 x6 - x3 x4 x5 x6 x1 x2 )"
  "Rotate the top three cell pairs on the data stack, bringing the pair X1 X2 to the top"
  (stack-2rot data-stack))

(define-word stack-2swap (:word "2SWAP")
  "( x1 x2 x3 x4 - x3 x4 x1 x2 )"
  "Exchange the top two cell pairs on the data stack"
  (stack-2swap data-stack))


;;; 2.1.3 Return Stack Manipulation

(define-word move-two-to-return-stack (:word "2>R")
  "(S: x1 x2 - ) (R: - x1 x2 )"
  "Pop the top two items off the data stack and push them onto the return stack"
  (let ((x2 (stack-pop data-stack))
        (x1 (stack-pop data-stack)))
    (stack-push return-stack x1)
    (stack-push return-stack x2)))

(define-word move-two-from-return-stack (:word "2R>")
  "(S: - x1 x2 ) (R: x1 x2 - )"
  "Pop the top two items off the return stack and push them onto the data stack"
  (let ((x2 (stack-pop return-stack))
        (x1 (stack-pop return-stack)))
    (stack-push data-stack x1)
    (stack-push data-stack x2)))

(define-word copy-two-from-return-stack (:word "2R@")
  "(S: - x1 x2 ) (R: x1 x2 - x1 x2 )"
  "Place a copy of the top two items on the return stack onto the data stack"
  (stack-underflow-check return-stack 2)
  (stack-push data-stack (stack-cell return-stack 1))
  (stack-push data-stack (stack-cell return-stack 0)))

(define-word move-to-return-stack (:word ">R")
  "(S: x - ) (R: - x )"
  "Pop the top item off the data stack and push it onto the return stack"
  (stack-push return-stack (stack-pop data-stack)))

(define-word move-from-return-stack (:word "R>")
  "(S: - x ) (R: x - )"
  "Pop the top item off the return stack and push it onto the data stack"
  (stack-push data-stack (stack-pop return-stack)))

(define-word copy-from-return-stack (:word "R@")
  "(S: - x ) (R: x - x )"
  "Place a copy of the top item on the return stack onto the data stack"
  (stack-underflow-check return-stack)
  (stack-push data-stack (stack-cell return-stack 0)))


;;; 2.2.1 Arithmetic and Shift Operations

;;; Single-Precision Operations

(define-word add (:word "+")
  "( n1 n2 - n3 )"
  (let ((n2 (stack-pop data-stack))
        (n1 (stack-pop data-stack)))
    (stack-push data-stack (cell-signed (+ n1 n2)))))

(define-word subtract (:word "-")
  "( n1 n2 - n3 )"
  (let ((n2 (stack-pop data-stack))
        (n1 (stack-pop data-stack)))
    (stack-push data-stack (cell-signed (- n1 n2)))))

(define-word multiply (:word "*")
  "( n1 n2 - n3 )"
  (let ((n2 (stack-pop data-stack))
        (n1 (stack-pop data-stack)))
    (stack-push data-stack (cell-signed (* n1 n2)))))

(define-word divide (:word "/")
  "( n1 n2 - n3 )"
  (let ((n2 (stack-pop data-stack))
        (n1 (stack-pop data-stack)))
    (if (zerop n2)
        (forth-error :divide-by-zero)
        (stack-push data-stack (cell-signed (truncate n1 n2))))))

(define-word multiply-divide (:word "*/")
  "( n1 n2 n3 - n4 )"
  (let ((n3 (stack-pop data-stack))
        (n2 (stack-pop data-stack))
        (n1 (stack-pop data-stack)))
    (stack-push data-stack (cell-signed (truncate (* n1 n2) n3)))))

(define-word multiply-divide-mod (:word "*/MOD")
  "( n1 n2 n3 - n4 n5 )"
  (let ((n3 (stack-pop data-stack))
        (n2 (stack-pop data-stack))
        (n1 (stack-pop data-stack)))
    (if (zerop n3)
        (forth-error :divide-by-zero)
        (multiple-value-bind (quotient remainder)
            (truncate (* n1 n2) n3)
          (stack-push data-stack (cell-signed remainder))
          (stack-push data-stack (cell-signed quotient))))))

(define-word divide-mod (:word "/MOD")
  "( n1 n2 - n3 n4 )"
  (let ((n2 (stack-pop data-stack))
        (n1 (stack-pop data-stack)))
    (if (zerop n2)
        (forth-error :divide-by-zero)
        (multiple-value-bind (quotient remainder)
            (truncate n1 n2)
          (stack-push data-stack (cell-signed remainder))
          (stack-push data-stack (cell-signed quotient))))))

(define-word add-one (:word "1+")
  "( n1 - n2 )"
  (stack-push data-stack (cell-signed (1+ (stack-pop data-stack)))))

(define-word subtract-one (:word "1-")
  "( n1 - n2 )"
  (stack-push data-stack (cell-signed (1- (stack-pop data-stack)))))

(define-word add-two (:word "2+")
  "( n1 - n2 )"
  (stack-push data-stack (cell-signed (+ (stack-pop data-stack) 2))))

(define-word subtract-two (:word "2-")
  "( n1 - n2 )"
  (stack-push data-stack (cell-signed (- (stack-pop data-stack) 2))))

(define-word ash-left-1 (:word "2*")
  "( x1 - x2 )"
  (stack-push data-stack (cell-signed (ash (stack-pop data-stack) 1))))

(define-word ash-right-1 (:word "2/")
  "( x1 - x2 )"
  (stack-push data-stack (cell-signed (ash (stack-pop data-stack) -1))))

(define-word ash-left (:word "LSHIFT")
  "( x1 u - n2 )"
  (let ((u (stack-pop data-stack))
        (x1 (stack-pop data-stack)))
    (when (minusp u)
      (forth-error :invalid-numeric-argument "Shift count can't be negative"))
    ;; The Forth standard defines LSHIFT as a logical left shift.
    ;; By treating the number as unsigned, we'll get the proper result.
    (stack-push data-stack (cell-signed (ash (cell-unsigned x1) u)))))

(define-word mod (:word "MOD")
  "( n1 n2 - n3 )"
  (let ((n2 (stack-pop data-stack))
        (n1 (stack-pop data-stack)))
    (if (zerop n2)
        (forth-error :divide-by-zero)
        (stack-push data-stack (cell-signed (mod n1 n2))))))

(define-word ash-right (:word "RSHIFT")
  "( x1 u - n2 )"
  (let ((u (stack-pop data-stack))
        (x1 (stack-pop data-stack)))
    (when (minusp u)
      (forth-error :invalid-numeric-argument "Shift count can't be negative"))
    ;; The Forth standard defines RSHIFT as a logical right shift.
    ;; By treating the number as unsigned, we'll get the proper result.
    (stack-push data-stack (cell-signed (ash (cell-unsigned x1) (- u))))))

;;; Mixed-Precision Operations

(define-word floor-mod (:word "FM/MOD")
  "( d n1 - n2 n3 )"
  "Divide the double precision integer D by the integer N1 using floored division"
  "Push the remainder N2 and quotient N3 onto the data stack"
  (let ((n1 (stack-pop data-stack))
        (d (stack-pop-double data-stack)))
    (if (zerop n1)
        (forth-error :divide-by-zero)
        (multiple-value-bind (quotient remainder)
            (floor d n1)
          (stack-push data-stack (cell-signed remainder))
          (stack-push data-stack (cell-signed quotient))))))

(define-word multiply-double (:word "M*")
  "( n1 n2 - d )"
  "Multiply the signed integers N1 and N2 and push the resulting double precision integer D onto the data stack"
  (let ((n2 (stack-pop data-stack))
        (n1 (stack-pop data-stack)))
    (stack-push-double data-stack (* n1 n2))))

(define-word single-to-double (:word "S>D")
  "( n - d )"
  "Convert the signed integer N to a signed double precision integer D"
  (stack-push-double data-stack (cell-signed (stack-pop data-stack))))

(define-word truncate-mod (:word "SM/MOD")
  "( d n1 - n2 n3 )"
  "Divide the double precision integer D by the integer N1 using symmetric division"
  "Push the remainder N2 and quotient N3 onto the data stack"
  (let ((n1 (stack-pop data-stack))
        (d (stack-pop-double data-stack)))
    (if (zerop n1)
        (forth-error :divide-by-zero)
        (multiple-value-bind (quotient remainder)
            (truncate d n1)
          (stack-push data-stack (cell-signed remainder))
          (stack-push data-stack (cell-signed quotient))))))

(define-word floor-mod (:word "UM/MOD")
  "( ud u1 - u2 u3 )"
  "Divide the unsigned double precision integer UD by the unsigned integer U1"
  "Push the unsigned remainder U2 and unsigned quotient U3 onto the data stack"
  (let* ((u1 (cell-unsigned (stack-pop data-stack)))
         (d (stack-pop-double data-stack))
         (ud (multiple-value-bind (low high)
                 (double-components d)
               (double-cell-unsigned low high))))
    (if (zerop u1)
        (forth-error :divide-by-zero)
        (multiple-value-bind (quotient remainder)
            (truncate ud u1)
          (stack-push data-stack (cell-unsigned remainder))
          (stack-push data-stack (cell-unsigned quotient))))))

(define-word multiply-double (:word "U*")
  "( u1 u2 - ud )"
  "Multiply the unsigned integers U1 and U2 and push the resulting unsigned double precision integer UD onto the data stack"
  (let ((u2 (cell-unsigned (stack-pop data-stack)))
        (u1 (cell-unsigned (stack-pop data-stack))))
    (stack-push-double data-stack (* u1 u2))))


;;; 2.2.2 Logical Operations

;;; Single-Precision Operations

(define-word abs (:word "ABS")
  "( n1 - n2 )"
  "Push the absolute value of N1 onto the data stack"
  (stack-push data-stack (cell-signed (abs (stack-pop data-stack)))))

(define-word and (:word "AND")
  "( x1 x2 - x3 )"
  "Return the bitwise logical and of X1 with X2"
  (stack-push data-stack (cell-unsigned (logand (stack-pop data-stack) (stack-pop data-stack)))))

(define-word invert (:word "INVERT")
  "( x1 - x2 )"
  "Invert all bits of X1, giving the logical inverse X2"
  (stack-push data-stack (cell-unsigned (lognot (stack-pop data-stack)))))

(define-word max (:word "MAX")
  "( n1 n2 - n3)"
  "Push the larger of N1 and N2 onto the data stack"
  (stack-push data-stack (cell-signed (max (stack-pop data-stack) (stack-pop data-stack)))))

(define-word min (:word "MIN")
  "( n1 n2 - n3)"
  "Push the smaller of N1 and N2 onto the data stack"
  (stack-push data-stack (cell-signed (min (stack-pop data-stack) (stack-pop data-stack)))))

(define-word negate (:word "NEGATE")
  "( n1 - n2 )"
  "Change the sign of the top of the data stack"
  (stack-push data-stack (cell-signed (- (stack-pop data-stack)))))

(define-word or (:word "OR")
  "( x1 x2 - x3 )"
  "Return the bitwise logical inclusive or of X1 with X2"
  (stack-push data-stack (cell-unsigned (logior (stack-pop data-stack) (stack-pop data-stack)))))

(define-word within (:word "WITHIN")
  "( x1 x2 x3 - flag )"
  "Returns true if X2 <= X1 < X3. X1, X2, and X3 should be either all signed or all unsigned"
  (let ((x3 (stack-pop data-stack))
        (x2 (stack-pop data-stack))
        (x1 (stack-pop data-stack)))
    (if (and (<= x2 x1) (< x1 x3))
        (stack-push data-stack +true+)
        (stack-push data-stack +false+))))

(define-word xor (:word "XOR")
  "( x1 x2 - x3 )"
  "Return the bitwise logical exclusive or of X1 with X2"
  (stack-push data-stack (cell-unsigned (logxor (stack-pop data-stack) (stack-pop data-stack)))))


;;; 2.3.2.1 Variables

(defun push-parameter-as-cell (fs &rest parameters)
  (with-forth-system (fs)
    (stack-push data-stack (first parameters))))

(define-word variable (:word "VARIABLE")
  "VARIABLE <name>"
  "Allocate a cell in data space and create a dictionary entry for <name> which returns the address of that cell"
  (let ((name (word files #\Space)))
    (when (null name)
      (forth-error :zero-length-name))
    (align-memory memory)
    (let* ((address (allocate-memory memory +cell-size+))
           (word (make-word name #'push-parameter-as-cell :parameters (list address))))
      (add-word (word-lists-compilation-word-list word-lists) word))))

(define-word 2variable (:word "2VARIABLE")
  "2VARIABLE <name>"
  "Allocate two cells in data space and create a dictionary entry for <name> which returns the address of the first cell"
  (let ((name (word files #\Space)))
    (when (null name)
      (forth-error :zero-length-name))
    (align-memory memory)
    (let* ((address (allocate-memory memory (* 2 +cell-size+)))
           (word (make-word name #'push-parameter-as-cell :parameters (list address))))
      (add-word (word-lists-compilation-word-list word-lists) word))))

(define-word cvariable (:word "CVARIABLE")
  "CVARIABLE <name>"
  "Allocate a byte in data space and create a dictionary entry for <name> which returns the address of that byte"
  (let ((name (word files #\Space)))
    (when (null name)
      (forth-error :zero-length-name))
    (let* ((address (allocate-memory memory 1))
           (word (make-word name #'push-parameter-as-cell :parameters (list address))))
      (add-word (word-lists-compilation-word-list word-lists) word))))


;;; 2.3.2.2 Constants and Values

(define-word constant (:word "CONSTANT")
  "CONSTANT <name>" "( x - )"
  "Create a dictionary entry for <name> which pushes signed integer X on the data stack"
  (let ((name (word files #\Space))
        (value (stack-pop data-stack)))
    (when (null name)
      (forth-error :zero-length-name))
    (let ((word (make-word name #'push-parameter-as-cell :parameters (list value))))
      (add-word (word-lists-compilation-word-list word-lists) word))))

(defun push-parameter-as-double-cell (fs &rest parameters)
  (with-forth-system (fs)
    (stack-push-double data-stack (first parameters))))

(define-word 2constant (:word "2CONSTANT")
  "2CONSTANT <name>" "( x1 x2 - )"
  "Create a dictionary entry for <name> which pushes the signed double integer X1,X2 on the data stack"
  (let ((name (word files #\Space))
        (value (stack-pop-double data-stack)))
    (when (null name)
      (forth-error :zero-length-name))
    (let ((word (make-word name #'push-parameter-as-double-cell :parameters (list value))))
      (add-word (word-lists-compilation-word-list word-lists) word))))

(defun push-cell-at-parameter (fs &rest parameters)
  (with-forth-system (fs)
    (stack-push data-stack (memory-cell memory (first parameters)))))

(define-word value (:word "VALUE")
  "VALUE <name>" "( x - )"
  "Allocate a cell in data space, initialize it to X, and create a dictionary entry for <name> which returns"
  "the contents of that cell in data space. To change the value, use TO"
  (let ((name (word files #\Space))
        (value (stack-pop data-stack)))
    (when (null name)
      (forth-error :zero-length-name))
    (align-memory memory)
    (let* ((address (allocate-memory memory +cell-size+))
           (word (make-word name #'push-cell-at-parameter :parameters (list address :value))))
      (setf (memory-cell memory address) value)
      (add-word (word-lists-compilation-word-list word-lists) word))))


;;; 2.3.3 Arrays and Tables

(define-word create-cell (:word ",")
  "( x - )"
  "Allocate one cell in data space and store x in the cell"
  (let ((value (stack-pop data-stack))
        (address (allocate-memory memory +cell-size+)))
    (setf (memory-cell memory address) value)))
  
(define-word align (:word "ALIGN")
  "( - )"
  "If the data space pointer is not aligned, reserve enough space to align it"
  (align-memory memory))

(define-word aligned (:word "ALIGNED")
  "( addr - a-addr) "
  "Return A-ADDR, the first aligned address greater than or equal to ADDR"
  (let ((addr (stack-pop data-stack)))
    (if (zerop (mod addr +cell-size+))
        addr
        (+ addr (- +cell-size+ (mod addr +cell-size+))))))

(define-word allocate (:word "ALLOT")
  "( u - )"
  "Allocate U bytes of data space beginning at the next available location"
  (let ((count (stack-pop data-stack)))
    (unless (plusp count)
      (forth-error :invalid-numeric-argument "Byte count to ALLOT can't be negative"))
    (allocate-memory memory count)))

(define-word create-buffer (:word "BUFFER:")
  "BUFFER: <name>" "( n - )"
  "Reserve N bytes of memory and create a dictionary entry for <name> that returns the address of the first byte"
  (let ((name (word files #\Space)))
    (when (null name)
      (forth-error :zero-length-name))
    (let* ((count (stack-pop data-stack))
           (address (allocate-memory memory count))
           (word (make-word name #'push-parameter-as-cell :parameters (list address))))
      (add-word (word-lists-compilation-word-list word-lists) word))))

(define-word create-char (:word "C,")
  "( char - )"
  "Allocate space for one character in data space and store CHAR"
  (let ((value (stack-pop data-stack))
        (address (allocate-memory memory +char-size+)))
    (setf (memory-char memory address) (extract-char value))))

(define-word cell-incf (:word "CELL+")
  "( a-addr1 - a-addr2 )"
  "Add the size of a cell in bytes to A-ADDR1, giving A-ADDR2"
  (stack-push data-stack (+ (stack-pop data-stack) +cell-size+)))

(define-word cells-size (:word "CELLS")
  "( n1 - n2 )"
  "Return the size in bytes of n1 cells"
  (stack-push data-stack (* (stack-pop data-stack) +cell-size+)))

(define-word char-incf (:word "CHAR+")
  "( a-addr1 - a-addr2 )"
  "Add the size of a character in bytes to A-ADDR1, giving A-ADDR2"
  (stack-push data-stack (+ (stack-pop data-stack) +char-size+)))

(define-word chars-size (:word "CHARS")
  "( n1 - n2 )"
  "Return the size in bytes of n1 characters"
  (stack-push data-stack (* (stack-pop data-stack) +char-size+)))

(define-word create (:word "CREATE")
  "CREATE <name>"
  "Create a dictionary entry for <name> that returns the address of the next available location in data space"
  (let ((name (word files #\Space)))
    (when (null name)
      (forth-error :zero-length-name))
    (let* ((address (data-space-high-water-mark memory))
           (word (make-word name #'push-parameter-as-cell :parameters (list address))))
      (add-word (word-lists-compilation-word-list word-lists) word))))


;;; 2.3.4 Memory Stack Operations

(define-word write-cell (:word "!")
  "( x a-addr - )"
  "Store the cell X at the address A-ADDR"
  (let ((address (stack-pop data-stack))
        (data (stack-pop data-stack)))
    (setf (memory-cell memory address) data)))

(define-word incf-cell (:word "+!")
  "( n a-addr - )"
  "Add N to the contents of the cell at A-ADDR and store the result back into A-ADDR"
  (let ((address (stack-pop data-stack))
        (n (stack-pop data-stack)))
    (setf (memory-cell memory address) (cell-signed (+ (memory-cell memory address) n)))))

(define-word write-two-cells (:word "2!")
  "( x1 x2 a-addr - )"
  "Store the two cells X1 and X2 in the two cells beginning at the address A-ADDR"
  (let ((address (stack-pop data-stack))
        (data (stack-pop-double data-stack)))
    (setf (memory-double-cell memory address) data)))

(define-word read-two-cells (:word "2@")
  "( a-addr - x1 x2 )"
  "Push the contents of the two cells starting at the address A-ADDR onto the data stack"
  (stack-push-double data-stack (memory-double-cell memory (stack-pop data-stack))))

(define-word read-cell (:word "@")
  "( a-addr - x )"
  "Push the contents of the cell at the address A-ADDR onto the data stack"
  (stack-push data-stack (cell-signed (memory-cell memory (stack-pop data-stack)))))

(define-word write-blanks (:word "BLANK")
  "( c-addr u - )"
  "Set a region of memory, at address C-ADDR and of length U, to ASCII blanks"
  (let ((count (stack-pop data-stack))
        (address (stack-pop data-stack)))
    (unless (plusp count)
      (forth-error :invalid-numeric-argument "Count to BLANK can't be negative"))
    ;; NOTE: Relies on the fact that +CHAR-SIZE+ is 1
    (memory-fill memory address count +forth-char-space+)))

(define-word write-char (:word "C!")
  "( char a-addr - )"
  "Store the character CHAR at the address A-ADDR"
  (let ((address (stack-pop data-stack))
        (char (extract-char (stack-pop data-stack))))
    (setf (memory-char memory address) char)))

(define-word incf-char (:word "C+!")
  "( char a-addr - )"
  "Add CHAR to the contents of the character at A-ADDR and store the result back into A-ADDR"
  (let ((address (stack-pop data-stack))
        (char (extract-char (stack-pop data-stack))))
    (setf (memory-char memory address) (extract-char (+ (memory-char memory address) char)))))

(define-word read-char (:word "C@")
  "( a-addr - char )"
  "Push the character at the address A-ADDR onto the data stack"
  (stack-push data-stack (memory-char memory (stack-pop data-stack))))

(define-word erase-memory (:word "ERASE")
  "( c-addr u - )"
  "Set a region of memory, at address C-ADDR and of length U, to zero"
  (let ((count (stack-pop data-stack))
        (address (stack-pop data-stack)))
    (unless (plusp count)
      (forth-error :invalid-numeric-argument "Count to ERASE can't be negative"))
    (memory-fill memory address count 0)))

(define-word fill-memory (:word "FILL")
  "( c-addr u b - )"
  "Set a region of memory, at address C-ADDR and of length U, to the byte B"
  (let ((byte (ldb (byte 8 0) (stack-pop data-stack)))
        (count (stack-pop data-stack))
        (address (stack-pop data-stack)))
    (unless (plusp count)
      (forth-error :invalid-numeric-argument "Count to FILL can't be negative"))
    (memory-fill memory address count byte)))

(define-word move-memory (:word "MOVE")
  "( addr1 addr2 u - )"
  "Copy U bytes starting from a source starting at the address ADDR1 to the destination starting at address ADDR2"
  (let ((count (stack-pop data-stack))
        (destination (stack-pop data-stack))
        (source (stack-pop data-stack)))
    (unless (plusp count)
      (forth-error :invalid-numeric-argument "Count to MOVE can't be negative"))
    (memory-copy memory source destination count)))

(define-word to (:word "TO")
  "TO <name>" "( x - )"
  "Store X in the data space associated with <name> which must have been created with VALUE"
  (let* ((name (word files #\Space))
         (word (lookup word-lists name))
         (value (stack-pop data-stack)))
    (when (null name)
      (forth-error :zero-length-name))
    (when (null word)
      (forth-error :undefined-word "~A is not defined" name))
    (unless (eq (second (word-parameters word)) :value)
      (forth-error :invalid-name-argument "~A was not created by VALUE"))
    (setf (memory-cell memory (first (word-parameters word))) value)))


;;; 3.6.2 Numeric Output

(define-word print-tos (:word ".")
  "( n - )"
  "Display the top cell of the data stack as a signed integer"
  (let ((value (cell-signed (stack-pop data-stack))))
    (format t "~VR " base value)))

(define-word print-tos-unsigned (:word "U.")
  "( u - )"
  "Display the top cell of the data stack as an unsigned integer"
  (let ((value (cell-unsigned (stack-pop data-stack))))
    (format t "~VR " base value)))


;;; 6.2.2 Colon Definitions

(define-word start-definition (:word ":")
  ": <name>"
  ""
  (let ((name (word files #\Space)))
    (when (null name)
      (forth-error :zero-length-name))
    (unless (null (lookup word-lists name))
      (format t "~A is not unique. " name))
    (begin-compilation fs)
    (setf (word-name compiling-word) name)))

;;; :NONAME

(define-word finish-definition (:word ";" :immediate? t :compile-only? t)
  ""
  (finish-compilation fs)
  (align-memory memory))

;;; RECURSE


;;; 6.3.1 The Forth Compiler

;;; COMPILE,

(define-state-word state)

(define-word interpret (:word "[" :immediate? t :compile-only? t)
  "Temporarily switch from compiling a definition to interpreting words"
  (setf compiling-paused? t)
  (setf (state fs) :interpreting))

(define-word compile (:word "]")
  "Switch back to compiling a definition after using ']'"
  (unless (shiftf compiling-paused? nil)
    (forth-error :not-compiling "Can't resume compiling when nothing's being compiled"))
  (setf (state fs) :compiling))


;;; 6.6.2 Managing Word Lists

(define-state-word context)

(define-state-word current)
