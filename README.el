;;; Guardrail

(when (< emacs-major-version 29)
  (error (format "Emacs Bedrock only works with Emacs 29 and newer; you have version ~a" emacs-major-version)))

;; This initializes the packages for when one is reading the org file directly
(package-initialize)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Basic settings
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Package initialization
;;
;; We'll stick to the built-in GNU and non-GNU ELPAs (Emacs Lisp Package
;; Archive) for the base install, but there are some other ELPAs you could look
;; at if you want more packages. MELPA in particular is very popular. See
;; instructions at:
;;
;;    https://melpa.org/#/getting-started
;;
;; You can simply uncomment the following if you'd like to get started with
;; MELPA packages quickly:
;;
(with-eval-after-load 'package
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))

;; If you want to turn off the welcome screen, uncomment this
(setopt inhibit-splash-screen t)

;; Disable menu bar 
(menu-bar-mode -1)

(setopt initial-major-mode 'fundamental-mode)  ; default mode for the *scratch* buffer
(setopt display-time-default-load-average nil) ; this information is useless for most

;; Automatically reread from disk if the underlying file changes
(setopt auto-revert-avoid-polling t)
;; Some systems don't do file notifications well; see
;; https://todo.sr.ht/~ashton314/emacs-bedrock/11
(setopt auto-revert-interval 5)
(setopt auto-revert-check-vc-info t)
(global-auto-revert-mode)

;; Save history of minibuffer
(savehist-mode)

;; Move through windows with Ctrl-<arrow keys>
(windmove-default-keybindings 'control) ; You can use other modifiers here

;; Fix archaic defaults
(setopt sentence-end-double-space nil)

;; Make right-click do something sensible
(when (display-graphic-p)
  (context-menu-mode))

					; Disable the bell
(setq ring-bell-function 'ignore)

(set-face-attribute 'default nil :height 150)  ; set font size

(setq undo-outer-limit 72000000)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Discovery aids
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Show the help buffer after startup
;;(add-hook 'after-init-hook 'help-quick)
;;(setq inhibit-startup-screen t
;;	initial-buffer-choice  nil)

;; which-key: shows a popup of available keybindings when typing a long key
;; sequence (e.g. C-x ...)
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Minibuffer/completion settings
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; For help, see: https://www.masteringemacs.org/article/understanding-minibuffer-completion

(setopt enable-recursive-minibuffers t)                ; Use the minibuffer whilst in the minibuffer
(setopt completion-cycle-threshold 1)                  ; TAB cycles candidates
(setopt completions-detailed t)                        ; Show annotations
(setopt tab-always-indent 'complete)                   ; When I hit TAB, try to complete, otherwise, indent
(setopt completion-styles '(basic initials substring)) ; Different styles to match input to candidates

(setopt completion-auto-help 'always)                  ; Open completion always; `lazy' another option
(setopt completions-max-height 20)                     ; This is arbitrary
(setopt completions-detailed t)
(setopt completions-format 'one-column)
(setopt completions-group t)
(setopt completion-auto-select 'second-tab)            ; Much more eager
					;(setopt completion-auto-select t)                     ; See `C-h v completion-auto-select' for more possible values

(keymap-set minibuffer-mode-map "TAB" 'minibuffer-complete) ; TAB acts more like how it does in the shell

;; some global key bindings
(global-set-key (kbd "C-S-p") 'execute-extended-command)
(global-set-key (kbd "C-f") 'isearch-forward)
(global-set-key (kbd "C-S-f") 'isearch-backward)
(global-set-key (kbd "C-s") 'save-buffer)
(global-set-key (kbd "C-s") 'save-buffer)
(define-key minibuffer-local-map (kbd "C-S-p") 'keyboard-escape-quit)

;; For a fancier built-in completion option, try ido-mode,
;; icomplete-vertical, or fido-mode. See also the file extras/base.el

;;(icomplete-vertical-mode)
;;(fido-vertical-mode)
;;(setopt icomplete-delay-completions-threshold 4000)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Interface enhancements/defaults
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Mode line information
(setopt line-number-mode t)                        ; Show current line in modeline
(setopt column-number-mode t)                      ; Show column as well

(setopt x-underline-at-descent-line nil)           ; Prettier underlines
(setopt switch-to-buffer-obey-display-actions t)   ; Make switching buffers more consistent

(setopt show-trailing-whitespace nil)      ; By default, don't underline trailing spaces
(setopt indicate-buffer-boundaries 'left)  ; Show buffer top and bottom in the margin

;; Enable horizontal scrolling
(setopt mouse-wheel-tilt-scroll t)
(setopt mouse-wheel-flip-direction t)

;; We won't set these, but they're good to know about
;;
;; (setopt indent-tabs-mode nil)
;; (setopt tab-width 4)

;; Misc. UI tweaks
(blink-cursor-mode -1)                                ; Steady cursor
(pixel-scroll-precision-mode)                         ; Smooth scrolling

;; Use common keystrokes by default
(cua-mode)

;; Display line numbers in programming mode
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(setopt display-line-numbers-width 3)           ; Set a minimum width

;; Nice line wrapping when working with text
(add-hook 'text-mode-hook 'visual-line-mode)

;; Modes to highlight the current line with
(let ((hl-line-hooks '(text-mode-hook prog-mode-hook)))
  (mapc (lambda (hook) (add-hook hook 'hl-line-mode)) hl-line-hooks))

;; remove scroll-bar
;;(scroll-bar-mode -1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Tab-bar configuration
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Show the tab-bar as soon as tab-bar functions are invoked
(setopt tab-bar-show 1)

;; Add the time to the tab-bar, if visible
(add-to-list 'tab-bar-format 'tab-bar-format-align-right 'append)
(add-to-list 'tab-bar-format 'tab-bar-format-global 'append)
(setopt display-time-format "%a %F %T")
(setopt display-time-interval 1)
(display-time-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Theme
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package emacs
  :config
  (load-theme 'modus-operandi))          ; for light theme, use modus-operandi

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Built-in customization framework
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(modus-operandi))
 '(package-selected-packages '(org-roam citar ess evil which-key)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Motion aids
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package avy
  :ensure t
  :demand t
  :bind (("C-c j" . avy-goto-line)
	 ("S-j"   . avy-goto-char-timer)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Power-ups: Embark and Consult
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Consult: Misc. enhanced commands
(use-package consult
  :ensure t
  :bind (
	 ;; Drop-in replacements
	 ("C-x b" . consult-buffer)     ; orig. switch-to-buffer
	 ("M-y"   . consult-yank-pop)   ; orig. yank-pop
	 ;; Searching
	 ("M-s r" . consult-ripgrep)
	 ("M-s l" . consult-line)       ; Alternative: rebind C-s to use
	 ("M-s s" . consult-line)       ; consult-line instead of isearch, bind
	 ("M-s L" . consult-line-multi) ; isearch to M-s s
	 ("M-s o" . consult-outline)
	 ;; Isearch integration
	 :map isearch-mode-map
	 ("M-e" . consult-isearch-history)   ; orig. isearch-edit-string
	 ("M-s e" . consult-isearch-history) ; orig. isearch-edit-string
	 ("M-s l" . consult-line)            ; needed by consult-line to detect isearch
	 ("M-s L" . consult-line-multi)      ; needed by consult-line to detect isearch
	 )
  :config
  ;; Narrowing lets you restrict results to certain groups of candidates
  (setq consult-narrow-key "<"))

(use-package embark-consult
  :ensure t
  :after embark
  :after consult
  )

(use-package embark
  :ensure t
  :demand t
  :after avy
  :bind (("C-c a" . embark-act))        ; bind this to an easy key to hit
  :init
  ;; Add the option to run embark when using avy
  (defun bedrock/avy-action-embark (pt)
    (unwind-protect
	(save-excursion
	  (goto-char pt)
	  (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)

  ;; After invoking avy-goto-char-timer, hit "." to run embark at the next
  ;; candidate you select
  (setf (alist-get ?. avy-dispatch-alist) 'bedrock/avy-action-embark))

(use-package embark-consult
  :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Minibuffer and completion
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Vertico: better vertical completion for minibuffer commands
(use-package vertico
  :ensure t
  :init
  ;; You'll want to make sure that e.g. fido-mode isn't enabled
  (vertico-mode))

(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map
	      ("M-DEL" . vertico-directory-delete-word)))

;; Marginalia: annotations for minibuffer
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode))

;; Popup completion-at-point
(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-preview-current nil)    ;; Disable current candidate preview
  :bind
  (:map corfu-map
	("SPC" . corfu-insert-separator)
	("C-n" . corfu-next)
	("C-p" . corfu-previous)))

;; Part of corfu
(use-package corfu-popupinfo
  :after corfu
  :ensure nil
  :hook (corfu-mode . corfu-popupinfo-mode)
  :custom
  (corfu-popupinfo-delay '(0.25 . 0.1))
  (corfu-popupinfo-hide nil)
  :config
  (corfu-popupinfo-mode))

;; Make corfu popup come up in terminal overlay
(use-package corfu-terminal
  :if (not (display-graphic-p))
  :ensure t
  :config
  (corfu-terminal-mode))

(use-package corfu-doc
  :hook (corfu-mode-hook . corfu-doc-mode))

;; Fancy completion-at-point functions; there's too much in the cape package to
;; configure here; dive in when you're comfortable!
(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

;; Pretty icons for corfu
(use-package kind-icon
  :if (display-graphic-p)
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package eshell
  :init
  (defun bedrock/setup-eshell ()
    ;; Something funny is going on with how Eshell sets up its keymaps; this is
    ;; a work-around to make C-r bound in the keymap
    (keymap-set eshell-mode-map "C-r" 'consult-history))
  :hook ((eshell-mode . bedrock/setup-eshell)))

;; Orderless: powerful completion style
(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Misc. editing enhancements
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Modify search results en masse
(use-package wgrep
  :ensure t
  :config
  (setq wgrep-auto-save-buffer t))

(which-key-show-top-level)

(use-package tramp
  :ensure t
  :config
  (eval-after-load 'tramp '(setenv "NCPUS" "23"))  ;; set env variables
  (eval-after-load 'tramp '(setenv "OMP_NUM_THREADS" "23"))  ;; set env variables

  (add-to-list 'tramp-methods
	       ;; this is an internal method for interactive scripting, change to what your server uses
	       '("qsub"   
		 (tramp-login-program        "qsub")
		 (tramp-login-args           (("-I -l ncpus=23"))) ; options here?
		 ;; the local $SHELL may contain conflicting configuration
		 ;; this should be good for most cases 
		 (tramp-login-env            (("SHELL") ("/bin/sh")))
		 (tramp-remote-shell         "/bin/sh")
		 (tramp-remote-shell-args    ("-c"))
		 (tramp-connection-timeout   10)))
  )

;;; This will try to use tree-sitter modes for many languages. Please run
    ;;;
    ;;;   M-x treesit-install-language-grammar
    ;;;
    ;;; Before trying to use a treesit mode.

    ;;; Contents:
    ;;;
    ;;;  - Built-in config for developers
    ;;;  - Version Control
    ;;;  - Common file types
    ;;;  - Eglot, the built-in LSP client for Emacs

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;
    ;;;   Built-in config for developers
    ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq treesit-language-source-alist
      '((r . ("https://github.com/r-lib/tree-sitter-r" "main" "src"))
        (nim . ("https://github.com/alaviss/tree-sitter-nim" "main" "src"))))

(use-package emacs
  :config
  ;; Treesitter config

  ;; Tell Emacs to prefer the treesitter mode
  ;; You'll want to run the command `M-x treesit-install-language-grammar' before editing.
  (setq major-mode-remap-alist
        '((yaml-mode . yaml-ts-mode)
          (bash-mode . bash-ts-mode)
          (js2-mode . js-ts-mode)
          (typescript-mode . typescript-ts-mode)
          (json-mode . json-ts-mode)
          ;;  (nim-mode . nim-ts-mode)
          (css-mode . css-ts-mode)
          (python-mode . python-ts-mode)))
  :hook
  ;; Auto parenthesis matching
  (prog-mode . electric-pair-mode))

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;
    ;;;   Version Control
    ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Magit: best Git client to ever exist
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;
    ;;;   Common file types
    ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package markdown-mode
  :hook ((markdown-mode . visual-line-mode)))

(use-package yaml-mode
  :ensure t)

(use-package json-mode
  :ensure t)

;; Emacs ships with a lot of popular programming language modes. If it's not
;; built in, you're almost certain to find a mode for the language you're
;; looking for with a quick Internet search.

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;
    ;;;   Eglot, the built-in LSP client for Emacs
    ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Helpful resources:
;;
;;  - https://www.masteringemacs.org/article/seamlessly-merge-multiple-documentation-sources-eldoc

(use-package eglot
  ;; no :ensure t here because it's built-in
  :defer t
  ;; Configure hooks to automatically turn-on eglot for selected modes
  :custom
  (eglot-send-changes-idle-time 0.1)
  (eglot-extend-to-xref t)              ; activate Eglot in referenced non-project files

  :config
  (fset #'jsonrpc--log-event #'ignore)  ; massive perf boost---don't log every event
  ;; Sometimes you need to tell Eglot where to find the language server
  ;; (add-to-list 'eglot-server-programs
  ;;              '(haskell-mode . ("haskell-language-server-wrapper" "--lsp")))
  (setq eglot-stay-out-of '(company))

  (defun company-R-objects--prefix ()
    (unless (ess-inside-string-or-comment-p)
      (let ((start (ess-symbol-start)))
        (when start
          (buffer-substring-no-properties start (point))))))

  (defun company-R-objects--candidates (arg)
    (let ((proc (ess-get-next-available-process)))
      (when proc
        (with-current-buffer (process-buffer proc)
          (all-completions arg (ess--get-cached-completions arg))))))

  (defun company-capf-with-R-objects--check-prefix (prefix)
    (cl-search "$" prefix))

  (defun company-capf-with-R-objects (command &optional arg &rest ignored)
    (interactive (list 'interactive))
    (cl-case command
      (interactive (company-begin-backend 'company-R-objects))
      (prefix (company-R-objects--prefix))
      (candidates (if (company-capf-with-R-objects--check-prefix arg)
                      (company-R-objects--candidates arg)
                    (company-capf command arg)))
      (annotation (if (company-capf-with-R-objects--check-prefix arg)
                      "R-object"
                    (company-capf command arg)))
      (kind (if (company-capf-with-R-objects--check-prefix arg)
                'field
              (company-capf command arg)))
      (doc-buffer (company-capf command arg))))
  )

(use-package citar
  :ensure t
  :bind (("C-c b" . citar-insert-citation)
	 :map minibuffer-local-map
	 ("M-b" . citar-insert-preset))
  :custom
  ;; Allows you to customize what citar-open does
  (citar-file-open-functions '(("html" . citar-file-open-external)
			       ;; ("pdf" . citar-file-open-external)
			       (t . find-file))))

;; Optional: if you have the embark package installed, enable the ability to act
;; on citations with Citar by invoking `embark-act'.
(use-package citar-embark
  :ensure t
  :after citar embark
  :diminish ""
  :no-require
  :config (citar-embark-mode))

(use-package citar-org-roam
  :diminish ""
  ;; To get this to work both Citar *and* Org-roam have to have been used
  :after citar org-roam
  :no-require
  :config
  (citar-org-roam-mode)
  (setq citar-org-roam-note-title-template "${author} - ${title}\n#+filetags: ${tags}"))

(use-package org
  :ensure t
  :hook ((org-mode . visual-line-mode)  ; wrap lines at word breaks
	 (org-mode . flyspell-mode)     ; spell checking!
	 (org-mode . notebook-mode)
	 (org-mode . toc-org-mode))    ; notebook mode

  :bind (:map global-map
	      ("C-c l s" . org-store-link)          ; Mnemonic: link → store
	      ("C-c l i" . org-insert-link-global)) ; Mnemonic: link → insert
  :init
  (setq  org-startup-with-inline-images 'inlineimages)
  (setq org-image-actual-width `( ,(truncate (* (frame-pixel-width) 0.85))))
  (setq org-confirm-babel-evaluate nil)
  ;;(setq org-format-latex-options (plist-put org-format-latex-options :scale 2))
  (setq org-format-latex-options (plist-put nil :scale 1.0))

  :custom
  (org-display-remote-inline-images 'download)

  :config
  (require 'oc-csl)                     ; citation support
  (add-to-list 'org-export-backends 'md)

  ;; Make org-open-at-point follow file links in the same window
  (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file)

  ;; Make exporting quotes better
  (setq org-export-with-smart-quotes t)

  ;; Verbatim in slides
  (require 'ox-latex)
  (add-to-list 'org-latex-packages-alist '("" "minted"))
  (setq org-latex-listings 'minted)

  ;; toggle blocks
  (defvar org-blocks-hidden nil)

  (defun org-toggle-blocks ()
    (interactive)
    (if org-blocks-hidden
	(org-show-block-all)
      (org-hide-block-all))
    (setq-local org-blocks-hidden (not org-blocks-hidden)))

  (define-key org-mode-map (kbd "C-c b t") 'org-toggle-blocks)
  ;; (define-key org-mode-map (kbd "C-c b t") 'org-babel-switch-to-session-with-code)

  (add-hook 'org-mode-hook 'org-toggle-blocks)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (R . t)
     (julia . t)
     (latex . t)
     (C . t)
     (emacs-lisp . t)))

  (defun ek/babel-ansi ()
    (when-let ((beg (org-babel-where-is-src-block-result nil nil)))
      (save-excursion
	(goto-char beg)
	(when (looking-at org-babel-result-regexp)
	  (let ((end (org-babel-result-end))
		(ansi-color-context-region nil))
	    (ansi-color-apply-on-region beg end))))))
  (add-hook 'org-babel-after-execute-hook 'ek/babel-ansi)


  (define-key org-mode-map (kbd "$")
	      (lambda ()
		(interactive)
		(insert "$")
		(save-excursion
		  (backward-char 1)
		  (if (org-inside-LaTeX-fragment-p)
		      (progn
			(forward-char 2)
			(org-preview-latex-fragment))))))

  )

;; THIS SECTION IS FOR THE HTML EMBEDDED EXPORT
(require 'org)
(require 'ox-html)
(require 'base64)

(defcustom org-html-image-base64-max-size #x40000
  "Export embedded base64 encoded images up to this size."
  :type 'number
  :group 'org-export-html)

(defun file-to-base64-string (file &optional image prefix postfix)
  "Transform binary file FILE into a base64-string prepending PREFIX and appending POSTFIX.
		  Puts \"data:image/%s;base64,\" with %s replaced by the image type before the actual image data if IMAGE is non-nil."
  (concat prefix
	  (with-temp-buffer
	    (set-buffer-multibyte nil)
	    (insert-file-contents file nil nil nil t)
	    (base64-encode-region (point-min) (point-max) 'no-line-break)
	    (when image
	      (goto-char (point-min))
	      (insert (format "data:image/%s;base64," (image-type-from-file-name file))))
	    (buffer-string))
	  postfix))


(defun orgTZA-html-base64-encode-p (file)
  "Check whether FILE should be exported base64-encoded.
    The return value is actually FILE with \"file://\" removed if it is a prefix of FILE."
  (when (and (stringp file)
	     (string-match "\\`file:" file))
    (if (string-match "\\`file://ssh" file)
	(setq file (replace-regexp-in-string "\\`file://ssh" "/ssh" file))
      (setq file (substring file (match-end 0)))))
  (and
   (file-readable-p file)
   (let ((size (nth 7 (file-attributes file))))
     (<= size org-html-image-base64-max-size))
   file))


(defun orgTZA-html--format-image (source attributes info)
  "Return \"img\" tag with given SOURCE and ATTRIBUTES.
		  SOURCE is a string specifying the location of the image.
		  ATTRIBUTES is a plist, as returned by
		  `org-export-read-attribute'.  INFO is a plist used as
		  a communication channel."
  (if (string= "svg" (file-name-extension source))
      (org-html--svg-image source attributes info)
    (let* ((file (orgTZA-html-base64-encode-p source))
	   (data (if file (file-to-base64-string file t)
		   source)))
      (org-html-close-tag
       "img"
       (org-html--make-attribute-string
	(org-combine-plists
	 (list :src data
	       :alt (if (string-match-p "^ltxpng/" source)
			(org-html-encode-plain-text
			 (org-find-text-property-in-string 'org-latex-src source))
		      (file-name-nondirectory source)))
	 attributes))
       info))))

(advice-add 'org-html--format-image :override #'orgTZA-html--format-image)

;; END THIS SECTION IS FOR THE HTML EMBEDDED EXPORT

(use-package toc-org
  :ensure t
  :after org
  :hook (org-mode-hook . toc-org-mode)
  )

(use-package svg-tag-mode
  :ensure t
  )

(require 'org)
(require 'svg-tag-mode)

(defgroup notebook nil
  "Customization options for `notebook-mode'."
  :group 'org)

(defcustom notebook-babel-python-command
  "/opt/anaconda3/bin/python"
  "Python interpreter's path."
  :group 'notebook)

(defcustom notebook-cite-csl-styles-dir
  "."
  "CSL styles citations' directory."
  :group 'notebook)

(defcustom notebook-tags
  '(
    ;; Inline code
    ;; --------------------------------------------------------------------
    ("^#\\+call:" .     ((lambda (tag) (svg-tag-make "CALL"
						     :face 'org-meta-line))
			 (lambda () (interactive) (notebook-call-at-point)) "Call function"))
    ("call_" .         ((lambda (tag) (svg-tag-make "CALL"
						    :face 'default
						    :margin 1
						    :alignment 0))
			(lambda () (interactive) (notebook-call-at-point)) "Call function"))
    ("src_" .          ((lambda (tag) (svg-tag-make "CALL"
						    :face 'default
						    :margin 1
						    :alignment 0))
			(lambda () (interactive) (notebook-call-at-point)) "Execute code"))

    ;; Code blocks
    ;; --------------------------------------------------------------------
    ("^#\\+begin_src\\( [a-zA-Z\-]+\\)" .  ((lambda (tag)
					      (svg-tag-make (upcase tag)
							    :face 'org-meta-line
							    :crop-left t))))
    ("^#\\+begin_src" . ((lambda (tag) (svg-tag-make "RUN"
						     :face 'org-meta-line
						     :inverse t
						     :crop-right t))
			 (lambda () (interactive) (notebook-run-at-point)) "Run code block"))
    ("^#\\+end_src" .    ((lambda (tag) (svg-tag-make "END"
						      :face 'org-meta-line))))
    (":session" . ((lambda (tag) (svg-tag-make "ZOOM-IN"
					       :face 'org-meta-line
					       :inverse t
					       :crop-right t))
		   (lambda () (interactive) (mb/org-babel-zoom-in)) "Zoom-in"))



    ;; Export blocks
    ;; --------------------------------------------------------------------
    ("^#\\+begin_export" . ((lambda (tag) (svg-tag-make "EXPORT"
							:face 'org-meta-line
							:inverse t
							:alignment 0
							:crop-right t))))
    ("^#\\+begin_export\\( [a-zA-Z\-]+\\)" .  ((lambda (tag)
						 (svg-tag-make (upcase tag)
							       :face 'org-meta-line
							       :crop-left t))))
    ("^#\\+end_export" . ((lambda (tag) (svg-tag-make "END"
						      :face 'org-meta-line))))

    ;; :noexport: tag
    ;; --------------------------------------------------------------------
    ("\\(:no\\)export:" .    ((lambda (tag) (svg-tag-make "NO"
							  :face 'org-meta-line
							  :inverse t
							  :crop-right t))))
    (":no\\(export:\\)" .    ((lambda (tag) (svg-tag-make "EXPORT"
							  :face 'org-meta-line
							  :crop-left t))))

    ;; Miscellaneous keywords
    ;; --------------------------------------------------------------------
    ("|RUN|" .          ((lambda (tag) (svg-tag-make "RUN"
						     :face 'org-meta-line
						     :inverse t))))
    ("|RUN ALL|" .       ((lambda (tag) (svg-tag-make "RUN ALL"
						      :face 'org-meta-line))
			  (lambda () (interactive) (notebook-run)) "Run all notebook code blocks"))
    ("|SETUP|" .         ((lambda (tag) (svg-tag-make "SETUP"
						      :face 'org-meta-line))
			  (lambda () (interactive) (notebook-setup)) "Setup notebook environment"))
    ("|ZOOM-IN-CODE|" .       ((lambda (tag) (svg-tag-make "ZOOM-IN"
							   :face 'org-meta-line))
			       (lambda () (interactive) (mb/org-babel-zoom-in)) "Zoom-in"))

    ("|EXPORT|" .        ((lambda (tag) (svg-tag-make "EXPORT"
						      :face 'org-meta-line))
			  (lambda () (interactive) (notebook-export-html)) "Export the notebook to HTML"))
    ("|CALL|" .          ((lambda (tag) (svg-tag-make "CALL"
						      :face 'org-meta-line))))


    ;; References
    ;; --------------------------------------------------------------------
    ("\\(\\[cite:@[A-Za-z]+:\\)" .
     ((lambda (tag) (svg-tag-make (upcase tag)
					;            :face 'nano-default
				  :inverse t
				  :beg 7 :end -1
				  :crop-right t))))
    ("\\[cite:@[A-Za-z]+:\\([0-9a-z]+\\]\\)" .
     ((lambda (tag) (svg-tag-make (upcase tag)
					;            :face 'nano-default
				  :end -1
				  :crop-left t))))

    ;; Miscellaneous properties
    ;; --------------------------------------------------------------------
    ("^#\\+caption:" .   ((lambda (tag) (svg-tag-make "CAPTION"
						      :face 'org-meta-line))))
    ("^#\\+latex:" .     ((lambda (tag) (svg-tag-make "LATEX"
						      :face 'org-meta-line))))
    ("^#\\+html:" .      ((lambda (tag) (svg-tag-make "HTML"
						      :face 'org-meta-line))))
    ("^#\\+name:" .      ((lambda (tag) (svg-tag-make "NAME"
						      :face 'org-meta-line))))
    ("^#\\+header:" .    ((lambda (tag) (svg-tag-make "HEADER"
						      :face 'org-meta-line))))
    ("^#\\+label:" .     ((lambda (tag) (svg-tag-make "LABEL"
						      :face 'org-meta-line))))
    ("^#\\+results:"  .  ((lambda (tag) (svg-tag-make "RESULTS"
						      :face 'org-meta-line)))))
  "The `notebook-mode' tags alist.
       This alist is the `notebook-mode' specific tags list.  It follows the
       same definition pattern as the `svg-tag-tags' alist (to which
       `notebook-tags' is added)."
  :group 'notebook)


(defcustom notebook-font-lock-case-insensitive t
  "Make the keywords fontification case insensitive if non-nil."
  :group 'notebook)

(defcustom notebook-indent t
  "Default document indentation.
	 If non-nil, `org-indent' is called when the mode is turned on."
  :group 'notebook)

(defcustom notebook-hide-blocks t
  "Default visibility of org blocks in `notebook-mode'.
	 If non-nil, the org blocks are hidden when the mode is turned on."
  :group 'notebook)

(defun notebook-run-at-point ()
  "Update notebook rendering at point."
  (interactive)
  (org-ctrl-c-ctrl-c)
  (org-redisplay-inline-images))

(defalias 'notebook-call-at-point 'org-ctrl-c-ctrl-c)

(defun notebook-setup ()
  "Notebook mode setup function."
  (interactive)
  (setq org-cite-csl-styles-dir notebook-cite-csl-styles-dir)
  (setq org-babel-python-command notebook-babel-python-command)
  (require 'ob-python)
  (require 'oc-csl))

(defalias 'notebook-run 'org-babel-execute-buffer)

(defalias 'notebook-export-html 'org-html-export-to-html)

(defun notebook-mode-on ()
  "Activate notebook mode."

  (add-to-list 'font-lock-extra-managed-props 'display)
  (setq font-lock-keywords-case-fold-search notebook-font-lock-case-insensitive)
  (setq org-image-actual-width `( ,(truncate (* (frame-pixel-width) 0.85))))
  (setq org-startup-with-inline-images t)
  (mapc #'(lambda (tag) (add-to-list 'svg-tag-tags tag)) notebook-tags)
  (org-redisplay-inline-images)
  (if notebook-indent (org-indent-mode))
  (if notebook-hide-blocks (org-hide-block-all))
  (add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)
  (svg-tag-mode 1)
  (message "notebook mode on"))

(defun notebook-mode-off ()
  "Deactivate notebook mode."

  (svg-tag-mode -1)
  (if notebook-indent (org-indent-mode -1))
  (if notebook-hide-blocks (org-hide-block-all))
  (remove-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images))

     ;;; autoload
(define-minor-mode notebook-mode
  "Minor mode for graphical tag as rounded box."
  :group 'notebook
  (if notebook-mode
      (notebook-mode-on)
    (notebook-mode-off)))

(define-globalized-minor-mode
  global-notebook-mode notebook-mode notebook-mode-on)

(use-package notebook
  :after org-mode
  :config
  (svg-tag-mode 1)
  )

(use-package ess
    :ensure t 
    :defer t
    :init
    (add-hook 'ess-mode-hook
              (lambda()
                (eglot-ensure)
                (make-local-variable 'company-backends)
                (setq company-backends '(company-files company-capf-with-R-objects))))
    ;;(setq ess-use-flymake nil)
    (setq ess-use-company 'scriptonly)
    :config
    (setq ess-history-directory "~/.cache")
    (setq ess-R-font-lock-keywords
          '((ess-R-fl-keyword:keywords . t)
            (ess-R-fl-keyword:constants . t)
            (ess-R-fl-keyword:modifiers . t)
            (ess-R-fl-keyword:fun-defs . t)
            (ess-R-fl-keyword:assign-ops . t)
            (ess-R-fl-keyword:%op% . t)
            (ess-fl-keyword:fun-calls . t)
            (ess-fl-keyword:numbers . t)
            (ess-fl-keyword:operators)
            (ess-fl-keyword:delimiters)
            (ess-fl-keyword:=)
            (ess-R-fl-keyword:F&T . t)))
    (setq ess-help-own-frame 'one)  ; avoid destroying existing frame
    (setq ess-help-reuse-window t)  ; same above
    (setq comint-scroll-to-bottom-on-input t)
    (setq comint-scroll-to-bottom-on-output t)
    (setq comint-move-point-for-output t)
    (setq comint-scroll-show-maximum-output t)

    (setq ess-ask-for-ess-directory nil)
    (setq ess-startup-directory 'default-directory)

    ;; Trying to speed up ess on orgmode
    (setq ess-eval-visibly-p 'nowait)

    (setq display-buffer-alist
          '(("^\\*R[:\\*]" . (display-buffer-in-side-window
                              (side . bottom)
                              (slot . -1)
                              ))
            ("^\\*R dired\\*" . (display-buffer-in-side-window
                                 (side . right)
                                 (slot . -1)
                                 (window-width . 0.25)))
            ("^\\*help\\[R\\]" . (display-buffer-in-side-window
                                  (side . right)
                                  (slot . 1)
                                  (window-width . 0.33)))))

    (define-key comint-mode-map (kbd "<up>") 'comint-previous-matching-input-from-input)
    (define-key comint-mode-map (kbd "<down>") 'comint-next-matching-input-from-input)

    )

(defun mb/org-babel-zoom-in ()
  "Edit src block with lsp support by tangling the block and
then setting the org-edit-special buffer-file-name to the
absolute path. Finally load eglot."
  (interactive)
  
  ;; org-babel-get-src-block-info returns lang, code_src, and header
  ;; params; Use nth 2 to get the params and then retrieve the :tangle
  ;; to get the filename
  (let* ((src-block-info (org-babel-get-src-block-info))
         (lang (nth 0 src-block-info))
         (params (nth 2 src-block-info))
         (tangled-file-name (expand-file-name (assoc-default :tangle params))))
    
    ;; Check if the language is R
    (when (string-equal lang "R")
      ;; Tangle the src block at point
      (org-babel-tangle '(4))

      ;; Switch to session with code
      (org-babel-switch-to-session-with-code)

      ;; Set the buffer-file-name to the tangled file
      (setq-local buffer-file-name tangled-file-name)
      
      ;; Ensure eglot is running
      (eglot-ensure)

      ;; Switch to ESS process buffer
      (ess-switch-to-inferior-or-script-buffer t)
      (ess-rdired)
      )))
