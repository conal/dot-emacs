;;; -*- Emacs-Lisp -*-

(setq debug-on-error t)

;;; Common Lisp conveniences
(load-library "cl")

;; maybe a temp thing until I'm on emacs 22
;; (setq user-emacs-directory (getenv "HOME"))
;; Default is "~/.emacs.d/". I want to move my customizations there.

(setq my-extra-load-path
      '(;;;"~/gnu"
        "~/.emacs.d/elisp"
        "~/.emacs.d/elisp/erc-5.2"
        "~/.emacs.d/elisp/erc-5.2-extras"
        ;;; "~/gnu/site-lisp"
        ;; "~/gnu/haskell-mode-2.8.0"
        "~/darcs-repos/haskellmode-emacs/"
        "~/git-repos/ghc-mod/elisp"
        "~/git-repos/git-emacs"
        "~/git-repos/mmm-mode"
        ;; "~/gnu/ispell4"
        ))

(setq load-path
      (append (mapcar #'expand-file-name my-extra-load-path)
              load-path))

(setq inhibit-startup-message t)

(defconst tabula-dir
  (expand-file-name
   (if (eq system-type 'gnu/linux) "~" "~/Tabula"))
  "Directory for Tabula content.")


(put 'narrow-to-region 'disabled nil)
(put 'indent-region 'disabled t)
(put 'minibuffer-complete-and-exit 'disabled nil)
(put 'indent-region 'disabled nil)


; Backups.
(setq version-control 't)
(setq kept-old-versions 1)
(setq kept-new-versions 2)
(setq delete-old-versions t)


(load "bibtex")

;; (load "codeconv.el")
;;;(load "comment-region.el")  ;;; missing from winemacs


;; Dealing with control-m's and input echoing.  See
; http://www.cs.washington.edu/homes/voelker/ntemacs.html#shell-ctrlm
;; Doesn't seem to work
;; (add-hook 'comint-output-filter-functions 'shell-strip-ctrl-m)

;; (defun my-comint-init ()
;;   ;; (setq comint-process-echoes t)
;;   )
;; (add-hook 'comint-mode-hook 'my-comint-init)

;; Python support
(push "~/gnu/python-mode-1.0" load-path)
(push '("\\.py$" . python-mode) auto-mode-alist)
(push '("python" . python-mode) interpreter-mode-alist)
(autoload 'python-mode "python-mode" "Python editing mode." t)

;;; (defvar comint-mode-hook
;;;   '(lambda () "strip ^M"
;;;      (setq comint-output-filter-functions
;;;            (append '(comint-strip-ctrl-m) comint-output-filter-functions))))

;;; For remote file editing.  Not working yet.

;; (push "~/gnu/tramp-2.1.7/lisp" load-path)
;; (require 'tramp)

;; Use visual-lines-mode instead. Works sensibly with next-error.
;; (require 'longlines)

;;; Instead, require longlines where needed.
;; (autoload 'longlines-mode
;;   "longlines.el"
;;   "Minor mode for automatically wrapping long lines." t)

;; For tiddlywiki editing. see http://gimcrackd.com/etc/src/#Twee

;; used in longlines.el (used by twee)
(setq window-min-width 2)

;; (defvar my-journal-twee "~/Journal/journal.tw"
;;   "Location of daily journal twee file.")

;; (setq my-journal-twee "~/anygma/journal.tw")

;; (defun journal-entry (file-name)
;;   "Insert a new journal entry at start of file named by FILE-NAME."
;;   (interactive "f")
;;   (find-file file-name)
;;   (goto-char (point-max))
;;   (twee-no-longlines
;;    (unless (bolp) (newline)) ; start on fresh line
;;    (insert (format-time-string "\n:: %Y-%m-%d [%Y-%m day]\n* "))
;;    (open-line 1)
;;    ))

;; (defun new-day-tw ()
;;   "Insert a new journal entry."
;;   (interactive)
;;   (journal-entry "~/Journal/journal.tw")
;; ;;   (newline)(newline)
;; ;;   (insert "------------------") (newline)
;; ;;   (insert "LambdaPix hours: ") (newline)
;; ;;   (previous-line 4)
;; ;;   (end-of-line)
;;   )

;; ;; While I'm working with Anygma, use a different journal file.  Sort out non-private stuff later.
;; (defun anygma ()
;;   "Insert a new journal entry for anygma work."
;;   (interactive)
;;   (journal-entry "~/anygma/journal.tw"))

;; (defun new-day ()
;;   "Insert a new journal entry at start of file named by variable my-journal-twee."
;;   (interactive)
;;   (find-file my-journal-twee)
;;   (goto-char (point-max))
;;   (twee-no-longlines
;;    (unless (bolp) (newline)) ; start on fresh line
;;    (insert (format-time-string "\n:: %Y-%m-%d [%Y-%m day]\n* "))
;;    (open-line 1)
;;    ))

;; (defun anygma ()
;;   "Insert a new Anygma journal entry."
;;   (interactive)
;;   (find-file "~/Journal/anygma.md")
;;   (goto-char (point-max))
;;   (unless (bolp) (newline)) ; start on fresh line
;;   (insert (format-time-string "### %A %d %B, %Y"))
;;   (newline 2)
;;   (open-line 1)
;;   ))

(defun replace-nth (n x l)
  "Replace the Nth element of L with X"
  (let ((copy (copy-list l)))
    (setf (nth n copy) x)
    copy))

(defun tabula-journal ()
  "gitit (wiki) page for Tabula journal. See `journal'."
  (interactive)
  (a-journal (concat tabula-dir "/Journal")))

;; (defun personal-journal ()
;;   "gitit (wiki) page for personal journal. See `journal'."
;;   (interactive)
;;   (a-journal "~/Journal/wiki"))

(defalias 'journal 'tabula-journal)  

(defun a-journal (dir)
  "gitit (wiki) journal page.  A directory for each year, and a page for each week, named for the date of the Sunday of that week."
  (interactive "DWiki directory: ")
  (let* ((now (current-time))
         (dec-now (decode-time now))
         (day (nth 3 dec-now)) ;; day of month
         (dow (nth 6 dec-now)) ;; day of week
         ;; back up day of month & week
         (sunday (apply #'encode-time (replace-nth 3 (- day dow) (replace-nth 6 0 dec-now))))
         (file-name (concat dir (format-time-string "/wikidata/%Y/%m-%d.page" sunday)))
         ;; e.g. "# Monday, September 13, "
         (entry-header (format-time-string "# %A, %B %d\n" now)))
    (make-directory (file-name-directory file-name) t) ;; make if doesn't exist
    (find-file file-name)
    (twee-no-longlines
     (when (= (buffer-size) 0)
       ;; Header info.  The space before html comments avoid confusion with literate Haskell.
       ;; Using %e causes the day # to be blank-padded instead of zero-padded.
       ;; Or use %-e or %-d for no padding.
       (insert (format-time-string "---\ntitle: Notes for week of %B %e\n...\n\n" sunday))
       (insert " <!-- References -->\n\n <!-- -->\n"))
     ;; Insert entry header if not already present
     (goto-char (point-min))
     (if (search-forward entry-header nil t)
         (goto-char (point-max))
       (goto-char (point-max))
       (unless (bolp) (insert "\n"))   ; start on blank line
       ;; Clear final newlines for uniform separation
       (looking-back "\n+" nil t)
       (delete-region (match-beginning 0) (match-end 0))
       (newline 4)                     ; start on fresh line
       (previous-line)
       (insert entry-header "\n")
;;        (insert "## Hours\n\nxx hours: \n\n## ")
;;        (previous-line 2) (end-of-line)
       (markdown-mode)                 ; cleans up lhs mode spill-over
       )
     ))
  ;; For convenience, rename the buffer. If there's already a different
  ;; journal file, rename it first.
  (let ((journal-name "journal")
        (buf (current-buffer)))
    (let ((current-journal (get-buffer journal-name)))
      (when (and current-journal (not (eq buf current-journal)))
        (message "renaming")
        (save-excursion
          (set-buffer current-journal)
          (rename-buffer (file-name-nondirectory (buffer-file-name)))))
      (rename-buffer journal-name)))
  )


(defun google (string)
  "Run a Google search in a browser."
  (interactive "sSearch for: ")
  (browse-url (concat "http://www.google.com/search?q=" string)))

(defun google-region (from to &optional quoted)
  "Run a Google search on the contents of the region FROM/TO"
  (interactive "r\nP")
  ;; (message "google-region %d %d %s" from to quoted)
  (let ((str (buffer-substring from to)))
    (google (if quoted (concat "\"" str "\"") str))
    ))
(global-set-key "\C-cG" 'google-region)

(defun disqus-fix (start end)
  "Convert region markdown to HTML and fix up for use in a disqus comment.
Stash the result to the kill ring for pasting into a disqus comment box."
  (interactive "r")
  (save-window-excursion
    (shell-command-on-region start end "pandoc --smart --no-wrap")
    (switch-to-buffer "*Shell Command Output*")
    (flet ((rr (from to) 
               (replace-regexp from to nil (point-min) (point-max))))
      (rr "</p><p>" "</p><br><p>")
      (rr "<blockquote>\n<p>" "<blockquote>")
      (rr "</blockquote>\n<p>" "</blockquote><p>")
      (rr "</p></blockquote>" "</blockquote>")
      )
    (kill-ring-save (point-min) (point-max))
    ))


(defun quotes ()
  "Open quotes file, and paste a quotation."
  (interactive)
  (find-file (expand-file-name "~/Misc/quotes-tw.tw"))
  (goto-char (point-max))
  ;; Clear final newlines for uniform separation
  (looking-back "\n+" nil t)
  (delete-region (match-beginning 0) (match-end 0))
  (newline 3)                     ; start on fresh line
  (previous-line)
  (yank)
  )

(defun downloads ()
  "Open downloads file and prepare to add a new item."
  (interactive)
  (find-file (expand-file-name "~/Journal/download.md"))
  (goto-char (point-min))
  (search-forward "\nOne-time:\n\n" nil t)
  (open-line 1)
  (insert "* ")
  ;; (yank)
  )

(require 'javascript-mode)
(require 'css-mode)
;; (require 'hoogle)

;;; My own stuff

(load "~/darcs-repos/haskellmode-emacs/haskell-site-file")

(load "my-abbrev")
(load "my-text")
(load "my-tex")
(load "my-modes")
(load "my-mmm")


;;(load "my-shell")

(global-set-key "\C-c\C-a" 'align-regexp)

(require 'last-modified)
(setq user-full-name "Conal Elliott")
(push 'fix-last-modified-string write-file-hooks)

(add-hook 'find-file-hooks 'auto-insert)

(setq default-major-mode 'indented-text-mode)

;;; I have my own simpler markdown mode

;; (autoload 'markdown-mode "markdown-mode.el"
;;       "Major mode for editing Markdown files" t)

(setq auto-mode-alist
      (append '(
              ;;("\\.bib$"           . bibtex-mode)
              ;;("Makefile"          . makefile-mode)
                ("\\.bmp$"           . hexl-mode)
;;                 ("\\.hs$"            . haskell-mode)
;;                 ("\\.hsc$"           . haskell-mode)
;;                 ("\\.hi$"            . haskell-mode)
             ;; ("\\.lhs$"           . literate-haskell-mode)
                ("\\.lhs$"           . markdown-mode) ;; with mmm. happens in skel
             ;; ("\\.lhs$"           . twee-mode)
             ;; ("\\.lhs$"           . latex-mode)              ; rely on mmm-mode
;;                 ("\\.ly$"            . literate-haskell-mode)
             ;; ("itsalltext/.*"     . twee-mode) ;; before \\.txt
                ("mozex\\.textarea"  . twee-mode) ;; before \\.txt
                ("\\.tw$"            . twee-mode)
                ("\\.css$"           . css-mode)
                ("\\.js$"            . javascript-mode)
                ("\\-make.inc"       . makefile-mode)
                ("[mM]akefile"       . makefile-mode)
                ("\\.txt$"           . indented-text-mode)
                ("\\.md$"            . markdown-mode)
                ("\\.markdown$"      . markdown-mode)
                ;; omit markdown until paragraph fill works
;;                 ("\\.md\\(ml\\)?$"   . markdown-mode)
;;                 ("README\\|CHANGES\\|TODO$"   . markdown-mode)
                )
              auto-mode-alist))

;; Doesn't work.  Hm.
;; 
;; (push '("^Junk\\." auto-revert-tail-mode) auto-mode-alist)

;; ;; I like a big font.
;; (defun choose-big-font ()
;;   (interactive)
;;   (set-default-font "-outline-Courier New-bold-r-normal-normal-21-157-96-96-c-130-iso10646-1")
;;   )
;; ;; (choose-big-font)

;; Misc

;; Don't use.  The characters are all wrong and only kick in when I
;; explicitly font-lock-fontify-buffer.
;; (require 'pretty-lambda)

(global-set-key "\C-c#" 'what-line)

;;(global-set-key "\C-c\t" 'dynamic-complete)
;;(global-set-key "\C-c?" 'dynamic-list-completions)

;;(global-set-key "\C-c%" 'query-replace-regexp)

(global-set-key "\C-cg" 'goto-line)
(global-set-key "\C-c\C-t" 'transpose-paragraphs)

;; (global-set-key "\C-c\C-c" 'comment-region)

;;; For help on notating key sequences, see
;;; http://xahlee.org/emacs/keyboard_shortcuts.html

(defun new-entry (file-name intro-string)
  (find-file file-name)
  (end-of-buffer)
  (insert "\C-j\C-j")
  ;;(next-line 1)
  ;;(insert-time-stamp)
  (insert (current-time-string))
  (beginning-of-line)
  ;; delete time of day
  (forward-char 10)
  (delete-char 9)
  ;; put in asterisks and center
  (beginning-of-line)
  (insert "* * *  ")
  (end-of-line)
  (insert "  * * *")
  (center-line)
  (insert "\C-j\C-j" intro-string)
  (end-of-buffer)
  )


(defun was-new-day ()
  "Insert a new day header for my what-did file"
  (interactive)
  (new-entry "~/misc/what-did.txt" "Misc did:\C-j\C-j  - ")
  )

(defun nvc-journal ()
  "Insert a new day header for my nvc journal"
  (interactive)
  (new-entry "~/NVC/journal.txt" "")
  )

(defun save-replace (from to)
  (save-excursion
    (replace-string from to nil nil nil)))

(defun fix-quotes ()
  "Replace non-ascii quotes by ascii quotes"
  (interactive)
  ;; I guess there are a lot of unicode variations of quotation marks.
  ;; TODO: trade in these non-regexp replacements with regexp versions so that there's only one per result.
  (save-replace "\205" "...")
  (save-replace "…" "...")
  (save-replace "\222" "'")
  (save-replace "\223" "\"")
  (save-replace "\224" "\"")
  (save-replace "\226" "---")
  (save-replace "\227" "--")
  (save-replace "" "--")
  (save-replace "" "\"")
  (save-replace "" "\"")
  (save-replace "" "'")
  (save-replace "½" "1/2")
  (save-replace "“" "\"")
  (save-replace "“" "\"")
  (save-replace "“" "\"")
  (save-replace "”" "\"")
  (save-replace "“" "\"")
  (save-replace "”" "\"")
  (save-replace "”" "\"")
  (save-replace "”" "\"")
  (save-replace "“" "\"")
  (save-replace "”" "\"")
  (save-replace "“" "\"")
  (save-replace "”" "\"")
  (save-replace "“" "\"")
  (save-replace "“" "\"")
  (save-replace "”" "\"")
  (save-replace "“" "\"")
  (save-replace "”" "\"")
  (save-replace "”" "\"")
  (save-replace "“" "\"")
  (save-replace "‘" "'")
  (save-replace "‘" "'")
  (save-replace "’" "'")
  (save-replace "’" "'")
  (save-replace "’" "'")
  (save-replace "’" "'")
  (save-replace "’" "'")
  (save-replace "’" "'")
  (save-replace "’" "'")
  (save-replace "ﬁ" "fi")
  (save-replace "ﬀ" "ff")
  )

(defun fix-pdf ()
  "Replace non-ascii characters extracted from a pdf"
  (interactive)
  (save-replace "ﬀ" "ff")
  (save-replace "Pro ject" "Project")
  (save-replace "pro ject" "project")
  (save-replace "Ob ject" "Object")
  (save-replace "ob ject" "object")
  (save-replace "“" "\"")
  (save-replace "”" "\"")
  (save-replace "‘" "'")
  (save-replace "’" "'")
  ;; (save-replace "" "")
  )

(defun fix-symbols ()
  "Replace ascii symbols with unicode ones for blog post"
  (interactive)
  (save-replace "\<forall\>" "∀")
  (save-replace "-->" "#-#>")   ; hack to hide "->".  better?
  (save-replace "->" "→")
  (save-replace "#-#>" "-->")   ; matching hack
  (save-replace "\\ " "λ")
  (save-replace "`lub`" "⊔")
  (save-replace " \. " " ∘ ")
  (save-replace "=>" "⇒")
  (save-replace "==" "≡")
  )


(require 'compile)
(setq compile-command "make ")

;; I don't remember what this next bit accomplishes.  Sat Nov  8 07:47:28 2008
;; (setq compilation-error-regexp-alist
;;       (cons '("\n\\([^( \t\n]+\\)[:(][ \t]*\\([0-9]+\\)\\([) \t]\\|:[^0-9\n]\\)" 1 2) compilation-error-regexp-alist))

(defun do-make ()
  (interactive)
  (save-some-buffers t)
  (call-interactively 'compile))

(global-set-key "\C-cm" 'do-make)

(defun save-make-go ()
  "Save buffers and run make with no arguments."
  (interactive)
  (save-some-buffers t)
  ;; How to kill-compilation if it's running?
  ;; (catch 'error (kill-compilation))
  (kill-compilation-or-not)
  (save-window-excursion
    (compile "make" t)))


;; Can I use catch instead?  How does one catch an error in e-lisp?
(defun kill-compilation-or-not ()
  "Kill the process made by the \\[compile] or \\[grep] commands.  Like kill-compilation, but
doesn't error out when the process is not running."
  ;; (interactive)
  (let ((buffer (compilation-find-buffer)))
    (if (get-buffer-process buffer)
	(interrupt-process (get-buffer-process buffer))
      ;; (error "The %s process is not running" (downcase mode-name))
      )))



(global-set-key [f7] 'save-make-go)
(global-set-key [f8] 'save-make-go)

(setq abbrev-file-name (expand-file-name "~/.abbrev_defs"))
(read-abbrev-file abbrev-file-name)

(put 'eval-expression 'disabled nil)





;;; Load a partial-completion mechanism, which makes minibuffer completion
;;; search multiple words instead of just prefixes; for example, the command
;;; `M-x byte-compile-and-load-file RET' can be abbreviated as `M-x b-c-a RET'
;;; because there are no other commands whose first three words begin with
;;; the letters `b', `c', and `a' respectively.

;;(load-library "complete")
(partial-completion-mode t)
;;(setq partial-completion-mode nil)
;;(setq PC-meta-flag t)        ; meta not necessary

;; I like case-folding completion
(setq completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)

(defun zap-matching ()
  "Zap away the current opening delimiter and its matching closer."
  (interactive)
  (let ((open (point)))
    (forward-sexp)
    (delete-char -1)
    (goto-char open)
    (delete-char 1)))

(global-set-key "\C-cz" 'zap-matching)
(global-set-key "\C-cZ" 'zap-matching)  ; ilisp uses \C-cz

(defun insert-time-stamp ()
  "Insert the current date and time in the buffer.  Useful for making change
logs, putting in a Last Modified in a new file, etc."
  (interactive)
  (insert (current-time-string)))

(global-set-key "\C-cT" 'insert-time-stamp)

(defun insert-change-log-item ()
  "Insert a ChangeLog item into the current buffer"
  (interactive)
  (beginning-of-buffer)
  (insert "\n\n** " (current-time-string) " by " (user-full-name) "\n")
  (insert "    "))

;;; dynamic abbreviation
(setq dabbrev-case-fold-search 'case-fold-search)
(setq dabbrev-case-replace nil)         ; or 'case-replace

(setq explicit-shell-file-name nil)

;; Still useful?  Sat Nov  8 07:49:04 2008
;;
;; ;; From http://www.cs.washington.edu/homes/voelker/ntemacs.html
;; (setq explicit-shell-file-name "bash")  ;; or "sh"
;; (defun my-shell-setup ()
;;   "For bash under Emacs 20"
;;   (setq comint-scroll-show-maximum-output 'this)
;;   (setq comint-completion-addsuffix t)
;;   (setq comint-process-echoes nil) ; was nil
;;   (setq comint-eol-on-send t)
;;   (make-variable-buffer-local 'comint-completion-addsuffix))
;;
;; (setq shell-mode-hook 'my-shell-setup)
;; 
;; (setq process-coding-system-alist (cons '("bash" . raw-text-unix)
;; 					process-coding-system-alist))


(cd "~")

;; C-m maps to RET, and I don't want it to.
;; (global-unset-key "\C-m")

;; \C-M-% is hard for me
(global-set-key "\C-c%" 'query-replace-regexp)

;; instead of other-window-any-screen
(global-set-key "\M-o" 'other-window)


(global-set-key [home] 'beginning-of-line)
(global-set-key [end] 'end-of-line)

(global-unset-key "\C-z")

(defun expand-car (pair)
  (cons (concat "^" (expand-file-name (car pair))) (cdr pair)))

(defun insert-todo ()
  "Insert \"TODO: \", prefixed by the mode's comment chars."
  (interactive)
  (comment-dwim nil)
  (insert "TODO: "))

(global-set-key "\C-ct" 'insert-todo)

;; Normally meta-tab, which conflicts with window manager
(global-set-key [s-tab] 'complete-symbol)

;;; Windows stuff:
;; (require 'gnuserv)
;; (gnuserv-start)

(setenv "PAGER" "/bin/cat")
(setenv "EDITOR"
        (if (eq system-type 'darwin)
            (expand-file-name "~/bin/emacsclient-osx")
          "emacsclient"))
(server-start)

;; (setq haskell-font-lock-symbols nil)

;;; SGML/HTML

;; Haskell "--" code comments look like html comments to emacs when
;; sgml-specials contains ?-.  So exclude here.  Must happen before
;; loading sgml-mode.
(setq sgml-specials '(?\"))

;; Instead of iconify
(global-set-key "\C-z" 'undo)
;; C-x C-z runs the command iconify-or-deiconify-frame
;; But I often hit that combo accidentally
(global-unset-key "\C-x\C-z")

;; Apparently, only the following setting is necessary and sufficient for
;; color duplex printing.
;; (setq ps-printer-name
;;       ;; "//research/112c3cld"
;;       ;; See email from Hugues Feb 6, 2002.
;;       ;; "//conal01/112c3cld-emacs-duplex"
;;       "980"
;;       )

(require 'avoid)
(mouse-avoidance-mode 'none) ;; or 'banish. 'animate appears to spaz on my Mac.

(setq darcs-command-prefix "\C-cd")
(require 'darcs)

(defun darcs-simple-record (label)
  (interactive "sLabel for patch to record: ")
  (darcs-run-command
   (concat "darcs record --all --skip-long-comment"
           " --patch-name=\"" label "\"")))

(defun darcs-add (filename)
  "Add the current buffer's file to the repo"
  (interactive (list (darcs-current-file)))
  (darcs-maybe-save filename)
  (darcs-run-command (darcs-file-command "darcs add %s" (file-name-nondirectory filename))))


(defun darcs-push ()
  "Push to a darcs repo"
  (interactive)
  (let (compile-command)
    (compile "darcs push" nil)))

(define-key darcs-mode-commands-map "r" 'darcs-simple-record)
(define-key darcs-mode-commands-map "a" 'darcs-add)
(define-key darcs-mode-commands-map "p" 'darcs-push)


;; See http://emacs.wordpress.com/2007/09/10/smooth-scrolling/
;; Hm.  breaks the next-line function
;; (require 'smooth-scrolling)


(require 'erc)
(require 'erc-sound)
(erc-sound-enable)                                      ; try it out

;; (require 'status)
;; (require 'erc-status)

;; Does elisp have real lexical closures?
;; 
;; (defun scroll-cmd (n)
;;   #'(lambda () (interactive) (scroll-up n)))
;; 
;; Apparently not,
;; I get "Symbol's value as variable is void: n"
;; Meanwhile, backquote/comma.  To-do: investigate "lexical-let"


(defun scroll-cmd (n)
  `(lambda () (interactive) (scroll-up ,n)))

(global-set-key [?\C-\;] (scroll-cmd 1))
(global-set-key [?\C-:]  (scroll-cmd -1))


(defvar save-junk-name "Junk"
  "Name of buffer used by \[save-junk]")

(defun save-junk (start end)
  "Save region to buffer named by \[save-junk-name], with current buffer's extension."
  (interactive "r")
  (let ((junk-file (concat save-junk-name "."
                           (file-name-extension (buffer-file-name)))))
    (write-region
     (format "\n%s From %s, line %d, %s:\n"
             comment-start
             (file-name-nondirectory (buffer-file-name))
             (count-lines 1 (point))
             (format-time-string "%x %X")
             )
     nil junk-file t)
    (append-to-file start end junk-file)))

(global-set-key "\C-c\C-j" 'save-junk)


(defun find-ancestor (dir-name)
  "Return an ancestor director with the given name.  Error if none."
  (interactive "sAncestor name: ")
  (let* ((start (buffer-file-name))
         (look #'(lambda (from)
                   ;; (message "at %s" from)
                   (if (string-equal (file-name-nondirectory from) dir-name)
                       from
                     (let ((next (directory-file-name (file-name-directory from))))
                       (if (string-equal from next)
                           (error "Didn't find %s above %s" dir-name start)
                         (funcall look next)))))))
    (funcall look start)))

(global-set-key [f9] 'next-error)
(global-set-key [f3] 'ispell-complete-word)   ; handier than esc-tab for multi-use

(define-key global-map [(meta control down-mouse-3)] 'imenu)

(defun today-irc-url (channel)
  "The URL for today's IRC log of a given channel"
  (format-time-string (concat "http://tunes.org/~nef/logs/" channel "/%y.%m.%d") nil))

(require 'http-get)

(defun fix-utf8 (string)
  "Fix utf8 chars in STRING"
  (interactive "sString: ")
  (save-window-excursion
    (switch-to-buffer "*fix-utf8 scratch buffer*" t)
    (set-language-environment 'utf-8)
    (delete-region (point-min) (point-max))
    (insert string)
    (decode-coding-region (point-min) (point-max) 'utf-8)
    (buffer-substring (point-min) (point-max))))

(defun irc-filter-pre-insert ()
  "For use as http-filter-pre-insert-hook"
  ;; (message "filter-irc-log-chunk")
  ;; Remove channel quit/join and @where ops reply
  (setq string (replace-regexp-in-string
                ;; 19:48:38 --- quit: lbc_ (Quit: lbc_)
                "^\\([0-9:]+ --- [a-z]+: \\|.*dibblego conal\\|.*##politics  invites you to join.*\\).*\n"
                ;; "\\|\*\*\*"  ;; what's this one?
                ""
                ;; (fix-utf8 string)
                string
                ))
  ;; avoid loss of newlines.
  ;; (longlines-mode 0)
  )

(defun irc-filter-post-insert ()
  "For use as http-filter-post-insert-hook"
  ;; To avoid requiring manual mode change after loading the whole buffer
  ;; what process to use here?
  ;; (decode-coding-region (process-mark) (point) 'utf-8)
  ;; (longlines-mode 1)
  )

(defun irc-log (url)
  "Show today's #haskell IRC log"
  (interactive
   (list (read-from-minibuffer "URL: " (today-irc-url "haskell"))))
  ;; http-filter-pre-insert-hook is buffer-local, so without the next
  ;; line, I was setting http-filter-pre-insert-hook in the wrong buffer.
  (switch-to-buffer (concat "*HTTP GET " url " *"))  ;; creates
  (pushnew 'irc-filter-pre-insert  http-filter-pre-insert-hook)
  (pushnew 'irc-filter-post-insert http-filter-post-insert-hook)
  ;; (set-language-environment 'utf-8)
  (http-get url)
  (text-mode)  ;; http-get changes the mode do fundamental
  ;; (view-mode 1) oops -- too soon.
  ;; oops.  too soon.
  ;; (decode-coding-region (point-min) (point-max) 'utf-8)
  )

(defun chat-save ()
  "Save the current buffer in my chat logs"
  (interactive)
  (let ((coding-system-for-write 'raw-text))
    (write-region (point-min) (point-max) 
                  (concat (format-time-string "~/chats/%Y/%m-%d ")
                          (buffer-name) ;; (remove ?# (buffer-name))
                          ".txt"))))

(defun elim-re (pattern)
  "Elminate the pattern throughout a buffer."
  (replace-regexp pattern "" nil (point-min) (point-max)))

;; (defun core-clean ()
;;   "Clean up ghc core output in a buffer."
;;   (interactive)
;;   (elim-re "
;; ")
;;   (elim-re "\\<[a-z]+\\.")
;;   ;; strip variable name suffixes.  nope.
;;   ;; (elim-re "_[a-z0-9]+\\>")
;;   (haskell-mode))


;; (defun irc-clean-log ()
;;   "Clean up an IRC log, removing join & leave messages etc"
;;   (interactive)
;;   ;; (longlines-mode 0)
;;   (elim-re ".* --- .*: .*\n")
;;   (elim-re "^\*\*\* .*\n")
;;   (elim-re ".*dibblego conal .*\n")
;;   ;; TODO: merge regexps for one elim-re call
;;   (message "cleaned IRC log")
;;   ;; clean before longlines.  otherwise, lose eols
;;   (longlines-mode)
;;   (goto-char 0)
;;   )


(defun open (file)
  "The system \"open\" command"
  (interactive "fFile to open: ")
  (call-process "open" nil 0 nil (expand-file-name file)))

;;; next two definitions from Svein Ove Aas
(defun first-letter ()
  (move-beginning-of-line nil)
  (let ((beg (point)))
    (search-forward-regexp "[^[:space:]]")
    (- (- (point) beg) 1)))

(defun dewhere-fun ()
  (interactive)
  (save-excursion
    (move-beginning-of-line nil)
    (let ((beg (point)))
      ;; Skip where syntax
      (search-forward-regexp "[[:space:]^]+where[[:space:]]" nil 1)
      (if (< 1 (count-lines beg (point)))
        (goto-char beg)  ; No where, reset point
        (backward-char)) ; Move to just after the where
      ;; Find the function name
      (search-forward-regexp "[[:alnum:]]")
      (backward-char)
      (setq beg (point))
      ;; Find the first line with text at a column before the function name
      (move-beginning-of-line nil)
      (let* ((col (- beg (point)))
             (end (loop do (next-line) until (<= (first-letter) col) finally return (point))))
        (backward-char)
        (kill-region beg (point))))))



(defun pasteboard-insert-markdown ()
  "Extract html from Mac OS X pasteboard, convert to markdown, and paste/yank."
  (interactive)
  (twee-no-longlines
   (call-process-shell-command "PasteMarkdown" nil t))
  ;; (delete-backward-char 3) ; extraneous chars
  )
(global-set-key "\C-\M-y" 'pasteboard-insert-markdown)


;; Look for a more pleasant sound.
(setq visible-bell t)

;; (setq preferred-frame-height
;;       (if (string-equal (getenv "USERDOMAIN") "COMPY")
;;           37
;;         48))

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(PC-meta-flag nil)
 '(auto-save-interval 30)
 '(backup-by-copying t)
 '(c-style-variables-are-local-p nil)
 '(c-tab-always-indent t)
 '(column-number-mode t)
 '(comment-style (quote plain))
 '(dabbrev-case-fold-search nil)
 '(default-frame-alist-qqq (quote ((height . 37) (width . 126) (font . "-outline-Courier
New-bold-r-normal-normal-19-142-96-96-c-110-iso10646-1") (tool-bar-lines . 0) (menu-bar-lines . 1))))
 '(default-input-method "TeX")
 '(display-buffer-reuse-frames t)
 '(erc-autojoin-channels-alist (quote (("freenode.net" "#haskell-blah" "#haskell-iphone" "#haskell-ops" "#haskell-in-depth" "#ghc" "#haskell") (".*\\.freenode\\.net" "#haskell" "#ghc" "#haskell-in-depth" "#haskell-ops" "#haskell-blah" "#haskell-iphone"))))
 '(erc-away-nickname nil)
 '(erc-fill-column 100)
 '(erc-fill-mode nil)
 '(erc-mode-hook (quote (erc-munge-invisibility-spec pcomplete-erc-setup erc-button-add-keys (lambda nil (setq imenu-create-index-function (quote erc-create-imenu-index))) (lambda nil (abbrev-mode 1)))))
 '(erc-nick "conal")
 '(erc-nick-uniquifier "+")
 '(erc-prompt-for-password t)
 '(erc-user-full-name "Conal Elliott")
 '(erc-whowas-on-nosuchnick t)
 '(eval-expression-print-length 200)
 '(eval-expression-print-level 12)
 '(haskell-indent-offset 2)
 '(inferior-haskell-wait-and-jump t)
 '(ispell-program-name "aspell")
 '(ispell-silently-savep t)
 '(longlines-show-hard-newlines nil)
 '(longlines-wrap-follows-window-size t)
 '(mac-pass-command-to-system nil)
 '(markdown-command "pandoc --toc --smart --standalone --to html")
 '(message-log-max 500)
 '(mmm-global-mode (quote maybe) nil (mmm-mode))
 '(mmm-mode-ext-classes-alist (quote ((twee-mode nil twee) (markdown-mode nil markdown) (text-mode nil literate-haskell-lhs2TeX) (latex-mode nil literate-haskell-lhs2TeX))) nil (mmm-mode))
 '(mmm-submode-decoration-level 2)
 '(p4-follow-symlinks t)
 '(parens-require-spaces nil)
 '(partial-completion-mode t nil (complete))
 '(ps-font-size (quote (8 . 10)))
 '(scroll-conservatively 1000)
 '(sentence-end-double-space nil)
 '(tex-shell-file-name "bash")
 '(user-mail-address "conal@conal.net")
 '(vc-make-backup-files t))

(when (eq system-type 'darwin)
  (custom-set-variables
   '(ispell-extra-args (quote ("-d" "/Library/Application Support/cocoAspell/aspell6-en-6.0-0/en.multi")))))

;;; See http://www.emacswiki.org/emacs/EmacsClient#toc21
;;; 
;;;  '(server-done-hook (quote ((lambda nil (kill-buffer nil)) delete-frame)))
;;;  '(server-switch-hook (quote ((lambda nil (let (server-buf) (setq server-buf (current-buffer)) (bury-buffer) (switch-to-buffer-other-frame server-buf))))))

(put 'downcase-region 'disabled nil)
(put 'upcase-region   'disabled nil)

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(font-lock-doc-face ((t (:inherit font-lock-string-face :foreground "tomato4"))))
 '(mmm-default-submode-face ((t (:background "lemon chiffon")))))


;; (require 'desktop)
;; (desktop-load-default)
;; (desktop-read)
;; (add-hook 'kill-emacs-hook 'desktop-save)


;; http://www.emacswiki.org/emacs/InteractiveSpell#toc1
(setq ispell-process-directory (expand-file-name "~/"))


;;; Some Linux customizations:
(setq x-select-enable-clipboard t)

;;; Turn off the tool bar.
(tool-bar-mode 0)

;;; For carbon emacs
(set-frame-parameter nil 'alpha 1.0)

;; (set-frame-parameter nil 'fullscreen 'fullboth)

;; If you put the following in your ~/.emacs.el, you can toggle fullscreen
;; with M-Ret.

(defun toggle-fullscreen ()
  (interactive)
  (set-frame-parameter nil 'fullscreen (if (frame-parameter nil 'fullscreen)
                                           nil
                                           'fullboth)))

(global-set-key [(meta return)] 'toggle-fullscreen)


;;; Turn off some especially dangerous mac-style bindings for Cocoa Emacs
(global-unset-key [(super v)])
(global-unset-key [(super x)])
;; (global-unset-key [(super h)])
(global-unset-key [(super d)])
(global-unset-key [(super m)])  ;; minimizes to dock

(global-set-key [(super x)] 'execute-extended-command)

(global-set-key [(meta F11)] 'blort)

;;; git for emacs
;;; Modified from http://www.michael-hammer.at/blog/emacs_git/
;; (add-to-list 'load-path "/usr/share/emacs/site-lisp/git")
;;; already there
;;; (add-to-list 'vc-handled-backends 'GIT)
(autoload 'git-status "git-status" "Entry point into git-status mode." t)
(autoload 'git-blame-mode "git-blame"
  "Minor mode for incremental blame for Git." t)

;keybindindings for git
(global-set-key [(meta super s)] 'git-status)

(defun swap-option-command ()
  "Swap option & command keys.  I also changed the binding of
screen-shots in the OS from command-# and command-$ to
command-option-3 and command-option-4, with control added for the
clipboard versions.  In other words, I replaced shift with
option, so as to avoid a clash with.  I also changed the
Spotlight binding from command-space to option-space."
  (interactive)
  (let ((option-was mac-option-modifier))
    (setq mac-option-modifier mac-command-modifier)
    (setq mac-command-modifier option-was)))

;;; default
;; (setq mac-option-modifier 'meta)
;; (setq mac-command-modifier 'super)

(when (eq system-type 'darwin)
  (swap-option-command))

(push ".DS_Store" PC-ignored-extensions)

(defun blogify-region (from to)
  "Run blogify on the contents of the region bounded by FROM and TO and save the result in the inter-program copy buffer."
  (interactive "r")
  (save-window-excursion
    (shell-command-on-region from to "blogify")
    (switch-to-buffer "*Shell Command Output*")
    (kill-ring-save (point-min) (point-max))
    ;; (x-select-text (buffer-string))
    ))

(defun blogify-buffer ()
  "Run blogify on the contents of the current buffer and save the result in the inter-program copy buffer."
  (interactive)
  (blogify-region (point-min) (point-max)))


;;; I keep running afoul of an oddity/bug in longlines-mode.
;;; Some of my long lines get hard breaks on saving.
;;; Here's a temporary hack to help me cope while I'm investigating.
;;; I wonder if it would help to turn longlines mode off while saving.
;;;
;;; Note 2011-10-28: I've switched from longlines-mode to
;;; visual-line-mode. Hopefully no more bogus line breaks.

(defun oops-longlines-breaks ()
  "Patch up after longlines mode messes up and inserts real line breaks.
I'd rather fix the real problem than keep patching it up."
  (interactive)
  (twee-no-longlines
   (query-replace-regexp "\\([a-z0-9',`\"_):&]\\)\n\\([a-z0-9'`\"(&_[]\\)" "\\1 \\2")))

(autoload 'wikipedia-mode "wikipedia-mode.el"
  "Major mode for editing documents in Wikipedia markup." t)

(add-to-list 'auto-mode-alist '("\\.wiki\\'" . wikipedia-mode))

;;; From http://en.wikipedia.org/wiki/Wikipedia:Wikipedia-mode.el :
;;; 
;;;   wikimedia-mode.el is apparently no longer maintained and most of the
;;;   code here has been incorporated into mediawiki.el.

(require 'zoom-frm)
(global-set-key (if (boundp 'mouse-wheel-down-event) ; Emacs 22+
                    (vector (list 'control mouse-wheel-down-event))
                  [C-mouse-wheel])    ; Emacs 20, 21
                'zoom-in)
(when (boundp 'mouse-wheel-up-event) ; Emacs 22+
  (global-set-key (vector (list 'control mouse-wheel-up-event))
                  'zoom-out))

(if (eq system-type 'darwin)
    (progn
      (global-set-key [s-up] 'zoom-in)
      (global-set-key [s-down]   'zoom-out))
  (progn
    (global-set-key [S-mouse-1]   'zoom-in)
    (global-set-key [C-S-mouse-1] 'zoom-out)))

;; TODO: unify zoom bindings

;; Get rid of `mouse-set-font' or `mouse-appearance-menu':
;; (global-set-key [S-down-mouse-1] nil)

;; On Linux, M-SPC is getting co-opted (for the window menu).
(when (eq system-type 'gnu/linux)
  (global-set-key [?\s- ] 'just-one-space))

;;; Perforce
(require 'p4)
;;; I have DIFF=vimdiff, which leads p4-submit to hang when
;;; p4-check-empty-diff is true.
(setenv "DIFF" "diff")

;;; Notification and erc
;;; See http://www.emacswiki.org/emacs/ErcGrowl

(defvar growlnotify-command (executable-find "growlnotify") "The path to growlnotify")

(defun growl (title message)
  "Shows a message through the growl notification system using
 `growlnotify-command` as the program."
  (flet ((encfn (s) (encode-coding-string s (keyboard-coding-system))) )
    (let* ((process (start-process "growlnotify" nil
                                   growlnotify-command
                                   (encfn title)
                                   "-a" "Emacs"
                                   "-n" "Emacs")))
      (process-send-string process (encfn message))
      (process-send-string process "\n")
      (process-send-eof process)))
  t)

(defun my-erc-hook (match-type nick message)
  "Shows a growl notification, when user's nick was mentioned. If the buffer is currently not visible, makes it sticky."
  (unless (posix-string-match "^\\** *Users on #" message)
    (growl
     (concat "ERC: name mentioned on: " (buffer-name (current-buffer)))
     message
     )))

(when (eq system-type 'darwin)
  (add-hook 'erc-text-matched-hook 'my-erc-hook))

;;; Big font in a big window
(maximize-frame)
(while (> (window-width) 112)
  (enlarge-font 1))

;;; For now
(cd (concat tabula-dir "/swp4/t4/hwarchABAX2/tdh/Utils/"))
(shell)

(setq debug-on-error nil)

;;; End of customizations