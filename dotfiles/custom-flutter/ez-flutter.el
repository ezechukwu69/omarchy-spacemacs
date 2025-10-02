;;; ez-flutter.el --- Interactive Flutter commands with dape integration -*- lexical-binding: t; -*-

;; Author: Your Name
;; Version: 1.0.0
;; Package-Requires: ((emacs "27.1") (dape "0.1"))
;; Keywords: flutter, dart, mobile, development
;; URL: https://github.com/yourusername/ez-flutter

;;; Commentary:

;; This package provides interactive Flutter development commands integrated
;; with dape (Debug Adapter Protocol for Emacs). It includes commands for
;; starting/stopping Flutter apps, hot reload/restart functionality, device
;; management, and automatic hot reload on save.

;;; Code:

;; (require 'dape)
(require 'project)
(require 'dart-mode nil t)
(require 'apheleia nil t)

(defun ez/flutter-start ()
  (interactive)
  (dape '(
          modes (dart-mode)
          command "flutter"
          command-args ("debug_adapter")
          :type "dart"
          :name "Flutter Debug"
          :args ["-v"]
          :request "launch"
          :program "lib/main.dart"
          :cwd (project-root (project-current))
          )))

(defun ez/flutter-stop ()
  (interactive)
  (dape-kill dape--connection))

(defun ez/flutter-devices ()
  (interactive)
  (let* ((command "flutter emulators | awk '/^Id\s+•/{p=1; next} /^To run an emulator/{p=0} p' | grep -v '^\s*$' | awk '{print $1}'")
         (result (split-string (shell-command-to-string command) "\n" t))
         (picked (completing-read "Pick emulator" result)))
    (shell-command (format "flutter emulators --launch %s" picked))))

(defun ez/send-flutter-command (command)
  (dape-request dape--connection command nil))

(defun ez/flutter-reload ()
  (interactive)
  (ez/send-flutter-command "hotReload"))

(defun ez/flutter-restart ()
  (interactive)
  (ez/send-flutter-command "hotRestart"))

(defun ez/reload-on-save ()
  "Run after Apheleia finishes formatting in Dart mode."
  (when (or (derived-mode-p 'dart-mode) (derived-mode-p 'dart-ts-mode))
    ;; Replace with your actual command
    (ez/flutter-reload)))

(add-hook 'apheleia-post-format-hook #'ez/reload-on-save)

(provide 'ez-flutter)

;;; ez-flutter.el ends here
