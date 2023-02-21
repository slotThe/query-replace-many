;;; query-replace-many.el --- A wrapper around `query-replace' that supports multiple matches -*- lexical-binding: t; -*-

;; Copyright (C) 2023  Tony Zorman
;;
;; Author: Tony Zorman <soliditsallgood@mailbox.org>
;; Keywords: convenience, keybindings
;; Version: 0.1
;; Package-Requires: ((emacs "24.1"))
;; Homepage: https://github.com/slotThe/query-replace-many

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package exposes `query-replace-many', a function that works like
;; `query-replace', only it works on multiple matches; that is, the user
;; can specify multiple (FROM . TO) replacement pairs, and an empty
;; query finalises the selection.
;;
;; A blog post, explaining some of the motivation behind the package, is
;; available here:
;;
;;        https://tony-zorman.com/posts/query-replace-many.html

;;; Code:

(eval-when-compile (require 'cl-lib))

(defun query-replace-many--get-queries (&optional pairs)
  "Get multiple `query-replace' pairs from the user.
PAIRS is a list of replacement pairs of the form (FROM . TO)."
  (pcase-let* ((`(,from ,to ,delim ,arg)
                (query-replace-read-args
                 (mapconcat #'identity
                            (seq-keep #'identity
                                      (list "Query replace many"
                                            (cond ((eq current-prefix-arg '-) "backward")
                                                  (current-prefix-arg         "word"))
                                            (when (use-region-p) "in region")))
                            " ")
                 nil))                  ; no regexp-flag
               (from-to (cons (regexp-quote from)
                              (replace-regexp-in-string "\\\\" "\\\\" to t t))))
    ;; HACK: Since the default suggestion of replace.el will be the last
    ;; one we've entered, an empty string will give us exactly that.
    ;; Instead of trying to fight against this, use it in order to
    ;; signal an exit.
    (if (member from-to pairs)
        (list pairs delim arg)
      (query-replace-many--get-queries (push from-to pairs)))))

(defun query-replace-many
    (pairs &optional delimited start end backward region-noncontiguous-p)
  "Like `query-replace', but query for several replacements.
Query for replacement PAIRS until the users enters an empty
string (but see `query-replace-many--get-queries').

The optional arguments DELIMITED, START, END, BACKWARD, and
REGION-NONCONTIGUOUS-P are as in `query-replace' and
`perform-replace', which see."
  (interactive
   (let ((common (query-replace-many--get-queries)))
     (list (nth 0 common)     (nth 1 common)
           (if (use-region-p) (region-beginning))
           (if (use-region-p) (region-end))
           (nth 2 common)     (if (use-region-p) (region-noncontiguous-p)))))
  (perform-replace
   (concat "\\(?:" (mapconcat #'car pairs "\\|") "\\)") ; build query
   (cons (lambda (pairs _count)
           (cl-loop for (from . to) in pairs
                    when (string-match from (match-string 0))
                    return to))
         pairs)
   :query :regexp delimited nil nil start end backward region-noncontiguous-p))

(provide 'query-replace-many)
;;; query-replace-many.el ends here
