-- FPSFix: quietly restore 60 FPS after loading, login, and zoning.
_addon.name = 'FPSFix'
_addon.author = 'A'
_addon.version = '1.0.1'
_addon.commands = {'fpsfix', 'fps'}

require('chat')

local generation = 0
local last_request = 'none'
local target_command = 'config FrameRateDivisor 1'

local function message(text)
    windower.add_to_chat(0, string.color('[FPSFix] ', 167) .. text)
end

-- Windower's Config plugin does not expose a documented live divisor getter.
-- Sending 1 unconditionally is intentional, including if the previous value is 0.
local function apply(reason)
    last_request = reason
    windower.send_command(target_command)
end

local function on_transition(reason)
    generation = generation + 1
    local current = generation
    apply(reason)

    -- Another addon or the Config plugin may restore 30 FPS during a zone load.
    -- Reapply briefly, then stop; there is no frame-by-frame polling.
    for _, delay in ipairs({1, 3}) do
        coroutine.schedule(function()
            if generation == current then
                apply(reason .. ' +' .. tostring(delay) .. 's')
            end
        end, delay)
    end
end

local function help()
    windower.add_to_chat(0, string.color('--------- ', 140) .. string.color('FPSFix v' .. _addon.version, 167) .. string.color(' ---------', 140))
    local function line(command, description)
        windower.add_to_chat(0,
            string.color('//fpsfix', 200) .. ' ' .. string.color(command, 207) ..
            ' ' .. string.color('->', 200) .. ' ' .. description)
    end
    windower.add_to_chat(0, string.color('//fps', 200) .. ' ' .. string.color('->', 200) .. ' Request 60 FPS immediately')
    line('(bare)', 'Request 60 FPS immediately')
    line('help', 'Show these commands')
    line('status', 'Show enforcement and last request')
    line('apply', 'Request 60 FPS immediately')
    line('restart', 'Restart FPSFix')
    line('unload', 'Unload FPSFix')
end

local function status()
    message('Auto 60 FPS: ON | Load/login/zone | Last request: ' .. last_request .. ' | Live readback: unavailable')
end

windower.register_event('load', function()
    on_transition('load')
end)

windower.register_event('login', function()
    on_transition('login')
end)

windower.register_event('zone change', function()
    on_transition('zone')
end)

windower.register_event('unload', function()
    -- Invalidate pending delayed requests when unloading.
    generation = generation + 1
end)

windower.register_event('addon command', function(command)
    command = command and command:lower() or 'apply'
    if command == 'help' then
        help()
    elseif command == 'status' then
        status()
    elseif command == 'apply' then
        apply('manual')
        message('60 FPS requested (FrameRateDivisor 1).')
    elseif command == 'restart' then
        message('Restarting.')
        windower.send_command('lua r fpsfix')
    elseif command == 'unload' then
        message('Unloading.')
        windower.send_command('lua u fpsfix')
    else
        message('Unknown command: ' .. command)
        help()
    end
end)
