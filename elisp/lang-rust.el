;;; lang-rust.el --- Rust

;;; Commentary:
;; Rust is a systems programming language that runs blazingly fast, prevents
;; segfaults, and guarantees thread safety.

;;; Code:
(require 'base-lib)
(require 'base-keybinds)

;;;
;; Packages

(use-package rust-mode
  :general
  (:keymaps 'rust-mode-map :states 'normal
            :prefix my-local-leader-key
            "t a" 'cargo-process-test)
  :init
  (add-hooks-pair 'rust-mode 'flycheck-mode)
  :config
  (setq rust-format-on-save (executable-find "rustfmt")))

(use-package racer
  :after rust-mode
  :general
  (:keymaps 'rust-mode-map :states 'normal
            "K" 'racer-describe
            "gd" 'racer-find-definition)
  :init
  (add-hooks-pair 'rust-mode
                  '(racer-mode
                    eldoc-mode))
  :config
  (unless (executable-find "racer")
    (warn "rust-mode: couldn't find racer; no syntax checking/go to definition/documentation lookup"))
  (unless (getenv "RUST_SRC_PATH")
    (setenv "RUST_SRC_PATH" racer-rust-src-path)))

(use-package company-racer
  :when (package-installed-p 'company)
  :after rust-mode
  :config
  (with-eval-after-load "company"
    (push-company-backends 'rust-mode '(company-racer
                                        company-keywords
                                        company-dabbrev-code))))

(use-package flycheck-rust
  :after rust-mode
  :init
  (add-hooks-pair 'flycheck-mode 'flycheck-rust-setup))

(use-package cargo
  :init
  (add-hooks-pair 'rust-mode 'cargo-minor-mode))

(provide 'lang-rust)
;;; lang-rust.el ends here
