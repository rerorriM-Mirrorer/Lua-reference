-- FixConfig: restore selected Windower Config plugin settings on load, login and zoning.
_addon.name = 'FixConfig'
_addon.author = 'A'
_addon.version = '1.1.0'
_addon.commands = {'fixconfig', 'fix'}

require('chat')
local config = require('config')

-- Windower's Lua Config library stores these separately from the Config plugin.
-- Per-character overrides are merged over the defaults when the player logs in.
local defaults = {
    fps_divisor = 1,
    clipping_plane = 1.5,
    battle_auto_target = false,
    debug = false,
}
local settings = config.load(defaults)
local generation = 0
local last_request = 'none'
local is_unloading = false

local function notify(text)
    windower.add_to_chat(0, string.color('[FixConfig] ', 167) .. text)
end

local function trace(text)
    if settings.debug then
        notify(string.color('Debug: ', 207) .. text)
    end
end

local function fps_name(divisor)
    if divisor == 0 then return 'Uncapped' end
    if divisor == 2 then return '30 FPS' end
    return '60 FPS'
end

local function target_description()
    return fps_name(settings.fps_divisor) .. ' | Draw: ' .. tostring(settings.clipping_plane) ..
        ' | AutoTarget: ' .. (settings.battle_auto_target and 'ON' or 'OFF')
end

local function send_setting(field, value)
    -- Never call `config save`; that command persists unrelated Config plugin settings.
    windower.send_command('config ' .. field .. ' ' .. tostring(value))
end

local function apply_fps(divisor, reason)
    last_request = reason
    send_setting('FrameRateDivisor', divisor)
    trace('Requested ' .. fps_name(divisor) .. ' (' .. reason .. ').')
end

local function apply_all(reason)
    last_request = reason
    send_setting('FrameRateDivisor', settings.fps_divisor)
    send_setting('ClippingPlane', settings.clipping_plane)
    send_setting('BattleAutoTarget', tostring(settings.battle_auto_target))
    trace('Requested all: ' .. target_description() .. ' (' .. reason .. ').')
end

local function transition(reason, reload_character)
    -- Refresh per-character preferences after login before applying them.
    if reload_character then
        config.reload(settings)
    end
    generation = generation + 1
    local current = generation
    apply_all(reason)

    -- Windower or other software can restore settings during zoning. Keep retries
    -- finite and invalidate stale ones when another transition begins.
    for _, delay in ipairs({1, 3}) do
        coroutine.schedule(function()
            if not is_unloading and generation == current then
                apply_all(reason .. ' +' .. delay .. 's')
            end
        end, delay)
    end
end

local function save_preferences()
    -- Config library save (addon/data/settings.xml), NOT Config plugin `config save`.
    local info = windower.ffxi.get_info()
    if info and info.logged_in and windower.ffxi.get_player() then
        settings:save()
        return true
    end
    notify('Settings applied but not saved - log in to save character preferences.')
    return false
end

local function parse_fps(value)
    if not value then return nil end
    value = value:lower()
    if value == '60' or value == '1' then return 1 end
    if value == '30' or value == '2' then return 2 end
    if value == '0' or value == 'uncapped' then return 0 end
    return nil
end

local function parse_draw(value)
    if not value then return nil end
    local n = tonumber(value)
    if not n or n <= 0 or n ~= n or n == math.huge or n == -math.huge then
        return nil
    end
    return n
end

local function help()
    windower.add_to_chat(0, string.color('--------- ', 140) ..
        string.color('FixConfig v' .. _addon.version, 167) .. string.color(' ---------', 140))
    local function line(command, description)
        windower.add_to_chat(0, string.color('//fix', 200) ..
            (command ~= '' and (' ' .. string.color(command, 207)) or '') ..
            ' ' .. string.color('->', 200) .. ' ' .. description)
    end
    line('', 'Reapply all preferred settings')
    line('fps <30|60|uncapped>', 'Set and save preferred frame rate')
    line('draw <distance>', 'Set and save clipping plane (e.g. 1.5)')
    line('autotarget [on|off]', 'Toggle or set battle auto-target')
    line('defaults', 'Reset preferred settings to 60 / 1.5 / OFF')
    line('status', 'Show saved targets and last request')
    line('debug [on|off]', 'Toggle diagnostic request messages')
    line('apply', 'Reapply all preferred settings')
    line('restart', 'Restart FixConfig')
    line('unload', 'Unload FixConfig')
    line('help', 'Show this help')
    windower.add_to_chat(0, string.color('//fps', 200) .. ' ' ..
        string.color('->', 200) .. ' Request 60 FPS once (legacy shortcut)')
    windower.add_to_chat(0, string.color('//fpsfix', 200) .. ' ' ..
        string.color('->', 200) .. ' Legacy 60 FPS shortcut and commands')
end

local function status()
    notify('Desired: ' .. target_description() .. ' | Debug: ' .. (settings.debug and 'ON' or 'OFF'))
    notify('Last request: ' .. last_request .. ' | Actual Config plugin values: not readable')
