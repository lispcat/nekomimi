
;;; Anki :::

(use-package anki-editor
  :defer t)

;;; Org ;;;

(use-package-local org
  ;; :after org
  :config
  ;; org directory
  (setq org-directory "~/Notes/org")
  ;; ;; Failed experiment
  ;; (setq org-list-full-item-re ;; TODO: add "- e.g." and "->" ?
  ;; 	(concat
  ;; 	 "^[ 	]*"
  ;; 	 "\\(\\(?:[-+*/]\\|\\(?:[0-9]+\\|[A-Za-z]\\)[.)]\\)\\(?:[ 	]+\\|$\\)\\)"
  ;; 	 "\\(?:\\[@\\(?:start:\\)?\\([0-9]+\\|[A-Za-z]\\)\\][ 	]*\\)?"
  ;; 	 "\\(?:\\(\\[[ X-]\\]\\)\\(?:[ 	]+\\|$\\)\\)?"
  ;; 	 "\\(?:\\(.*\\)[ 	]+::\\(?:[ 	]+\\|$\\)\\)?"))
  )

(use-package toc-org
  :hook org-mode)

;;; Workflow ;;;

(use-package-local org-agenda
  :after org
  :config
  (setq org-agenda-files
	(list "~/Notes/org/agenda.org"))
  ;; (define-key 'org-agenda-mode-map (kbd ")") 'org-agenda-todo)
  :bind (:map org-agenda-mode-map
	      (")" . 'org-agenda-todo)))

