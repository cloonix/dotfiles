return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    -- load on demand
    lazy = true,
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    keys = {
        { "<leader>gh", "<cmd>CopilotChat<cr>", desc = "LazyGit" }
    }    -- See Commands section for default commands if you want to lazy load on them
  },
}
