;;; package -- summary:
;;; My init.el. Should probably be factored out into a bunch of files with specific functions,
;;; but it's not yet.

;;; Commentary:
;;; See package summary for current remarks.

;;; Code:

;; per-machine settings. okay if it doesn't exist.
(load "~/.emacs.d/local.el" t)

(defvar solarized-enabled t)
(setq custom-file "~/.emacs.d/custom.el")

(load custom-file :noerror)

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

(require 'package)
(setq
 package-archives '(("gnu" . "http://elpa.gnu.org/packages")
		    ("org" . "http://orgmode.org/elpa/")
		    ("melpa" . "http://melpa.org/packages/")
		    ("melpa-stable" . "http://stable.melpa.org/packages/")))

(defvar package-archive-priorities '(("melpa" . 1)))
(defvar use-package-always-ensure t)

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)

(use-package flycheck)

;; language support

(when (>= emacs-major-version 24)
  (use-package haml-mode)
  (use-package fish-mode))

(use-package haskell-mode)
(use-package gradle-mode)

(use-package protobuf-mode)
;(use-package flycheck-protobuf)

(use-package markdown-mode)
(use-package toml-mode)
(use-package yaml-mode)

(use-package projectile
  :demand
  :init   (setq projectile-use-git-grep t)
  :config (projectile-global-mode t)
  :bind   (("s-f" . projectile-find-file)
	   ("s-F" . projectile-grep)))

(use-package undo-tree
  :diminish undo-tree-mode
  :config (global-undo-tree-mode)
    :bind ("s-/" . undo-tree-visualize))

(use-package flx-ido
  :demand
  :init
  (setq
   ido-enable-flex-matching t
   ;; C-d to open directories
   ;; C-f to revert to find-file
   ido-show-dot-for-dired nil
   ido-enable-dot-prefix t)
  :config
  (ido-mode 1)
  (ido-everywhere 1)
    (flx-ido-mode 1))

(use-package goto-chg
  :commands goto-last-change
  ;; complementary to
  ;; C-x r m / C-x r l
  ;; and C-<space> C-<space> / C-u C-<space>
  :bind (("C-." . goto-last-change)
	          ("C-," . goto-last-change-reverse)))

(use-package highlight-symbol
  :diminish highlight-symbol-mode
  :commands highlight-symbol
    :bind ("s-h" . highlight-symbol))

(use-package popup-imenu
  :commands popup-imenu
    :bind ("M-i" . popup-imenu))

(use-package scala-mode)
(use-package sbt-mode)
(use-package ensime
  :config (setq ensime-startup-notification nil))

