;; totally revamped by 95ssb jun 1993, for emacs 19

;; autoloading of modes for various programming languages is done in
;; /usr/cs-local/emacs/site-lisp/default.el.  to use a mode which is
;; commented out, paste the code here and remove the comments (the ;;
;; bits).  to eliminate a mode which is currently autoloading,
;; uncomment the line (setq inhibit-default-init) and paste in those
;; modes from default.el which you still wish to use.

;; (setq inhibit-default-init)

(setq emacs23 (eq emacs-major-version 23))
(when emacs23 
  (load "~/.emacs.d/package.el"))

(setq emacs24 (eq emacs-major-version 24))

;; allow compiling with F1 key (added 6-30-95, 97lhz)
(global-set-key [f1] 'compile)
;; set the default compile-command to "make" added 6-13-96, 99grh
(setq compile-command "make ")

;; Don't create auto-save files (~/.saves-hostname-pid)
;; To enable auto-saving, copy the line to your .local_emacs and set it to
;; any non-nil value. This will create lots of little .saves files, so beware!
(setq auto-save-default nil)


(setq emacs21 (eq emacs-major-version 21))

(when emacs21
  (tool-bar-mode -1)
  (tooltip-mode -1)
  (global-set-key [home] 'beginning-of-buffer)
  (global-set-key [end] 'end-of-buffer))

(global-font-lock-mode t)

;; load .local_emacs if it exists OK if it's not there. (added 6-14-96, 99grh)
(load "~/.local_emacs" t)

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t)
 '(kill-do-not-save-duplicates t)
 '(kill-ring-max 200)
 '(kill-whole-line nil)
 '(save-interprogram-paste-before-kill t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )


(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)
(when emacs23 
  (unless (package-installed-p 'scala-mode)
    (package-refresh-contents) (package-install 'scala-mode)))
(when emacs24
  (unless (package-installed-p 'scala-mode2)
    (package-refresh-contents) (package-install 'scala-mode2)))

(unless (package-installed-p 'rust-mode)
  (package-refresh-contents) (package-install 'rust-mode))


(defun comment-line-toggle ()
  "comment or uncomment current line"
  (interactive)
  (comment-or-uncomment-region (line-beginning-position) (line-end-position)))

(setq old-compile-command compile-command)

(defun set-compile-cargo ()
  (make-local-variable 'compile-command)
  (setq compile-command "cargo build"))

(add-hook 'rust-mode-hook 'set-compile-cargo)
