 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#000000',
    base01 = '#131414',
    base02 = '#1e1e1e',
    base03 = '#8c9292',
    base04 = '#c2c7c8',
    base05 = '#e4e2e2',
    base06 = '#e4e2e2',
    base07 = '#e4e2e2',
    base08 = '#ffb4ab',
    base09 = '#cdc3d4',
    base0A = '#c2c7c8',
    base0B = '#b9cacc',
    base0C = '#cdc3d4',
    base0D = '#b9cacc',
    base0E = '#c2c7c8',
    base0F = '#dee3e4',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e4e2e2',          bg = '#000000' })
  hi('TelescopeBorder',         { fg = '#8c9292',             bg = '#000000' })
  hi('TelescopePromptNormal',   { fg = '#e4e2e2',          bg = '#000000' })
  hi('TelescopePromptBorder',   { fg = '#8c9292',             bg = '#000000' })
  hi('TelescopePromptPrefix',   { fg = '#b9cacc',             bg = '#000000' })
  hi('TelescopePromptCounter',  { fg = '#c2c7c8',  bg = '#000000' })
  hi('TelescopePromptTitle',    { fg = '#000000',             bg = '#b9cacc' })
  hi('TelescopePreviewTitle',   { fg = '#000000',             bg = '#c2c7c8' })
  hi('TelescopeResultsTitle',   { fg = '#000000',             bg = '#cdc3d4' })
  hi('TelescopeSelection',      { fg = '#e4e2e2',          bg = '#1e1e1e' })
  hi('TelescopeSelectionCaret', { fg = '#b9cacc',             bg = '#1e1e1e' })
  hi('TelescopeMatching',       { fg = '#b9cacc',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e4e2e2',          bg = '#000000' })
  hi('MiniPickBorder',         { fg = '#8c9292',             bg = '#000000' })
  hi('MiniPickPrompt',   { fg = '#e4e2e2',          bg = '#000000' })
  hi('MiniPickPromptPrefix',   { fg = '#b9cacc',             bg = '#000000' })
  hi('MiniPickBorderText',    { fg = '#000000',             bg = '#b9cacc' })
  hi('MiniPickMatchCurrent',      { fg = '#e4e2e2',          bg = '#1e1e1e' })
  hi('MiniPickPromptCaret', { fg = '#b9cacc',             bg = '#1e1e1e' })
  hi('MiniPickMatchRanges',       { fg = '#b9cacc',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