(use-package smartparens
  :diminish smartparens-mode
  :commands
  smartparens-strict-mode
  smartparens-mode
  sp-restrict-to-pairs-interactive
  sp-local-pair
  :init
  (setq sp-interactive-dwim t)
  :config
  (require 'smartparens-config)
  (sp-use-smartparens-bindings)

  (sp-pair "(" ")" :wrap "C-(") ;; how do people live without this?
  (sp-pair "[" "]" :wrap "s-[") ;; C-[ sends ESC
  (sp-pair "{" "}" :wrap "C-{")

  ;; WORKAROUND https://github.com/Fuco1/smartparens/issues/543
  (bind-key "C-<left>" nil smartparens-mode-map)
  (bind-key "C-<right>" nil smartparens-mode-map)

  (bind-key "s-<delete>" 'sp-kill-sexp smartparens-mode-map)
    (bind-key "s-<backspace>" 'sp-backward-kill-sexp smartparens-mode-map))

(defun contextual-backspace ()
  "Hungry whitespace or delete word depending on context."
  (interactive)
  (if (looking-back "[[:space:]\n]\\{2,\\}" (- (point) 2))
      (while (looking-back "[[:space:]\n]" (- (point) 1))
	(delete-char -1))
    (cond
     ((and (boundp 'smartparens-strict-mode)
	   smartparens-strict-mode)
      (sp-backward-kill-word 1))
     ((and (boundp 'subword-mode)
	   subword-mode)
      (subword-backward-kill 1))
     (t
      (backward-kill-word 1)))))

(global-set-key (kbd "C-<backspace>") 'contextual-backspace)

(use-package yasnippet
  :diminish yas-minor-mode
  :commands yas-minor-mode
    :config (yas-reload-all))

(use-package expand-region
  :commands 'er/expand-region
  :bind ("C-=" . er/expand-region))

(require 'ensime-expand-region)

(defun scala-mode-newline-comments ()
  "Custom newline appropriate for `scala-mode'."
  ;; shouldn't this be in a post-insert hook?
  (interactive)
  (newline-and-indent)
  (scala-indent:insert-asterisk-on-multiline-comment))

(bind-key "RET" 'scala-mode-newline-comments scala-mode-map)

(add-hook 'scala-mode-hook
	  (lambda ()
	    (show-paren-mode)
	    (smartparens-mode)
	    (yas-minor-mode)
	    (git-gutter-mode)
	    (company-mode)
	    (ensime-mode)
	    (scala-mode:goto-start-of-code)
	    (setq comment-start "/* "
		  comment-end " */"
		  comment-style 'multi-line
		  comment-empty-lines t)))

(sp-local-pair 'scala-mode "(" nil :post-handlers '(("||\n[i]" "RET")))
(sp-local-pair 'scala-mode "{" nil :post-handlers '(("||\n[i]" "RET") ("| " "SPC")))

(defun sp-restrict-c (sym)
  "Smartparens restriction on `SYM' for C-derived parenthesis."
  (sp-restrict-to-pairs-interactive "{([" sym))

(bind-key "s-<delete>" (sp-restrict-c 'sp-kill-sexp) scala-mode-map)
(bind-key "s-<backspace>" (sp-restrict-c 'sp-backward-kill-sexp) scala-mode-map)
(bind-key "s-<home>" (sp-restrict-c 'sp-beginning-of-sexp) scala-mode-map)
(bind-key "s-<end>" (sp-restrict-c 'sp-end-of-sexp) scala-mode-map)

(bind-key "s-{" 'sp-rewrap-sexp smartparens-mode-map)

;; git-related packages
(use-package magit
  :commands magit-status magit-blame
  :init (setq magit-revert-buffers nil)
  :bind (("s-g" . magit-status)
	 ("s-b" . magit-blame))
  :config (setq magit-push-always-verify nil))

(use-package git-gutter)
(use-package gitignore-mode)
(use-package gitconfig-mode)
(use-package dockerfile-mode)

(if (or (or (eq system-type 'windows-nt)
      (eq system-type 'ms-dos))
     (< emacs-major-version 24))
    (use-package yagist)
  (use-package gist))

(use-package achievements)

(use-package org)

;; solarized
(use-package color-theme)
(use-package color-theme-solarized)

(when solarized-enabled
  (if (>= emacs-major-version 24)
      (load-theme 'solarized t)
    (color-theme-solarized)))

(use-package rust-mode
  :config (defun rust-hook ()
	    (if (not (string-match "cargo" compile-command))
		(set (make-local-variable 'compile-command)
		     "cargo build"))))

(add-hook 'rust-mode-hook 'rust-hook)

(use-package go-mode
  :config (defun go-hook ()
	   (setq gofmt-command "goimports")
	   (add-hook 'before-save-hook 'gofmt-before-save)
	   (if (not (string-match "go" compile-command))
	       (set (make-local-variable 'compile-command)
		    "go build -v && go test -v && go vet"))
	   (local-set-key (kbd "M-.") 'godef-jump)
	   (auto-complete-mode)))

(add-hook 'go-mode-hook 'go-hook)

(use-package go-autocomplete)
(use-package govet)
(use-package golint)

;; to load these packages, make sure go is installed and
;; GOPATH is set, then run `go get github.com/dougm/goflymake`
(when (getenv "GOPATH")
  (defvar init-gopath (getenv "GOPATH"))
  (defvar init-goflymake (concat init-gopath "/src/github.com/dougm/goflymake"))
  (when (file-accessible-directory-p init-goflymake)
    (add-to-list 'load-path init-goflymake)
    (require 'go-flymake)
    (require 'go-flycheck)))

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

(global-set-key (kbd "C-c c") (lambda ()
			      (interactive)
			      (comment-or-uncomment-region (line-beginning-position) (line-end-position))))

;; we want this last in order to override the upstream config
(load "~/.local_emacs" t)

(provide 'init)
;;; init.el ends here
