
;;; Functions:

(defun mimi/open-neko-personal-dir ()
  (interactive)
  (dired neko-personal-dir))

;;; Set leader-key binds:

(mimi/leader-define-key
 "f" '(:ignore t :which-key "files")
 "ff" 'find-file
 "fp" 'mimi/open-neko-personal-dir)


(provide 'neko-files)
