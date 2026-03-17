;; -*- lexical-binding: t -*-
  ;;; Guardrail
  (when (< emacs-major-version 29)
    (error (format "Emacs Bedrock only works with Emacs 29 and newer; you have version ~a" emacs-major-version)))


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
    (add-to-list 'package-archives '("melpa"  . "https://melpa.org/packages/") t))

  ;; This initializes the packages for when one is reading the org file directly
  (package-initialize)

  ;; If you want to turn off the welcome screen, uncomment this
  (setopt inhibit-splash-screen t)

  ;; Native compilation settings (optional, but recommended if your Emacs was built with it)
  (setq native-comp-deferred-compilation t
        native-comp-jit-compilation t)

  (when (featurep 'native-compile)
    (setq native-comp-async-report-warnings-errors nil)
    (setq native-comp-speed 3))

  (setq native-comp-compiler-options '("-march=znver3" "-Ofast" "-g0" "-fno-finite-math-only" "-fgraphite-identity" "-floop-nest-optimize" "-fdevirtualize-at-ltrans" "-fipa-pta" "-fno-semantic-interposition" "-flto=auto" "-fuse-linker-plugin"))

  ;; Kitty image viewer
  (setq image-use-external-converter t)

  (with-eval-after-load 'org
    (setq org-file-apps
          '((auto-mode . emacs)
            ("\\.png\\'"
             . "kitty @ launch --type=window --location=vsplit --cwd=current --title=Image kitty +kitten icat --hold %s")
            ("\\.jpg\\'"
             . "kitty @ launch --type=window --location=vsplit --cwd=current --title=Image kitty +kitten icat --hold %s"))))

  ;; Recent files
  (use-package recentf
    :init (recentf-mode)
    :custom (recentf-max-menu-items 25))

  ;; Save place in files
  (save-place-mode 1)

  ;; Enable async operations in Dired
  ;(use-package async
  ;  :ensure t
  ;  :config (dired-async-mode 1))

  ;; Enable CUA mode
  (cua-mode)

  ;; Disable menu bar
  (menu-bar-mode -1)

  ;;(setopt initial-major-mode 'fundamental-mode)  ; default mode for the *scratch* buffer
  (setopt display-time-default-load-average nil) ; this information is useless for most

  ;; Automatically reread from disk if the underlying file changes
  (setopt auto-revert-avoid-polling t)
  ;; Some systems don't do file notifications well; see
  ;; https://todo.sr.ht/~ashton314/emacs-bedrock/11
  (setopt auto-revert-interval 5)
  (setopt auto-revert-check-vc-info nil)
  (global-auto-revert-mode)

  ;; Save history of minibuffer
  (setq savehist-file "~/.emacs.d/savehist"
        history-length 1000
        history-delete-duplicates t
        savehist-save-minibuffer-history t
        savehist-additional-variables '(kill-ring search-ring regexp-search-ring))
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

  (setq undo-outer-limit 72000000)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;
  ;;;   Discovery aids
  ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; which-key: shows a popup of available keybindings when typing a long key
  ;; sequence (e.g. C-x ...)
  (use-package which-key
    :ensure t
    :defer t
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
  ;;(setopt completions-group t)
  (setopt completion-auto-select 'second-tab)            ; Much more eager
  (setopt completion-auto-select t)                     ; See `C-h v completion-auto-select' for more possible values

  ;; (keymap-set minibuffer-mode-map "TAB" 'minibuffer-complete) ; TAB acts more like how it does in the shell

  ;; some global key bindings
  (global-set-key (kbd "C-S-p") 'execute-extended-command)
  (global-set-key (kbd "C-f") 'isearch-forward)
  (global-set-key (kbd "C-S-f") 'isearch-backward)
  (global-set-key (kbd "C-s") 'save-buffer)
  ;(define-key minibuffer-local-map (kbd "C-S-p") 'keyboard-escape-quit)

  ;; For a fancier built-in completion option, try ido-mode,
  ;; icomplete-vertical, or fido-mode. See also the file extras/base.el

  ;(icomplete-vertical-mode)
  ;(fido-vertical-mode)
  ;(setopt icomplete-delay-completions-threshold 4000)

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

  ;; mouse in terminal
  (unless (display-graphic-p) (xterm-mouse-mode 1))

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
  ;;(setopt tab-bar-show 1)

  ;; Add the time to the tab-bar, if visible
  ;; (add-to-list 'tab-bar-format 'tab-bar-format-align-right 'append)
  ;; (add-to-list 'tab-bar-format 'tab-bar-format-global 'append)
  ;; (setopt display-time-format "%a %F %T")
  ;; (setopt display-time-interval 1)
  ;; (display-time-mode)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;
  ;;;   Theme
  ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; Copyright (c) 2025  Nicolas P. Rougier
  ;; Released under the GNU General Public License 3.0
  ;; Author: Nicolas P. Rougier <nicolas.rougier@inria.fr>
  ;; URL: https://github.com/rougier/nano-emacs

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;
  ;;;  N A N O 
  ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; --- Typography stack -------------------------------------------------------
  (set-face-attribute 'default nil
                      :height 140 :weight 'light :family "Roboto Mono")
  (set-face-attribute 'bold nil :weight 'regular)
  (set-face-attribute 'bold-italic nil :weight 'regular)
  (set-display-table-slot standard-display-table 'truncation (make-glyph-code ?…))
  (set-display-table-slot standard-display-table 'wrap (make-glyph-code ?–))

  ;; --- Frame / windows layout & behavior --------------------------------------
  (setq default-frame-alist
        '((height . 44) (width  . 81) (left-fringe . 0) (right-fringe . 0)
          (internal-border-width . 32) (vertical-scroll-bars . nil)
          (bottom-divider-width . 0) (right-divider-width . 0)
          (undecorated-round . t)))
  (modify-frame-parameters nil default-frame-alist)
  ;;(setq-default pop-up-windows nil)

  ;; --- Activate / Deactivate modes --------------------------------------------
  (blink-cursor-mode -1) ;;(tool-bar-mode -1) (menu-bar-mode -1)
  (global-hl-line-mode 1) (icomplete-vertical-mode 1)
  (pixel-scroll-precision-mode 1)

  ;; --- Minimal NANO (not a real) theme ----------------------------------------
  (defface nano-default '((t)) "")   (defface nano-default-i '((t)) "")
  (defface nano-highlight '((t)) "") (defface nano-highlight-i '((t)) "")
  (defface nano-subtle '((t)) "")    (defface nano-subtle-i '((t)) "")
  (defface nano-faded '((t)) "")     (defface nano-faded-i '((t)) "")
  (defface nano-salient '((t)) "")   (defface nano-salient-i '((t)) "")
  (defface nano-popout '((t)) "")    (defface nano-popout-i '((t)) "")
  (defface nano-strong '((t)) "")    (defface nano-strong-i '((t)) "")
  (defface nano-critical '((t)) "")  (defface nano-critical-i '((t)) "")

  (defun nano-set-face (name &optional foreground background weight)
    "Set NAME and NAME-i faces with given FOREGROUND, BACKGROUND and WEIGHT"

    (apply #'set-face-attribute `(,name nil
                                  ,@(when foreground `(:foreground ,foreground))
                                  ,@(when background `(:background ,background))
                                  ,@(when weight `(:weight ,weight))))
    (apply #'set-face-attribute `(,(intern (concat (symbol-name name) "-i")) nil
                                  :foreground ,(face-background 'nano-default)
                                  ,@(when foreground `(:background ,foreground))
                                  :weight regular)))

  (defun nano-link-face (sources faces &optional attributes)
    "Make FACES to inherit from SOURCES faces and unspecify ATTRIBUTES."

    (let ((attributes (or attributes
                          '( :foreground :background :family :weight
                             :height :slant :overline :underline :box))))
      (dolist (face (seq-filter #'facep faces))
        (dolist (attribute attributes)
          (set-face-attribute face nil attribute 'unspecified))
        (set-face-attribute face nil :inherit sources))))

  (defun nano-install-theme ()
    "Install THEME"

    (set-face-attribute 'default nil
                        :foreground (face-foreground 'nano-default)
                        :background (face-background 'nano-default))
    (dolist (item '((nano-default .  (variable-pitch variable-pitch-text
                                      fixed-pitch fixed-pitch-serif))
                    (nano-highlight . (hl-line highlight))
                    (nano-subtle .    (match region
                                       lazy-highlight widget-field))
                    (nano-faded .     (shadow
                                       font-lock-comment-face
                                       font-lock-doc-face
                                       icomplete-section
                                       completions-annotations))
                    (nano-popout .    (warning
                                       font-lock-string-face))
                    (nano-salient .   (success link
                                       help-argument-name
                                       custom-visibility
                                       font-lock-type-face
                                       font-lock-keyword-face
                                       font-lock-builtin-face
                                       completions-common-part))
                    (nano-strong .    (font-lock-function-name-face
                                       font-lock-variable-name-face
                                       icomplete-first-match
                                       minibuffer-prompt))
                    (nano-critical .  (error
                                       completions-first-difference))
                    (nano-faded-i .   (help-key-binding))
                    (nano-default-i . (custom-button-mouse
                                       isearch))
                    (nano-critical-i . (isearch-fail))
                    ((nano-subtle nano-strong) . (custom-button
                                                  icomplete-selected-match))
                    ((nano-faded-i nano-strong) . (show-paren-match))))
      (nano-link-face (car item) (cdr item)))

    ;; Mode & header lines 
    (set-face-attribute 'header-line nil
                        :background 'unspecified
                        :underline nil
                        :box `( :line-width 1
                                :color ,(face-background 'nano-default))
                        :inherit 'nano-subtle)
    (set-face-attribute 'mode-line nil
                        :background (face-background 'default)
                        :underline (face-foreground 'nano-faded)
                        :height 40 :overline nil :box nil)
    (set-face-attribute 'mode-line-inactive nil
                        :background (face-background 'default)
                        :underline (face-foreground 'nano-faded)
                        :height 40 :overline nil :box nil))

  (defun nano-light (&rest _args)
    "NANO light theme (based on material colors)"

    (interactive)
    (nano-set-face 'nano-default "#37474F" "#FFFFFF") ;; Blue Grey / L800
    (nano-set-face 'nano-strong "#000000" nil 'regular) ;; Black
    (nano-set-face 'nano-highlight nil "#FAFAFA") ;; Very Light Grey
    (nano-set-face 'nano-subtle nil "#ECEFF1") ;; Blue Grey / L50
    (nano-set-face 'nano-faded "#90A4AE") ;; Blue Grey / L300
    (nano-set-face 'nano-salient "#673AB7") ;; Deep Purple / L500
    (nano-set-face 'nano-popout "#FFAB91") ;; Deep Orange / L200
    (nano-set-face 'nano-critical "#FF6F00") ;; Amber / L900
    (nano-install-theme))
   ;; Sixteen (converted to hex from HSL)
  ;; blue:   #3c97dd   blue2:  #86c1b9
  ;; grey:   #b8b8b8   grey2:  #999999  grey3: #333333  grey4: #383838
  ;; grey5:  #545454   grey6:  #666666  grey7: #cccccc
  ;; orange: #f09642   orange2:#f4c725  pink:  #ba8caf
  ;; red:    #d2322d   white:  #ffffff  white2:#f7f7f7  white3:#f5f5f5
  ;; white5: #ededed   white6: #dedede  yellow:#9dbf40

  (defun nano-seventeen (&rest _args)
    "NANO light theme styled after Sublime Text 'Sixteen'."

    (interactive)
    ;; text (grey5) on white background
    (nano-set-face 'nano-default  "#545454" "#f9f9f9")  ;; fg, bg
    ;; strong accents (headings/prompts). Using Sixteen's 'pink'
    (nano-set-face 'nano-strong   "#d2322d" nil 'regular)
    ;; highlight line / selection (Sublime 'white4' approx)
    (nano-set-face 'nano-highlight nil       "#ededed")
    ;; subtle blocks/regions / selection
    (nano-set-face 'nano-subtle   nil       "#d8d8d8")  ;; light gray selection
    ;; comments/docs (Sublime 'grey' ~72%)
    (nano-set-face 'nano-faded    "#b8b8b8")
    ;; salient accents (links, types, builtins → keep Sixteen blue)
    (nano-set-face 'nano-salient  "#f09642")
    ;; pop-out items (strings in Sixteen are yellow)
    (nano-set-face 'nano-popout   "#9dbf42")
    ;; critical (errors/warnings → Sixteen red)
    (nano-set-face 'nano-critical "#d2322d")
    (nano-install-theme))

  (defun nano-dark (&rest args)
    "NANO dark theme (based on nord colors)"

    (interactive)
    (nano-set-face 'nano-default "#ECEFF4" "#2E3440") ;; Snow Storm 3
    (nano-set-face 'nano-strong "#ECEFF4" nil 'regular) ;; Polar Night 0
    (nano-set-face 'nano-highlight nil "#3B4252")  ;; Polar Night 1
    (nano-set-face 'nano-subtle nil "#434C5E") ;; Polar Night 2
    (nano-set-face 'nano-faded "#677691") ;;
    (nano-set-face 'nano-salient "#81A1C1")  ;; Frost 2
    (nano-set-face 'nano-popout "#D08770") ;; Aurora 1
    (nano-set-face 'nano-critical "#EBCB8B") ;; Aurora 2
    (nano-install-theme))

  ;; --- Command line theme chooser ---------------------------------------------
  (add-to-list 'command-switch-alist '("-dark"      . nano-dark))
  (add-to-list 'command-switch-alist '("-light"     . nano-light))
  (add-to-list 'command-switch-alist '("-seventeen" . nano-seventeen))
  (cond ((member "-dark"  command-line-args) (nano-dark))
        ((member "-light" command-line-args) (nano-light))
        (t (nano-seventeen)))

  ;;; --- Palette for terminal-like Inferior ESS (REPL) ---
  (defconst ess-term-bg        "#000000")  ;; pure black
  (defconst ess-term-fg        "#d0d0d0")  ;; soft light gray (comfortable on black)
  (defconst ess-term-border    "#303030")  ;; subtle selection/line box

  ;; Keep your Sixteen-like accents consistent
  (defconst ess16-red          "#d2322d")  ;; errors/warnings
  (defconst ess16-orange       "#f09642")  ;; numbers / salient
  (defconst ess16-yellow       "#9dbf42")  ;; strings
  (defconst ess16-blue         "#3c97dd")  ;; links/prompts
  (defconst ess16-comment      "#a8a8a8")  ;; comments (if any appear in REPL)

  (defun my/inferior-ess-terminal-dark ()
    "Render only inferior ESS buffers with terminal-like dark styling."
    (when (derived-mode-p 'inferior-ess-mode)
      ;; Preserve ANSI colors in comint output (bold, etc.)
      (ansi-color-for-comint-mode-on)
      ;; Set buffer-wide background/foreground
      (buffer-face-set `(:background ,ess-term-bg :foreground ,ess-term-fg))
      ;; Prompt and messages
      (set-face-attribute 'comint-highlight-prompt nil
                          :foreground ess16-blue :weight 'bold)
      ;; Region / selection (subtle on black)
      (face-remap-add-relative 'region `(:background ,ess-term-border))
      (face-remap-add-relative 'hl-line `(:background "#101010"))
      ;; Optional: accents for warning/error/success in REPL output
      (face-remap-add-relative 'warning `(:foreground ,ess16-orange :weight bold))
      (face-remap-add-relative 'error   `(:foreground ,ess16-red    :weight bold))
      (face-remap-add-relative 'success `(:foreground "#7bd88f"))   ;; gentle green
      ;; Optional: line spacing on pure black to reduce glare
      (setq-local line-spacing 0.15)))

  ;; Apply ONLY to the interactive ESS REPL
  (add-hook 'inferior-ess-mode-hook #'my/inferior-ess-terminal-dark)

  ;;; Important: do NOT hook ess-r-mode or ess-mode
  ;; (remove-hook 'ess-r-mode-hook #'my/ess-terminal-dark-buffer) ; if you had something before
  ;; (remove-hook 'ess-mode-hook   #'my/ess-terminal-dark-buffer)

  ;; --- Minibuffer completion --------------------------------------------------
  (setq tab-always-indent 'complete
        icomplete-delay-completions-threshold 0
        icomplete-compute-delay 0
        icomplete-show-matches-on-no-input t
        icomplete-hide-common-prefix nil
        icomplete-prospects-height 9
        icomplete-separator " . "
        icomplete-with-completion-tables t
        icomplete-in-buffer t
        icomplete-max-delay-chars 0
        icomplete-scroll t
        resize-mini-windows 'grow-only
        icomplete-matches-format nil)
  (bind-key "TAB" #'icomplete-force-complete icomplete-minibuffer-map)
  (bind-key "RET" #'icomplete-force-complete-and-exit icomplete-minibuffer-map)

  ;; --- Minimal key bindings ---------------------------------------------------
  (defun nano-quit ()
    "Quit minibuffer from anywhere (code from Protesilaos Stavrou)"

    (interactive)
    (cond ((region-active-p) (keyboard-quit))
          ((derived-mode-p 'completion-list-mode) (delete-completion-window))
          ((> (minibuffer-depth) 0) (abort-recursive-edit))
          (t (keyboard-quit))))

  (defun nano-kill ()
    "Delete frame or kill emacs if there is only one frame left"
    (interactive)
    (condition-case nil
        (delete-frame)
      (error (save-buffers-kill-terminal))))


  (bind-key "C-x k" #'kill-current-buffer)
  (bind-key "C-x C-c" #'nano-kill)
  (bind-key "C-x C-r" #'recentf-open)
  (bind-key "C-g" #'nano-quit)
  (bind-key "M-n" #'make-frame)
  (bind-key "C-z"  nil) ;; No suspend frame
  (bind-key "C-<wheel-up>" nil) ;; No text resize via mouse scroll
  (bind-key "C-<wheel-down>" nil) ;; No text resize via mouse scroll

  ;; --- Sane settings ----------------------------------------------------------
  (set-default-coding-systems 'utf-8)
  (setq-default indent-tabs-mode nil
                ring-bell-function 'ignore
                select-enable-clipboard t)

  ;; --- OSX Specific -----------------------------------------------------------
  (when (eq system-type 'darwin)
    (select-frame-set-input-focus (selected-frame))
    (setq mac-option-modifier nil
          ns-function-modifier 'super
          mac-right-command-modifier 'hyper
          mac-right-option-modifier 'alt
          mac-command-modifier 'meta))

  ;; --- Header & mode lines ----------------------------------------------------
  (setq-default mode-line-format "")
  (setq-default header-line-format
    '(:eval
      (let ((prefix (cond (buffer-read-only     '("RO" . nano-default-i))
                          ((buffer-modified-p)  '("**" . nano-critical-i))
                          (t                    '("RW" . nano-faded-i))))
            (mode (concat "(" (downcase (cond ((consp mode-name) (car mode-name))
                                              ((stringp mode-name) mode-name)
                                              (t "unknow")))
                          " mode)"))
            (coords (format-mode-line "%c:%l ")))
        (list
         (propertize " " 'face (cdr prefix)  'display '(raise -0.25))
         (propertize (car prefix) 'face (cdr prefix))
         (propertize " " 'face (cdr prefix) 'display '(raise +0.25))
         (propertize (format-mode-line " %b ") 'face 'nano-strong)
         (propertize mode 'face 'header-line)
         (propertize " " 'display `(space :align-to (- right ,(length coords))))
         (propertize coords 'face 'nano-faded)))))

  ;; --- Minibuffer setup -------------------------------------------------------
  (defun nano-minibuffer--setup ()
    (set-window-margins nil 3 0)
    (let ((inhibit-read-only t))
      (add-text-properties (point-min) (+ (point-min) 1)
        `(display ((margin left-margin)
                   ,(format "# %s" (substring (minibuffer-prompt) 0 1))))))
    (setq truncate-lines t))
  (add-hook 'minibuffer-setup-hook #'nano-minibuffer--setup)


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
   '(package-selected-packages
     '(meow treesit-auto htmlize ultra-scroll tree-sitter-langs tree-sitter-ess-r nim-ts-mode tree-sitter copilot editorconfig quelpa-use-package quelpa nim-mode org-roam citar ess evil which-key))
   '(package-vc-selected-packages
     '((ultra-scroll :vc-backend Git :url "https://github.com/jdtsmith/ultra-scroll"))))
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
    :defer t
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
    :defer t
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

  (use-package embark
    :ensure t
    :demand t
    :after avy
    :defer t
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
    :ensure t
    :after embark consult
    :defer t)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;
        ;;;   Minibuffer and completion
        ;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; Marginalia: annotations for minibuffer
  (use-package marginalia
    :ensure t
    :defer t
    :config
    (marginalia-mode))

  ;; Popup completion-at-point
  (use-package corfu
    :ensure t
    :defer t
    :init
    (global-corfu-mode t)
    :custom
    (corfu-auto t
        corfu-auto-delay 0.05                   ;; low delay; tweak to taste
        corfu-auto-prefix 1                     ;; trigger after 1 char
        corfu-quit-no-match t                   ;; close if nothing to show
        corfu-preselect 'prompt)
    :bind
    (:map corfu-map
          ("SPC" . corfu-insert-separator)
          ("C-n" . corfu-next)
          ("C-p" . corfu-previous)))

  ;; Part of corfu
  (use-package corfu-popupinfo
    :after corfu
    :defer t
    :hook (corfu-mode . corfu-popupinfo-mode)
    :custom
    ;(corfu-popupinfo-delay '(0.25 . 0.1))
    (corfu-popupinfo-hide nil)
    :config
    (corfu-popupinfo-mode))

  ;; Make corfu popup come up in terminal overlay
  (use-package corfu-terminal
    :if (not (display-graphic-p))
    :ensure t
    :defer t
    :config
    (corfu-terminal-mode))

  ;; Fancy completion-at-point functions; there's too much in the cape package to
  ;; configure here; dive in when you're comfortable!
  (use-package cape
    :ensure t
    ;;:defer t
    :init
    (add-to-list 'completion-at-point-functions #'cape-dabbrev)
    (add-to-list 'completion-at-point-functions #'cape-file)
  :hook
  ;;(ess-mode . mpger/cape-capf-ess)
  (ess-r-mode . mpger/cape-capf-ess)
  (ess-r-inferior-mode . mpger/cape-capf-ess)
    )

  ;; Pretty icons for corfu
  (use-package kind-icon
    :if (display-graphic-p)
    :ensure t
    :after corfu
    :config
    (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

  (use-package eshell
    :defer t
    :init
    (defun bedrock/setup-eshell ()
      ;; Something funny is going on with how Eshell sets up its keymaps; this is
      ;; a work-around to make C-r bound in the keymap
      (keymap-set eshell-mode-map "C-r" 'consult-history))
    :hook ((eshell-mode . bedrock/setup-eshell)))

  ;; Orderless: powerful completion style
  (use-package orderless
    :ensure t
    :defer t
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
    :defer t
    :config
    (setq wgrep-auto-save-buffer t))

  (which-key-show-top-level)

;; Fast VC on remote files
(setq vc-ignore-dir-regexp
      (format "\\(%s\\)\\|\\(%s\\)"
              vc-ignore-dir-regexp
              tramp-file-name-regexp))
(setq vc-handled-backends '(Git))       ;; Avoid scanning many VC backends
(setq remote-file-name-inhibit-cache 60)
(setq tramp-verbose 0)
(setq tramp-ssh-controlmaster-options
      "-o ControlPath=/tmp/ssh-ControlPath-%r@%h:%p -o ControlMaster=auto -o ControlPersist=yes")

(with-eval-after-load 'tramp
  ;; Your custom tramp methods:
  (add-to-list 'tramp-methods
               `("magma"
                 (tramp-login-program "qsub")
                 (tramp-login-args (("-I" "-q" "magma" "-lnodes=giant")))
                 (tramp-login-env (("SHELL") ("/bin/sh")))
                 (tramp-remote-shell "/bin/sh")
                 (tramp-remote-shell-args ("-c"))
                 (tramp-connection-timeout 20)))
  (add-to-list 'tramp-methods
               `("workq"
                 (tramp-login-program "qsub")
                 (tramp-login-args (("-I" "-q" "workq" "-l" "ncpus=23")))
                 (tramp-login-env (("SHELL") ("/bin/sh")))
                 (tramp-remote-shell "/bin/sh")
                 (tramp-remote-shell-args ("-c"))
                 (tramp-connection-timeout 20))))

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
	  (css-mode . css-ts-mode)
	  (ess-r-mode . r-mode)
	  (inferior-ess-r-mode . r-mode)
	  (nim-mode . nim-ts-mode)
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
  :defer t
  :ensure t
  :bind (("C-x g" . magit-status))
  :commands (magit-status magit-blame))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Common file types
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package markdown-mode
  :defer t
  :hook ((markdown-mode . visual-line-mode)))

(use-package yaml-mode
  :defer t
  :ensure t)

(use-package json-mode
  :defer t
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
  (eglot-send-changes-idle-time 0.4)
  (eglot-report-progress nil)          ; suppress nimlangserver progress spam
  (jsonrpc-inhibit-debug-logs t)
  (eglot-extend-to-xref t)             ; activate Eglot in referenced non-project files
  :hook
  ((ess-r-mode-inferior . eglot-ensure)
   (nim-ts-mode         . eglot-ensure))
  :config
  (fset #'jsonrpc--log-event #'ignore)  ; massive perf boost---don't log every event
  (setq eldoc-echo-area-use-multiline-p nil)  ; Disable multiline echo area messages
  ;; Sometimes you need to tell Eglot where to find the language server
  (add-to-list 'eglot-server-programs
               '(nim-ts-mode . ("~/.nimble/bin/nimlangserver" "--autobind")))
  ;; Point nimlangserver at the correct nimsuggest (matches active nim 2.3.1 compiler)
  ;; Without this, it falls back to /usr/bin/nimsuggest (2.2.0) → 0 completions
  (setq-default eglot-workspace-configuration
                '((:nim . (:nimsuggestPath "~/.nimble/bin/nimsuggest"))))

  )

(defun mpger/cape-capf-ess ()
  (dolist (elmnt
	   (mapcar #'cape-company-to-capf
		   (list #'company-R-library #'company-R-args #'company-R-objects)))
    (add-to-list 'completion-at-point-functions elmnt))
  (setq-local orderless-matching-styles '(orderless-literal))) ;; default is '(orderless-literal orderless-regexp)

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
(setq org-latex-pdf-process
      '("lualatex -shell-escape -interaction=nonstopmode -output-directory=%o %f"
        "lualatex -shell-escape -interaction=nonstopmode -output-directory=%o %f"))

(use-package citar-org-roam
  :defer t
  :diminish ""
  ;; To get this to work both Citar *and* Org-roam have to have been used
  :after citar org-roam
  :no-require
  :config
  (citar-org-roam-mode)
  (setq citar-org-roam-note-title-template "${author} - ${title}\n#+filetags: ${tags}"))

(use-package org
  :ensure t
  :defer t
  :hook ((org-mode . visual-line-mode)  ; wrap lines at word breaks
	 (org-mode . flyspell-mode))    ; spell checking!
	;; (org-mode . toc-org-mode)
        ;; (org-mode . svg-tag-mode))    ; notebook mode

  :bind (:map global-map
	      ("C-c l s" . org-store-link)          ; Mnemonic: link → store
	      ("C-c l i" . org-insert-link-global)) ; Mnemonic: link → insert
  :init
  (setq  org-startup-with-inline-images 'inlineimages)
  (setq org-image-actual-width `( ,(truncate (* (frame-pixel-width) 0.85))))
  (setq org-confirm-babel-evaluate nil)
  (setq org-format-latex-options (plist-put nil :scale 2.0))

  :custom
  (org-display-remote-inline-images 'download)

  :config
  (require 'oc-csl)                     ; citation support
  (add-to-list 'org-export-backends 'md)

  ;; Make org-open-at-point follow file links in the same window
  (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file)

  ;; Make exporting quotes better
  (setq org-export-with-smart-quotes t)

  ;; toggle blocks
  (defvar org-blocks-hidden nil)

  (defun org-toggle-blocks ()
    (interactive)
    (if org-blocks-hidden
	(org-show-block-all)
      (org-hide-block-all))
    (setq-local org-blocks-hidden (not org-blocks-hidden)))

  (add-hook 'org-mode-hook 'org-toggle-blocks)

 (defvar my/org-babel-lazy-languages
   '((R . ob-R)
     (julia . ob-julia)
     (python . ob-python)
     (shell . ob-shell)
     (emacs-lisp . ob-emacs-lisp)
     (lisp . ob-lisp)
     (scheme . ob-scheme)
     (sql . ob-sql)
     (awk . ob-awk)
     (C . ob-C)
     (cpp . ob-C)
     (js . ob-js)
     (java . ob-java)
     (jupyter . ob-jupyter)
     (latex . ob-latex)
     (matlab . ob-matlab)
     (octave . ob-octave)
     (perl . ob-perl)
     (ruby . ob-ruby)
     (scala . ob-scala)
     (sed . ob-sed)
     (haskell . ob-haskell)
     (fortran . ob-fortran)
     (go . ob-go)
     (groovy . ob-groovy)
     (maxima . ob-maxima)
     (makefile . ob-makefile)
     (dot . ob-dot)
     (plantuml . ob-plantuml)
     (gnuplot . ob-gnuplot)
     (ledger . ob-ledger)
     (screen . ob-screen)
     (sql . ob-sql)
     (restclient . ob-restclient))
   "Mapping of Org Babel languages to their corresponding features.")

 (defun my/org-babel-load-language-if-needed (lang)
   "Load Org Babel language LANG if not already loaded."
   (unless (assoc lang org-babel-load-languages)
     (let ((feature (cdr (assoc lang my/org-babel-lazy-languages))))
       (when feature
         (require feature)
         (setq org-babel-load-languages
               (cons (cons lang t) org-babel-load-languages))
         (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages)))))

 (defun my/org-babel-get-src-lang ()
   "Get the language of the current Org Babel block."
   (let ((info (org-babel-get-src-block-info 'light)))
     (when info
       (intern (car info)))))

 (defun my/org-babel--maybe-load-lang (info)
  "Ensure the language in INFO is loaded before execution."
  (let ((lang (intern (car info))))
    (my/org-babel-load-language-if-needed lang))
  info)

(advice-add 'org-babel-get-src-block-info :filter-return #'my/org-babel--maybe-load-lang)

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
(require 'base64)
(with-eval-after-load 'ox-html
  (advice-add 'org-html--format-image :override #'orgTZA-html--format-image))

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

;; END THIS SECTION IS FOR THE HTML EMBEDDED EXPORT

;(use-package toc-org
;  :ensure t
;  :after org)

(setq org-latex-listings 'listings)           ;; older setting

(use-package svg-tag-mode
  :ensure t
  :demand t)

(require 'svg-tag-mode)

;; Prevent errors if something tries to set svg-tag-tags early
;;(unless (boundp 'svg-tag-tags)
 ;; (setq svg-tag-tags nil))

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
                           (lambda () (interactive) (org-edit-src-code)) "Zoom-in"))



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
                                  (lambda () (interactive) (org-sbe "setup")) "Setup notebook environment"))
            ("|ZOOM-IN-CODE|" .       ((lambda (tag) (svg-tag-make "ZOOM-IN"
                                                                   :face 'org-meta-line))
                                       (lambda () (interactive) (org-edit-src-code)) "Zoom-in"))

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
            ;(require 'svg-tag-mode)
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

        (add-hook 'org-mode-hook #'notebook-mode)

(use-package ess
  :ensure t
  :defer t
  :commands (ess-r-mode ess-switch-to-inferior-or-script-buffer ess-rdired ess-get-process)
  :hook
  (ess-mode . (lambda ()
                (eglot-ensure)
                (make-local-variable 'company-backends)))
  :config
  (require 'ess-site)
  (setq ess-use-flymake nil)
  (setq ess-use-company 'scriptonly)
  (setq ess-indent-with-fancy-comments nil)
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

(defun sloth/org-babel-edit-prep (info)
  (let* ((proc (ess-get-process))
         (proc-name (if proc
                        (process-name proc)
                      "R-default")))
    (setq buffer-file-name
          (format "org-src-%s.org" proc-name)))
  (eglot-ensure)
  (ess-switch-to-inferior-or-script-buffer t)
  (ess-rdired)
  (when (derived-mode-p 'prog-mode)
    (copilot-mode)))

(advice-add 'org-edit-src-code
            :before (defun sloth/org-edit-src-code/before (&rest args)
                      (when-let* ((element (org-element-at-point))
                                  (type (org-element-type element))
                                  (lang (org-element-property :language element))
                                  (mode (org-src-get-lang-mode lang))
                                  ((eglot--lookup-mode mode))
                                  (edit-pre (intern
                                             (format "org-babel-edit-prep:%s" lang))))
                        (if (fboundp edit-pre)
                            (advice-add edit-pre :after #'sloth/org-babel-edit-prep)
                          (fset edit-pre #'sloth/org-babel-edit-prep)))))

(use-package nim-mode
    :ensure t)

;; --- Tree-sitter for Nim ---------------------------------------------
;; Install the Nim grammar first:
;;   M-x treesit-install-language-grammar RET nim RET
;; Then use community nim-ts-mode:
(use-package nim-ts-mode
  :vc (:url "https://github.com/niontrix/nim-ts-mode" :rev :newest)
  :mode ("\\.nim\\'" . nim-ts-mode)
  :init
  (add-to-list 'treesit-language-source-alist
               '(nim "https://github.com/alaviss/tree-sitter-nim")))

(defun nimble-build-if-project ()
  "Check if the current project is a Nimble project and run 'nimble build' from the project root."
  (interactive)
  (let ((project-root (locate-dominating-file
                       default-directory
                       (lambda (dir)
                         (directory-files dir nil "\\.nimble\\'")))))
    (if project-root
        (progn
          (message "Project root found: %s" project-root)
          (let ((default-directory project-root))
            (message "Running 'nimble build' in directory: %s" default-directory)
            (compile "nimble build")))
      (message "Not a Nimble project: No '*.nimble' file found in the project root."))))

(with-eval-after-load 'nim-mode
  (define-key nim-mode-map (kbd "C-c C-c") 'nimble-build-if-project))

;(use-package ultra-scroll
  ;:load-path "~/code/emacs/ultra-scroll" ; if you git clone'd instead of package-vc-install
;  :init
;  (setq scroll-conservatively 101 ; important!
;        scroll-margin 0)
;  :config
;  (ultra-scroll-mode 1))

(require 'notifications)
(defun notify-on-command-end ()
  "Send a desktop notification when an ESS command ends."
  (interactive)
  (notifications-notify
   :title "ESS Command Finished"
   :body "Your ESS command has completed."))

(defun my-ess-eval-advice (orig-fun &rest args)
  "Advice to add a notification after `ess-eval-linewise'."
  (apply orig-fun args)
  (notify-on-command-end))

(advice-add 'org-babel-execute-src-block :around #'my-ess-eval-advice)
(advice-add 'ess-eval-region :around #'my-ess-eval-advice)
(advice-add 'ess-eval-buffer :around #'my-ess-eval-advice)
(advice-add 'ess-eval-line :around #'my-ess-eval-advice)
(advice-add 'ess-eval-line-and-step :around #'my-ess-eval-advice)
(advice-add 'ess-eval-function :around #'my-ess-eval-advice)
(advice-add 'ess-eval-linewise :around #'my-ess-eval-advice)


(customize-set-variable
 'tramp-ssh-controlmaster-options
 (concat
    "-o ControlPath=/tmp/ssh-ControlPath-%%r@%%h:%%p "
    "-o ControlMaster=auto -o ControlPersist=yes"))

;;(setq tramp-verbose 6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs loaded in %.2fs with %d GCs"
                     (float-time (time-subtract after-init-time before-init-time))
                     gcs-done)))

(setq recentf-max-saved-items 100)
