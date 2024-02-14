local M = {}

local api = vim.api

local state = ""
local game_n = 1
local num_of_games = 10
local timer = 0

local games = {
    "- hjkl",
    "- relative",
    "- whack-a-mole",
    "- change-text",
    "- random"
}

local function string_trim(str)
    return str:match("^%s*(.-)%s*$")
end

function M.countdown(buf)
    local counter = 3
    while counter > 0 do
        api.nvim_buf_set_lines(buf, 0, -1, false, { "Game starts in " .. counter })
        counter = counter - 1
        vim.cmd("redraw")
        vim.wait(1000)
    end
end

function M.hjkl(buf)
    local buf_content = {
        "HJKL game [" .. game_n .. "/" .. num_of_games .. "]",
        "Use the 'hjkl' keys to move the cursor on the X character, them press `x` to delete it"
    }
    local banner_len = #buf_content
    local playground_size = 20
    for _ = 1, playground_size do
        table.insert(buf_content, string.rep(" ", playground_size))
    end
    api.nvim_buf_set_lines(buf, 0, -1, false, buf_content)
    local cursor_row = math.random(5 + banner_len, playground_size - 5)
    local cursor_col = math.random(5, playground_size - 5)
    local point_row = cursor_row + math.random(-5, 5)
    local point_col = cursor_col + math.random(-5, 5)
    -- FIXME: still can apear on each other
    while point_col + 1 == cursor_col and point_row + 1 == cursor_row do
        point_row = cursor_row + math.random(-5, 5)
        point_col = cursor_col + math.random(-5, 5)
    end
    api.nvim_win_set_cursor(0, { cursor_row, cursor_col })
    api.nvim_buf_set_text(buf, point_row, point_col, point_row, point_col, { "X" })
    game_n = game_n + 1
end

function M.relative(buf)
    local buf_content = {
        "Relative game [" .. game_n .. "/" .. num_of_games .. "]",
        "Use the <number>j/k to move to the 'DELETE ME' line and press 'VD' to delete it"
    }
    local banner_len = #buf_content
    local playground_size = 20
    for _ = 1, playground_size do
        table.insert(buf_content, string.rep(" ", playground_size))
    end
    api.nvim_buf_set_lines(buf, 0, -1, false, buf_content)
    local cursor_row = math.random(banner_len + 1, playground_size)
    local relative_row = math.random(banner_len + 1, playground_size)
    while relative_row + 1 == cursor_row do
        relative_row = math.random(1, playground_size)
    end
    api.nvim_win_set_cursor(0, { cursor_row, 0 })
    api.nvim_buf_set_text(buf, relative_row, 0, relative_row, 0, { "DELETE ME" })
    game_n = game_n + 1
end

local wam_expected_cursor_state = {}

