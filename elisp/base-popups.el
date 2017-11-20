;;; base-popups.el --- Popups configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Pop, pop, pop.

;;; Code:

(eval-when-compile
  (require 'base-package))

;;;
;; Settings

(add-to-list 'display-buffer-alist
             '("^*Async Shell Command*" . (display-buffer-no-window)))

(set-popup-buffer
 (rx bos "*Messages*" eos)
 (rx bos "*Warnings*" eos)
 (rx bos "*Backtrace*" eos)
 (rx bos "*Pp Eval Output*" eos)
 (rx bos "*Shell Command Output*" eos)
 (rx bos "*Process List*" eos)
 (rx bos "*Help*" eos)
 (rx bos "*Man " (one-or-more anything) "*" eos)
 (rx bos "*General Keybindings*" eos)
 (rx bos "*compilation*" eos)
 (rx bos "*xref*" eos)
 (rx bos "*eshell*" eos)
 (rx bos "*scratch*" eos))

(provide 'base-popups)
;;; base-popups.el ends here
