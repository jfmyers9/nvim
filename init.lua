local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.o.autoread = true
vim.o.autowriteall = true
vim.o.expandtab = true
vim.o.grepformat = "%f:%l:%c:%m,%f:%l:%m"
vim.o.grepprg = "rg --vimgrep --no-heading --smart-case"
vim.o.hidden = true
vim.o.ignorecase = true
vim.o.linespace = -1
vim.o.mouse = 'a'
vim.o.number = true
vim.o.scrolloff = 4
vim.o.shiftwidth = 2
vim.o.showmatch = true
vim.o.signcolumn = 'yes'
vim.o.softtabstop = 2
vim.o.splitright = true
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.wrap = false

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set("v", "Y", '"+y')

require('lazy').setup({
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-storm]])
    end,
  },
  { 'williamboman/mason.nvim', config = true },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup({
        automatic_installation = true,
        ensure_installed = {
          "bufls",
          "dockerls",
          "gopls",
          "graphql",
          "lua_ls",
          "tflint",
          "yamlls",
        },
      })
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require('mason-lspconfig').setup_handlers {
        function(server_name)
          require('lspconfig')[server_name].setup {
            capabilities = capabilities,
          }
        end,
        ["lua_ls"] = function()
          require('lspconfig').lua_ls.setup {
            settings = { Lua = { diagnostics = { globals = { 'vim' } } } },
            capabilities = capabilities,
          }
        end,
        ["kotlin_language_server"] = function()
          local root_files = {
            'settings.gradle',     -- Gradle (multi-project)
            'settings.gradle.kts', -- Gradle (multi-project)
            'build.xml',           -- Ant
            'pom.xml',             -- Maven
            'build.gradle',        -- Gradle
            'build.gradle.kts',    -- Gradle
            'maven_install.json',
          }
          local util = require 'lspconfig.util'
          require('lspconfig').kotlin_language_server.setup {
            capabilities = capabilities,
            root_dir = util.root_pattern(unpack(root_files))
          }
        end,
      }
    end,
  },
  { 'neovim/nvim-lspconfig' },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'go', 'lua', 'vim' },
        auto_install = true,
        highlight = {
          enable = true,
        },
      }
    end,
  },
  { 'tpope/vim-abolish' },
  { 'tpope/vim-commentary' },
  { 'tpope/vim-eunuch' },
  { 'tpope/vim-fugitive' },
  { 'tpope/vim-repeat' },
  { 'tpope/vim-rhubarb' },
  { 'tpope/vim-surround' },
  { 'tpope/vim-vinegar' },
  { 'jose-elias-alvarez/null-ls.nvim' },
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<C-p>',      '<cmd>lua require("fzf-lua").files()<CR>',            { silent = true, noremap = true } },
      { '<Leader>sg', '<cmd>lua require("fzf-lua").live_grep_native()<CR>', { silent = true, noremap = true } },
      { '<Leader>sf', '<cmd>lua require("fzf-lua").files()<CR>',            { silent = true, noremap = true } },
      { '<Leader>sl', '<cmd>lua require("fzf-lua").lines()<CR>',            { silent = true, noremap = true } },
      { '<Leader>sc', '<cmd>lua require("fzf-lua").git_commits()<CR>',      { silent = true, noremap = true } },
    },
  },
  { 'kevinhwang91/nvim-bqf', ft = 'qf' },
  { 'windwp/nvim-autopairs', config = true },
  { 'nvim-lua/plenary.nvim' },
  { 'github/copilot.vim' },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.jumpable(1) then
              luasnip.jump(1)
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif luasnip.expandable() then
              luasnip.expand()
            elseif check_backspace() then
              fallback()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "tmux" },
        }),
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end
  },
})

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local buffer = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)


    vim.api.nvim_buf_set_option(buffer, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local bufopts = { noremap = true, silent = true, buffer = buffer }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)

    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds { buffer = buffer }
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = buffer,
        callback = function()
          vim.lsp.buf.format { timeout_ms = 5000 }
        end,
      })
    end
  end,
})

require('fzf-lua').setup {
  keymap = {
    fzf = {
      ["ctrl-q"] = "select-all+accept",
    },
  },
}

local null_ls = require("null-ls")

local sources = {
  null_ls.builtins.formatting.goimports,
}

null_ls.setup({
  sources = sources,
})
