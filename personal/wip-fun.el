

;; no cover
;; (use-package listen)

;; emms extract metadata?
;; https://www.reddit.com/r/emacs/comments/981khz/emacs_music_player_with_emms/

;; TODO: 
(use-package emms
  :config
  (require 'emms-setup)
  (require 'emms-player-mpd)
  (require 'emms-player-mpv)
  (emms-all)
  
  ;; variables
  
  (setq emms-source-file-default-directory "~/Music/library/")
  ;; emms-player-mpv-parameters '("--no-audio-display=no"); broken
  (setq emms-browser-covers #'emms-browser-cache-thumbnail-async)
  ;; sort by natural order
  (setq emms-playlist-sort-function #'emms-playlist-sort-by-natural-order)
  ;; sort album by natural order
  (setq  emms-browser-album-sort-function #'emms-playlist-sort-by-natural-order)

  ;; backends
  
  (setq emms-player-list '(emms-player-mpd emms-player-mpv))

  ;; get info from mpd
  (add-to-list 'emms-info-functions 'emms-info-mpd)
  ;; ? show current song when next song starts?
  (add-hook 'emms-player-started-hook #'emms-show)
  ;; connect to mpd
  (setq emms-player-mpd-server-name "localhost")
  (setq emms-player-mpd-server-port "6600")
  (setq emms-player-mpd-music-directory "\~/Music/library")
  (emms-player-mpd-connect)

  ;; enable playerctl pausing
  
  (require 'emms-mpris)
  (emms-mpris-enable)

  ;; (setq emms-player-list '(emms-player-mpd))
  ;; (add-to-list 'emms-info-functions 'emms-info-mpd)
  ;; (add-to-list 'emms-player-list 'emms-player-mpd)
 
  ;; TODO: add this function to emms-info-functions (hard to implement?)
  ;; (instead make my own function that runs ffprobe and gets info? might be better)
  (defun my/emms-show-album-cover-in-emacs ()
    (interactive)
    (if-let ((track (emms-playlist-current-selected-track))
	     (song-path (emms-track-get track 'name))
	     (cover-path "/tmp/emms-album-cover.jpg")) ;; is jpg fine?
	(if (not (file-exists-p song-path))
	    (message "Error: cannot find path to currently playing song")
	  (when (file-exists-p cover-path)
	    (delete-file cover-path))
	  (let ((exit-code
		 (shell-command
		  (message "extracting: %s"
			   (format "ffmpeg -i %s -an -vcodec copy %s -y"
				   (shell-quote-argument song-path)
				   (shell-quote-argument cover-path))))))
	    (cond ((/= exit-code 0)
		   (message "Error: ffmpeg cover extraction failed with code %s"
			    exit-code))
		  ((file-exists-p cover-path)
		   (with-current-buffer (get-buffer-create "*Album Cover*")
		     (erase-buffer)
		     (insert-image (create-image cover-path))
		     (pop-to-buffer (current-buffer))))
		  (t
		   (message "Error: ffmpeg cover at cover-path not found.")))))
      (message "No song currently playing"))))

;; Hook to display album cover in Emacs when the track changes
;; (add-hook 'emms-player-started-hook 'emms-show-album-cover-in-emacs)
