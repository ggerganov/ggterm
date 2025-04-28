vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
        ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
        ['+'] = function () end,
        ['*'] = function () end,
    },
}

local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

vim.cmd('hi! link CurSearch Search')
vim.g.editorconfig = false

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    use {
        'rachartier/tiny-glimmer.nvim',
        config = function()
            require('tiny-glimmer').setup({
                enabled = true,

                -- Disable this if you wants to debug highlighting issues
                disable_warnings = true,

                default_animation = "fade",
                refresh_interval_ms = 6,

                overwrite = {
                    -- Automatically map keys to overwrite operations
                    -- If set to false, you will need to call the API functions to trigger the animations
                    -- WARN: You should disable this if you have already mapped these keys
                    -- 		 or if you want to use the API functions to trigger the animations
                    auto_map = true,

                    -- For search and paste, you can easily modify the animation to suit your needs
                    -- For example you can set a table to default_animation with custom parameters:
                    -- default_animation = {
                    --     name = "fade",
                    --
                    --     settings = {
                    --         max_duration = 1000,
                    --         min_duration = 1000,
                    --
                    --         from_color = "DiffDelete",
                    --         to_color = "Normal",
                    --     },
                    -- },
                    -- settings needs to respect the animation you choose settings
                    search = {
                        enabled = true,
                        default_animation = "fade",

                        -- Keys to navigate to the next match
                        next_mapping = "nzzzv",

                        -- Keys to navigate to the previous match
                        prev_mapping = "Nzzzv",
                    },
                    paste = {
                        enabled = true,
                        default_animation = "fade",

                        -- Keys to paste
                        paste_mapping = "p",

                        -- Keys to paste above the cursor
                        Paste_mapping = "P",
                    },
                    undo = {
                        enabled = true,

                        default_animation = {
                            name = "fade",

                            settings = {
                                from_color = "DiffDelete",

                                max_duration = 500,
                                min_duration = 500,
                            },
                        },
                        undo_mapping = "u",
                    },
                    redo = {
                        enabled = true,

                        default_animation = {
                            name = "fade",

                            settings = {
                                from_color = "DiffAdd",

                                max_duration = 500,
                                min_duration = 500,
                            },
                        },

                        redo_mapping = "<c-r>",
                    },
                },
            })
        end
    }

    use {
        'RRethy/vim-illuminate',
        config = function()
            require('illuminate').configure({
                -- providers: provider used to get references in the buffer, ordered by priority
                providers = {
                    'lsp',
                    'treesitter',
                    'regex',
                },
                -- delay: delay in milliseconds
                delay = 100,
                -- filetype_overrides: filetype specific overrides.
                -- The keys are strings to represent the filetype while the values are tables that
                -- supports the same keys passed to .configure except for filetypes_denylist and filetypes_allowlist
                filetype_overrides = {},
                -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
                filetypes_denylist = {
                    'dirbuf',
                    'dirvish',
                    'fugitive',
                },
                -- filetypes_allowlist: filetypes to illuminate, this is overridden by filetypes_denylist
                -- You must set filetypes_denylist = {} to override the defaults to allow filetypes_allowlist to take effect
                filetypes_allowlist = {},
                -- modes_denylist: modes to not illuminate, this overrides modes_allowlist
                -- See `:help mode()` for possible values
                modes_denylist = {},
                -- modes_allowlist: modes to illuminate, this is overridden by modes_denylist
                -- See `:help mode()` for possible values
                modes_allowlist = {},
                -- providers_regex_syntax_denylist: syntax to not illuminate, this overrides providers_regex_syntax_allowlist
                -- Only applies to the 'regex' provider
                -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
                providers_regex_syntax_denylist = {},
                -- providers_regex_syntax_allowlist: syntax to illuminate, this is overridden by providers_regex_syntax_denylist
                -- Only applies to the 'regex' provider
                -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
                providers_regex_syntax_allowlist = {},
                -- under_cursor: whether or not to illuminate under the cursor
                under_cursor = true,
                -- large_file_cutoff: number of lines at which to use large_file_config
                -- The `under_cursor` option is disabled when this cutoff is hit
                large_file_cutoff = 100000,
                -- large_file_config: config to use for large files (based on large_file_cutoff).
                -- Supports the same keys passed to .configure
                -- If nil, vim-illuminate will be disabled for large files.
                large_file_overrides = nil,
                -- min_count_to_highlight: minimum number of matches required to perform highlighting
                min_count_to_highlight = 1,
                -- should_enable: a callback that overrides all other settings to
                -- enable/disable illumination. This will be called a lot so don't do
                -- anything expensive in it.
                should_enable = function(bufnr) return true end,
                -- case_insensitive_regex: sets regex case sensitivity
                case_insensitive_regex = false,
                -- disable_keymaps: disable default keymaps
                disable_keymaps = false,
            })
        end
    }

    -- slow :(
    --use({
    --    'mvllow/modes.nvim',
    --    tag = 'v0.2.0',
    --    config = function()
    --        require('modes').setup()
    --    end
    --})

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)
