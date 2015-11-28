;; per-machine settings. okay if it's not there.
(load "~/.emacs.d/local.el" t)

(setq emacs23 (eq emacs-major-version 23))
(when emacs23 
  (load "~/.emacs.d/package.el"))

(global-set-key [f1] 'compile)
(setq compile-command "make ")

;; creates a lot of small autosaves if set
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
 '(frame-background-mode (quote dark))
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

(require-package 'flycheck)

;; language support

(if (<= emacs-major-version 23) 
  (require-package 'scala-mode)
  (require-package 'scala-mode2))
(when (>= emacs-major-version 24)
  (require-package 'haml-mode)  
  (require-package 'fish-mode))

(require-package 'rust-mode)
(require-package 'haskell-mode)
(require-package 'gradle-mode)

(require-package 'go-mode)
(require-package 'go-autocomplete)
(require-package 'govet)
(require-package 'golint)

;; git-related packages
(require-package 'magit)

(if (or (or (eq system-type 'windows-nt) (eq system-type 'ms-dos)) 
	(< emacs-major-version 24))
    (require-package 'yagist)
  (require-package 'gist))

(require-package 'achievements)

(require-package 'org)

;; solarized
(require-package 'color-theme)
(require-package 'color-theme-solarized)
(if (>= emacs-major-version 24)
    (load-theme 'solarized t)
  (color-theme-solarized))

(defun comment-line-toggle ()
  "comment or uncomment current line"
  (interactive)
  (comment-or-uncomment-region (line-beginning-position) (line-end-position)))

;; have rust projects default to 'cargo build' for compile command
(defun set-compile-cargo ()
  (if (not (string-match "cargo" compile-command))
      (set (make-local-variable 'compile-command)
	   "cargo build")))

(defun my-go-mode-hook ()
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save)
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
	   "go build -v && go test -v && go vet"))
  (local-set-key (kbd "M-.") 'godef-jump)
  (auto-complete-mode))

;; to load these packages, make sure go is installed and
;; GOPATH is set, then run `go get github.com/dougm/goflymake`
(when (getenv "GOPATH")
  (setq gopath (getenv "GOPATH"))
  (setq goflymake (concat gopath "/src/github.com/dougm/goflymake"))
  (when (file-accessible-directory-p goflymake)
    (add-to-list 'load-path goflymake)
    (require 'go-flymake)
    (require 'go-flycheck)))

(add-hook 'rust-mode-hook 'set-compile-cargo)
(add-hook 'go-mode-hook 'my-go-mode-hook)

(global-set-key (kbd "C-c s") 'eshell)
(global-set-key (kbd "C-c i") (lambda ()
				(interactive)
				(find-file "~/.emacs.d/init.el")))
(global-set-key (kbd "C-c ;") (lambda ()
				(interactive)
				(eval-buffer)
				(message "Buffer eval complete.")))
(global-set-key (kbd "C-c k") 'magit-status)
