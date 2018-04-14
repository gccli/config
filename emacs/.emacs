; basic settings, key-define
(add-to-list 'load-path "~/.emacs.d/lisp")
(custom-set-variables '(inhibit-startup-screen t))
(custom-set-faces)

(setq-default indent-tabs-mode nil)
(setq tab-width 4)

(define-key global-map "\C-w" 'kill-ring-save)
(define-key global-map "\M-w" 'kill-region)
(global-set-key "\M-2" 'mark-word)
(global-set-key "\C-cw" 'global-whitespace-mode)
(global-set-key "\C-cp" 'predictive-mode)
(global-set-key [C-f1] 'jump-to-register)
(global-set-key [C-f2] 'bookmark-jump)
(global-set-key [C-f10] 'jump-to-register)
(global-set-key [C-f11] 'bookmark-jump)

(global-set-key [M-f1] 'jump-to-register)
(global-set-key [M-f2] 'bookmark-jump)

; initialize with 2 window
(defun 2-windows-vertical-to-horizontal ()
  (let ((buffers (mapcar 'window-buffer (window-list))))
    (when (= 2 (length buffers))
      (delete-other-windows)
      (set-window-buffer (split-window-horizontally) (cadr buffers)))))
(add-hook 'emacs-startup-hook '2-windows-vertical-to-horizontal)

;; deal with white spaces
(require 'whitespace)
(setq whitespace-style
      '(face trailing lines lines-tail empty space-after-tab space-before-tab))
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; set backup
(setq
 backup-by-copying t           ; don't clobber symlinks
 backup-directory-alist
 '((""."~/.emacs.d/backups"))  ; don't litter my fs tree
 delete-old-versions t
 kept-new-versions 3
 kept-old-versionps 1
 version-control t)            ; use versioned backups

;; auto insert template
(add-hook 'find-file-hook 'auto-insert)
(require 'setup-autoinsert)

;; cc-mode and cscope
(require 'xcscope)
(cscope-setup)
(setq cscope-do-not-update-database t)
(setq cscope-option-use-inverted-index t)
(setq cscope-index-recursively t)
(setq c-default-style "linux" c-basic-offset 4)
(setq-default indent-tabs-mode nil)
(add-hook 'c-mode-common-hook '(lambda () (require 'column-marker)))
(add-hook 'c-mode-hook (lambda () (column-marker-2 90)))

;; Toggle window dedication
(defun toggle-window-dedicated ()
  "Toggle whether the current active window is dedicated or not"
  (interactive)
  (message
   (if (let (window (get-buffer-window (current-buffer)))
         (set-window-dedicated-p window
                                 (not (window-dedicated-p window))))
       "Window '%s' is dedicated"
     "Window '%s' is normal")
   (current-buffer)))

(global-set-key [pause] 'toggle-window-dedicated)


; For yaml mode
;(require 'yaml-mode)
(autoload 'yaml-mode "yaml-mode" "Major mode for editing yaml file." t)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))
(add-hook 'yaml-mode-hook
          '(lambda ()
             (define-key yaml-mode-map "\C-m" 'newline-and-indent)))

; For org-mode
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(add-to-list 'auto-mode-alist '("\\.txt\\'" . org-mode))
(add-hook 'org-mode-hook 'turn-on-font-lock)
(add-hook 'org-mode-hook
(lambda () (setq truncate-lines nil)))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

;; programming mode
(autoload 'php-mode "php-mode" "Major mode for editing php code." t)
(setq auto-mode-alist  (cons '("\\.m$" . octave-mode) auto-mode-alist))
(setq auto-mode-alist  (cons '("\\.php$" . php-mode) auto-mode-alist))

(autoload 'go-mode "go-mode" "Major mode for editing go code." t)
(setq auto-mode-alist  (cons '("\\.go$" . go-mode) auto-mode-alist))

; marddown mode
(autoload 'markdown-mode "markdown-mode" "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\README\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
(setq markdown-enable-math t)

; LeX settings
(load-file "~/.emacs.d/lisp/tex.el")
(load-file "~/.emacs.d/lisp/predictive.el")
(put 'TeX-narrow-to-group 'disabled nil)
