;;; term-cursor-color.el --- Synchronize Emacs cursor colors with terminal

;; Copyright (C) 2021, 2022 Vladimir Panteleev

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, you can either send email to this
;; program's maintainer or write to: The Free Software Foundation,
;; Inc.; 59 Temple Place, Suite 330; Boston, MA 02111-1307, USA.

;;; Commentary:

;; Please see the README.md file accompanying this file for
;; documentation.

;;; Code:

;;;###autoload
(define-minor-mode term-cursor-color-mode
  "Synchronize Emacs cursor color with the selected Emacs tty frame.

Note that if the mode is later disabled, or emacs is exited
normally, the original color is not restored."
  :global t
  :group 'terminals
  :init-value nil
  (if term-cursor-color-mode
      (progn
        (add-hook 'post-command-hook 'term-cursor-color--update t)
        (add-hook 'window-state-change-hook 'term-cursor-color--update t)
        (add-hook 'tty-setup-hook 'term-cursor-color--update t))
    (remove-hook 'post-command-hook 'term-cursor-color--update)
    (remove-hook 'window-state-change-hook 'term-cursor-color--update)
    (remove-hook 'tty-setup-hook 'term-cursor-color--update)))

(defun term-cursor-color--update ()
  "Synchronize terminal cursor color with the selected Emacs frame, if it is a tty."
  (when (and (frame-live-p (selected-frame))
             (eq (framep-on-display) t))
    (let* ((frame (selected-frame))
           (color (frame-parameter frame 'cursor-color)))
      (when color
        (unless (string-equal color (frame-parameter frame 'term-cursor-color-last-color))
	  (term-cursor-color--set color)
	  (set-frame-parameter frame 'term-cursor-color-last-color color))))))

(defun term-cursor-color--set (color)
  "Unconditionally set the current TTY terminal's cursor color."

  (send-string-to-terminal (format "\e]12;%s\a" color)))

(provide 'term-cursor-color)

;;; term-cursor-color.el ends here
