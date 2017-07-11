(load "auctex.el" nil t t)
(load "preview-latex.el" nil t t)
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)
(mapc (lambda (mode)
      (add-hook 'LaTeX-mode-hook mode))
      (list 'LaTeX-math-mode
            'turn-on-reftex
            'linum-mode))

(add-hook 'LaTeX-mode-hook
          (lambda ()
            (setq TeX-auto-untabify t     ; remove all tabs before saving
                  TeX-engine 'xetex       ; use xelatex default
                  TeX-show-compilation t) ; display compilation windows
            (TeX-global-PDF-mode t)       ; PDF mode enable, not plain
            (setq TeX-save-query nil)
            (imenu-add-menubar-index)
            (define-key LaTeX-mode-map (kbd "TAB") 'TeX-complete-symbol)))

(add-hook 'LaTeX-mode-hook (lambda () (TeX-fold-mode 1)))
(setq TeX-view-program-list
      '(("Evince" "evince %o")
        ("Okular" "okular --unique %o")
        ))

(add-hook 'LaTeX-mode-hook
          (lambda ()
            (setq TeX-view-program-selection '((output-pdf "Evince")
                                               (output-dvi "Evince")))))

;(add-hook 'LaTeX-mode-hook
;          (lambda ()
;            (setq TeX-view-program-selection '((output-pdf "Okular")
;                                               (output-dvi "Okular")))))
