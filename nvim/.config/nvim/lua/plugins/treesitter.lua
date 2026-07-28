return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  dependencies = { "williamboman/mason.nvim" },
  config = function()
    local ensure = { "lua", "javascript", "astro", "css" }

    local function install_parsers()
      require("nvim-treesitter").install(ensure)
    end

    local ok, registry = pcall(require, "mason-registry")
    if ok then
      registry.refresh(function()
        local ok_pkg, pkg = pcall(registry.get_package, "tree-sitter-cli")
        if ok_pkg and pkg and not pkg:is_installed() then
          pkg:on("install:success", vim.schedule_wrap(install_parsers))
          pkg:install()
        else
          vim.schedule(install_parsers)
        end
      end)
    else
      install_parsers()
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = ensure,
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
