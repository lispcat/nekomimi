(use-package-local scheme-mode
  :mode "\\.sld\\'")

(use-package geiser
  :defer t
  :custom
  (geiser-default-implementation 'guile)
  (geiser-active-implementations '(guile))
  (geiser-implementations-alist '(((regexp "\\.scm$") guile))))

(use-package geiser-guile
  :after geiser)

(use-package rainbow-delimiters
  :hook scheme-mode)


(provide 'neko-lang-scheme)
