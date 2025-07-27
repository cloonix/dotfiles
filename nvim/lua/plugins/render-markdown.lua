return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    name = "render-markdown",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" }
    },
    config = function()
      require("render-markdown").setup({})
    end,
    ft = { "markdown" }
  }
}
