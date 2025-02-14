

;;; Keybinds ;;;

(use-package meow
  ;; :after meow
  :config
  ;; bug, temp workaround:
  ;; (setq meow-keypad-leader-dispatch "C-c")

  (defun ri/meow-exit-all-and-save ()
    "When run, exit meow insert mode, exit snippet, then save buffer."
    (interactive)
    ;; (execute-kbd-macro (kbd "<escape>"))
    (meow-insert-exit)
    (when (buffer-modified-p (current-buffer))
      (save-buffer)))

  ;; (defun ri/kbd-escape ()
  ;;   "When run, exit meow insert mode, exit snippet, then save buffer."
  ;;   (interactive)
  ;;   (execute-kbd-macro (kbd "<escape>")))

  (defvar ri/meow-insert-default-modes
    '(vterm-mode
      eshell-mode)
    "Start these modes in meow-insert-mode.")

  (defvar ri/meow-SPC-ignore-list
    '(Info-mode
      gnus-summary-mode
      gnus-article-mode
      w3m-mode)
    "Disable meow-keypad in these modes.")

  ;; set some keys for insert-mode
  (meow-define-keys 'insert
    ;; '("C-g" . ri/kbd-escape)
    '("C-g" . meow-insert-exit)
    ;; '("C-g" . "<escape>")
    '("C-M-g" . ri/meow-exit-all-and-save))

  ;; start certain modes in insert-mode
  ;; (dolist (mode ri/meow-insert-default-modes)
  ;;   (add-to-list 'meow-mode-state-list `(,mode . insert)))

  ;; disable meow-keypad (space key) on certain modes
  (defun ri/meow-SPC-ignore ()
    "When run, either run SPC for the current major-mode or meow-keypad."
    (interactive)
    ;; if t, appropriate to replace and run mode cmd.
    (if-let ((in-ignore-list?
              (cl-some (lambda (mode)
                         (eq major-mode mode))
                       ri/meow-SPC-ignore-list))
             (cmd-to-replace
              (lookup-key (current-local-map) (kbd "SPC"))))
        (funcall cmd-to-replace)
      (meow-keypad)))
  ;; (meow-motion-overwrite-define-key
  ;;  '("SPC" . ri/meow-SPC-ignore))

  ;; enter meow insert mode after creating new org heading
  (add-hook 'org-insert-heading-hook 'meow-insert)

  (setq meow-use-cursor-position-hack t))
