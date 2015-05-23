;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is part of xyzzy.
;;;

; .xyzzy 
;
;;---------------------------------------
;; delphi-mode.l
;;---------------------------------------
;(load-library "delphi-mode")
;(push '("\\.pas$" . delphi-mode) *auto-mode-alist*)
;(push '("\\.dpr$" . delphi-mode) *auto-mode-alist*)
;(push '("\\.p$" . pascal-mode) *auto-mode-alist*)


(provide "delphi")

(in-package "editor")

(export '(*delphi-mode-hook*
	  delphi-mode
	  *delphi-keyword-file*
	  delphi-electric-rbrace
	  delphi-goto-matched-parenthesis
	  *delphi-indent-tabs-mode*))

(defvar *delphi-mode-hook* nil)

(defvar *delphi-indent-tabs-mode* nil)

(defvar *delphi-keyword-hash-table* nil)
(defvar *delphi-keyword-file* "delphi")

(defvar *delphi-mode-syntax-table* nil)
(unless *delphi-mode-syntax-table*
  (setq *delphi-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
	(set-syntax-punctuation *delphi-mode-syntax-table* c))))
  (set-syntax-string *delphi-mode-syntax-table* #\")
  (set-syntax-string *delphi-mode-syntax-table* #\')
  ;(set-syntax-escape *delphi-mode-syntax-table* #\\)
  (set-syntax-symbol *delphi-mode-syntax-table* #\_)
  (set-syntax-match *delphi-mode-syntax-table* #\( #\))
  (set-syntax-match *delphi-mode-syntax-table* #\[ #\])
  (set-syntax-start-comment *delphi-mode-syntax-table* #\{)
  (set-syntax-end-comment *delphi-mode-syntax-table* #\})
  (set-syntax-start-multi-comment *delphi-mode-syntax-table* "(*")
  (set-syntax-end-multi-comment *delphi-mode-syntax-table* "*)")
  (set-syntax-start-c++-comment *delphi-mode-syntax-table* #\/)
  (set-syntax-end-c++-comment *delphi-mode-syntax-table* #\LFD))

(defvar *delphi-mode-map* nil)
(unless *delphi-mode-map*
  (setq *delphi-mode-map* (make-sparse-keymap))
  (define-key *delphi-mode-map* #\} 'delphi-electric-rbrace)
  (define-key *delphi-mode-map* '(#\ESC #\]) 'delphi-goto-matched-parenthesis))

(defvar *delphi-mode-abbrev-table* nil)
(unless *delphi-mode-abbrev-table*
  (define-abbrev-table '*delphi-mode-abbrev-table*))

(defun delphi-electric-rbrace (&optional (arg 1))
  (interactive "*p")
  (self-insert-command arg)
  (and (interactive-p)
       (not *executing-macro*)
       (save-excursion
	 (and (scan-buffer "{" :reverse t)
	      (show-matched-parenthesis))))
  t)

(defun delphi-goto-matched-parenthesis ()
  (interactive)
  (cond ((looking-at "[][()]")
	 (goto-matched-parenthesis))
	((looking-for "}")
	 (unless (scan-buffer "{" :reverse t)
	   (message "ˆê’v‚·‚éŠ‡ŒÊ‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ")))
	((looking-for "{")
	 (unless (scan-buffer "}")
	   (message "ˆê’v‚·‚éŠ‡ŒÊ‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ")))
	(t
	 (let ((pos (save-excursion
		      (let ((tail (progn
				    (skip-syntax-spec-forward "w_")
				    (point))))
			(skip-syntax-spec-backward "w_")
			(cond ((and (looking-for "begin" t)
				    (= (- tail (point)) 5))
			       (goto-char tail)
			       (if (forward-identifier "end" "begin" t)
				   (point)
				 (progn
				   (message "ˆê’v‚·‚éend‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ")
				   nil)))
			      ((and (looking-for "end" t)
				    (= (- tail (point)) 3))
			       (forward-char -1)
			       (if (backward-identifier "begin" "end" t)
				   (point)
				 (progn
				   (message "ˆê’v‚·‚ébegin‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ")
				   nil))))))))
	   (when pos
	     (goto-char pos))))))

(defun delphi-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "delphi")
  (setq buffer-mode 'delphi-mode)
  (use-syntax-table *delphi-mode-syntax-table*)
  (use-keymap *delphi-mode-map*)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start "^$\\|\f")
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'indent-tabs-mode)
  (setq indent-tabs-mode *delphi-indent-tabs-mode*)
  (and *delphi-keyword-file*
       (null *delphi-keyword-hash-table*)
       (setq *delphi-keyword-hash-table*
	     (load-keyword-file *delphi-keyword-file* t)))
  (when *delphi-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *delphi-keyword-hash-table*))
  (setq *local-abbrev-table* *delphi-mode-abbrev-table*)
  (setq comment-start "// ")
  (setq comment-end "")
  (setq comment-start-skip "/\\(\\*+\\|/\\)[ \t]*")
  (setq comment-indent-function 'c-comment-indent)
  (run-hooks '*delphi-mode-hook*))
