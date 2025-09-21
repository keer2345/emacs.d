;;; init-themes.el --- Defaults for themes -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require-package 'color-theme-sanityinc-solarized)
(require-package 'color-theme-sanityinc-tomorrow)

;; Don't prompt to confirm theme safety. This avoids problems with
;; first-time startup on Emacs > 26.3.
(setq custom-safe-themes t)

;; If you don't customize it, this is the theme you get.
(setq-default custom-enabled-themes '(sanityinc-tomorrow-bright))

;; Ensure that themes will be applied even if they have not been customized
(defun reapply-themes ()
  "Forcibly load the themes listed in `custom-enabled-themes'."
  (dolist (theme custom-enabled-themes)
    (unless (custom-theme-p theme)
      (load-theme theme)))
  (custom-set-variables `(custom-enabled-themes (quote ,custom-enabled-themes))))

(add-hook 'after-init-hook 'reapply-themes)



;; Toggle between light and dark

(defun light ()
  "Activate a light color theme."
  (interactive)
  (setq custom-enabled-themes '(sanityinc-tomorrow-day))
  (reapply-themes))

(defun dark ()
  "Activate a dark color theme."
  (interactive)
  (setq custom-enabled-themes '(sanityinc-tomorrow-bright))
  (reapply-themes))


(when (maybe-require-package 'dimmer)
  (setq-default dimmer-fraction 0.15)
  (add-hook 'after-init-hook 'dimmer-mode)
  (with-eval-after-load 'dimmer
    ;; TODO: file upstream as a PR
    (advice-add 'frame-set-background-mode :after (lambda (&rest args) (dimmer-process-all))))
  (with-eval-after-load 'dimmer
    ;; Don't dim in terminal windows. Even with 256 colours it can
    ;; lead to poor contrast.  Better would be to vary dimmer-fraction
    ;; according to frame type.
    (defun sanityinc/display-non-graphic-p ()
      (not (display-graphic-p)))
    (add-to-list 'dimmer-exclusion-predicates 'sanityinc/display-non-graphic-p)))

(use-package doom-themes
  :config
  (load-theme 'doom-one t) ; 加载 doom-one 主题，'t' 表示强制加载
  ;; 启用炫酷的模型线
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(use-package zenburn-theme
  :config
  (load-theme 'zenburn t))

(use-package doric-themes

;; 随机主题        
;; 主题黑名单
(setq exclude-theme-list '(leuven doom-one doom-acario-light))
(defun random-theme ()
  "随机选择一个主题，排除不喜欢的主题"
  (interactive)
  (let* ((excluded-themes exclude-theme-list) ; 排除的主题列表
         (available-themes (seq-filter (lambda (theme)
                                        (not (memq theme excluded-themes)))
                                      (custom-available-themes)))
         (random-theme (nth (random (length available-themes)) available-themes)))
    (when random-theme
      (disable-theme (car custom-enabled-themes)) ; 禁用当前主题
      (load-theme random-theme t)
      (message "🎨 随机主题: %s" random-theme))))

;; 启动时调用
(add-hook 'after-init-hook 'random-theme)

(provide 'init-themes)
;;; init-themes.el ends here