end

local function apply_and_save(target)
    save_preferences()
    if target == 'fps' then
        apply_fps(settings.fps_divisor, 'manual fps')
        notify('Preferred frame rate: ' .. fps_name(settings.fps_divisor) .. '.')
    elseif target == 'draw' then
        last_request = 'manual draw'
        send_setting('ClippingPlane', settings.clipping_plane)
        notify('Preferred clipping plane: ' .. tostring(settings.clipping_plane) .. '.')
    else
        last_request = 'manual autotarget'
        send_setting('BattleAutoTarget', tostring(settings.battle_auto_target))
        notify('Preferred battle auto-target: ' .. (settings.battle_auto_target and 'ON' or 'OFF') .. '.')
    end
end

local function invalid(message)
    notify(message)
    help()
end

local function command_handler(action, argument, extra)
    action = action and action:lower() or 'apply'
    argument = argument and argument:lower() or nil
    if action == 'help' then
        help()
    elseif action == 'status' then
        status()
    elseif action == 'apply' then
        apply_all('manual')
        notify('Reapplied: ' .. target_description() .. '.')
    elseif action == 'fps' then
        if extra then return invalid('Usage: //fix fps <30|60|uncapped>') end
        if not argument then
            notify('Preferred frame rate: ' .. fps_name(settings.fps_divisor) .. '.')
            return
        end
        local divisor = parse_fps(argument)
        if divisor == nil then return invalid('Invalid FPS: use 30, 60 or uncapped.') end
        settings.fps_divisor = divisor
        apply_and_save('fps')
    elseif action == 'draw' then
        if extra then return invalid('Usage: //fix draw <distance>') end
        if not argument then
            notify('Preferred clipping plane: ' .. tostring(settings.clipping_plane) .. '.')
            return
        end
        local draw = parse_draw(argument)
        if not draw then return invalid('Draw distance must be a positive finite number.') end
        settings.clipping_plane = draw
        apply_and_save('draw')
    elseif action == 'autotarget' then
        if extra then return invalid('Usage: //fix autotarget [on|off]') end
        if argument and argument ~= 'on' and argument ~= 'off' then
            return invalid('Usage: //fix autotarget [on|off]')
        end
        if argument == nil then
            settings.battle_auto_target = not settings.battle_auto_target
        else
            settings.battle_auto_target = argument == 'on'
        end
        apply_and_save('autotarget')
    elseif action == 'defaults' then
        settings.fps_divisor = defaults.fps_divisor
        settings.clipping_plane = defaults.clipping_plane
        settings.battle_auto_target = defaults.battle_auto_target
        save_preferences()
        apply_all('defaults')
        notify('Restored defaults: ' .. target_description() .. '.')
    elseif action == 'debug' then
        if extra or (argument and argument ~= 'on' and argument ~= 'off') then
            return invalid('Usage: //fix debug [on|off]')
        end
        settings.debug = argument == nil and not settings.debug or (argument == 'on')
        save_preferences()
        notify('Debug: ' .. (settings.debug and 'ON' or 'OFF') .. '.')
    elseif action == 'restart' then
        if not is_unloading then
            is_unloading = true
            generation = generation + 1
            notify('Restarting.')
            windower.send_command('lua r fixconfig')
        end
    elseif action == 'unload' then
        if not is_unloading then
            is_unloading = true
            generation = generation + 1
            notify('Unloading.')
            windower.send_command('lua u fixconfig')
        end
    else
        invalid('Unknown command: ' .. action)
    end
end

windower.register_event('load', function()
    transition('load', false)
end)
windower.register_event('login', function()
    transition('login', true)
end)
windower.register_event('zone change', function()
    transition('zone', false)
end)
windower.register_event('logout', function()
    -- A delayed zone retry must not run after leaving a character.
    generation = generation + 1
end)
windower.register_event('unload', function()
    is_unloading = true
    generation = generation + 1
end)

-- LuaCore doesn't pass which _addon.commands alias was used to the callback.
-- Keep `//fix` as the full-repair command, while preserving the distinct
-- existing `//fps` one-setting behavior without overriding a user's alias.
-- `unhandled command` runs only if no plugin/other command already claimed it.
windower.register_event('unhandled command', function(name, ...)
    if type(name) ~= 'string' then return end
    name = name:lower()
    if name ~= 'fps' and name ~= 'fpsfix' then return end
    local args = {...}
    if name == 'fps' then
        if #args > 0 and args[1]:lower() ~= 'apply' then
            notify('Usage: //fps (for 60 FPS); use //fix fps <30|60|uncapped> to save a preference.')
        else
            apply_fps(1, 'legacy //fps')
            notify('60 FPS requested (FrameRateDivisor 1).')
        end
    elseif #args == 0 or args[1]:lower() == 'apply' then
        apply_fps(1, 'legacy //fpsfix')
        notify('60 FPS requested (FrameRateDivisor 1).')
    else
        command_handler(unpack(args))
    end
    return true
end)

windower.register_event('addon command', command_handler)
