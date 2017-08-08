;;; base-ui.el --- UI configuration

;;; Commentary:
;; The behavior of things.

;;; Code:
(require 'base-vars)

;;;
;; Settings
(setq-default
 ;; Disable bidirectional text for tiny performance boost
 bidi-display-reordering nil
 ;; Disable non selected window highlight
 cursor-in-non-selected-windows nil
 highlight-nonselected-windows nil
 display-line-number-width 3
 blink-matching-paren nil
 frame-inhibit-implied-resize t
 redisplay-dont-pause t
 jit-lock-defer-time nil
 jit-lock-stealth-nice 0.1
 jit-lock-stealth-time 0.2
 jit-lock-stealth-verbose nil
 max-mini-window-height 0.3
 mouse-yank-at-point t           ; Middle-click paste at point, not at click
 resize-mini-windows 'grow-only  ; Minibuffer resizing
 show-help-function nil          ; Hide :help-echo text
 split-width-threshold nil       ; Favor horizontal splits
 use-dialog-box nil              ; Avoid GUI
 visible-cursor nil
 x-stretch-cursor nil
 uniquify-buffer-name-style 'forward
 ;; Fringes
 fringes-outside-margins t
 indicate-buffer-boundaries 'right
 indicate-empty-lines t
 visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow)
 ;; `pos-tip' defaults
 pos-tip-internal-border-width 6
 pos-tip-border-width 1
 ;; No blinking or beeping
 ring-bell-function #'ignore
 visible-bell nil
 calendar-week-start-day 1)

;; y/n instead of yes/no
(setq-default confirm-kill-emacs 'y-or-n-p)
(fset #'yes-or-no-p #'y-or-n-p)

;; Show typed keystrokes in Minibuffer, while not inside isearch
(setq echo-keystrokes 0.02)
(add-hook 'isearch-mode-hook #'(lambda() (setq echo-keystrokes 0)))
(add-hook 'isearch-mode-end-hook #'(lambda() (setq echo-keystrokes 0.02)))

;; Disable toolbar & menubar
(tooltip-mode -1) ; Tooltips in echo area
(menu-bar-mode -1)

(defun my|minibuffer-disable-fringes ()
  "No fringes in minibuffer."
  (set-window-fringes (minibuffer-window) 0 0 nil))

(when (or (display-graphic-p) (daemonp))
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  ;; Standardize fringe width
  (push (cons 'left-fringe  my-fringe-width) default-frame-alist)
  (push (cons 'right-fringe my-fringe-width) default-frame-alist)

  (add-hooks-pair '(emacs-startup minibuffer-setup)
                  'my|minibuffer-disable-fringes))

;; Undo/redo changes to window layout
(defvar winner-dont-bind-my-keys t)
(require 'winner)
(add-hook 'window-setup-hook #'winner-mode)

(defun my|reset-non-gui-bg-color (&optional frame)
  "Unset background color for FRAME without graphic."
  (unless (display-graphic-p frame)
    (set-face-background 'default nil frame)))
(add-hook 'after-make-frame-functions #'my|reset-non-gui-bg-color)
(add-hook 'after-init-hook #'my|reset-non-gui-bg-color)

;; Use an Emacs compatible pager
(setenv "PAGER" "/usr/bin/cat")

;; Highlight matching delimiters
(require 'paren)
(setq show-paren-delay 0.1
      show-paren-highlight-openparen t
      show-paren-when-point-inside-paren t)
(show-paren-mode +1)

;; Filter ANSI escape codes in compilation-mode output
(autoload 'ansi-color-apply-on-region "ansi-color" nil t)
(require 'compile)
(add-hook 'compilation-filter-hook
          #'(lambda ()
              (let ((inhibit-read-only t))
                (ansi-color-apply-on-region compilation-filter-start (point)))))

;; Text scaling
(defadvice text-scale-increase (around all-buffers (arg) activate)
  "Text scale across all buffers."
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer ad-do-it)))

;; Visual line wrapping
(diminish 'visual-line-mode)
(add-hooks-pair '(text-mode prog-mode)
                'visual-line-mode)

;; Visual mode for browser
(add-hooks-pair 'eww-mode 'buffer-face-mode)

;;;
;; Packages

;; Align visually wrapped lines
;; NOTE: This can cause performance issues with font-lock.
(use-package adaptive-wrap
  :commands adaptive-wrap-prefix-mode)

;; Pretty icons
(use-package all-the-icons
  :when (display-graphic-p))

(use-package all-the-icons-ivy
  :when (display-graphic-p)
  :init
  (all-the-icons-ivy-setup))

;; Highlight source code identifiers based on their name
(use-package color-identifiers-mode
  :diminish color-identifiers-mode
  :commands color-identifiers-mode
  :init
  (add-hooks-pair 'after-init 'global-color-identifiers-mode))

;; Highlight source code identifiers for modes not supported by
;; `color-identifiers-mode'
(use-package rainbow-identifiers
  :diminish rainbow-identifiers-mode
  :commands rainbow-identifiers-mode)

;; Dynamically change the default text scale
(use-package default-text-scale
  :commands (default-text-scale-increase default-text-scale-decrease))

(use-package eldoc-overlay-mode
  :diminish eldoc-overlay-mode
  :commands eldoc-overlay-mode)

;; Highlight TODO inside comments and strings
(use-package hl-todo
  :commands hl-todo-mode
  :init
  (add-hooks-pair 'prog-mode 'hl-todo-mode))

;; Clickable links (builtin)
(use-package goto-addr
  :init
  (add-hooks-pair 'text-mode 'goto-address-mode)
  (add-hooks-pair 'prog-mode 'goto-address-prog-mode))

;; Library to hide lines base on regexp
(use-package hide-lines
  :commands (hide-lines
             hide-lines-matching
             hide-lines-not-matching
             hide-lines-show-all))

;; Code folding (builtin)
(use-package hideshow
  :commands hs-minor-mode
  :init
  (add-hooks-pair 'prog-mode 'hs-minor-mode)
  :config
  (setq hs-hide-comments-when-hiding-all nil
        ;; Nicer code-folding overlays
        hs-set-up-overlay
        (lambda (ov)
          (when (eq 'code (overlay-get ov 'hs))
            (overlay-put
             ov 'display (propertize " … " 'face 'my-folded-face))))))

;; For modes that don't adequately highlight numbers
(use-package highlight-numbers :commands highlight-numbers-mode)

;; Line highlighting (builtin)
(use-package hl-line
  :commands hl-line-mode
  :init
  (global-hl-line-mode +1)
  :config
  ;; Only highlight in selected window
  (setq hl-line-sticky-flag nil
        global-hl-line-sticky-flag nil))

;; Indentation guides
(use-package indent-guide
  :commands indent-guide-mode
  :diminish indent-guide-mode
  :init
  (add-hooks-pair 'prog-mode 'indent-guide-mode)
  :config
  (setq indent-guide-delay 0.2
        indent-guide-char "\x2502"))

;; Display docs inline
(use-package inline-docs
  :commands inline-docs
  :config
  (setq inline-docs-border-symbol ?─))

;; Flash the line around cursor on large movements
(use-package nav-flash
  :preface
  (eval-when-compile
    (declare-function windmove-do-window-select "windmove")
    (declare-function evil-window-top "evil")
    (declare-function evil-window-middle "evil")
    (declare-function evil-window-bottom "evil"))

  (defun my|blink-cursor (&rest _)
    "Blink current line using `nav-flash'."
    (interactive)
    (unless (minibufferp)
      (nav-flash-show)
      ;; only show in the current window
      (overlay-put compilation-highlight-overlay 'window (selected-window))))

  :commands nav-flash-show
  :init
  (advice-add #'recenter :around #'my|blink-cursor)

  (with-eval-after-load "windmove"
    (advice-add #'windmove-do-window-select :around #'my|blink-cursor))

  (with-eval-after-load "evil"
    (advice-add #'evil-window-top    :after #'my|blink-cursor)
    (advice-add #'evil-window-middle :after #'my|blink-cursor)
    (advice-add #'evil-window-bottom :after #'my|blink-cursor)))

;; Centered buffer mode
(use-package olivetti
  :diminish olivetti-mode
  :preface (defvar olivetti-mode-map (make-sparse-keymap))
  :init
  (setq-default olivetti-body-width 120
                olivetti-minimum-body-width 72)
  (add-hooks-pair '(text-mode prog-mode help-mode)
                  'olivetti-mode))

;; Display page breaks as a horizontal line
(use-package page-break-lines
  :commands page-break-lines-mode
  :diminish (page-break-lines-mode)
  :init (global-page-break-lines-mode +1))

;; Visually separate delimiter pairs
(use-package rainbow-delimiters
  :commands rainbow-delimiters-mode
  :init (add-hooks-pair 'lisp-mode 'rainbow-delimiters-mode)
  :config (setq rainbow-delimiters-max-face-count 3))

(provide 'base-ui)
;;; base-ui.el ends here
