local M = {}

vim.g.format_on_save = true -- global switch

-- Prefer none-ls (prettier, stylua, ...) when it can format this buffer,
-- otherwise fall back to whichever LSP server can.
local function pick_client(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local fallback
  for _, client in ipairs(clients) do
    if client:supports_method("textDocument/formatting", bufnr) then
      if client.name == "null-ls" then
        return client
      end
      fallback = fallback or client
    end
  end
  return fallback
end

function M.format(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local client = pick_client(bufnr)
  if not client then
    return
  end
  vim.lsp.buf.format({
    bufnr = bufnr,
    timeout_ms = 2000,
    filter = function(c)
      return c.id == client.id
    end,
  })
end

local function enabled(bufnr)
  -- a buffer-local setting wins over the global one
  local b = vim.b[bufnr].format_on_save
  if b ~= nil then
    return b
  end
  return vim.g.format_on_save
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true }),
  callback = function(args)
    if enabled(args.buf) then
      M.format(args.buf)
    end
  end,
})

-- Toggle for every buffer
vim.keymap.set("n", "<leader>tf", function()
  vim.g.format_on_save = not vim.g.format_on_save
  vim.notify("Format on save (global): " .. (vim.g.format_on_save and "ON" or "OFF"))
end, { desc = "Toggle format on save (global)" })

-- Toggle for the current buffer only
vim.keymap.set("n", "<leader>tF", function()
  local current = enabled(0)
  vim.b.format_on_save = not current
  vim.notify("Format on save (buffer): " .. (vim.b.format_on_save and "ON" or "OFF"))
end, { desc = "Toggle format on save (buffer)" })

return M
