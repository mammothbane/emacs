;;; package -- summary:
;;; My init.el. Should probably be factored out into a bunch of files with specific functions,
;;; but it's not yet.

;;; Commentary:
;;; See package summary for current remarks.

;;; Code:

;; per-machine settings. okay if it doesn't exist.
(load "~/.emacs.d/local.el" t)

(defvar solarized-enabled t)

(defvar init-emacs23 (eq emacs-major-version 23))
(defvar init-emacs21 (eq emacs-major-version 21))

(when init-emacs23
  (load "~/.emacs.d/package.el"))

(global-set-key [f1] 'compile)
(setq compile-command "make ")

;; creates a lot of small autosaves if set
(setq auto-save-default nil)
(setq vc-follow-symlinks nil)

(when init-emacs21
  (tool-bar-mode -1)
  (tooltip-mode -1)
  (global-set-key [home] 'beginning-of-buffer)
  (global-set-key [end] 'end-of-buffer))

(global-font-lock-mode t)

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

; (if (<= emacs-major-version 23)
;  (require-package 'scala-mode)
;  (require-package 'scala-mode2))

(when (>= emacs-major-version 24)
  (require-package 'haml-mode)
  (require-package 'fish-mode))

(require-package 'scala-mode)

(require-package 'rust-mode)
(require-package 'flycheck-rust)

(require-package 'haskell-mode)
(require-package 'flycheck-haskell)

(require-package 'gradle-mode)

(require-package 'swift-mode)
(require-package 'flycheck-swift3)

(require-package 'go-mode)
(require-package 'go-autocomplete)
(require-package 'govet)
(require-package 'golint)
(require-package 'protobuf-mode)
;(require-package 'flycheck-protobuf)

(require-package 'markdown-mode)
(require-package 'toml-mode)
(require-package 'yaml-mode)

;; git-related packages
(require-package 'magit)
(setq magit-push-always-verify nil)

(require-package 'gitignore-mode)
(require-package 'gitconfig-mode)

(if (or (or (eq system-type 'windows-nt)
      (eq system-type 'ms-dos))
     (< emacs-major-version 24))
    (require-package 'yagist)
  (require-package 'gist))

(require-package 'achievements)

(require-package 'org)

;; solarized
(require-package 'color-theme)
(require-package 'color-theme-solarized)
(when solarized-enabled
  (if
       (>= emacs-major-version 24)
       (load-theme 'solarized t)
     (color-theme-solarized)))

(defun comment-line-toggle ()
  "Comment or uncomment current line."
  (interactive)
  (comment-or-uncomment-region (line-beginning-position) (line-end-position)))

(defun set-compile-cargo ()
  "Rust projects default to 'cargo build' for compile command."
  (if (not (string-match "cargo" compile-command))
      (set (make-local-variable 'compile-command)
	   "cargo build")))

(defun my-go-mode-hook ()
  "Set up goimports and gofmt for go-mode."
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
  (defvar init-gopath (getenv "GOPATH"))
  (defvar init-goflymake (concat init-gopath "/src/github.com/dougm/goflymake"))
  (when (file-accessible-directory-p init-goflymake)
    (add-to-list 'load-path init-goflymake)
    (require 'go-flymake)
    (require 'go-flycheck)))

(add-hook 'rust-mode-hook 'set-compile-cargo)
(add-hook 'go-mode-hook 'my-go-mode-hook)
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)

(add-hook 'after-init-hook #'global-flycheck-mode)

(add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++17")))

(global-auto-complete-mode t)

(global-set-key (kbd "C-c s") 'eshell)
(global-set-key (kbd "C-c i") (lambda ()
				(interactive)
				(find-file "~/.emacs.d/init.el")))
(global-set-key (kbd "C-c ;") (lambda ()
				(interactive)
				(eval-buffer)
				(message "Buffer eval complete.")))
(global-set-key (kbd "C-c k") 'magit-status)

;; we want this last in order to override the upstream config
(load "~/.local_emacs" t)

(provide 'init)
;;; init.el ends here
