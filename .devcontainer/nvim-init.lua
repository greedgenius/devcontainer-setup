-- Leader Keys
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Basic Settings
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.autochdir = true
vim.opt.viewoptions = "folds,cursor,curdir"

vim.opt.list = true
vim.opt.listchars = {
  tab = "» ",
  trail = '·',
  extends = '❯',
  precedes = '❮',
}

-- Enable persistent undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('data') .. '/undo'
vim.opt.undolevels = 10000
vim.opt.undoreload = 10000

-- Create view directory if it doesn't exist
local view_dir = vim.fn.stdpath('data') .. '/view'
if vim.fn.isdirectory(view_dir) == 0 then
    vim.fn.mkdir(view_dir, 'p')
end

-- Create undo directory if it doesn't exist
local undo_dir = vim.fn.stdpath('data') .. '/undo'
if vim.fn.isdirectory(undo_dir) == 0 then
    vim.fn.mkdir(undo_dir, 'p')
end

-- Key Mappings

-- File Operations
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>qq', ':q!<CR>', { desc = 'Force quit' })
vim.keymap.set('n', '<leader>qa', ':qa<CR>', { desc = 'Quit all' })
vim.keymap.set('n', '<leader>qaa', ':qa!<CR>', { desc = 'Force quit all' })
vim.keymap.set('n', '<leader>w', ':w!<CR>', { desc = 'Save with force' })
vim.keymap.set('n', '<leader>wq', ':wq!<CR>', { desc = 'Save and quit with force' })

-- Window Navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left split' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom split' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top split' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right split' })

-- Window Resizing
vim.keymap.set('n', '<leader>h', ':vertical resize -2<CR>', { desc = 'Decrease width -2' })
vim.keymap.set('n', '<leader>hh', ':vertical resize -10<CR>', { desc = 'Decrease width -10' })
vim.keymap.set('n', '<leader>hhh', ':vertical resize -30<CR>', { desc = 'Decrease width -30' })
vim.keymap.set('n', '<leader>l', ':vertical resize +2<CR>', { desc = 'Increase width +2' })
vim.keymap.set('n', '<leader>ll', ':vertical resize +10<CR>', { desc = 'Increase width +10' })
vim.keymap.set('n', '<leader>lll', ':vertical resize +30<CR>', { desc = 'Increase width +30' })
vim.keymap.set('n', '<leader>j', ':resize +2<CR>', { desc = 'Increase height +2' })
vim.keymap.set('n', '<leader>jj', ':resize +10<CR>', { desc = 'Increase height +10' })
vim.keymap.set('n', '<leader>jjj', ':resize +30<CR>', { desc = 'Increase height +30' })
vim.keymap.set('n', '<leader>k', ':resize -2<CR>', { desc = 'Decrease height -2' })
vim.keymap.set('n', '<leader>kk', ':resize -10<CR>', { desc = 'Decrease height -10' })
vim.keymap.set('n', '<leader>kkk', ':resize -30<CR>', { desc = 'Decrease height -30' })

-- Utility
vim.keymap.set('n', '<leader>ev', ':e ~/.config/nvim/init.lua<CR>', { desc = 'Edit init.lua' })
vim.keymap.set('i', 'jk', '<ESC>', { desc = 'Exit insert mode' })
vim.keymap.set('i', ';;', '<C-x><C-o>', { desc = 'Omni completion' })
vim.keymap.set('n', '<leader>rmv', function()
    vim.cmd('normal! gg')
    vim.cmd('normal! zR')
    vim.cmd('normal! zz')
end, { desc = 'Reset view for current file' })

-- Autocmds
local autocmd = vim.api.nvim_create_autocmd

-- Auto-save and restore folds/cursor position
autocmd('BufWinLeave', {
    pattern = '*',
    callback = function()
        if vim.fn.expand('%') ~= '' and vim.bo.buftype == '' then
            vim.cmd('mkview')
        end
    end,
    desc = 'Save view on buffer leave'
})

autocmd('BufWinEnter', {
    pattern = '*',
    command = 'silent! loadview',
    desc = 'Load view on buffer enter'
})

-- Force .pm files to be detected as perl filetype and enable marker folding
autocmd({'BufRead', 'BufNewFile'}, {
    pattern = {'*.pm', '*.pl', '*.t'},
    callback = function()
        vim.bo.filetype = 'perl'
    end,
    desc = 'Set Perl filetype'
})

-- Enable marker folding for Perl files (runs after view loading)
autocmd('BufWinEnter', {
    pattern = {'*.pm', '*.pl', '*.t'},
    callback = function()
        if vim.bo.filetype == 'perl' then
            vim.opt_local.foldmethod = "marker"
            vim.opt_local.foldlevel = 0
        end
    end,
    desc = 'Enable marker folding for Perl files after view load'
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin configuration (adapted for container environment)
require("lazy").setup({
    -- Core Plugins
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require'nvim-treesitter.configs'.setup {
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = {
                    enable = true
                },
                fold = {
                    enable = true
                },
                ensure_installed = {
                    "markdown",
                    "markdown_inline",
                    "lua",
                    "vim",
                    "bash",
                    "json",
                    "yaml",
                    "dockerfile",
                    "javascript",
                    "typescript",
                    "python",
                },
                auto_install = true,
            }
        end
    },
    
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme "catppuccin"
        end
    },
    
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require('lualine').setup {
                options = {
                    theme = 'auto',
                },
                sections = {
                    lualine_c = {
                        {
                            'filename',
                            path = 1,
                        }
                    }
                }
            }
        end
    },

    -- File Management
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local telescope = require('telescope')
            local actions = require('telescope.actions')
            
            telescope.setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-n>"] = function(prompt_bufnr)
                                local entry = require('telescope.actions.state').get_current_line()
                                actions.close(prompt_bufnr)
                                vim.cmd('e ' .. entry)
                            end,
                        },
                    },
                },
            })
            
            -- Keymaps
            vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', { desc = 'Find files' })
            vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', { desc = 'Live grep' })
            vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', { desc = 'Buffers' })
            vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>', { desc = 'Help tags' })
        end
    },
    
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require('neo-tree').setup({
                filesystem = {
                    visible = true,
                }
            })
            vim.keymap.set('n', '<leader>nn', function()
                vim.cmd(':Neotree<CR>')
            end, { desc = 'Open file tree' })
        end
    },
    
    -- Utility Plugins
    {
        "junegunn/vim-easy-align",
        config = function()
            vim.keymap.set({'n', 'x'}, 'ga', '<Plug>(EasyAlign)', { desc = 'EasyAlign' })
        end
    },
    
    {
        "mbbill/undotree",
        config = function()
            vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>', { desc = 'Toggle undotree' })
        end
    },
    
    {
        "chentoast/marks.nvim",
        config = function()
            require'marks'.setup {}
        end
    },
    
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end
    },
    
    {
        "christoomey/vim-tmux-navigator",
        lazy = false,
    },
    
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        config = function()
            require('dashboard').setup {
                theme = 'hyper',
                config = {
                    week_header = {
                        enable = true,
                    },
                    shortcut = {
                        { desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
                        { desc = ' Files', group = 'Label', action = 'Telescope find_files', key = 'f' },
                        { desc = ' Workspace', group = 'DiagnosticHint', action = 'cd /workspace', key = 'w' },
                    },
                },
            }
        end,
        dependencies = { {'nvim-tree/nvim-web-devicons'}}
    },
})