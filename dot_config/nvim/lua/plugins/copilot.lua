return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>",
          },
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4,
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-n>",
            prev = "<M-p>",
            dismiss = "<C-c>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = "node", -- Node.js version must be > 18.x
        server_opts_overrides = {},
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      debug = true, -- Enable debugging
      show_folds = false,
      show_line_numbers = false,
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")

      -- Setup CopilotChat
      chat.setup(opts)

      -- Setup which-key group
      local wk = require("which-key")
      wk.add({
        { "<leader>C", icon = { icon = "\u{e709}", hl = "" }, group = "Copilot" },
      })

      -- Key mappings
      vim.keymap.set({ "n", "v" }, "<leader>Cc", ":CopilotChat ", { desc = "Open chat" })
      vim.keymap.set({ "n", "v" }, "<leader>Ce", "<cmd>CopilotChatExplain<cr>", { desc = "Explain code" })
      vim.keymap.set({ "n", "v" }, "<leader>Ct", "<cmd>CopilotChatTests<cr>", { desc = "Generate tests" })
      vim.keymap.set({ "n", "v" }, "<leader>Cr", "<cmd>CopilotChatReview<cr>", { desc = "Review code" })
      vim.keymap.set({ "n", "v" }, "<leader>Cf", "<cmd>CopilotChatFixDiagnostic<cr>", { desc = "Fix diagnostic" })
      vim.keymap.set({ "n", "v" }, "<leader>Co", "<cmd>CopilotChatOptimize<cr>", { desc = "Optimize code" })
      vim.keymap.set({ "n", "v" }, "<leader>Cd", "<cmd>CopilotChatDocs<cr>", { desc = "Generate docs" })
    end,
  },
}
