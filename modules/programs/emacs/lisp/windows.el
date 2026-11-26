;;; windows.el -*- lexical-binding: t -*-

(defvar nixmacs-master-count 1)
(defvar nixmacs-master-factor 0.55)
(defvar nixmacs-narrow-threshold 132)
(defvar nixmacs-tiling nil)

(defvar nixmacs-popup-buffer-regexp
  (rx bos (? " ") "*"
      (or "Org Select" "Org todo" "Org tags" "Org Export Dispatcher"
          "Agenda Commands" "Calendar")
      "*" eos))

(defvar ediff-buffer-A)
(defvar ediff-buffer-B)
(defvar ediff-buffer-C)
(defvar ediff-ancestor-buffer)

(defun nixmacs-window-children (window)
  "Return the child windows of WINDOW in order."
  (let ((child (window-child window)) children)
    (while child
      (push child children)
      (setq child (window-next-sibling child)))
    (nreverse children)))

(defun nixmacs-window-leaves (window)
  "Return the live windows under WINDOW in order."
  (if (window-live-p window)
      (list window)
    (mapcan #'nixmacs-window-leaves (nixmacs-window-children window))))

(defun nixmacs-tiled-windows (&optional frame)
  "Return FRAME's tiled panes, masters first."
  (nixmacs-window-leaves (window-main-window frame)))

(defun nixmacs-narrow-p (frame)
  "Return non-nil when FRAME is too narrow for side-by-side areas."
  (< (window-total-width (window-main-window frame)) nixmacs-narrow-threshold))

(defun nixmacs-areas (count)
  "Return the master and stack pane counts for COUNT panes."
  (let ((masters (min nixmacs-master-count count)))
    (cons masters (- count masters))))

(defun nixmacs-layout-shape (window)
  "Return the shape of the window tree under WINDOW."
  (if (window-live-p window)
      'pane
    (cons (if (window-combined-p (window-child window) t) 'columns 'rows)
          (mapcar #'nixmacs-layout-shape (nixmacs-window-children window)))))

(defun nixmacs-area-shape (count)
  "Return the shape of an area holding COUNT panes."
  (if (= count 1) 'pane (cons 'rows (make-list count 'pane))))

(defun nixmacs-expected-shape (frame count)
  "Return the shape FRAME should have with COUNT panes."
  (pcase-let ((`(,masters . ,stack) (nixmacs-areas count)))
    (if (or (zerop masters) (zerop stack))
        (nixmacs-area-shape count)
      (list (if (nixmacs-narrow-p frame) 'rows 'columns)
            (nixmacs-area-shape masters)
            (nixmacs-area-shape stack)))))

(defun nixmacs-fits-p (frame count)
  "Return non-nil when COUNT panes fit in FRAME."
  (pcase-let* ((main (window-main-window frame))
               (height (window-total-height main))
               (width (window-total-width main))
               (rows (max window-min-height 4))
               (`(,masters . ,stack) (nixmacs-areas count)))
    (cond ((or (zerop masters) (zerop stack))
           (>= height (* count rows)))
          ((nixmacs-narrow-p frame)
           (and (>= (* nixmacs-master-factor height) (* masters rows))
                (>= (* (- 1 nixmacs-master-factor) height) (* stack rows))))
          (t
           (and (>= (* nixmacs-master-factor width) window-min-width)
                (>= (* (- 1 nixmacs-master-factor) width) window-min-width)
                (>= height (* (max masters stack) rows)))))))

(defun nixmacs-window-snapshot (window)
  "Return what WINDOW shows, to put back after a re-tile."
  (list (window-buffer window) (window-start window) (window-point window)
        (window-prev-buffers window) (window-dedicated-p window)
        (window-parameter window 'quit-restore)
        (window-parameter window 'quit-restore-prev)))

(defun nixmacs-window-restore (window snapshot)
  "Show SNAPSHOT in WINDOW."
  (pcase-let ((`(,buffer ,start ,point ,prev ,dedicated ,quit ,quit-prev) snapshot))
    (when (buffer-live-p buffer)
      (set-window-buffer window buffer)
      (when start (set-window-start window start t))
      (when point (set-window-point window point))
      (set-window-prev-buffers window prev)
      (set-window-dedicated-p window dedicated)
      (set-window-parameter window 'quit-restore quit)
      (set-window-parameter window 'quit-restore-prev quit-prev))))

(defun nixmacs-split-area (window count)
  "Split WINDOW into COUNT even rows and return them in order."
  (let ((panes (list window))
        (remaining count))
    (while (> remaining 1)
      (let ((window-combination-limit (= remaining count)))
        (push (split-window (car panes)
                            (/ (window-total-height (car panes)) remaining)
                            'below)
              panes))
      (setq remaining (1- remaining)))
    (nreverse panes)))

(defun nixmacs-build (frame count)
  "Lay out COUNT empty panes in FRAME and return them in order."
  (pcase-let ((first (car (nixmacs-tiled-windows frame)))
              (`(,masters . ,stack) (nixmacs-areas count)))
    (dolist (window (cdr (nixmacs-tiled-windows frame)))
      (delete-window window))
    (if (or (zerop masters) (zerop stack))
        (nixmacs-split-area first count)
      (let* ((side (if (nixmacs-narrow-p frame) 'below 'right))
             (size (round (* nixmacs-master-factor
                             (window-size first (eq side 'right)))))
             (other (let ((window-combination-limit t))
                      (split-window first size side))))
        (append (nixmacs-split-area first masters)
                (nixmacs-split-area other stack))))))

(defun nixmacs-resize (frame)
  "Size FRAME's master area by `nixmacs-master-factor' and even out each area."
  (let ((main (window-main-window frame)))
    (unless (window-live-p main)
      (let ((areas (nixmacs-window-children main)))
        (if (< 0 nixmacs-master-count (length (nixmacs-tiled-windows frame)))
            (let ((horizontal (window-combined-p (car areas) t)))
              (ignore-errors
                (window-resize (car areas)
                               (- (round (* nixmacs-master-factor
                                            (window-size main horizontal)))
                                  (window-size (car areas) horizontal))
                               horizontal))
              (dolist (area areas)
                (unless (window-live-p area)
                  (balance-windows area))))
          (balance-windows main))))))

(defun nixmacs-arrange (frame &optional snapshots force-resize)
  "Re-tile FRAME, showing SNAPSHOTS in order when given.
Return the panes in order, or nil when SNAPSHOTS do not fit. Sizes reset
when the layout changes or with FORCE-RESIZE."
  (let* ((nixmacs-tiling t)
         (windows (nixmacs-tiled-windows frame))
         (selected (frame-selected-window frame))
         (snapshots (or snapshots
                        (mapcar (lambda (window)
                                  (cons (eq window selected)
                                        (nixmacs-window-snapshot window)))
                                windows)))
         (count (length snapshots)))
    (cond ((and (= count (length windows))
                (equal (nixmacs-layout-shape (window-main-window frame))
                       (nixmacs-expected-shape frame count)))
           (when force-resize
             (nixmacs-resize frame))
           windows)
          ((nixmacs-fits-p frame count)
           (let ((panes (nixmacs-build frame count)))
             (seq-mapn (lambda (window snapshot)
                        (nixmacs-window-restore window (cdr snapshot))
                        (when (car snapshot)
                          (if (eq frame (selected-frame))
                              (select-window window)
                            (set-frame-selected-window frame window))))
                      panes snapshots)
             (nixmacs-resize frame)
             panes)))))

(defun nixmacs-ediff-active-p (frame)
  "Return non-nil while a visible ediff session uses FRAME's windows."
  (when (bound-and-true-p ediff-session-registry)
    (let ((buffers (mapcan
                    (lambda (control)
                      (when (and (buffer-live-p control) (get-buffer-window control t))
                        (with-current-buffer control
                          (delq nil (list control ediff-buffer-A ediff-buffer-B
                                          ediff-buffer-C ediff-ancestor-buffer)))))
                    ediff-session-registry)))
      (and buffers
           (seq-some (lambda (window) (memq (window-buffer window) buffers))
                     (window-list frame 'nomini))))))

(defun nixmacs-tiling-p (frame)
  "Return non-nil when FRAME should be tiled now."
  (not (or nixmacs-tiling (frame-parent frame) (nixmacs-ediff-active-p frame))))

(defun nixmacs-tile (&optional frame force-resize)
  "Re-tile FRAME, resetting sizes with FORCE-RESIZE."
  (let ((frame (or frame (selected-frame))))
    (when (nixmacs-tiling-p frame)
      (nixmacs-arrange frame nil force-resize))))

(defun nixmacs-insert-pane (frame after buffer)
  "Add a pane showing BUFFER after AFTER in FRAME's order and return it.
AFTER outside the tiled panes adds the pane at the end. Return nil when
there is no room."
  (let* ((windows (nixmacs-tiled-windows frame))
         (selected (frame-selected-window frame))
         (snapshots (mapcar (lambda (window)
                              (cons (eq window selected)
                                    (nixmacs-window-snapshot window)))
                            windows))
         (index (if (memq after windows)
                    (1+ (seq-position windows after))
                  (length windows))))
    (when-let* ((panes (nixmacs-arrange
                        frame (append (seq-take snapshots index)
                                      (list (list nil buffer))
                                      (seq-drop snapshots index)))))
      (nth index panes))))

(defun nixmacs-split-for-display (window)
  "Split for `display-buffer' by adding a pane after the selected one."
  (let ((frame (window-frame window)))
    (if (nixmacs-tiling-p frame)
        (nixmacs-insert-pane frame (frame-selected-window frame) (window-buffer window))
      (split-window-sensibly window))))

(defun nixmacs-display-buffer-below-selected (buffer alist)
  "Show BUFFER in a new pane after the selected one, or in the next pane."
  (let ((frame (selected-frame)))
    (when (nixmacs-tiling-p frame)
      (if-let* ((window (nixmacs-insert-pane frame (selected-window) buffer)))
          (window--display-buffer buffer window 'window alist)
        (let ((windows (nixmacs-tiled-windows frame)))
          (when (cdr windows)
            (window--display-buffer
             buffer (or (cadr (memq (selected-window) windows)) (car windows))
             'reuse alist)))))))

(defun nixmacs-display-buffer-popup (buffer alist)
  "Show BUFFER in a bottom popup when it is a short-lived menu."
  (when (string-match-p nixmacs-popup-buffer-regexp (buffer-name buffer))
    (display-buffer-in-side-window
     buffer (append '((side . bottom) (slot . 0)
                      (window-height . fit-window-to-buffer))
                    alist))))

(defun nixmacs-tile-after-delete (delete &optional window)
  "Call DELETE on WINDOW, then re-tile its frame unless WINDOW was a side window."
  (let* ((window (window-normalize-window window))
         (frame (window-frame window))
         (side (window-parameter window 'window-side)))
    (prog1 (funcall delete window)
      (when (and (not side) (frame-live-p frame))
        (nixmacs-tile frame)))))

(defun nixmacs-track-tiled-window (frame)
  "Remember FRAME's selected pane when it is a tiled pane."
  (let ((window (frame-selected-window frame)))
    (when (memq window (nixmacs-tiled-windows frame))
      (set-frame-parameter frame 'nixmacs-last-tiled window))))

(defun nixmacs-last-tiled-window (&optional frame)
  "Return the pane last selected in FRAME outside its side windows."
  (let ((window (frame-parameter frame 'nixmacs-last-tiled)))
    (and (window-live-p window) (eq (window-frame window) (or frame (selected-frame)))
         window)))

(defun nixmacs-tiled-selected ()
  "Return the tiled panes, or signal an error outside them."
  (let ((windows (nixmacs-tiled-windows)))
    (unless (memq (selected-window) windows)
      (user-error "Not a tiled pane"))
    windows))

(defun nixmacs-swap-panes (window other)
  "Swap what WINDOW and OTHER show, keeping each pane's quit behavior."
  (let ((quit (window-parameter window 'quit-restore))
        (other-quit (window-parameter other 'quit-restore)))
    (window-swap-states window other)
    (set-window-parameter window 'quit-restore quit)
    (set-window-parameter other 'quit-restore other-quit)))

(defun nixmacs-arrange-panes ()
  "Re-tile the selected frame and reset its sizes."
  (interactive)
  (nixmacs-tile nil t))

(defun nixmacs-select-next-pane (&optional count)
  "Select the COUNT-th next tiled pane, wrapping around."
  (interactive "p")
  (let ((windows (nixmacs-tiled-selected)))
    (select-window (nth (mod (+ (seq-position windows (selected-window)) (or count 1))
                             (length windows))
                        windows))))

(defun nixmacs-select-previous-pane (&optional count)
  "Select the COUNT-th previous tiled pane, wrapping around."
  (interactive "p")
  (nixmacs-select-next-pane (- (or count 1))))

(defun nixmacs-swap-next-pane (&optional count)
  "Swap the selected pane with the COUNT-th next one and follow it."
  (interactive "p")
  (let* ((windows (nixmacs-tiled-selected))
         (other (nth (mod (+ (seq-position windows (selected-window)) (or count 1))
                          (length windows))
                     windows)))
    (unless (eq other (selected-window))
      (nixmacs-swap-panes (selected-window) other)
      (select-window other))))

(defun nixmacs-swap-previous-pane (&optional count)
  "Swap the selected pane with the COUNT-th previous one and follow it."
  (interactive "p")
  (nixmacs-swap-next-pane (- (or count 1))))

(defun nixmacs-zoom ()
  "Swap the selected pane with the first master, or the master with the next pane."
  (interactive)
  (let* ((windows (nixmacs-tiled-selected))
         (window (selected-window))
         (master (car windows)))
    (when (eq window master)
      (setq window (or (cadr windows) (user-error "No other pane"))))
    (nixmacs-swap-panes master window)
    (select-window master)))

(defun nixmacs-change-master-factor (delta)
  "Grow the master area by DELTA of the frame."
  (setq nixmacs-master-factor (min 0.95 (max 0.05 (+ nixmacs-master-factor delta))))
  (nixmacs-tile nil t))

(defun nixmacs-grow-master ()
  "Grow the master area."
  (interactive)
  (nixmacs-change-master-factor 0.05))

(defun nixmacs-shrink-master ()
  "Shrink the master area."
  (interactive)
  (nixmacs-change-master-factor -0.05))

(defun nixmacs-more-masters ()
  "Put one more pane in the master area."
  (interactive)
  (setq nixmacs-master-count (1+ nixmacs-master-count))
  (nixmacs-tile nil t))

(defun nixmacs-fewer-masters ()
  "Put one fewer pane in the master area."
  (interactive)
  (setq nixmacs-master-count (max 0 (1- nixmacs-master-count)))
  (nixmacs-tile nil t))

(defun nixmacs-clone-pane ()
  "Show the selected buffer in a new pane after this one."
  (interactive)
  (nixmacs-tiled-selected)
  (select-window (or (nixmacs-insert-pane (selected-frame) (selected-window)
                                          (current-buffer))
                     (user-error "No room for another pane"))))

(defun nixmacs-new-pane ()
  "Show a new empty buffer in a new pane after this one."
  (interactive)
  (pop-to-buffer (generate-new-buffer "untitled")
                 '(nixmacs-display-buffer-below-selected)))

(defvar-keymap nixmacs-tiling-mode-map
  "M-j" #'nixmacs-select-next-pane
  "M-k" #'nixmacs-select-previous-pane
  "M-J" #'nixmacs-swap-next-pane
  "M-K" #'nixmacs-swap-previous-pane
  "M-h" #'nixmacs-shrink-master
  "M-l" #'nixmacs-grow-master
  "M-d" #'nixmacs-fewer-masters
  "M-i" #'nixmacs-more-masters
  "M-r" #'nixmacs-arrange-panes
  "M-C" #'delete-window
  "M-<return>" #'nixmacs-zoom
  "M-S-<return>" #'nixmacs-clone-pane)

(defvar nixmacs-tiling-mode-map-alist
  `((nixmacs-tiling-mode . ,nixmacs-tiling-mode-map)))

(define-minor-mode nixmacs-tiling-mode
  "Tile windows as master and stack panes, dwm style."
  :global t :group 'windows
  (if nixmacs-tiling-mode
      (progn
        (setq split-window-preferred-function #'nixmacs-split-for-display
              display-buffer-overriding-action '((nixmacs-display-buffer-popup))
              display-buffer-base-action
              '((display-buffer-reuse-window nixmacs-display-buffer-below-selected)))
        (add-to-list 'emulation-mode-map-alists 'nixmacs-tiling-mode-map-alist)
        (advice-add 'delete-window :around #'nixmacs-tile-after-delete)
        (add-hook 'window-selection-change-functions #'nixmacs-track-tiled-window)
        (nixmacs-tile))
    (setq split-window-preferred-function #'split-window-sensibly
          display-buffer-overriding-action '(nil)
          display-buffer-base-action '(nil)
          emulation-mode-map-alists
          (delq 'nixmacs-tiling-mode-map-alist emulation-mode-map-alists))
    (advice-remove 'delete-window #'nixmacs-tile-after-delete)
    (remove-hook 'window-selection-change-functions #'nixmacs-track-tiled-window)))

(nixmacs-tiling-mode 1)
