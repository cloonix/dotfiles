-- Linting configuration using nvim-lint
-- Provides real-time error checking and linting for various file types

local HOME = os.getenv("HOME")
return {
  "mfussenegger/nvim-lint",
  optional = true, -- allows LazyVim to skip if not needed
  opts = {
    linters = {
      -- Configure markdownlint-cli2 to use custom config from home directory
      -- This ensures consistent markdown formatting rules across the project
      ["markdownlint-cli2"] = {
        args = { "--config", HOME .. "/.markdownlint-cli2.yaml", "--" },
      },
    },
  },
}
