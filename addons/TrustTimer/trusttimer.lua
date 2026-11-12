_addon.name = 'TrustTimer'
_addon.author = 'A'
_addon.version = '0.1.0-test1'
_addon.commands = {'tt', 'trusttimer'}

require('chat') -- Adds string.color for Windower chat help.
local config = require('config')
local texts = require('texts')
local packets = require('packets')

local resolution = windower.get_windower_settings()
local default_x = math.max(30, math.floor(resolution.ui_x_res * 0.5 - 115))
local default_y = math.max(30, math.floor(resolution.ui_y_res * 0.15))
local defaults = {
    enabled = true,
    duration = 120,
    debug = false,
    hud = {
        pos = {x = default_x, y = default_y},
        text = {
            font = 'Arial', size = 14, red = 235, green = 237, blue = 241, alpha = 255,
            stroke = {width = 2, alpha = 190, red = 35, green = 35, blue = 35},
        },
        flags = {bold = true, italic = true, draggable = false},
        bg = {visible = false},
    },
}
local settings = config.load(defaults)

-- Never inherit a saved edit-mode drag flag after a reload.
settings.hud.flags.draggable = false
local hud = texts.new('', settings.hud, settings)
hud:hide()

local state = {
    roster = nil,
    pending_invite = nil,
    expires_at = nil,
    ready_until = nil,
    demo_until = nil,
    demo_ready_until = nil,
    editing = false,
    last_tick = nil,
    last_text = nil,
    last_color = nil,
    last_alpha = nil,
    last_visible = false,
}

local function message(body, color)
    windower.add_to_chat(0, string.color('[TrustTimer] ', 167)..string.color(body, color or 0))
end

local function debug_message(body)
    if settings.debug then message('Debug: '..body, 207) end
end

local function show_text(content, red, green, blue, alpha)
    if content ~= state.last_text then
        hud:text(content)
        state.last_text = content
    end
    local color = string.format('%d:%d:%d', red, green, blue)
    if color ~= state.last_color then
        hud:color(red, green, blue)
        state.last_color = color
    end
    if alpha ~= state.last_alpha then
        hud:alpha(alpha)
        state.last_alpha = alpha
    end
    if not state.last_visible then
        hud:show()
        state.last_visible = true
    end
end

local function hide_text()
    if state.last_visible then hud:hide() end
    state.last_visible = false
    -- Restore the persisted baseline after the temporary green/amber states.
    if state.last_color ~= '235:237:241' then
        hud:color(235, 237, 241)
        state.last_color = '235:237:241'
    end
    if state.last_alpha ~= 255 then
        hud:alpha(255)
        state.last_alpha = 255
    end
end

local function remaining(deadline, now)
    return math.max(0, deadline - now)
end

local function clock_text(seconds)
    return string.format('%d:%02d', math.floor(seconds / 60), seconds % 60)
end

local function display(now)
    if state.editing then
        show_text('Trusts Available in 1:42  [drag to move]', 255, 218, 145, 255)
        return
    end

    if not settings.enabled then hide_text() return end

    if state.demo_until and now >= state.demo_until then
        state.demo_until = nil
        state.demo_ready_until = now + 3
    end
    if state.expires_at and now >= state.expires_at then
        state.expires_at = nil
        state.ready_until = now + 3
    end

    local deadline = state.demo_until or state.expires_at
    if deadline then
        show_text('Trusts Available in '..clock_text(remaining(deadline, now)), 235, 237, 241, 255)
        return
    end

    local ready_deadline = state.demo_ready_until or state.ready_until
    if ready_deadline and now < ready_deadline then
        local alpha = math.min(255, math.max(0, (ready_deadline - now) * 90))
        show_text('Trusts Ready!', 156, 232, 164, alpha)
    else
        state.ready_until = nil
        state.demo_ready_until = nil
        hide_text()
    end
end

