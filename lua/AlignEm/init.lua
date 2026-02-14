local M = {}


local szNameSpace  = "AlignEm"
local iNameSpaceID = vim.api.nvim_create_namespace(szNameSpace)
local szUserCmd    = ""
local bSimulating  = false

local cursorTable  = {}


--/////////////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////////////
local RedrawExtMarks = function()

    -- Do we have valid cursors or valid user cmd?
    if #cursorTable <= 0 then
        return
    end

    -- Remove old cursors.
    vim.api.nvim_buf_clear_namespace(0, iNameSpaceID, 0, -1)

    for i = 2, #cursorTable do
        vim.api.nvim_buf_set_extmark(0, iNameSpaceID, cursorTable[i][1] - 1, cursorTable[i][2], {
            virt_text = {{" ", "Cursor"}},
            virt_text_pos = "overlay",}
        )
    end

end


--/////////////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////////////
local HandleCmd = function()

    -- Prevent infinite loop
    if bSimulating == true then
        return
    end

    -- Do we have valid cursors or valid user cmd?
    if #cursorTable <= 0 or szUserCmd == "" then
        return
    end

    -- Make sure we are in correct mode.
    if vim.api.nvim_get_mode().mode ~= 'n' then
        return
    end

    bSimulating = true

    -- original row & col
    local iOriginalPos = vim.api.nvim_win_get_cursor(0)

    -- iterate over each fake cursor. simulate & set its position.
    for i = 1, #cursorTable do -- @ index 1 is the original cursor itself.

        vim.api.nvim_win_set_cursor(0, cursorTable[i])

        -- Simulate...
        vim.cmd("normal! " .. szUserCmd)

        cursorTable[i] = vim.api.nvim_win_get_cursor(0)
    end

    -- Refresh / Redraw ExtMarks
    RedrawExtMarks()

    -- Restore orignial pos of the cursor
    vim.api.nvim_win_set_cursor(0, iOriginalPos)

    print(string.format("Executing command : %s over %d cursors", szUserCmd, #cursorTable))

    -- Reset usercommand after simulating it.
    szUserCmd   = ""
    bSimulating = false
end


--/////////////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////////////
M.AlignAllCursors = function()

    if bSimulating == true then
        return
    end

    if #cursorTable <= 0 then
        return
    end

    -- Only ever align in normal mode.
    if vim.api.nvim_get_mode().mode ~= 'n' then
        return
    end


    bSimulating = true

    -- Finding target coloum
    local iTargetCol = 0
    for i = 1, #cursorTable do
        local iCol = cursorTable[i][2]

        if iCol > iTargetCol then
            iTargetCol = iCol
        end
    end


    -- Setting all cursors to target col
    for i = 1, #cursorTable do

        -- set real cursor @ this cursor's position
        vim.api.nvim_win_set_cursor(0, cursorTable[i])

        local spaceCount = iTargetCol - cursorTable[i][2]

        if spaceCount > 0 then
            local iRow0 = cursorTable[i][1] - 1
            local iCol  = cursorTable[i][2]
            vim.api.nvim_buf_set_text(0, iRow0, iCol, iRow0, iCol, {string.rep(' ', spaceCount)})
        end

        cursorTable[i] = vim.api.nvim_win_get_cursor(0)
    end

    -- set real cursor pos to original ( + space adjusted )
    vim.api.nvim_win_set_cursor(0, cursorTable[1])

    -- Redraw all cursors.
    RedrawExtMarks()

    bSimulating = false
    szUserCmd   = ""
end


--/////////////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////////////
M.RemoveAllCursors = function()
    vim.api.nvim_buf_clear_namespace(0, iNameSpaceID, 0, -1)

    -- Clear cursor table.
    print(string.format("Removed %d cursors", #cursorTable))
    cursorTable = {}
end


--/////////////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////////////
local IsLineEmpty = function(iRowOneBased)
    local szLine = vim.api.nvim_buf_get_lines(0, iRowOneBased - 1, iRowOneBased, false)[1]

    -- BS line is emtpy line :)
    if szLine == false then
        return true
    end

    return szLine:find("%S") == nil
end


--/////////////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////////////
M.AddCursor = function()

    -- Must be in normal mode.
    if vim.api.nvim_get_mode().mode ~= 'n' then
        print("Must be in normal mode to AlignEm plugin")
    end


    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Adding the original cursor as the first value.
    if #cursorTable <= 0 then
        cursorTable[1] = {row, col}
    end

    -- Make sure have enough rows to add one more cursor.
    local iMaxRows        = vim.api.nvim_buf_line_count(0)
    local iNewCursorIndex = cursorTable[#cursorTable][1] + 1 -- points at line next to last cursor, according to 1-based index
    for iLineIndex = iNewCursorIndex, iMaxRows + 1 do

        if iNewCursorIndex > iMaxRows then
            return
        end

        if IsLineEmpty(iLineIndex) == false then
            iNewCursorIndex = iLineIndex
            break
        end
    end

    -- clamp the coloum to whatever the target line has. { (-1) to make 0-based }
    local szLine      = vim.api.nvim_buf_get_lines(0, iNewCursorIndex - 1, iNewCursorIndex + 1, false)[1]
    local iColClamped = col
    if col > #szLine then
        iColClamped = #szLine
    end

    -- (-1) to make 0-based
    vim.api.nvim_buf_set_extmark(0, iNameSpaceID, iNewCursorIndex - 1, iColClamped, {
        virt_text     = {{" ", "Cursor"}},
        virt_text_pos = "overlay",}
    )

    cursorTable[#cursorTable+1] = {iNewCursorIndex, col}
    print(string.format("New cursor @ row : %d, col : %d", cursorTable[#cursorTable][1], cursorTable[#cursorTable][2]))
    szUserCmd = ""
end


--/////////////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////////////
M.setup = function()

    -- Record all inputs if in normal mode.
    vim.on_key(function(key)

        -- must be in normal mode.
        if vim.api.nvim_get_mode().mode ~= 'n' then
            return
        end

        if bSimulating == false and #cursorTable > 0 then
            szUserCmd = szUserCmd .. key
        end

    end, iNameSpaceID)


    -- If some key sequence moved our cursor & we have fake cursors, move all fake cursors.
    vim.api.nvim_create_autocmd("CursorMoved", {callback = HandleCmd})

end


return M
