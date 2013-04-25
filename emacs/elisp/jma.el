
;; This is a hack, I should bind it to a key
(defun mozilla ()
  (interactive)
  ;(browse-url-of-file "Z:/public_html/index.html"))
  (browse-url-of-file "http://www.ficc.gs.com/~abrjef/"))
(global-set-key [f8] 'mozilla)

;; OLD VERSION, probably ok to delete, 5-nov-2007
;; (defun jma-grep (pattern prefix)
;;   "Search for pattern in the files u:/data/notes/*txt.
;; Search is case insensitive unless  a prefix argument is provided,
;; in which case the search becomes case-sensitive."
;;   (interactive "sPattern: \np")
;;   (let ((flag (if (not (= prefix 1)) "" "-i")))
;;     (compilation-start
;;      (concat "grep " flag " -n -e \"" pattern "\" " (getenv "HOME") "data/*.txt")
;;      'grep-mode)))

(defun jma-grep (pattern prefix)
  "Search for pattern in the files u:data/notes/*txt.
Search is case insensitive unless  a prefix argument is provided,
in which case the search becomes case-sensitive."
  (interactive "sPattern: \np")
  (let ((flag (if (not (= prefix 1)) "" "-i"))
	(args (split-string pattern)))
    (let ((cmd (concat "grep " flag
		       " -n -e \"" (car args) "\" "
		       "u:data/notes/*.txt")))
      (compilation-start
       (jma-grep-sub cmd flag (cdr args))
       'grep-mode))))

(defun jma-grep-sub (cmd flag args)
  "cmd is a grep command, args are more things to grep for in the results.
flag should be valid grep flags (typically '-i') or else the empty string."
  (message cmd)
  (if args
      (jma-grep-sub (concat cmd "| grep " flag " -e " (car args))
		   flag
		   (cdr args))
    cmd))

(global-set-key [f9] 'jma-grep)


(require 'add-log)

(defun jma-doc-note ()
  "Insert date string followed by four blank lines at beginning
  of file, placing mark two lines after."
  (interactive)
  (goto-char (point-min))
  (insert "** [" (funcall add-log-time-format) "]\n\n\n\n\n")
  (backward-char 3))

(global-set-key [C-f12] 'jma-doc-note)

(defun jma-doc-update ()
  "Insert date string followed by four blank lines at beginning
  of file, placing mark two lines after."
  (interactive)
  (beginning-of-line)
  (insert " ** Updated [" (funcall add-log-time-format) "]\n\n\n")
  (backward-char 2))

(global-set-key [C-S-f12] 'jma-doc-update)


(defun jma-daily-log ()
  "Find my daily change log and add an entry about what I did today"
  (interactive)
  (let ((daily-log-file "u:data/daily.log"))
    (find-file daily-log-file)
    (add-change-log-entry nil daily-log-file nil t)))

(defun jma-weekly-log ()
  "Find my weekly change log and add an entry"
  (interactive)
  (let ((weekly-log-file "u:/data/weekly.log"))
    (find-file weekly-log-file)
    (goto-char (point-min))
    (insert (format-time-string "%Y-%m-%d") "    " "\n")
    (goto-char (point-min))
    (end-of-line)))

(global-set-key [M-f12] 'jma-daily-log)
(global-set-key [M-S-f12] 'jma-weekly-log)

;; Useful at GS
;; (defun jma-location ()
;;   "Where is this disk?"
;;   (interactive)
;;   (save-excursion
;;     (find-file "u:.LOCATION")
;;     (message (concat "u: is mapped to " (buffer-substring (point-min) (point-max))))
;;     (kill-buffer (current-buffer))
;;     ))

;; (global-set-key [C-f8] 'jma-location)


(defun gpl-for-me (prog-name)
  "Create a GPL string for a module of prog-name."
  (let ((copyright-string (replace-regexp-in-string "%d" (format-time-string "%Y")
						   "Copyright %d  Jeff Abrahamson")))
    (let ((gpl-list (list copyright-string
			  ""
			  "This file is part of %s."
			  ""
			  "%s is free software: you can redistribute it and/or modify"
			  "it under the terms of the GNU General Public License as published by"
			  "the Free Software Foundation, either version 3 of the License, or"
			  "(at your option) any later version."
			  ""
			  "%s is distributed in the hope that it will be useful,"
			  "but WITHOUT ANY WARRANTY; without even the implied warranty of"
			  "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
			  "GNU General Public License for more details."
			  ""
			  "You should have received a copy of the GNU General Public License"
			  "along with %s.  If not, see <http://www.gnu.org/licenses/>."
			  )))
    (replace-regexp-in-string "%s" prog-name
			      (mapconcat 'identity gpl-list "\n")))))



(defun c-header-init (prog-name)
  "Insert standard copyright and header protection code"
  (interactive "*sProgram Name:  ")
  (if (= (point-min) (point-max))
      (progn
	(insert (concat
		 "/*\n"
		 (replace-regexp-in-string "^" "  " (gpl-for-me prog-name))
		"\n*/\n\n\n\n"))
	(if (string-match "\\.h$" (buffer-name))
	    (let ((guard-name (upcase
			       (concat "__"
				       (replace-regexp-in-string "\\." "_" (buffer-name))
				       "__"))
			      ))
	      (insert (concat
		       "#ifndef " guard-name "\n"
		       "#define " guard-name " 1\n"
		       "\n\n\n"
		       "#endif  /* " guard-name "*/\n")))))
    (message "Buffer is not empty.")))


(defun py-header-init (prog-name)
  "Insert standard copyright and header protection code"
  (interactive "*sProgram Name:  ")
  (if (= (point-min) (point-max))
      (progn
	(insert (concat
		 "#!/usr/bin/python\n\ngpl=\"\"\"\n"
		 (gpl-for-me prog-name)
		"\n\"\"\"\n\n\n\n")))
    (message "Buffer is not empty.")))


(defun c++-accessor (m_name m_type)
  "Add accessor functions for member"
  (interactive "*sMember Name: \nsType: ")
  (let ((f_name (replace-regexp-in-string "m_" "" m_name)))
    (beginning-of-line)
    (newline-and-indent)
    (insert (concat "const " m_type " &" f_name "() const { return " m_name "; };"))
    (newline-and-indent)
    (insert (concat "void " f_name "(const " m_type " &in) { " m_name " = in; };\n"))))