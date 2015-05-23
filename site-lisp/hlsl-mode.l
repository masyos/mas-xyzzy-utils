;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is part of xyzzy.
;;;

;;---------------------------------------
;; hlsl-mode.l
;;---------------------------------------
;(load-library "hlsl-mode")
;(push '("\\.fx$" . hlsl-mode) *auto-mode-alist*)

(provide "hlsl-mode")

(in-package "editor")

(export '(hlsl-mode *default-c-mode* *hlsl-comment-column*
	  *hlsl-mode-hook* *hlsl-keyword-file* *hlsl-indent-tabs-mode*
	  *syntax-option-indent-hlsl*
	  hlsl-indent-level hlsl-continued-statement-offset
	  hlsl-argdecl-indent hlsl-brace-offset hlsl-brace-imaginary-offset
	  hlsl-label-offset hlsl-comment-indent))

(defvar *hlsl-mode-hook* nil)

(defconstant *syntax-option-indent-hlsl* 4)

(unless (boundp 'hlsl-indent-level)
  (setq hlsl-indent-level 2)
  (setq hlsl-continued-statement-offset 2)
  (setq hlsl-argdecl-indent 5)
  (setq hlsl-brace-offset 0)
  (setq hlsl-brace-imaginary-offset 0)
  (setq hlsl-label-offset -2)
  (setq hlsl-comment-indent 2))

(defvar *hlsl-keyword-hash-table* nil)
(defvar *hlsl-keyword-file* "HLSL")

(defvar *hlsl-indent-tabs-mode* nil)
(defvar *hlsl-comment-column* nil)

(defvar *hlsl-mode-syntax-table* nil)
(unless *hlsl-mode-syntax-table*
  (setq *hlsl-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
	(set-syntax-punctuation *hlsl-mode-syntax-table* c))))
  (set-syntax-option *hlsl-mode-syntax-table*
		     (+ *syntax-option-c-preprocessor*
			*syntax-option-indent-hlsl*))
  (set-syntax-string *hlsl-mode-syntax-table* #\")
  (set-syntax-string *hlsl-mode-syntax-table* #\')
  (set-syntax-escape *hlsl-mode-syntax-table* #\\)
  (set-syntax-symbol *hlsl-mode-syntax-table* #\_)
  (set-syntax-symbol *hlsl-mode-syntax-table* #\#)
  (set-syntax-match *hlsl-mode-syntax-table* #\( #\))
  (set-syntax-match *hlsl-mode-syntax-table* #\{ #\})
  (set-syntax-match *hlsl-mode-syntax-table* #\[ #\])
  (set-syntax-start-multi-comment *hlsl-mode-syntax-table* "/*")
  (set-syntax-end-multi-comment *hlsl-mode-syntax-table* "*/")
  (set-syntax-start-c++-comment *hlsl-mode-syntax-table* #\/)
  (set-syntax-end-c++-comment *hlsl-mode-syntax-table* #\LFD))

(defvar *hlsl-mode-map* nil)
(unless *hlsl-mode-map*
  (setq *hlsl-mode-map* (make-sparse-keymap))
  (define-key *hlsl-mode-map* #\{ 'c-electric-insert)
  (define-key *hlsl-mode-map* #\: 'c-electric-insert)
  (define-key *hlsl-mode-map* #\# 'c-electric-insert)
  (define-key *hlsl-mode-map* #\} 'c-electric-close)
  (define-key *hlsl-mode-map* #\C-h 'backward-delete-char-untabify-or-selection)
  (define-key *hlsl-mode-map* #\TAB 'c-indent-line)
  (define-key *hlsl-mode-map* #\C-M-q 'indent-sexp)
  (define-key *hlsl-mode-map* #\RET 'c-newline-and-indent))

(defvar *hlsl-mode-abbrev-table* nil)
(unless *hlsl-mode-abbrev-table*
  (define-abbrev-table '*hlsl-mode-abbrev-table*))

(autoload 'c-build-summary-of-functions "cfns" nil)

(defun hlsl-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "HLSL")
  (setq buffer-mode 'hlsl-mode)
  (use-syntax-table *hlsl-mode-syntax-table*)
  (use-keymap *hlsl-mode-map*)
  (make-local-variable 'mode-specific-indent-command)
  (setq mode-specific-indent-command 'c-indent-line)
  (make-local-variable 'c-comment-indent-variable)
  (setq c-comment-indent-variable 'hlsl-comment-indent)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start "^$\\|\f")
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'indent-tabs-mode)
  (setq indent-tabs-mode *hlsl-indent-tabs-mode*)
  (make-local-variable 'tags-find-target)
  (setq tags-find-target #'c-tags-find-target)
  (make-local-variable 'tags-find-point)
  (setq tags-find-point #'c-tags-find-point)
  (make-local-variable 'build-summary-function)
  (setq build-summary-function 'c-build-summary-of-functions)
  (and *hlsl-keyword-file*
       (null *hlsl-keyword-hash-table*)
       (setq *hlsl-keyword-hash-table*
	     (load-keyword-file *hlsl-keyword-file*)))
  (when *hlsl-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *hlsl-keyword-hash-table*))
  (setq *local-abbrev-table* *hlsl-mode-abbrev-table*)
  (setq comment-start "// ")
  (setq comment-end "")
  (setq comment-start-skip "/\\(\\*+\\|/\\)[ \t]*")
  (setq comment-indent-function 'c-comment-indent)
  (when *hlsl-comment-column*
    (setq comment-column *hlsl-comment-column*))
  (run-hooks '*hlsl-mode-hook*))

