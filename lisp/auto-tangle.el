;;; auto-tangle.el --- Automatically tangle Emacs Lisp libraries  -*- lexical-binding: t -*-

;; Copyright (C) 2018 Terje Larsen

;; Author: Terje Larse <terlar@gmail.com>
;; URL: https://github.com/terlar/auto-tangle
;; Keywords: convenience, lisp
;; Version: 0.1.0

;; This file is NOT part of GNU Emacs.

;; auto-tangle is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; auto-tangle is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides two minor modes which automatically tangles
;; and optionally compiles Emacs Lisp source files.

;;; Code:

(autoload 'org-babel-tangle-file "ob-tangle" nil t)
(autoload 'byte-compile-file "bytecomp" nil t)
(autoload 'async-start "async")

(defgroup auto-tangle nil
  "Automatically tangle Org files."
  :group 'convenience
  :prefix 'auto-tangle
  :link '(function-link auto-tangle-mode))

;;;###autoload
(define-minor-mode auto-tangle-mode
  "Tangle Org files after the visiting buffers are saved."
  :lighter auto-tangle-mode-lighter
  :group 'auto-tangle
  (unless (derived-mode-p 'org-mode)
    (user-error "This mode only makes sense with org-mode"))
  (if auto-tangle-mode
      (add-hook  'after-save-hook #'auto-tangle-org-babel-tangle nil t)
    (remove-hook 'after-save-hook #'auto-tangle-org-babel-tangle t)))

(defvar auto-tangle-mode-lighter ""
  "Mode lighter for Auto-Tangle Mode.")

(defcustom auto-tangle-load nil
  "Whether to load the tangled target file."
  :group 'auto-tangle
  :type 'boolean)

(defcustom auto-tangle-byte-compile nil
  "Whether to byte compile the tangled target file."
  :group 'auto-tangle
  :type 'boolean)

(defun auto-tangle-org-babel-tangle (&optional file)
  "Perform tangle for Auto-Tangle Mode.
Optionally provide FILE or the buffer file name will be used."
  (unless file
    (setq file (buffer-file-name)))

  (let ((target (concat (file-name-sans-extension file) ".el")))
    (when (or (not (file-exists-p target))
              (file-newer-than-file-p file target))
      (org-babel-tangle-file file target "emacs-lisp")
      (when auto-tangle-byte-compile
        (byte-compile-file target))
      (when auto-tangle-load
        (load-file target)))))

(provide 'auto-tangle)
;;; auto-tangle.el ends here
