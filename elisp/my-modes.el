;;;; Misc mode settings.

(require 'my-text)
(require 'my-tex)
(require 'twee)
(require 'hs-lint)
(require 'find-file)  ;; for cc-other-file-alist
(require 'mmm-mode)


;; Was "^[^#$%>\n]*[#$%>] *", but the # shows up in infinite number
;; display from C.
(setq shell-prompt-pattern "^[^$%>\n]*[$%>] *")


(defun my-common-mode-stuff ()
  (interactive)
  (abbrev-mode 1)                       ; Use abbreviations
  ;; (auto-fill-mode 1)                    ; Do auto-fill
  (setq fill-column 74)
  (setq comment-column 56)
  (setq indent-tabs-mode nil)	        ; No tabs on indent
  (column-number-mode 1)
  ;;(local-set-key 'tab indent-line-function)
  ;;(local-set-key '(meta backspace) nil)
  ;; These next two got reversed.  Hmmm...
  ;;(local-set-key 'backspace 'backward-delete-char-untabify)
  ;; (local-set-key 'delete 'delete-char)
  (local-set-key "\C-ci" 'text-insert-item)
  (local-set-key "\C-cI" 'fix-next-marker)
  (setq dabbrev-case-replace nil)
  (local-set-key "\M-\t" 'ispell-complete-word) ;; esc-tab in Windows
  )


(add-hook 'python-mode-hook 'my-python-mode-hook)

(defun my-python-mode-hook ()
  (my-common-mode-stuff))

(setq text-mode-hook 'my-text-mode-hook)

(defun my-text-mode-hook ()
  (my-common-mode-stuff)
  (auto-fill-mode 1)
  ;; Paragraphs start and are separated by a blank line
;;   (setq paragraph-start "\\(\\+ +\\)\\|$"                  ; "^$"
;;         paragraph-separate "^$"               ; "^$"
;;         )
  (when t
    ;; Use "> " as the comment character.  This lets me
    ;; conveniently edit mail replies to non-Exchange users.
    (setq comment-start ">"
          comment-end ""
          comment-start-skip "^>  *"))
  (setq adaptive-fill-regexp nil)
  (setq adaptive-fill-function 'my-text-adaptive-fill-function)
  ;; In Emacs 20, indented-text-mode is an alias for text-mode.  (I
  ;; don't know why.)  But I want indented mode, so:
  (setq indent-line-function 'indent-relative-maybe)
  (modify-syntax-entry ?\_ "w")     ; word constituent
  ;; (modify-syntax-entry ?\' ".")  ; punctuation
  (modify-syntax-entry ?\| ".")     ; punctuation
  (modify-syntax-entry ?\" "\"")    ; string char 
  (ispell-minor-mode)
  ;; (longlines-mode t)                ; Always on?  Experiment.
  ;; Avoid a problem with imenu and sub-modes:
  (setq imenu-create-index-function '(lambda ()))
  )

(setq c++-mode-hook
      '(lambda ()
	 (my-common-mode-stuff)
         (modify-syntax-entry ?\_ "w")                  ; word constituent
	 (c-set-style "stroustrup")
         ))

(autoload 'csharp-mode "cc-mode")
(push '("\\.cs$" . csharp-mode) auto-mode-alist)

(defun my-c-mode-common-hook ()
  (c-set-style "stroustrup")                            ; indent 4 etc
  (auto-revert-mode t)  ; since i usually edit in xcode also
  (setq indent-tabs-mode nil)
  ;; (c-toggle-auto-newline t)
  ;; (local-unset-key [C-c C-a])  ; wrong key syntax?
  (local-unset-key "\C-c \C-a")   ; drop c-toggle-auto-newline for align-regexp
  ;; (message "my-c-mode-common-hook")
  (modify-syntax-entry ?\' "w")  ; for abbrevs
  ;; Override "/* ... */"
  (setq comment-start "// ")
  (setq comment-end "")
  )

(global-set-key [M-s-up] 'ff-find-other-file)

(add-to-list 'cc-other-file-alist '("\\.m\\'" (".h")))
(add-to-list 'cc-other-file-alist '("\\.h\\'" (".m" ".c" ".cpp")))

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

;;; From Brad Merrill

(c-add-style "myC#Style"
  '("C#"
  (c-basic-offset . 2)
  (c-comment-only-line-offset . (0 . 0))
  (c-offsets-alist . (
    (c                     . c-lineup-C-comments)
    (inclass		   . 0)
    (namespace-open	   . 0)
    (namespace-close	   . 0)
    (innamespace	   . 0)
    (class-open		   . +) ;; was +
    (class-close	   . 0)
    (inclass		   . 0)
    (defun-open		   . 0) ;; was +
    (defun-block-intro     . +) ;; was 0
    (inline-open	   . 0) ;; was ++, didn't help
    (statement-block-intro . +)
    (brace-list-intro      . +)
    ))
  ))

(defun my-csharp-mode-hook ()
  (cond (window-system
	 (turn-on-font-lock)
         (abbrev-mode 1)
         (auto-fill-mode 1)
         (modify-syntax-entry ?\. ".")
         (modify-syntax-entry ?\_ "w")
	 (c-set-style "myC#Style")
	 )))
(add-hook 'csharp-mode-hook 'my-csharp-mode-hook)

(defun my-vsh-mode-hook ()
  (abbrev-mode 1)
  (auto-fill-mode 1))

(add-hook 'vsh-mode-hook 'my-vsh-mode-hook)


(setq completion-ignored-extensions
      (append '(
                ".dll" ".obj"
                ".gz" ".exe" ".aux" ".log" ".ps" ".dvi" ".bbl" ".blg"
                ".hi" ".mc_o" ".mc_hi" ".mr_o" ".mr_hi" ".c_o" ".c_hi"
                ".hi-boot" ".hs-boot" ".o-boot" ".p_hi" ".p_hi-boot"
                ".p_o" ".p_o-boot" "_split"
                ".bmp" ".gif" ".jpeg" ".jpg"
                ".doc" ".vsd" ".out"
                ".class"
                "_print.tex" "_web.tex" ;; auto-gen'd for Pan Book project
                ".odp"
                )
               completion-ignored-extensions))

;;; Use font locking in all modes that support it.
(global-font-lock-mode t)

;;; There's a nasty bug with font-locking and shell-script modes.  The
;;; symptom is "No match 2 in highlight (2 font-lock-comment-face t))",
;;; and the buffer doesn't show up.  Then emacs keeps trying to fontify
;;; the shell script.  The fix is to do (sh-set-shell "/bin/sh") 

(defun fix-shell-script-fontify-problem ()
  (interactive)
  (sh-set-shell "/bin/sh"))

(defun ispell-expand (str)
  (concat ;; (expand-file-name "~/gnu/ispell4/")
	  str))

(setq ;; ispell-command (ispell-expand "exe/ispell.exe")
      ;; ispell-look-dictionary (ispell-expand "ispell.words")
      ;; ispell-look-command (ispell-expand "exe/look.exe")
      ;; ispell-command-options (list "-d" (ispell-expand "ispell.dict"))
      )
(setq ispell-enable-tex-parser t) 
;; For running ispell explicitly from a shell
;; (setenv "ISPELL_DICTIONARY" (ispell-expand "ispell.dict"))

(setq emacs-lisp-mode-hook
      '(lambda ()
         (my-common-mode-stuff)
         (imenu-add-menubar-index)))

;;; Haskell support

;;; My commands for starting up Hugs on various programs.
;;; Superceded by haskell-hugs.el
;;; (load "haskell")

;; (autoload 'haskell-mode "haskell-mode"
;;    "Major mode for editing Haskell scripts." t)
;; (autoload 'literate-haskell-mode "haskell-mode"
;;    "Major mode for editing literate Haskell scripts." t)

(add-hook 'haskell-mode-hook 'my-haskell-mode-hook)

;; (setq haskell-hugs-program-name
;;       "c:/Program Files/Hugs98/hugs.exe"
;;       ;; "c:/Hugs98/hugs-stack-dump"
;;       )

;; Turn off Haskell 98 compatability mode, so I can use non-98 features,
;; especially rank 2 types.
;; (setq haskell-hugs-program-args '("-98"))

;; (setq font-lock-maximum-decoration '((haskell-mode . t) (t . 0)))

;; (require 'hoogle)

(defun haskell-insert-section-header ()
  "Insert a pretty section header."
  (interactive)
  (insert "{--------------------------------------------------------------------\n")
  (insert"    \n")
  (insert"--------------------------------------------------------------------}\n")
  (forward-line -2)
  (end-of-line))

(defun my-haskell-mode-hook ()
  ;; (longlines-mode)
  ;; (turn-on-haskell-font-lock)
  ;; (turn-on-haskell-decl-scan)
  ;; From the haskell-mode README
  (turn-on-haskell-doc-mode)
  ;; (turn-on-haskell-indentation)
  (turn-on-haskell-indent)
  ;;(turn-on-haskell-simple-indent)
  (setq haskell-literate-default 'bird)
  ;; (font-lock-mode)  ;; why necessary?
  ;; font-lock-doc-face is lighter than I like
  ;; (setq haskell-literate-comment-face 'font-lock-comment-face)
  (my-common-mode-stuff)
  (auto-fill-mode 1)
  (setq comment-column 40)
  ;; Don't do the following, since I'm usually in mmm/markdown now.
  ;; (if haskell-literate (shared-tex-lhs-init))  ;; in my-tex.el
  ;; 
  ;;(setq indent-line-function 'indent-relative-maybe)
  ;;(local-set-key "\t" 'indent-relative)
  ;; (local-set-key "\M-s" 'center-line)
  ;;(modify-syntax-entry ?\\ ".")  ; lambda as punctuation
  ;; ?\' gets made a "quote" character, but I more often use it as a name
  ;; constituent.
  (modify-syntax-entry ?\' "w")
  ;; (local-set-key "\C-c<" 'LaTeX-mode)
  (local-set-key "\C-c<" 'markdown-invert-birdtracks)
  ;; Fix funny commenting behavior
  ;; (make-local-variable 'comment-padding)
  (setq comment-padding 1)
  (setq comment-start "--")
  (define-abbrev-table 'haskell-mode-abbrev-table ())
  (setq local-abbrev-table haskell-mode-abbrev-table)
  (set (make-local-variable 'fill-paragraph-function)
       'haskell-fill-paragraph)
  (imenu-add-menubar-index)
  ;; In mmm-mode, buffer-file-name is not set when haskell-mode is kicked
  ;; off, causing problems for flymake-mode. I don't want it on in that
  ;; case.
  (when buffer-file-name
    (flymake-mode 1))
  ;; http://sites.google.com/site/haskell/notes/ghci610emacsmadness
  ;; '(haskell-program-name "/home/conal/bin/ghci-no-tty")
  ;; (setq process-connection-type nil)
  (local-set-key "\C-c'" 'surround-ticks)
  (local-set-key [?\C-'] 'surround-ticks)
  (local-set-key "\C-c@" 'surround-atsign)
  (local-set-key "\C-ch" 'hoogle-lookup)
  (local-set-key "\C-c\C-r" 'inferior-haskell-reload-file)
  (local-set-key [f10] 'haskell-load-in-src)
  (local-set-key [f11] 'cabal-do)
  (local-set-key [?\C-|] 'add-spec)
  ;; (local-set-key [?\C-\\] 'add-spec)  ;; restore if i want toggle-input-method back
  ;; haskell-mode binds \C-c\C-g, but I like it to stay undefined
  (local-unset-key "\C-c\C-g")
  (local-set-key "\C-cl" 'hs-lint)
  (local-set-key "\C-cs" 'haskell-insert-section-header)
  ;; ghc-mod
  (ghc-init)
  ;; (flymake-mode) ;; Breaks in mmm-mode. Investigate
  (local-unset-key "\M-t")
  (local-set-key "\C-c\M-t" 'ghc-insert-template)       ; better key?
  (local-unset-key "\C-c\C-c")
  (local-set-key "\C-c\C-f" 'ghc-flymake-toggle-command) ; better key?
  (local-set-key [C-tab] 'ghc-complete) ; normally meta-tab
  (local-set-key "\M-i" 'ghc-import-module)
  )

;; For ghc-mod http://www.mew.org/~kazu/proj/ghc-mod/en/
(autoload 'ghc-init "ghc" nil t)

(defun inferior-haskell-reload-file ()
  (interactive)
  (inferior-haskell-load-file t))

(defvar cabal-do-command "make")
(defvar cabal-do-history nil)

(defun cabal-do (command)
  "Run a command right above ancestor \"src\" directory.  With an
 arg, prompt for the command.  Otherwise, use previous choice, or cabal-do-command."
  ;; I swiped this "interactive" incantation from compile.
  (interactive
   (if current-prefix-arg
       (list (read-from-minibuffer "Compile command: "
                                   (eval cabal-do-command) nil nil
                                   '(cabal-do-history . 1)))
     (list (eval cabal-do-command))))
  (setq cabal-do-command command)
  (let ((dir (file-name-directory (find-ancestor "src")))
        ;; (buff-was (current-buffer))
        (temp-buf (get-buffer-create "* cabal-install temp *")))
    (set-buffer temp-buf)
    (cd dir)
    (save-some-buffers t)
    (compile command)
    ;; (message "back to %s" buff-was)
    ;; (switch-to-buffer-other-frame buff-was)
    (kill-buffer temp-buf))
)

(defun haskell-load-in-src (quit-first)
  "Start up a fresh ghci in the \"src\" ancestor of the current buffer.
With a prefix arg, kill the process first, to get a fresh start."
  (interactive "P")
  ;; This def would be *much* simpler if inferior-haskell-load-file took a
  ;; directory as argument, instead of just a flag.
  (let ((proc (inferior-haskell-process)))
    (if (and proc quit-first)
        (progn
          ;; (inferior-haskell-send-command proc ":quit ")
          ;; (inferior-haskell-wait-for-prompt proc)
          (kill-process proc)
          (inferior-haskell-start-process nil)
          (inferior-haskell-wait-for-prompt proc)
          ;; I don't know how to wait for the process to die and/or restart, so don't continue
          ;; (haskell-load-in-src nil)
          )
      (let ((buff-was (current-buffer))
            (src (find-ancestor "src")))
        ;; (message "waking ghci buffer")
        ;; (wake-ghci-buffer)
        (inferior-haskell-start-process nil)
        (set-buffer inferior-haskell-buffer)
        ;; (message "sending :cd %s" src)
        (inferior-haskell-send-command proc (concat ":cd " src))
        ;; (inferior-haskell-wait-for-output)
        (set-buffer buff-was)
        (inferior-haskell-load-file nil)))))


(defun surround-punct (start end n)
  "Use strings START and END to bracket N words.  Starts at N-th most
recent s-expression, which is convenient for use inside a word or at the
end of it."
  (expand-abbrev)
  (backward-sexp n)
  (insert start)
  (forward-sexp n)
  (insert end))

(defun surround-atsign (arg)
  "Surround n words with @ marks for Haddock.  Starts at n-th most recent
s-expression, which is convenient for use inside a word or at the end of
it."
  (interactive "p")
  (surround-punct "@" "@" arg))

(defun surround-ticks (arg)
  "Surround n words with ' marks for Haddock.  Starts at n-th most recent
s-expression, which is convenient for use inside a word or at the end of
it."
  (interactive "p")
  (surround-punct "'" "'" arg))

(defun surround-pipes (arg)
  "Surround n words with | marks.  Starts at n-th most recent
s-expression, which is convenient for use inside a word or at the end of
it."
  (interactive "p")
  (surround-punct "|" "|" arg))

(defun surround-dollars (arg)
  "Surround n words with $ marks.  Starts at n-th most recent
s-expression, which is convenient for use inside a word or at the end of
it."
  (interactive "p")
  (surround-punct "$" "$" arg))

(defun surround-double-slash (arg)
  "Surround n words with // marks.  Starts at n-th most recent
s-expression, which is convenient for use inside a word or at the end of
it."
  (interactive "p")
  (surround-punct "//" "//" arg))


(defun haskell-fill-paragraph (arg)
  "If we're in a comment, keep the comment prefixes and fill the rest.  BUG: combines with line above
start of comment.  TODO: handle {- ... -} comments."
  (interactive "P")
  (beginning-of-line)
  (let* ((at-comment (looking-at " *-- "))
         (mdata (match-data))
         (fill-prefix
          (if at-comment (buffer-substring (car mdata) (cadr mdata)) fill-prefix)))
    (fill-paragraph arg)))

;;; Skeleton support for autoinsert when making a new Haskell file.  TODO:
;;; simplify.
(require 'haskell-skel)
(setq jao-copyright-file "~/Misc/copyright.txt")
(setq jao-company-name "Conal Elliott")

;;; I have key bindings to switch between literate haskell mode and tex
;;; mode.  when that happens, I lose the darcs-find-file-hook, which turns
;;; on darcs-mode if we're in a darcs directory.  I'd really rather have
;;; one mode that shows LaTeX and literate Haskell nicely.
(add-hook 'haskell-mode-hook 'darcs-find-file-hook)
(add-hook 'tex-mode-hook     'darcs-find-file-hook)


(defun my-html-mode-hook ()
  (my-common-mode-stuff)
  (setq comment-start "<!--"
	comment-end " -->"
	comment-start-skip "--[ \t]*"
	comment-indent-function 'sgml-comment-indent))
  
(add-hook 'html-mode-hook 'my-html-mode-hook)

(defun my-makefile-mode-hook ()
  (interactive)
  (abbrev-mode 1)                       ; Use abbreviations
  (auto-fill-mode 1)                    ; Do auto-fill
  (setq fill-column 74))

(add-hook 'makefile-mode-hook 'my-makefile-mode-hook)

(defun my-java-mode-hook ()
  (interactive)
  (setq indent-tabs-mode nil)	        ; No tabs on indent
  (modify-syntax-entry ?\_ "w")
  (abbrev-mode 1)                       ; Use abbreviations
  (auto-fill-mode 1)                    ; Do auto-fill
  (setq fill-column 74))
  
(add-hook 'java-mode-hook 'my-java-mode-hook)

;; (require 'cabal-mode)
;;
;; ;;; Assume new cabal files to be libraries.
;; ;;; TODO: prompt and select.
;; (add-to-list
;;  'auto-insert-alist
;;  '(cabal-mode . cabal-insert-basic-library))
;;
;; (add-hook 'cabal-mode-hook 'my-cabal-mode-hook)

;; Hm. There's no cabal-mode-hook??
(defun my-cabal-mode-hook ()
  (interactive)
  (auto-fill-mode 1)
  (abbrev-mode 1)
  (set (make-local-variable 'comment-start) "--"))

;; TODO: try other markdown modes

(define-derived-mode markdown-mode text-mode "Markdown"
  "Major mode for editing Markdown files."
;;   (longlines-mode t)
;;   ;; (mmm-mode t)  ;; necessary??
;;   (local-set-key [?\C-'] 'markdown-inline-code)
;;   ;; (local-set-key [?\C-_] 'markdown-emphasize)
;;   (local-set-key "\C-cc" 'markdown-insert-code-block)
;;   (local-set-key "\C-ci" 'twee-add-item)
  )

(defun md-add-blockquote (arg)
  "Add a blockquote, either as a simple \" >\" (if ARG present) or as html (if not)"
  (interactive "P")
  (twee-no-longlines
   (end-of-line)
   (insert "\n")
   (insert
    (if arg "\n > " "\n <blockquote>\n\n\n\n </blockquote>")
    "\n")
   (previous-line (if arg 1 3))
   (end-of-line)))

(defun md-add-lhs (arg)
  "Add a literate Haskell block as \"> \""
  (interactive "P")
  (twee-no-longlines
   (end-of-line)
   (insert "\n\n> ")
   (unless (looking-at "\n\n")
     (insert "\n\n")
     (backward-char 2))
   (markdown-mmmify-lines)
   ))

;; (setq markdown-mode-hook
;;       '(lambda ()
;;          (setq paragraph-start "\\(\\+  \\)\\|$")))

(defun markdown-inline-code (arg)
  "Surround previous ARG sexps with markdown backquotes."
  (interactive "p")
  (surround-punct "`" "`" arg)
  (expand-abbrev)
  ;; (insert " ")
  (when mmm-mode (mmm-parse-block 2)))

(defun markdown-emphasize (arg)
  "Surround previous ARG sexps with underscores."
  (interactive "p")
  (expand-abbrev)
  (surround-punct "_" "_" arg)
  ;; (insert " ")
  )

(defun markdown-insert-code-block ()
  "Begin inserting a code block."
  (interactive)
  (unless (bolp) (newline))
  (newline)
  (insert "    ")
  (unless (looking-at "\n\n")
    (newline)
    (newline)
    (previous-line 2)
    (end-of-line))
  (when mmm-mode (mmm-parse-block 2)))

(defun markdown-invert-birdtracks (from to)
  "Invert birdtracks (literate Haskell indicators) between FROM and TO,
turning \">\" to \"<\" and vice versa."
  (interactive "r")
  (save-excursion
    (goto-char from)
    (narrow-to-region from to)
    (while (re-search-forward "^[><]" nil t)
      (replace-match (if (string-equal (match-string 0) ">") "<" ">") nil nil))
    (widen)
    )
  )

(defun markdown-add-header (header)
  "Add a line following the current one and having the same length, 
consisting of repeated use of HEADER string (assumed one char).
See 'markdown-add-header-equals' and 'markdown-add-header-hyphen'"
  (interactive)
  (expand-abbrev)
  (beginning-of-line)
  (let ((from (point)))
    (end-of-line)
    (let ((to (point)))
      ;; (newline)
      (twee-no-longlines
       (let ((divider-regexp (concat "\n\\(" header "\\)*$")))
         (when (looking-at divider-regexp)
           ;; (message "i see the divider!")
           (delete-region (point) (match-end 0))
           )
         (insert "\n" (replace-regexp-in-string "." header (buffer-substring from to)))
         (if (looking-at "\n") (beginning-of-line 2) (newline))
         (newline)
         )))))

(defun markdown-add-header-equals ()
  "Add a line following the current one and having the same length, 
consisting of repeated '='. For an <h1>."
  (interactive)
  (markdown-add-header "=")
)

(defun markdown-add-header-hyphen ()
  "Add a line following the current one and having the same length, 
consisting of repeated '-'. For an <h2>."
  (interactive)
  (markdown-add-header "-")
)

(defun my-markdown-mode-hook ()
  (setq paragraph-start "\\(\\+  \\)\\|$")
  ;; (longlines-mode t)
  (visual-line-mode t)
  (auto-fill-mode 0)
  ;; (mmm-mode t)  ;; necessary??
  (local-set-key [?\C-'] 'markdown-inline-code)
  ;; (local-set-key [?\C-_] 'markdown-emphasize)
  (local-set-key "\C-cc" 'markdown-insert-code-block)
  (local-set-key "\C-ci" 'twee-add-item)
  (local-set-key "\C-cq" 'md-add-blockquote)
  (local-set-key "\C-c>" 'md-add-lhs)
  (local-set-key [?\C->] 'md-add-lhs)
  (local-set-key "\C-c<" 'markdown-invert-birdtracks)
  (local-set-key [?\C-=] 'markdown-add-header-equals)
  (local-set-key [?\C--] 'markdown-add-header-hyphen)
  (local-set-key [?\C-$] 'surround-dollars)
  (local-set-key "\C-cH" 'hoogle-lookup)
  (setq indent-line-function 'indent-relative)
  (setq tab-always-indent t)
  (setq require-final-newline nil)
  ;;(message "my-markdown-mode-hook: (buffer-file-name) is %s" (buffer-file-name))
  ;; With mmm, the haskell-literate variable somehow gets reset to nil
  ;; after being set to 'bird.  Fix it here.
  ;; 
  ;; Oh dear. This hack has a serious problem. When I use backticks to set
  ;; off haskell code in text, the whole line is colored as a comment.
  ;; This problem is a special case of a broader issue, which is that
  ;; haskell coloring spills out of the embedded code fragments.  For now,
  ;; turn off haskell-mode for these embedded fragments in my-mmm.
  (setq haskell-literate 'bird)
  ;; For literate haskell programs
  (local-set-key "\C-c\C-l" 'inferior-haskell-load-file)
  (local-set-key "\C-c\C-r" 'inferior-haskell-reload-file)
)

;;; Swiped & modified from twee-add-item.
;;; TODO: refactor/generalize 

;; (defun markdown-add-item () ... )

(add-hook 'markdown-mode-hook 'my-markdown-mode-hook)

;;; for gitit
(push '("\\.page$" . markdown-mode) auto-mode-alist)

;; For use with the FireFox plugin "It's All Text!".
;; https://addons.mozilla.org/firefox/4125.
;; Of course, I might want to edit things other than tiddlers, so this
;; choice is a hack.
;; (add-to-list 'auto-mode-alist '("itsalltext" . big-twee-mode))

;; (defun big-twee-mode ()
;;   (twee-mode)
;;   ;; (choose-big-font)
;;   )

;; There's some kind of buggy interaction between longlines and mmm modes
;; causing long lines to get hard breaks on loading.
;; Solution: require mmm-mode to be activated manually.
;; (setq mmm-global-mode nil) ; default = 'maybe


(add-hook 'twee-mode-hook 'my-twee-mode-hook)
;; (add-hook 'longlines-mode-hook 'twee-dont-fill-paragraph-hook)

(defun my-twee-mode-hook ()
  (turn-on-font-lock)
  (modify-syntax-entry ?\' "w")  ; for my abbrevs
  (ispell-minor-mode 1)
  (abbrev-mode 1)
  (setq indent-tabs-mode nil)
  (local-set-key "\C-cc" 'twee-add-code-env)
  (local-set-key "\C-c>" 'twee-add-quote-env)
  (local-set-key "\C-cs" 'add-spec-env)
  (local-set-key "\C-c@" 'add-code)
  (local-set-key [?\C-'] 'add-code)
  (local-set-key [?\C-,] 'markdown-mmmify-lines)
  (local-set-key "\C-ch" 'add-hask)
  (local-set-key "\C-cH" 'add-haskell)
  (local-set-key "@" 'twee-code-mmm)
  (local-set-key "\C-c*" 'surround-double-slash)
  (local-set-key [?\C-*] 'surround-double-slash)
  ;; (local-set-key "\C-c@" (twee-delim-command "@" "@"))
  )


;; (defun add-code ()
;;   "Insert \"\\begin{code} .... \\end{code}\" if at start of line and \"@ @\" otherwise."
;;   (interactive)
;;   (if (bolp)
;;       (add-code-env)
;;     (insert "@@")
;;     (backward-char 1)))

(defun add-code (arg)
  "\\[surround-atsign] and \\[mmm-parse-block] (when \\[[mmm-mode]])"
  (interactive "p")
  (surround-atsign arg)
  (expand-abbrev)
  ;; (insert " ") ; experiment
  (when mmm-mode (mmm-parse-block 1))
  )


(defun add-env (env)
  "Insert \"\\begin{<ENV>} .... \\end{<ENV>}\"."
  (unless (bolp) (newline)) ; start on new line
  (twee-no-longlines
   (insert "\\begin{" env "}\n\n\\end{" env "}")
   (previous-line 1))
  (when mmm-mode (mmm-parse-block 1))
  )

(defun add-code-env ()
  "Insert \"\\begin{code} .... \\end{code}\"."
  (interactive)
  (add-env "code"))

(defun twee-add-code-env ()
  "Like \\[add-code-env] but for use in twee-mode.  First does \\[twee-add-sublist] if not at
beginning of line."
  (interactive)
  (unless (bolp)
    (twee-add-sublist)
    ;; remove usual first list item
    ;; (beginning-of-line) (kill-line)
    ;; Use delete-region instead, to preserve kill-buffer state
    (delete-region (save-excursion (beginning-of-line) (point)) (point))
    )
  (add-code-env))

(defun twee-add-quote-env ()
  "Add a nested quote."
  (interactive)
  (twee-add-sublist)
  ;; remove usual first list item
  ;; (beginning-of-line) (kill-line)
  ;; Use delete-region instead, to preserve kill-buffer state
  (delete-region (save-excursion (beginning-of-line) (point)) (point))
  (backward-char 1)
  (insert ">")
  (forward-char 1)
  )

(defun twee-code-mmm ()
  "Insert an \"@\" and redo mmm-parse for recent text, to highlight.  Helps with the closing \"@\"."
  (interactive)
  (insert "@")
  (mmm-parse-block 1)
  )


(defun add-spec-env ()
  "Insert \"\\begin{spec} .... \\end{spec}\"."
  (interactive)
  (add-env "spec"))

(defun add-hask ()
  "Insert \"<hask>...</hask>\""
  (interactive)
  (insert "<hask></hask>")
  (backward-char 7))

(defun add-haskell ()
  "Insert \"<haskell>...</haskell>\""
  (interactive)
  (twee-no-longlines
   (insert "<haskell>\n\n</haskell>")
   (previous-line 1))
  (when mmm-mode (mmm-parse-block 1)))


(defun my-diff-mode-hook ()
  ;; (local-set-key "\M-o" 'diff-goto-source) ; default
  (local-set-key "\M-o" 'other-window)
  )

(add-hook 'diff-mode-hook 'my-diff-mode-hook)

(defun my-haskell-cabal-mode-hook ()
  ;; Cabal doesn't like tabs.  Maybe Stefan will change the default.  Requested on 2009-07-09.
  (setq indent-tabs-mode nil)
  (abbrev-mode t))

(add-hook 'haskell-cabal-mode-hook 'my-haskell-cabal-mode-hook)

(defun my-bibtex-mode-hook ()
  (setq indent-tabs-mode nil)
  (abbrev-mode t)
  ;; I don't know why paragraph boundaries aren't recognized.
  ;; Every line is treated as a paragraph.
  (setq paragraph-start "[ \f	]*$")
  )

(add-hook 'bibtex-mode-hook 'my-bibtex-mode-hook)

(autoload 'glsl-mode "glsl-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.vert\\'" . glsl-mode))
(add-to-list 'auto-mode-alist '("\\.frag\\'" . glsl-mode))
(add-to-list 'auto-mode-alist '("\\.vsh\\'" . glsl-mode))
(add-to-list 'auto-mode-alist '("\\.fsh\\'" . glsl-mode))
(add-to-list 'auto-mode-alist '("\\.glsl\\'" . glsl-mode))

(defun my-css-mode-hook ()
  (setq paragraph-start "^$")
  (setq paragraph-separate "^$"))

(add-hook 'css-mode-hook 'my-css-mode-hook)

(defun my-git-comment-hook ()
  (abbrev-mode 1)
  )

(add-hook 'git-comment-hook 'my-git-comment-hook)