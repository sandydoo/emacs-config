;;; lang-lua.el --- Lua -*- lexical-binding: t; -*-

;;; Commentary:
;; Lua is a powerful, efficient, lightweight, embeddable scripting language. It
;; supports procedural programming, object-oriented programming, functional
;; programming, data-driven programming, and data description.

;;; Code:

(eval-when-compile
  (require 'base-package))

;;;
;; Packages

(req-package lua-mode
  :mode ("\\.lua$")
  :interpreter "lua"
  :init
  (autoload 'eir-eval-in-lua "eval-in-repl-lua" nil t)

  (defun lua-repl ()
    "Open a Lua REPL."
    (interactive)
    (lua-start-process)
    (pop-to-buffer lua-process-buffer))

  (setq lua-documentation-function 'eww)
  :config
  (set-repl-command 'lua-mode #'lua-repl)
  (set-eval-command 'lua-mode #'eir-eval-in-lua)
  (set-popup-buffer (rx bos "*lua*" eos))

  (set-doc-fn 'lua-mode 'lua-search-documentation)

  (add-hooks-pair 'lua-mode 'flycheck-mode))

(req-package company-lua
  :require company lua-mode
  :after lua-mode
  :config
  (set-company-backends 'lua-mode 'company-lua))

(provide 'lang-lua)
;;; lang-lua.el ends here
