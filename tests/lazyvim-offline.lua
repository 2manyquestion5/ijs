-- PURPOSE: Exercise the actual wrapped LazyVim with no pre-existing user data.
-- CONSUMER: The lazyvim-offline Nix check, including intentional negative cases.
-- CUSTOMIZATION: Test the declared editor, completion and theme; not unrelated LSP servers.
-- SECURITY: Network attempts are rejected by a test-only Git guard; no real home is activated.
local function check()
  assert(vim.v.errmsg == "", vim.v.errmsg)
  local config = require("lazy.core.config")
  local plugins = config.plugins
  local mode = vim.env.IJS_TEST_MODE

  -- Corrupt the resolved graph to prove the assertions reject incomplete packages.
  if mode == "missing" then
    plugins["friendly-snippets"].dir = "/nonexistent-ijs-plugin"
  elseif mode == "misnamed" then
    plugins.nvim = plugins.catppuccin
    plugins.catppuccin = nil
  elseif mode == "network" then
    vim.fn.system({ "git", "clone", "https://example.invalid/plugin.git" })
    vim.fn.system({ "git", "fetch", "https://example.invalid/plugin.git" })
  end

  local function require_ok(condition, message)
    local prefix = (mode == "good" or mode == "existing") and "" or "IJS_REGRESSION: " .. mode .. ": "
    assert(condition, prefix .. message)
  end
  require_ok(vim.fn.filereadable(vim.env.IJS_NETWORK_ATTEMPTS) == 0, "network installer attempted")
  require_ok(config.options.install.missing == false, "automatic installation enabled")
  require_ok(config.options.checker.enabled == false, "automatic fetching enabled")
  require_ok(config.options.rocks.enabled == false, "Lua-rock installation enabled")
  require_ok(vim.g.mapleader == " ", "LazyVim leader changed")
  for _, extra in ipairs({ "lazyvim.plugins.extras.lang.nix", "lazyvim.plugins.extras.lang.python" }) do
    require_ok(vim.tbl_contains(config.spec.modules, extra), "language extra missing: " .. extra)
  end
  for _, name in ipairs({ "LazyVim", "lazy.nvim", "blink.cmp", "friendly-snippets", "catppuccin" }) do
    require_ok(plugins[name] ~= nil, "missing plugin identity: " .. name)
  end
  require_ok(plugins.nvim == nil, "incorrect Catppuccin identity nvim")
  for name, plugin in pairs(plugins) do
    local path = vim.uv.fs_realpath(plugin.dir)
    require_ok(path ~= nil and path:match("^/nix/store/") ~= nil, "missing/store-external plugin: " .. name)
    require_ok(plugin._.installed, "uninstalled plugin: " .. name)
  end
  for _, notification in ipairs(config.spec.notifs) do
    require_ok(notification.level < vim.log.levels.ERROR, notification.msg)
  end

  require("lazy").load({ plugins = { "blink.cmp", "friendly-snippets", "catppuccin" } })
  local blink_opts = require("lazy.core.plugin").values(plugins["blink.cmp"], "opts", false)
  require_ok(blink_opts.fuzzy.prebuilt_binaries.download == false, "Blink binary downloads enabled")
  require_ok(vim.wait(5000, function()
    return package.loaded["blink.cmp.fuzzy.rust"] ~= nil
  end, 20), "Blink's packaged native backend did not load")
  require_ok(vim.fn.filereadable(plugins["friendly-snippets"].dir .. "/package.json") == 1, "snippet package absent")
  local opts = require("lazy.core.plugin").values(plugins.catppuccin, "opts", false)
  require_ok(opts.flavour == "mocha", "theme flavour changed")
  vim.cmd.colorscheme("catppuccin")
  require_ok((vim.g.colors_name or ""):match("^catppuccin") ~= nil, "theme could not load")
  require_ok(vim.v.errmsg == "", vim.v.errmsg)
  require_ok(vim.fn.filereadable(vim.env.IJS_NETWORK_ATTEMPTS) == 0, "network installer attempted")
  if mode == "existing" then
    local note = vim.fn.readfile(vim.fn.stdpath("config") .. "/user-note.txt")[1]
    local state = vim.fn.readfile(vim.fn.stdpath("data") .. "/user-state.txt")[1]
    require_ok(note == "keep user configuration", "user configuration changed")
    require_ok(state == "keep user state", "user state changed")
    local legacy = vim.uv.fs_lstat(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")
    require_ok(legacy and legacy.type == "link", "legacy bootstrap link changed")
  end
end

local ok, error_message = xpcall(check, debug.traceback)
if not ok then
  io.stderr:write(tostring(error_message) .. "\n")
  vim.cmd("cquit 1")
else
  print("PASS: " .. vim.env.IJS_TEST_MODE .. " LazyVim startup, Nix paths, completion, snippets and theme")
  vim.cmd("qa!")
end
