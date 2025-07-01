local M = {}

-- State variables
local terminal_bufnr = nil
local terminal_win_id = nil
local last_win_id = nil
local terminal_height = 15

function M.toggle_terminal()
  local current_win = vim.api.nvim_get_current_win()

  if terminal_bufnr and terminal_win_id and vim.api.nvim_win_is_valid(terminal_win_id) then
    last_win_id = current_win

    vim.api.nvim_win_close(terminal_win_id, false)
    terminal_win_id = nil

    if last_win_id and vim.api.nvim_win_is_valid(last_win_id) then
      vim.api.nvim_set_current_win(last_win_id)
    end
    return
  end

  last_win_id = current_win

  if not terminal_bufnr or not vim.api.nvim_buf_is_valid(terminal_bufnr) then
    vim.cmd("botright new")
    vim.cmd("resize " .. terminal_height)

    vim.cmd("term")

    terminal_bufnr = vim.api.nvim_get_current_buf()

    vim.api.nvim_set_option_value("buflisted", false, { buf = terminal_bufnr })
    vim.api.nvim_set_option_value("filetype", "terminal", { buf = terminal_bufnr })
  else
    vim.cmd("botright new")
    vim.cmd("resize " .. terminal_height)
    vim.api.nvim_win_set_buf(0, terminal_bufnr)
  end

  terminal_win_id = vim.api.nvim_get_current_win()

  vim.cmd("startinsert")
end

function M.setup(opts)
  opts = opts or {}
  local key = opts.key or "<leader>t"

  vim.keymap.set("n", key, M.toggle_terminal, { noremap = true, silent = true })
end

return M
