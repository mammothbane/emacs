;; totally revamped by 95ssb jun 1993, for emacs 19

(setq emacs23 (eq emacs-major-version 23))
(when emacs23 
  (load "~/.emacs.d/package.el"))

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

;; from purcell's .emacs.d
(defun require-package (package &optional min-version no-refresh)
  "Install given PACKAGE, optionally requiring MIN-VERSION.
If NO-REFRESH is non-nil, the available package lists will not be
re-downloaded in order to locate PACKAGE."
  (if (package-installed-p package min-version)
      t
    (if (or (assoc package package-archive-contents) no-refresh)
        (package-install package)
      (progn
        (package-refresh-contents)
        (require-package package min-version t)))))

;; from purcell's .emacs.d
(defun maybe-require-package (package &optional min-version no-refresh)
  "Try to install PACKAGE, and return non-nil if successful.
In the event of failure, return nil and print a warning message.
Optionally require MIN-VERSION.  If NO-REFRESH is non-nil, the
available package lists will not be re-downloaded in order to
locate PACKAGE."
  (condition-case err
      (require-package package min-version no-refresh)
    (error
     (message "Couldn't install package `%s': %S" package err)
     nil)))

;; language support
(if (<= emacs-major-version 23) 
  (require-package 'scala-mode)
  (require-package 'scala-mode2))

(require-package 'rust-mode)
(require-package 'fish-mode)

;; git-related packages
(when (or (> emacs-major-version 24) 
	  (and (eq emacs-major-version 24) (>= emacs-minor-version 4)))
	  (require-package 'git-commit))

(if (or (eq system-type 'windows-nt) (eq system-type 'ms-dos))
    (require-package 'yagist)
  (require-package 'gist))

(require-package 'git-blame)
(require-package 'git-timemachine)
(require-package 'gitconfig-mode)
(require-package 'gitignore-mode)
(require-package 'git-dwim)
(require-package 'achievements)

(defun comment-line-toggle ()
  "comment or uncomment current line"
  (interactive)
  (comment-or-uncomment-region (line-beginning-position) (line-end-position)))


;; have rust projects default to 'cargo build' for compile command
(defun set-compile-cargo ()
  (make-local-variable 'compile-command)
  (setq compile-command "cargo build"))

(add-hook 'rust-mode-hook 'set-compile-cargo)
