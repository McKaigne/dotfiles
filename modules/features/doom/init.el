
;;; init.el -*- lexical-binding: t; -*-

(doom! :input

       :completion
       (corfu +orderless)
       vertico

       :ui
       dashboard
       hl-todo
       ophints
       treemacs
       vc-gutter
       vi-tilde-fringe
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       snippets

       :emacs
       dired
       electric
       undo
       vc

       :term
       eshell
       ghostel

       :checkers
       syntax

       :tools
       direnv
       editorconfig
       (eval +overlay)
       lookup
       lsp               ; <-- Uses lsp-mode instead of eglot
       magit
       make
       tree-sitter

       :lang
       (cc +lsp +tree-sitter)
       (elixir +lsp +tree-sitter)
       (emacs-lisp +tree-sitter)
       (haskell +lsp +tree-sitter)
       (json +tree-sitter)
       (latex +tree-sitter)
       (lua +tree-sitter)
       (markdown +tree-sitter)
       (nix +tree-sitter)
       (ocaml +lsp +tree-sitter)
       (org +tree-sitter)
       (python +tree-sitter)
       (rust +lsp +tree-sitter)
       (sh +tree-sitter)
       (yaml +tree-sitter)
       (zig +tree-sitter)

       :config
       (default +bindings))
