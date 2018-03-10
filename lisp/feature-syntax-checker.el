;;; feature-syntax-checker.el --- Syntax checking -*- lexical-binding: t; -*-

;;; Commentary:
;; Catching your errors.

;;; Code:

(eval-when-compile
  (require 'base-package)
  (require 'base-keybinds))

;; pkg-info doesn't get autoloaded when `flycheck-version' needs it.
(autoload 'pkg-info-version-info "pkg-info")

;;;
;; Packages

(req-package flycheck
  :demand t
  :diminish flycheck-mode
  :commands
  (flycheck-list-errors
   flycheck-buffer
   flycheck-add-next-checker)
  :general
  (:keymaps 'flycheck-error-list-mode-map :states '(normal motion emacs)
            "C-n" 'flycheck-error-list-next-error
            "C-p" 'flycheck-error-list-previous-error
            "j"   'flycheck-error-list-next-error
            "k"   'flycheck-error-list-previous-error
            "RET" 'flycheck-error-list-goto-error)
  (:keymaps 'motion
            "[e" 'previous-error
            "]e" 'next-error)
  :init
  (setq-default flycheck-emacs-lisp-load-path 'inherit)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  :config
  (set-evil-state 'flycheck-error-list-mode 'motion)
  (set-popup-buffer (rx bos "*Flycheck errors*" eos)
                    (rx bos "*Flycheck checker*" eos)))

;; Pos-frame error messages
(req-package flycheck-posframe
  :hook (flycheck-mode . flycheck-posframe-mode)
  :config
  (flycheck-posframe-configure-pretty-defaults))

;; Inline error messages
(req-package flycheck-inline
  :el-get t :ensure nil
  :disabled t
  :hook (after-init . flycheck-inline-mode)
  :init
  (setq flycheck-display-errors-delay 0.5))

;; Pop-up error messages
(req-package flycheck-popup-tip
  :disabled t
  :hook (flycheck-mode . flycheck-popup-tip-mode))

(provide 'feature-syntax-checker)
;;; feature-syntax-checker.el ends here
