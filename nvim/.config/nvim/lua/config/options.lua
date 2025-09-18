-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Indentation globale
local opt = vim.opt
opt.tabstop = 4 -- Un caractère TAB affiché comme 4 espaces
opt.shiftwidth = 4 -- Nombre d’espaces pour l’indentation automatique
opt.softtabstop = 4 -- Nombre d’espaces insérés lors de l’appui sur TAB
opt.expandtab = false -- Les TABs ne sont convertis en espaces
