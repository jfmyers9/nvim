local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
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
vim.o.ignorecase = true
vim.o.smartcase = true
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
      -- vim.cmd([[colorscheme tokyonight-day]])
    end,
  },
  { 'williamboman/mason.nvim', config = true },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      require('mason-lspconfig').setup({
        automatic_installation = true,
        ensure_installed = {
          "buf_ls",
          "dockerls",
          "gopls",
          "graphql",
          "lua_ls",
          "tflint",
          "vtsls",
          "yamlls",
        },
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Default config for all servers
      vim.lsp.config('*', {
        capabilities = capabilities,
      })

      -- Server-specific configs
      vim.lsp.config('lua_ls', {
        settings = { Lua = { diagnostics = { globals = { 'vim' } } } },
      })

      vim.lsp.config('gopls', {
        settings = {
          gopls = {
            buildFlags = { '-mod=readonly' },
          },
        },
      })

      vim.lsp.config('vtsls', {
        settings = {
          typescript = {
            preferGoToSourceDefinition = true,
            tsserver = {
              maxTsServerMemory = 16384,
            }
          },
          javascript = {
            preferGoToSourceDefinition = true,
          },
        },
      })

      -- Enable all installed servers
      vim.lsp.enable(require('mason-lspconfig').get_installed_servers())
    end,
  },
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
  {
    'nvimtools/none-ls.nvim',
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.goimports,
        },
      })
    end,
  },
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
    config = function()
      require('fzf-lua').setup {
        keymap = {
          fzf = {
            ["ctrl-q"] = "select-all+accept",
          },
        },
      }
    end,
  },
  { 'kevinhwang91/nvim-bqf', ft = 'qf' },
  { 'windwp/nvim-autopairs', config = true },
  { 'nvim-lua/plenary.nvim' },
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require('harpoon')
      harpoon:setup()

      -- Toggle harpoon (add if not present, remove if present)
      vim.keymap.set('n', '<leader>a', function()
        local list = harpoon:list()
        local current = vim.fn.expand('%:.')
        -- Find if current file is in list
        local found_idx = nil
        for i = 1, list:length() do
          local item = list:get(i)
          if item and item.value == current then
            found_idx = i
            break
          end
        end
        if found_idx then
          list:remove_at(found_idx)
          vim.notify('Removed from harpoon: ' .. current, vim.log.levels.INFO)
        else
          list:add()
          vim.notify('Added to harpoon: ' .. current, vim.log.levels.INFO)
        end
      end, { desc = 'Toggle harpoon mark' })

      vim.keymap.set('n', '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

      -- Navigate to specific marks
      vim.keymap.set('n', '<C-h>', function() harpoon:list():select(1) end)
      vim.keymap.set('n', '<C-t>', function() harpoon:list():select(2) end)
      vim.keymap.set('n', '<C-n>', function() harpoon:list():select(3) end)
      vim.keymap.set('n', '<C-s>', function() harpoon:list():select(4) end)
    end,
  },
  { 'hrsh7th/vim-vsnip' },
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
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
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
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
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
          { name = "vsnip" },
          { name = "buffer" },
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
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, opts)
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local buffer = args.buf
    vim.bo[buffer].omnifunc = 'v:lua.vim.lsp.omnifunc'

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

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.supports_method("textDocument/formatting") then
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

-- Context collection utilities
local function format_as_context(paths)
  local formatted = {}
  for _, path in ipairs(paths) do
    local relative = vim.fn.fnamemodify(path, ':.')
    table.insert(formatted, '@' .. relative)
  end
  return formatted
end

local function copy_context(paths, source_name)
  if #paths > 0 then
    local context = table.concat(format_as_context(paths), ' ')
    vim.fn.setreg('+', context)
    vim.notify('Copied ' .. #paths .. ' files from ' .. source_name .. ' to clipboard')
  else
    vim.notify('No files to copy from ' .. source_name)
  end
end

-- Get all harpoon items as paths
local function get_harpoon_paths()
  local harpoon = require('harpoon')
  local paths = {}
  local list = harpoon:list()
  for i = 1, list:length() do
    local item = list:get(i)
    if item and item.value then
      table.insert(paths, item.value)
    end
  end
  return paths
end

-- Get all visible split buffers as paths
local function get_split_paths()
  local paths = {}
  local seen = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if name ~= '' and not seen[name] then
      seen[name] = true
      table.insert(paths, name)
    end
  end
  return paths
end

-- <leader>bc: Copy all harpoon files
vim.keymap.set('n', '<leader>bc', function()
  copy_context(get_harpoon_paths(), 'harpoon')
end, { desc = 'Copy harpoon context to clipboard' })

-- <leader>bs: Copy all visible splits
vim.keymap.set('n', '<leader>bs', function()
  copy_context(get_split_paths(), 'splits')
end, { desc = 'Copy split context to clipboard' })

-- <leader>bp: Pick subset from harpoon via fzf
vim.keymap.set('n', '<leader>bp', function()
  local paths = get_harpoon_paths()
  if #paths == 0 then
    vim.notify('No files in harpoon list')
    return
  end

  require('fzf-lua').fzf_exec(paths, {
    prompt = 'Harpoon> ',
    actions = {
      ['default'] = function(selected)
        copy_context(selected, 'harpoon selection')
      end,
    },
    fzf_opts = {
      ['--multi'] = true,
    },
  })
end, { desc = 'Pick harpoon files to copy as context' })

-- <leader>bl: Copy visual selection as context with line numbers
vim.keymap.set('v', '<leader>bl', function()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local relative_path = vim.fn.expand('%:.')
  local context = '@' .. relative_path .. '#' .. start_line .. '-' .. end_line
  vim.fn.setreg('+', context)
  vim.notify('Copied: ' .. context)
end, { desc = 'Copy selection as context with line numbers' })
