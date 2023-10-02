;;; mix-mode.el --- major mode for editing MIX code

;; Copyright (C) 2000, 2007 Sergey Poznyakoff.

;; Authors: 2000, 2007 Sergey Poznyakoff
;; Version:  1.0
;; Keywords: mix TAOCP languages
;; $Id: mix-mode.el 154 2007-09-19 15:17:53Z gray $

;; This file is part of MIX simulator.

;; MIX simulator is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; MIX simulator is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(defvar mix-mode-syntax-table nil
  "Syntax table used in mix-mode buffers.")
(if mix-mode-syntax-table
    ()
  (setq mix-mode-syntax-table (make-syntax-table))
  (modify-syntax-entry ?* "<")
  (modify-syntax-entry ?\n ">"))

(defvar mix-mode-map ()
  "Keymap used in mix-mode buffers.")
(if mix-mode-map
    ()
  (setq mix-mode-map (make-sparse-keymap))
  (define-key mix-mode-map "\t" 'mix-tab-to-tab-stop)
  (define-key mix-mode-map "%" 'mix-match-paren-or-self-insert)
  (mapc (function (lambda (c)
		    (define-key mix-mode-map c 'mix-upcase-self-insert)))
	'("a" "b" "c" "d" "e" "f"
	  "g" "h" "i" "j" "k" "l"
	  "m" "n" "o" "p" "q" "r"
	  "s" "t" "u" "v" "w" "x" "y" "z")))

(defgroup mix nil
  "MIX"
  :group 'unix
  :group 'languages)

(defgroup mix-input nil
  "MIX major mode"
  :group 'mix
  :prefix "mix-")

(defcustom mix-auto-upcase t
  "*Whether to automatically upcase first three fields of a MIX text."
  :type 'boolean
  :group 'mix-input)


(defun mix-upcase-self-insert (arg)
  "If mix-auto-upcase is set and the current column is within the actual MIX
program text (i.e. first three columns as set by tab-stop-list), insert
the input character in upper-case. Otherwise, insert it as is."
  (interactive "p")
  (if (and mix-auto-upcase (< (current-column) (nth 2 tab-stop-list)))
       (insert (upcase last-command-char))
    (self-insert-command arg)))

(defun mix-tab-to-tab-stop (&optional whole-exp)
  "Insert spaces or tabs to next defined tab-stop column in MIX mode."
  (interactive)
  (and abbrev-mode (= (char-syntax (preceding-char)) ?w)
       (expand-abbrev))
  (tab-to-tab-stop))

(defvar mix-mode-abbrev-table nil
  "Abbrev table in use in mix-mode buffers.")
(define-abbrev-table 'mix-mode-abbrev-table ())

;;; Label lookup routines

;; Find the definition of local label argH. Forward search.
(defun mix-find-local-forward (arg)
  (push-mark)
  (cond
   ((search-forward-regexp (concat "^" arg "H") nil t)
    (beginning-of-line))
   (t
    (pop-mark)
    (message (concat "Local definition of " arg "H not found")))))
  
;; Find the definition of local label argH. Backward search.
(defun mix-find-local-backward (arg)
  (push-mark)
  (cond
   ((search-backward-regexp (concat "^" arg "H") nil t)
    (beginning-of-line))
   (t
    (pop-mark)
    (message (concat "Local definition of " arg "H not found")))))

;; Find the reference to the local label argB. 
(defun mix-find-local-ref-forward (arg)
  (push-mark)
  (cond
   ((search-forward-regexp (concat "\\s " arg "B\\s ") nil t)
    (forward-char 1))
   (t
    (pop-mark)
    (message (concat "Reference to " arg "B not found")))))

;; Find the reference to the local label argF
(defun mix-find-local-ref-backward (arg)
  (push-mark)
  (cond
   ((search-backward-regexp (concat "\\s " arg "F\\s ") nil t)
    (forward-char 1))
   (t
    (pop-mark)
    (message (concat "Reference to " arg "F not found")))))

;; Find the definition of the label STRING, search forward
(defun mix-find-label-forward (string &optional msg)
  (push-mark)
  (forward-line 1)
  (cond
   ((search-forward-regexp (concat "^" string "\\s ") nil t)
    (forward-word -1))
   (msg
    (exchange-point-and-mark)
    (pop-mark)
    (message (concat "Label " string " not found")))
   (t
    (exchange-point-and-mark)
    (pop-mark)
    nil)))

;; Find the definition of the label STRING, search backward
(defun mix-find-label-backward (string &optional msg)
  (push-mark)
  (forward-line -1)
  (cond
   ((search-backward-regexp (concat "^" string "\\s ") nil t)
    t)
   (msg
    (exchange-point-and-mark)
    (pop-mark)
    (message (concat "Label " string " not found")))
   (t
    (exchange-point-and-mark)
    (pop-mark)
    nil)))

(defun mix-find-equ (string)
  (push-mark)
  (cond
   ((search-backward-regexp (concat "^" string "\\s EQU") nil t)
    t)
   (t
    (message (concat "Literal " string " not defined")))))

;; Ask user for the search direction 
(defun mix-read-search-direction ()
  "Ask user for the direction of the search.
Allowed replies are `f' for forward, `b' for backward and C-g for cancel."
  (message "search direction (f, b): ")
  (let (r)
    (while (not r)
      (let ((c (read-char)))
	(setq r (cond
		 ((eq c ?b)
		  "backward")
		 ((eq c ?f)
		  "forward")
		 (t
		  (progn
		    (message "Please, answer f or b:")
		    nil))))))
    r))

(defun mix-match-paren-hook (&optional arg)
 (interactive "p")
 (cond
  ((looking-at "\\([1-9]\\)B\\s ")
   (mix-find-local-backward (buffer-substring (match-beginning 1)
					 (1+ (match-beginning 1)))))
  ((looking-at "\\([1-9]\\)F\\s ")
   (mix-find-local-forward (buffer-substring (match-beginning 1)
	  			         (1+ (match-beginning 1)))))
  ((looking-at "^\\([1-9]\\)H\\s ")
   (let ((dir (mix-read-search-direction)))
     (funcall (intern (concat "mix-find-local-ref-" dir))
	      (buffer-substring (match-beginning 1)
				(1+ (match-beginning 1))))))
  ((looking-at "\\s *\\([A-Z][A-Z0-9]*\\)")
   (or
    (mix-find-label-forward (buffer-substring (match-beginning 1)
					      (match-end 1)))
    (mix-find-label-backward (buffer-substring (match-beginning 1)
					       (match-end 1)) t)))
  ((looking-at "=\\([A-Z][A-Z0-9]*\\)=")
   (mix-find-equ (buffer-substring (match-beginning 1)
				   (match-end 1))))
  (arg
   (self-insert-command arg))))

(defun mix-match-paren-or-self-insert (arg)
  (interactive "p")
  (mix-match-paren-hook arg))

(defun mix-match-paren ()
  (mix-match-paren-hook))

;;;###autoload
(defun mix-mode ()
  "Major mode for editing MIX code.

Key bindings:
\\{mix-mode-map}
"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table mix-mode-syntax-table)
  (make-local-variable 'tab-stop-list)
  (make-local-variable 'left-margin)
  (setq major-mode 'mix-mode
	mode-name "MIX"
	local-abbrev-table mix-mode-abbrev-table
	tab-stop-list '(8 13 32 40 48 56 64 72 80 88 96 104 112 120)
	left-margin 8)
  (use-local-map mix-mode-map))
  
(provide 'mix-mode)
;;; mix-mode ends

