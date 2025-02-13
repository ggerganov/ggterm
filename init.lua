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
