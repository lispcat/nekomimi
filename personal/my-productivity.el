
;;; Productivity ;;;

;;
;; Org-Agenda
;;
;; The Todo-view
;;   /  filter by tag
;; File
;;   C-c C-q  org set tags
;;
;; Strategies
;; - define custom agenda views to quicken
;; - find all non-tagged tasks, make sure everything is tagged
;; Todo
;; - capture templates


;;;;;; Agenda ;;;;;;

(use-package-local org-agenda
  :after org
  :bind (:map org-agenda-mode-map
	      (")" . 'org-agenda-todo))
  :config
  (setq org-agenda-files
	(list "~/Notes/org/Inbox.org"
	      "~/Notes/denote/20250131T044005--agenda__agenda.org"
	      "~/Notes/denote/classes/20241215T083836--spring-classes__class_meta_todo.org"))
  (setq org-tag-alist
	'(;; Places
	  ("@home"   . ?H)
	  ("@school" . ?S)
	  ;; ("@work" . ?W)
	  ;; Activities
	  ("@task" . ?t)
	  ("@studying" . ?s)
	  ("@errands"  . ?e)
	  ("@tidy" . ?y)
	  ("@creative" . ?c)
	  ("@art" . ?a)
	  ("@programming" . ?p)
	  ;; ("@calls" . ?l)
	  ;; Devices
	  ("@phone" . ?P)
	  ("@computer" . ?C)))
  (defun my/org-get-prop-time ()
    (if (not (eq major-mode 'org-mode)) ""
      (let ((val (org-entry-get nil "TIME")))
	(if (not val) ""
	  (format "%s" (string-trim val))))))
  (defun my/org-get-prop-effort ()
    (if (not (eq major-mode 'org-mode)) ""
      (let ((val (org-entry-get nil "EFFORT")))
	(if (not val) ""
	  (format "%s" (string-trim val))))))
  (setq org-agenda-prefix-format
	`((agenda
	   . ,(concat " %i "
		      "%?-12t"
		      "%-6(my/org-get-prop-effort)"
		      "[%-3(my/org-get-prop-time)]   " ; time prop
		      "% s"))
	  (todo   . " %i ")
	  (tags   . " %i %-12:c")
	  (search . " %i %-12:c"))))

(use-package org-super-agenda
  :after org org-agenda
  :config
  (org-super-agenda-mode 1)
  (setq org-agenda-custom-commands
	`(("m" "Main View"
	   ((agenda nil ((org-agenda-span 'day)
			 (org-super-agenda-groups
			  '((:name "OVERDUE"
				   :and (:not (:todo "DONE") :deadline past)
				   :and (:not (:todo "DONE") :scheduled past)
				   :transformer (--> it (propertize it 'face '(:foreground "salmon")))
				   :order 1)
			    (:name "HIGH PRIORITY"
				   :and (:not (:todo "DONE") :date today :priority>= "A")
				   :order 2)
			    (:name "low priority"
				   :and (:not (:todo "DONE") :date today :priority<= "C")
				   :order 5)
			    (:name "Done"
				   :and (:todo "DONE" :date today)
				   :order 10)
			    (:name "old"
				   :and (:todo "DONE" :deadline past)
				   :and (:todo "DONE" :scheduled past)
				   :order 20)
			    (:name "Today"
				   :time-grid t
				   :date today
				   :deadline today
				   :scheduled today
				   :order 3)
			    (:discard (:property "FRACTION" :deadline future))
			    (:discard (:property "FRACTION" :scheduled future))
			    (:name "Future"
				   :and (:not (:todo "DONE") :deadline future)
				   :and (:not (:todo "DONE") :scheduled future)
				   :order 4)
			    )))))))))

(defun my/org-clone-with-fraction (days time effort)
  "Clone subtree with time shifts, prefixing each subheading with fraction prefix."
  (interactive
   (list
    (read-number "How many days to complete it over?: ")
    (read-number "How many minutes do you expect this task to take?: ")
    (read-number "On a scale of 1-10, how much effort will this take?: ")))
  ;; create clones
  (org-clone-subtree-with-time-shift days "-1d")
  (org-set-property "TIME" (format "%s" time))
  (org-set-property "EFFORT" (format "%s" effort))
  ;; adjust appropriately
  (save-excursion
    (org-next-visible-heading 1)
    ;; first, sort
    (cl-loop for depth from (1- days) downto 1 do
	     (save-excursion
	       ;; shift
	       (dotimes (_ depth)
		 (org-metadown))))
    ;; add todo and demote
    (save-excursion
      (cl-loop repeat (1- days) do
	       (org-next-visible-heading 1))
      (cl-loop for depth from (1- days) downto 0 do
	       (let ((frac (format "%d/%d" (1+ depth) days))
		     (time-daily (/ time days)))
		 (org-demote)
		 (let ((org-special-ctrl-a/e t))
		   (org-beginning-of-line))
		 (insert (concat frac " "))
		 (org-set-property "FRACTION" frac)
		 (org-set-property "TIME" (format "%s" time-daily))
		 (org-set-property "EFFORT" (format "%s" effort))
		 (org-next-visible-heading -1))))))

;; TODO: while in an org-agenda view, function "my/do-a-task", org pomo start on the asgn with the lowest effort value.

;;; TODO: Linear programming solver to show tasks to do for the day that would achieve the minimum amount of work i need to do for the given day over the next 7 days worth of assignments. have it consider effort and time properties.

;;;;;; Org Capture ;;;;;;

(use-package-local org-capture
  :after org
  :general
  (neko/leader-definer
    "oc" 'org-capture)
  :config
  (defun my/get-org-agenda-denote-file (name)
    (let ((regex (format "^.*--%s__.*\\.org$" name)))
      (car (seq-filter
	    (lambda (path)
	      (string-match regex (file-name-nondirectory path)))
	    org-agenda-files))))
  (setq org-capture-templates
	`(("t" "Tasks")
	  ("td" "Todo with deadline" entry
	   (file ,(my/get-org-agenda-denote-file "agenda"))
	   "* TODO %^{Task}\nDEADLINE: %^{Deadline}t\n%?\n"
	   :empty-lines 1
	   :immediate-finish nil)
	  ("tp" "Task" entry
	   (file ,(my/get-org-agenda-denote-file "agenda"))
	   "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)
	  ("n" "New note (with Denote)" plain
	   (file denote-last-path)
	   #'denote-org-capture :no-save t :immediate-finish nil
	   :kill-buffer t :jump-to-captured t))))

;;;;;; Org QL ;;;;;;

(use-package org-ql)

;;;;;; org pomodoro ;;;;;;

(use-package org-pomodoro)
