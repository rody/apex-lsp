;;; lsp-apex.el --- Apex support for lsp-mode -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020 Rodolphe Blancho
;;
;; Author: Rodolphe Blancho <http://github/rodolphe.blancho>
;; Maintainer: Rodolphe Blancho <rodolphe.blancho@gmail.com>
;; Created: November 06, 2020
;; Modified: November 06, 2020
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/rodolphe.blancho/lsp-apex
;; Package-Requires: ((emacs 27.1) (cl-lib "0.5"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Apex support for lsp-mode
;;
;;  The server jar can be downloaded at https://github.com/forcedotcom/salesforcedx-vscode/raw/develop/packages/salesforcedx-vscode-apex/out/apex-jorje-lsp.jar
;;
;;; Code:
;;;

(require 'lsp-mode)
(require 'f)

(defconst lsp-apex-jar-name "apex-jorje-lsp.jar")

(defcustom lsp-apex-jar-file
  (f-join lsp-server-install-dir "apex-jorje" lsp-apex-jar-name)
  "Apex LSP server jar command."
  :type 'string
  :group 'lsp-apex
  :type 'file)

(defcustom lsp-apex-jar-download-url
 "https://github.com/forcedotcom/salesforcedx-vscode/raw/develop/packages/salesforcedx-vscode-apex/out/apex-jorje-lsp.jar"
 "Automatic download URL for apex-jorje-lsp.jar"
  :group 'lsp-apex
  :type 'string)

(lsp-dependency
 'apex-jorje
 '(:system lsp-apex-jar-file)
 `(:download :url lsp-apex-jar-download-url
             :store-path lsp-apex-jar-file))

(defcustom lsp-apex-server-command
  `("java" "-jar" ,lsp-apex-jar-file)
  "Startup command for APEX language server."
  :type '(repeat string)
  :group 'lsp-apex)

(defun lsp-apex--create-connection ()
  (lsp-stdio-connection
   (lambda () lsp-apex-server-command)
   (lambda () (f-exists? lsp-apex-jar-file))))

(add-to-list 'lsp-language-id-configuration
             '(apex-mode . "apex"))

(lsp-register-client
 (make-lsp-client :new-connection (lsp-apex--create-connection)
                  :activation-fn (lsp-activate-on "apex")
                  :priority 0
                  :server-id 'apex-jorje
                  :multi-root t
                  :initialized-fn (lambda (workspace)
                                    (with-lsp-workspace workspace
                                      (lsp--set-configuration (lsp-configuration-section "apex"))))
                  :download-server-fn (lambda (_client callback error-callback _update?)
                                        (lsp-package-ensure 'apex-jorje callback error-callback))))

(lsp-consistency-check lsp-apex)

(provide 'lsp-apex)
;;; lsp-apex.el ends here