local function human_members()
    local party = windower.ffxi.get_party()
    if not party then return nil end
    local members = {}
    -- Examine the primary party only. Trust NPCs and alliance members are excluded.
    for i = 0, 5 do
        local member = party['p'..i]
        if member then
            local id = member.id or (member.mob and member.mob.id)
            local mob = member.mob
            local is_human = mob and mob.is_npc == false
            if not is_human and id and id > 0 and id < 0x01000000
                and (not mob or mob.is_npc ~= true) then
                is_human = true
            end
            if is_human then
                members[tostring(id or member.name)] = member.name or (mob and mob.name) or '?'
            end
        end
    end
    return members
end

local function check_roster(now)
    local player = windower.ffxi.get_player()
    if not player then return end
    local roster = human_members()
    if not roster then return end
    if not state.roster then
        state.roster = roster -- Baseline on load, login, or zone; never invent a join.
        return
    end
    local added = {}
    for key, name in pairs(roster) do
        if not state.roster[key] then added[#added + 1] = name end
    end
    state.roster = roster

    if #added > 0 then
        if state.pending_invite and now - state.pending_invite <= 180 then
            -- Invite intent alone isn't enough: start only when a PC actually joins.
            state.expires_at = now + settings.duration
            state.ready_until = nil
            state.pending_invite = nil
            debug_message('Confirmed PC join ('..table.concat(added, ', ')..'). Countdown started.')
        else
            debug_message('PC joined without a local invitation; no cooldown inferred.')
        end
    end
end

local function help_line(syntax, description)
    windower.add_to_chat(0, string.color('  //tt ', 200)..string.color(syntax, 207)
        ..string.color(' -> ', 200)..string.color(description, 0))
end

local function help()
    windower.add_to_chat(0, string.color('[TrustTimer] Commands', 167))
    help_line('help', 'Show these commands.')
    help_line('status', 'Show countdown, invite, and HUD state.')
    help_line('test [seconds]', 'Preview a 15-second timer, or a custom duration.')
    help_line('edit on|off', 'Show a draggable placement preview.')
    help_line('pos <x> <y>', 'Set HUD position in pixels.')
    help_line('resetpos', 'Recover the default HUD position.')
    help_line('size <pixels>', 'Set text size (8-40).')
    help_line('duration <seconds>', 'Set estimated invite cooldown (30-600).')
    help_line('enabled on|off', 'Enable or disable automatic HUD display.')
    help_line('debug on|off', 'Log invitation and party detection decisions.')
    help_line('clear', 'Clear the currently estimated cooldown.')
    help_line('restart', 'Reload the addon once.')
    help_line('unload', 'Unload the addon once.')
end

local function flag(value)
    if value == 'on' then return true end
    if value == 'off' then return false end
    return nil
end

local function set_edit(value)
    state.editing = value
    hud:draggable(value)
    display(os.time())
    message('Edit mode '..(value and 'ON - drag the text to reposition.' or 'OFF - position saved.'))
end

local function status()
    local now = os.time()
    local active = state.expires_at and remaining(state.expires_at, now) or 0
    local pending = state.pending_invite and remaining(state.pending_invite + 180, now) or 0
    local x, y = hud:pos()
    message(string.format('v%s | %s | cooldown %s | pending invite %s | edit %s',
        _addon.version, settings.enabled and 'enabled' or 'disabled',
        active > 0 and clock_text(active) or 'none',
        pending > 0 and clock_text(pending) or 'none', state.editing and 'on' or 'off'))
    message(string.format('HUD (%d, %d), size %d | estimate %ds | debug %s',
        x, y, settings.hud.text.size, settings.duration, settings.debug and 'on' or 'off'))
end

local function command(cmd, arg1, arg2)
    cmd = cmd and cmd:lower() or 'help'
    arg1 = arg1 and arg1:lower() or nil
    if cmd == 'help' then help() return end
    if cmd == 'status' then status() return end
    if cmd == 'test' then
        local seconds = tonumber(arg1) or (arg1 == nil and 15)
        if not seconds or seconds < 1 or seconds > 600 then
            message('Use //tt test [seconds] (1-600).', 123) return
        end
        state.demo_until = os.time() + math.ceil(seconds)
        state.demo_ready_until = nil
        display(os.time())
        message('Preview countdown started for '..math.ceil(seconds)..'s.')
        return
    end
    if cmd == 'edit' or cmd == 'enabled' or cmd == 'debug' then
        local value = flag(arg1)
        if value == nil then message('Use //tt '..cmd..' on|off.', 123) return end
        if cmd == 'edit' then set_edit(value)
        elseif cmd == 'enabled' then
            settings.enabled = value
            settings:save()
            display(os.time())
            message('HUD '..(value and 'enabled.' or 'disabled.'))
        else
            settings.debug = value
            settings:save()
            message('Debug '..(value and 'ON.' or 'OFF.'))
        end
        return
    end
    if cmd == 'pos' then
        local x, y = tonumber(arg1), tonumber(arg2)
        if not x or not y then message('Use //tt pos <x> <y>.', 123) return end
        x, y = math.floor(x), math.floor(y)
        hud:pos(x, y)
        settings:save()
        message(string.format('HUD position: %d, %d.', x, y))
        return
    end
    if cmd == 'resetpos' then
        hud:pos(default_x, default_y)
        settings:save()
        message('HUD position reset.')
        return
    end
    if cmd == 'size' or cmd == 'duration' then
        local n = tonumber(arg1)
        local min_val, max_val = cmd == 'size' and 8 or 30, cmd == 'size' and 40 or 600
        if not n or n < min_val or n > max_val then
            message('Use //tt '..cmd..' <'..min_val..'-'..max_val..'>.', 123) return
        end
        n = math.floor(n)
        if cmd == 'size' then hud:size(n) else settings.duration = n end
        settings:save()
        message(cmd..' set to '..n..'.')
        return
    end
    if cmd == 'clear' then
        state.expires_at, state.ready_until = nil, nil
        state.demo_until, state.demo_ready_until = nil, nil
        display(os.time())
        message('Countdown cleared.')
        return
    end
    if cmd == 'restart' or cmd == 'unload' then
        message(cmd == 'restart' and 'Restarting.' or 'Unloading.')
        windower.send_command('lua '..(cmd == 'restart' and 'r ' or 'unload ')..'trusttimer')
        return
    end
    message('Unknown command: '..cmd..'.', 123)
    help()
end

windower.register_event('addon command', command)

windower.register_event('outgoing chunk', function(id, data, modified, injected, blocked)
    if not settings.enabled or blocked or injected or id ~= 0x06E then return end
    local success, packet = pcall(packets.parse, 'outgoing', modified or data)
    if not success or not packet then
        debug_message('Could not parse outgoing party invitation.')
        return
    end
    if packet['Alliance'] ~= 0 then return end
    state.pending_invite = os.time()
    debug_message('Party invitation sent; awaiting human party-member confirmation.')
end)

windower.register_event('prerender', function()
    local now = os.time()
    if state.last_tick == now then return end
    state.last_tick = now
    if state.pending_invite and now - state.pending_invite > 180 then
        state.pending_invite = nil
        debug_message('Unconfirmed invitation expired.')
    end
    check_roster(now)
    display(now)
end)

windower.register_event('zone change', function()
    -- Preserve wall-clock countdown; discard only the roster comparison baseline.
    state.roster = nil
end)

windower.register_event('login', function()
    state.roster = nil
    state.pending_invite = nil
end)

windower.register_event('logout', function()
    state.roster = nil
    state.pending_invite = nil
    state.expires_at = nil
    state.ready_until = nil
    state.demo_until = nil
    state.demo_ready_until = nil
    hide_text()
end)

windower.register_event('unload', function()
    hud:destroy()
end)
