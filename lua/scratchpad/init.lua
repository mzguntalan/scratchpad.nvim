local M = {}

-- Default configuration
M.config = {
    keymap = {
        toggle = '<C-S-p>',
        done_undone = '<C-S-o>',
    },
    width = 0.5,  -- 50% of screen width
    height = 0.7, -- 70% of screen height
    file_path = '.scratchpad.md'
}

local scratchpad_buf = nil
local scratchpad_win = nil

local function create_scratchpad_buffer()
    if scratchpad_buf == nil or not vim.api.nvim_buf_is_valid(scratchpad_buf) then
        scratchpad_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(scratchpad_buf, 'buftype', 'acwrite')
        vim.api.nvim_buf_set_option(scratchpad_buf, 'filetype', 'markdown')
        vim.api.nvim_buf_set_name(scratchpad_buf, M.config.file_path)
    end
    return scratchpad_buf
end

local function open_scratchpad()
    local buf = create_scratchpad_buffer()
    local width = math.floor(vim.o.columns * M.config.width)
    local height = math.floor(vim.o.lines * M.config.height)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded'
    }
    
    scratchpad_win = vim.api.nvim_open_win(buf, true, opts)
    
    if vim.fn.filereadable(M.config.file_path) == 1 then
        local lines = vim.fn.readfile(M.config.file_path)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end
end

local function close_scratchpad()
    if scratchpad_win and vim.api.nvim_win_is_valid(scratchpad_win) then
        local lines = vim.api.nvim_buf_get_lines(scratchpad_buf, 0, -1, false)
        vim.fn.writefile(lines, M.config.file_path)
        vim.api.nvim_win_close(scratchpad_win, true)
        scratchpad_win = nil
    end
end

function M.toggle_scratchpad()
    if scratchpad_win and vim.api.nvim_win_is_valid(scratchpad_win) then
        close_scratchpad()
    else
        if vim.fn.filereadable(M.config.file_path) == 0 then
            local choice = vim.fn.input(M.config.file_path .. " does not exist yet. Track your imagination by creating it [y/n]? ")
            if choice:lower() ~= 'y' then
                print("\nScratchpad creation cancelled.")
                return
            end
        end
        open_scratchpad()
    end
end

function M.toggle_checkbox()
    if not (scratchpad_win and vim.api.nvim_win_is_valid(scratchpad_win)) then return end

    local line = vim.api.nvim_get_current_line()
    local pattern = "^(%s*%- %[)([xX ]?)(%])(.*)$"
    local g1, g2, g3, g4 = line:match(pattern)

    if g1 == nil and g3 == nil then
        return
    end
    g2 = g2 == nil and '' or g2
    g4 = g4 == nil and '' or g4
    if g1 and g2 and g3 and g4 then
        local new_g2 = (g2 == "" or g2 == " ") and "X" or " "
        local new_line = g1 .. new_g2 .. g3 .. g4
        vim.api.nvim_set_current_line(new_line)
    end
end

M.setup = function(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})
    vim.keymap.set('n', M.config.keymap.toggle, M.toggle_scratchpad, { noremap = true, silent = true })
    vim.keymap.set('n', M.config.keymap.done_undone, M.toggle_checkbox, { noremap = true, silent = true })
end

return M
