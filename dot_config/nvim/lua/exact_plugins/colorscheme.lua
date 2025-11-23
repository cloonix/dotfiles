-- GitHub Nvim Theme configuration
-- Provides a clean, modern dark theme based on GitHub's visual language
-- Using github_dark_dimmed variant for reduced eye strain and better contrast

return {
  -- GitHub-themed colorscheme with multiple variants (dark, dark_dimmed, light, etc.)
  {
    "projekt0n/github-nvim-theme",
    lazy = false, -- load immediately (colorscheme must be available at startup)
    priority = 1000, -- ensure it loads before all other plugins
    config = function()
      require('github-theme').setup({
        -- Additional configuration options can be added here if needed
        -- See https://github.com/projekt0n/github-nvim-theme for available options
      })
    end,
  },

  -- Configure LazyVim to use github_dark_dimmed as the default colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "github_dark_dimmed",
    },
  },
}
