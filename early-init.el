

;;;;;; General important:

;;; Variables

;;; Prevent package.el from auto-loading
(setq package-enable-at-startup nil)

;; less garbage collection at startupg
(setq gc-cons-threshold (* 50 1000 1000))

;; dont run byte-compiled code if outdated to .el file
(setq load-prefer-newer t)

;; remove unneeded UI elements
(setq default-frame-alist
      '((tool-bar-lines . 0) ; disable tool bar
	(menu-bar-lines . 0) ; disable menu bar
	(vertical-scroll-bars) ; disable vertical scroll bar
	(left-fringe . 10)   ; set left fringe (def: 8) (then: 8)
	(right-fringe . 10) ; set right fringe (def: 8) (then: 13)
	(drag-internal-border . t)
	(internal-border-width . 15) ; box border around buffer+modeline (creates gap)
        (fullscreen . maximized) ; TODO: ???
	))
(setq tool-bar-mode nil			; disable tool bar
      menu-bar-mode nil			; disable menu bar
      scroll-bar-mode nil		; disable vertical scroll bar
      )

;; prevent toolbar setup from running (optimization)
(advice-add 'tool-bar-setup :override #'ignore)
;; undo previous change so user can manually enable tool-bar later
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (advice-remove 'tool-bar-setup #'ignore)
	    (when tool-bar-mode (tool-bar-setup))))

;;; Paths:

(defconst neko-root-dir
  (abbreviate-file-name
   (file-name-directory
    (file-truename
     (or load-file-name buffer-file-name)))))
(defvar neko-components-dir (concat neko-root-dir "components/"))
(defvar neko-personal-dir (concat neko-root-dir "personal/"))
(defvar neko-special-config-dir (concat neko-personal-dir "nekomimi/"))
(defvar neko-local-dir (concat neko-root-dir "local/"))

(defvar neko-modules-config (concat neko-special-config-dir "modules.el"))

(setq custom-file (concat neko-local-dir "custom-vars.el"))

;;; User-side variables:

;; package manager
(defvar neko-package-manager 'straight)
;; benchmark
(defvar neko-benchmark nil)
;; increase gc freq after init
(defvar neko-after-init-gc-cons-threshold (* 2 1000 1000))
;; transparency
(defvar neko-transparency-value 100) ; (100 = no transparency).

;;; User-side functions:

;; enable transparency at startup (TODO: would this fuck up later set-frame-parameter?)
(defun nekomini-enable-init-transparency ()
  (unless (assoc 'alpha-background default-frame-alist)
    (add-to-list 'default-frame-alist (cons 'alpha-background neko-transparency-value))))

;;; Fixes

;; changes the eln-cache dir to be inside a subdir for cleanliness
(when (and (fboundp 'startup-redirect-eln-cache)
           (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name  "var/eln-cache/" neko-local-dir))))

;;; Load early-config.el:

(let ((path (concat neko-special-config-dir "early-config.el")))
  (if (file-exists-p path)
      (condition-case-unless-debug e ; soft error handling if loading fails
	  (load path)
	(error (display-warning 'early-config.el (error-message-string e) :error)))
    (message "Warning: early-config.el \"%s\" not found" path)))
