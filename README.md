# CL-Forth

Common Lisp implementation of the [Forth 2012 Standard](https://forth-standard.org), CL-Forth

## Supported Platforms

CL-Forth is fully supported by CCL v1.12.2-82 or later.

CL-Forth also supports SBCL 2.1.0 or later. However, at present, the word `RESIZE-FILE` will always return an error indication,
resulting in 7 failures in the File-Access word set tests.

CL-Forth compiles with LispWorks but crashes running the Forth test suite.


## Supported Operating Systems

CL-Forth is supported on macOS, Linux, and Windows.

On macOS, it has been verified to run on macOS Ventura or later.

On Linux, it has been verified to run on distributions with 5.10.162 kernels or later.

On Windows, it has been verified to run on Windows 10 or later.


## License

CL-Forth is made available under the terms of the [MIT License](LICENSE).


## Usage

CL-Forth is defined using ASDF and is dependent on the [CFFI](https://github.com/cffi/cffi) and
[trivial-gray-streams](https://github.com/trivial-gray-streams/trivial-gray-streams ) libraries.

To fetch a copy of CL-Forth and the [Forth 2012 Test Suite](https://github.com/gerryjackson/forth2012-test-suite.git) configured
to only run tests for those word sets implemented by CL-Forth.

``` bash
git clone https://github.com/gmpalter/cl-forth.git --recurse-submodules
```

To load CL-Forth into Lisp

``` lisp
(require '#:asdf)
(load "cl-forth.asd")
(asdf:load-system '#:cl-forth)
```

You can run the [Forth 2012 Test Suite](https://github.com/gerryjackson/forth2012-test-suite.git)

``` lisp
(asdf:test-system '#:cl-forth)
```

To start the CL-Forth interpreter loop

``` lisp
(forth:run)
```

CL-Forth is case-insensitive.


### Building a Standalone CL-Forth

You can build a standalone CL-Forth application.

Launch Lisp and evaluate the forms

``` lisp
(require '#:asdf)
(load "cl-forth.asd")
(asdf:load-system '#:cl-forth/application)
(forth-app:save-application "cl-forth")
```

This will create an executable named `cl-forth`. When you run `cl-forth`, it will startup directly into the Forth interpreter
loop.

``` forth
./cl-forth
CL-Forth Version 1.3
Running under Clozure Common Lisp Version 1.13 (v1.13) DarwinX8664
1 1 + .
2 OK.
: hello-world ." Hello World!" cr ;
OK.
hello-world
Hello World!
OK.
see hello-world
Source code for hello-world:
(DEFUN FORTH-WORDS::HELLO-WORLD (FS &REST PARAMETERS)
  (DECLARE (IGNORABLE PARAMETERS))
  (WITH-FORTH-SYSTEM (FS)
    (TAGBODY (WRITE-STRING "Hello World!")
             (TERPRI)
     :EXIT)))
OK.
bye
In this session:
  1 definition created
  240 bytes of object code generated
```

The application  recognizes these command line arguments

| | |
| --- | --- |
| `‑‑interpret EXPR`, `‑i EXPR` | Evaluate `EXPR` before entering the Forth interpreter loop. `EXPR` may need to be quoted to avoid interpretation by the shell.  This argument may be used multiple times. |
| `‑‑transcript PATH` | Record a timestamped transcript of this session in the file `PATH` |
| `‑‑help`, `‑h` | Display the available command line arguments and exit |
| `‑‑version`, `‑V` | Display the version of CL-Forth and exit |


## Missing Words

CL-Forth does not implement the optional Block word set.

CL-Forth does not implement the optional Extended-Character word set.

CL-Forth does not implement `KEY` which is part of the Core word set.

The following words that are part of the optional Facility and Facility extensions word set are not implemented.

| | | | | |
| --- | --- | --- | --- | --- |
| `AT-XY` | `KEY?` | `PAGE` | `EKEY` | `EKEY>CHAR` |
| `EKEY>FKEY` | `EKEY?` | `EMIT?` | `K-ALT-MASK` | `K-CTRL-MASK` |
| `K-DELETE` | `K-DOWN` | `K-END` | `K-F1` | `K-F10` |
| `K-F11` | `K-F12` | `K-F2` | `K-F3` | `K-F4` |
| `K-F5 `| `K-F6` | `K-F7` | `K-K8` | `K-F9` |
| `K-HOME` | `K-INSERT` | `K-LEFT` | `K-NEXT` | `K-PRIOR` |
| `K-RIGHT` | `K-SHIFT-MASK` | `K-UP` |

  
## Foreign Function Interface

CL-Forth includes a foreign function interface (FFI) loosely based on the External Library Interface in
[SwiftForth](https://www.forth.com/swiftforth/). See [FFI.md](FFI.md) for details.


## Additional Words

CL-Forth includes a number of words defined by other implementation that are not part of the Forth 2012 Standard.

These words are specific to CL-Forth.

| | |
| --- | --- |
| `.SF` | Display the contents of the floating-point stack |
| `.SR` | Display the contents of the return stack |
|  `ALL-WORDS` | Display all words in all word lists in the search order |
| `BREAK` | Enter a Lisp break loop |
| `INLINEABLE` | Mark that the most recent definition's code may be inlined |
| `NOTINTERPRETED` | Mark that the most recent definition must only appear in definitions |
| `RELOAD` | Reload a predefined definition (i.e., created by `define-word`) |
| `REMOVE` | Erase a single word |
| `SHOW-BACKTRACES` | Controls whether exceptions display the return and data stacks |
| `SHOW-CODE` | Controls whether completing a definition shows the generated code |
| `STATISTICS` | Report some useful statistics about this CL-Forth session |

These words are defined as "Common Usage" in the [Forth Programmer's Manual, 3rd Edition](https://www.forth.com/forth-books/).

| | | | | |
| --- | --- | --- | --- | --- |
| `,"` | `2+` | `2-` | `C+!` | `CONTEXT` |
| `CURRENT` | `CVARIABLE` | `M-` | `M/` | `NOT` |
| `NUMBER` |`NUMBER?` | `VOCABULARY` |

These words are defined by [SwiftForth](https://www.forth.com/swiftforth/).

| | | | | | |
| --- | --- | --- | --- | --- | --- |
| `-?` | `EMPTY` | `GILD` | `OFF` | `ON` | `OPTIONAL` |
| `SILENT` | `VERBOSE` | `WARNING` | `\\` | `{` |


## Implementation

_TO BE SUPPLIED_


## Native Code Support

CL-Forth implements `CODE` and `;CODE` to allow the definition of words written in Lisp rather than Forth. The terminator for
the Lisp code block is `;ENDCODE`.

Here is an example of using native code.

``` c
\ ( c-addr1 u - c-addr2 u)
\ Converts the string at C-ADDR1 U to uppercase and leaves the result in transient space at C-ADDR2 U.
CODE UPCASE
  (let ((count (cell-signed (stack-pop data-stack)))
        (address (stack-pop data-stack)))
    (unless (plusp count)
      (forth-exception :invalid-numeric-argument "Count to UPCASE must be positive"))
    (multiple-value-bind (data offset)
        (memory-decode-address memory address)
      (let* ((original (forth-string-to-native data offset count))
             (upcased (string-upcase original))
             (string-space (reserve-string-space memory))
             (address (transient-space-base-address memory string-space)))
        (ensure-transient-space-holds memory string-space count)
        (multiple-value-bind (data offset)
            (memory-decode-address memory address)
          (native-into-forth-string upcased data offset)
          (seal-transient-space memory string-space)
          (stack-push data-stack address)
          (stack-push data-stack count)))))
;ENDCODE
```