function M.whack_a_mole(buf)
    local buf_content = {
        "Whack A Mole game [" .. game_n .. "/" .. num_of_games .. "]",
        "Move in whatever way is best for you, to the place marked by the `^` character and delete it by pressing `x`",
        ""
    }

    local texts = {
        "api.nvim_buf_set_text(buf, relative_row, 0, relative_row, 0, { \"DELETE ME\" })",
        "api.nvim_buf_set_text(buf, point_row, point_col, point_row, point_col, { \"X\" })",
        "CEO Of TheStartup, Porque Maria",
        "How far that little candle throws its beams! So shines a good deed in a naughty world",
        "Ambition should be made of sterner stuff",
        "To be, or not to be: that is the question",
        "I could have put lorem ipsum here but I didn't"
    }
    local random_text = texts[math.random(#texts)]
    table.insert(buf_content, random_text)

    local random_index = math.random(#random_text - 1)
    while string.sub(random_text, random_index, random_index) == " " do
        random_index = math.random(#random_text - 1)
    end
    table.insert(buf_content, string.rep(" ", random_index - 1) .. "^")

    wam_expected_cursor_state = { 4, random_index - 1, string.sub(random_text, random_index, random_index) }

    api.nvim_buf_set_lines(buf, 0, -1, false, buf_content)
    api.nvim_win_set_cursor(0, { 4, 0 })
    game_n = game_n + 1
end

function M.change_text(buf)
    local buf_content = {
        "Change Text game [" .. game_n .. "/" .. num_of_games .. "]",
        "Move to and replace the `CHANGE` string using `ciw` as fast as you can"
    }
    local banner_len = #buf_content
    local playground_size = 20
    for _ = 1, playground_size do
        table.insert(buf_content, string.rep(" ", playground_size))
    end
    api.nvim_buf_set_lines(buf, 0, -1, false, buf_content)
    local cursor_row = math.random(banner_len + 1, playground_size)
    local relative_row = math.random(banner_len + 1, playground_size)
    while relative_row + 1 == cursor_row do
        relative_row = math.random(1, playground_size)
    end
    api.nvim_win_set_cursor(0, { cursor_row, 0 })

    -- TODO: more texts
    local texts = {
        "let variable: u32 = CHANGE;",
        "let variable: CHANGE = 420;"
    }

    api.nvim_buf_set_text(buf, relative_row, 0, relative_row, 0, { texts[math.random(#texts)] })
    game_n = game_n + 1
end

function M.random(buf)
    local random_game = games[math.random(#games)]
    while random_game == "- random" do
        random_game = games[math.random(#games)]
    end
    if random_game == "- hjkl" then
        M.hjkl(buf)
    elseif random_game == "- relative" then
        M.relative(buf)
    elseif random_game == "- whack-a-mole" then
        M.whack_a_mole(buf)
    elseif random_game == "- change-text" then
        M.change_text(buf)
    end
end

function M.main_screen(buf, avg_time)
    state = ""
    local content = { "== VIM Motions Training ==",
        "Choose a game mode by deleting selected line.", "" }
    if avg_time ~= nil then
        -- TODO: show min/max as well
        table.insert(content, "[GAME RESULTS] AVG: " .. math.floor(avg_time * 100) / 100 .. "s")
        table.insert(content, "")
    end
    for _, game in ipairs(games) do
        table.insert(content, game)
    end
    api.nvim_buf_set_lines(buf, 0, -1, false, content)
end

local function do_tables_match(table1, table2)
    return table.concat(table1) == table.concat(table2)
end

function M.start()
    -- Create a new buffer
    local buf = api.nvim_create_buf(true, true)

    -- Change some buffer options
    api.nvim_buf_set_name(buf, "Training")
    api.nvim_buf_set_option(buf, "filetype", "training")

    -- Write the starting message
    M.main_screen(buf, nil)

    -- Switch to that new buffer
    api.nvim_set_current_buf(buf)

    api.nvim_win_set_cursor(0, { 4, 0 }) -- row 4, col 0

    local training_grp = api.nvim_create_augroup("TrainingGrp", { clear = true })
    api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            vim.defer_fn(function()
                -- When user copied something, this callback is called and we grab what the
                -- user copied and store it in this variable
                local user_choice = string_trim(vim.fn.getreg(vim.v.register))
                if state == "" then
                    if user_choice == "- hjkl" then
                        state = "hjkl"
                        M.countdown(buf)
                        timer = vim.loop.hrtime()
                        M.hjkl(buf)
                    elseif user_choice == "- relative" then
                        state = "relative"
                        M.countdown(buf)
                        timer = vim.loop.hrtime()
                        M.relative(buf)
                    elseif user_choice == "- whack-a-mole" then
                        state = "whack-a-mole"
                        M.countdown(buf)
                        timer = vim.loop.hrtime()
                        M.whack_a_mole(buf)
                    elseif user_choice == "- change-text" then
                        state = "change-text"
                        M.countdown(buf)
                        timer = vim.loop.hrtime()
                        M.change_text(buf)
                    elseif user_choice == "- random" then
                        state = "random"
                        M.countdown(buf)
                        timer = vim.loop.hrtime()
                        M.random(buf)
                    end
                else
                    if game_n == num_of_games then
                        game_n = 1
                        local avg_time = ((vim.loop.hrtime() - timer) / 1e9) / num_of_games
                        M.main_screen(buf, avg_time)
                        return
                    end
                    if state == "hjkl" or state == "random" then
                        if user_choice == "X" then
                            if state == "random" then
                                M.random(buf)
                                return
                            end
                            M.hjkl(buf)
                        end
                    end
                    if state == "relative" or state == "random" then
                        if user_choice == "DELETE ME" then
                            if state == "random" then
                                M.random(buf)
                                return
                            end
                            M.relative(buf)
                        end
                    end
                    if state == "whack-a-mole" or state == "random" then
                        local cursor = api.nvim_win_get_cursor(0)
                        local cursor_state = { cursor[1], cursor[2], user_choice }
                        if do_tables_match(cursor_state, wam_expected_cursor_state) then
                            if state == "random" then
                                M.random(buf)
                                return
                            end
                            M.whack_a_mole(buf)
                        end
                    end
                    if state == "change-text" or state == "random" then
                        if user_choice == "CHANGE" then
                            if state == "random" then
                                M.random(buf)
                                return
                            end
                            M.change_text(buf)
                        end
                    end
                end
            end, 0)
        end,
        group = training_grp
    })
end

function M.setup(opts)
    opts = opts or {}

    api.nvim_create_user_command("Training", function()
        M.start()
    end, {})
end

return M
