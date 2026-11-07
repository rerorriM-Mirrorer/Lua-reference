_addon.name = 'SkillTrainer'
_addon.author = 'A'
_addon.version = '0.3.0-beta'
_addon.commands = {'st', 'skilltrainer'}

require('chat')
local res = require('resources')
local packets = require('packets')

-- Defaults are intentionally small and character-local; nothing starts at addon load.
local DEFAULT_MINUTES = 60
local REST_BELOW_PERCENT = 20
local RESUME_AT_PERCENT = 90
local MAX_REST_ATTEMPTS = 3

local modes = {
    healing = {name = 'Healing Magic', key = 'healing_magic', capped = 'Healing Magic Capped', spells = {'Cure'}},
    enhancing = {name = 'Enhancing Magic', key = 'enhancing_magic', capped = 'Enhancing Magic Capped', spells = {'Barstone', 'Barstonra', 'Barfire', 'Barfira'}},
    singing = {name = 'Singing', key = 'singing', capped = 'Singing Capped', spells = {"Army's Paeon", "Valor Minuet"}},
    summoning = {name = 'Summoning Magic', key = 'summoning_magic', capped = 'Summoning Magic Capped', spells = {'Carbuncle'}},
}

-- 0x062 includes skill Level and Capped, but not a numeric maximum.  The
-- main-job skill rank and job level determine the base cap.  Master Levels
-- increase innate skill caps by +1 each; we observe that from 0x061/0x0DF.
-- Source: FFXIclopedia Combat Skills rank cap chart (levels 1-99).
-- An unobserved Master Level is not silently treated as zero at job level 99.
local skill_ranks = {
    healing_magic   = {WHM='A+', PLD='C', RDM='C-', SCH='D'},
    enhancing_magic = {BLM='E', PLD='D', RDM='B+', RUN='B-', SCH='D', WHM='C+'},
    singing         = {BRD='C'},
    summoning_magic = {SMN='A-'},
    enfeebling_magic = {RDM='A+', BLM='C+', GEO='C+', WHM='C', DRK='C', SCH='D'},
}

local rank_low = {
    ['A+']={6,3,153,5}, ['A-']={6,3,153,5},
    ['B+']={5,2.9,147,4.9}, ['B-']={5,2.9,147,4.9},
    ['C+']={5,2.8,142,4.8}, ['C']={5,2.8,142,4.8},
    ['C-']={5,2.8,142,4.8}, ['D']={4,2.7,136,4.7},
    ['E']={4,2.5,126,4.5},
}

-- Levels 61-80 are nonlinear; preserve the published integer values rather
-- than relying on floating-point calculations near rounding boundaries.
local rank_mid = {
    ['A+']={207,212,217,222,227,232,236,241,246,251,256,261,266,271,276,281,286,291,296,301},
    ['A-']={207,211,215,219,223,227,231,235,239,244,249,254,259,264,269,274,279,284,289,294},
    ['B+']={199,203,207,210,214,218,221,225,229,233,237,241,246,251,256,261,266,271,276,281},
    ['B-']={198,201,204,206,209,212,214,217,220,223,226,229,232,236,240,245,250,255,260,265},
    ['C+']={192,195,197,200,202,205,207,210,212,215,218,221,224,227,230,235,240,245,250,255},
    ['C']={192,194,196,199,201,203,205,208,210,212,214,217,219,222,225,230,235,240,245,250},
    ['C-']={192,194,196,198,200,202,204,206,208,210,212,214,216,218,220,225,230,235,240,245},
    ['D']={184,186,188,190,192,194,195,197,199,201,203,205,207,208,210,214,218,222,226,230},
    ['E']={172,174,176,178,180,182,184,186,188,190,192,194,196,198,200,203,206,209,212,215},
}
local rank_high = {
    ['A+']={6,7}, ['A-']={6,7}, ['B+']={6,7}, ['B-']={6,7},
    ['C+']={6,7}, ['C']={6,7}, ['C-']={6,7}, ['D']={5,6}, ['E']={4,5},
}

local function rank_base_cap(rank, level)
    local low, mid, high = rank_low[rank], rank_mid[rank], rank_high[rank]
    if not low or not level or level < 1 or level > 99 then return nil end
    if level <= 50 then return math.floor(low[1] + (level - 1) * low[2] + 0.000001) end
    if level <= 60 then return math.floor(low[3] + (level - 50) * low[4] + 0.000001) end
    if level <= 80 then return mid[level - 60] end
    local at_90 = mid[20] + 10 * high[1]
    if level <= 90 then return mid[20] + (level - 80) * high[1] end
    return at_90 + (level - 90) * high[2]
end

-- The server's 0x062 skill packet contains the actual capped flags, unlike get_player().skills.
local observed_caps = {}
local packet_levels = {}
local server_cap_levels = {}
local manual_caps = {}
local master_level = nil
local announced_cap = nil
local cap_owner = nil -- Avoid reusing a cap packet from another character/job/level.
local active = nil
local phase = 'idle'
local started_at = 0
local expires_at = 0
local next_tick = 0
local next_action = 0
local rest_attempts = 0
local rest_command_at = 0
local rest_owned = false
local last_mode = nil
local last_minutes = DEFAULT_MINUTES
local trained_name, trained_job, trained_level = nil, nil, nil
local casts = 0
local debug_enabled = false
local paused_notice = nil
local book_run = nil
local whole_skill_levels = {}

-- Retail Sparks skill-up tomes are a contiguous, verified set: 6147-6179.
-- Their order corresponds to these 33 resource skill IDs. Book IDs, not
-- substring matching, prevent /st books from using unrelated consumables.
local book_skill_ids = {
    1,2,3,4,5,6,7,8,9,10,11,12,25,26,27,28,29,30,31,
    32,33,34,35,36,37,40,41,42,39,38,43,44,45,
}
local book_by_id, book_list = {}, {}
for offset, skill_id in ipairs(book_skill_ids) do
    local item_id = 6146 + offset
    local item, skill = res.items[item_id], res.skills[skill_id]
    if item and item.en and skill and skill.en then
        local entry = {
            id = item_id, name = item.en, skill_id = skill_id,
            skill_name = skill.en,
            key = skill.en:lower():gsub('[%s%-]', '_'),
        }
        book_by_id[item_id] = entry
        book_list[#book_list + 1] = entry
    end
end

local function notice(message)
    windower.add_to_chat(0, string.color('SkillTrainer', 167) .. string.color(' -> ', 200) .. string.color(message, 0))
end

local function debug(message)
    if debug_enabled then notice('[debug] ' .. message) end
end

local function help()
    local lines = {
        {'//st healing [minutes]', 'Cure yourself, rest for MP, stop on skill cap.'},
        {'//st enhancing [minutes]', 'Loop an available Bar-element spell.'},
        {'//st singing [minutes]', 'Loop an available self-buff song.'},
        {'//st summoning [minutes]', 'Summon and release only Carbuncle.'},
        {'//st books', 'Use recognized skill-up tomes in Inventory, one at a time.'},
        {'//st cap <number|auto>', 'Optional cap override for current mode.'},
        {'//st status', 'Show mode, skill, cap, MP, and time left.'},
        {'//st stop', 'Stop immediately (and stand if we initiated resting).'},
        {'//st restart', 'Restart the last mode and duration.'},
        {'//st debug on|off', 'Toggle state diagnostics.'},
        {'//st unload', 'Stop and unload this addon.'},
        {'//st help', 'Show this command list.'},
    }
    windower.add_to_chat(0, string.color('----- ', 140) .. string.color('SkillTrainer v' .. _addon.version, 167) .. string.color(' -----', 140))
    for _, entry in ipairs(lines) do
        local suffix = entry[1]:sub(5) -- //st (prefix) is colored separately.
        windower.add_to_chat(0, string.color('//st', 200) .. string.color(suffix, 207) .. string.color(' -> ', 200) .. string.color(entry[2], 0))
    end
end

local function owner_identity(player)
    if not player then return nil end
    return tostring(player.name) .. ':' .. tostring(player.main_job) .. ':' .. tostring(player.main_job_level)
end

local function refresh_owner(player)
    local identity = owner_identity(player)
    if identity ~= cap_owner then
        observed_caps, manual_caps, packet_levels, server_cap_levels = {}, {}, {}, {}
        whole_skill_levels = {}
        master_level, announced_cap = nil, nil
        cap_owner = identity
    end
end

local function calculated_cap(player, mode)
    if not player or not mode then return nil end
    local rank = skill_ranks[mode.key] and skill_ranks[mode.key][player.main_job]
    local level = tonumber(player.main_job_level)
    local base = rank_base_cap(rank, level)
    if not base then return nil end
    if level < 99 then return base, rank, true end
    -- An unavailable Master Level yields only a lower bound, not a full cap.
    local ml = tonumber(player.master_level) or master_level
    if ml == nil or ml < 0 or ml > 50 then return base, rank, false end
    return base + ml, rank, true
end

local function current_skill(player)
    if not active then return nil end
    return packet_levels[active.key] or (player and player.skills and player.skills[active.key])
end

local function cap_text(player, mode)
    local numeric, rank, exact = calculated_cap(player, mode)
    local override = manual_caps[mode.key]
    if override then
        return tostring(override) .. ' (override)', override, rank, true
    end
    if observed_caps[mode.key] and server_cap_levels[mode.key] then
        local value = server_cap_levels[mode.key]
        return tostring(value) .. ' (server)', value, rank, true
    end
    if not numeric then return 'unknown', nil, nil, false end
    if not exact then return ('%d+ML? (base only)'):format(numeric), numeric, rank, false end
    return tostring(numeric), numeric, rank, true
end

local function report_calculated_cap(player)
    if not active then return end
    local text_cap, numeric, rank, exact = cap_text(player, active)
    local key = tostring(text_cap) .. ':' .. tostring(rank)
    if key == announced_cap then return end
    announced_cap = key
    local value = current_skill(player)
    if numeric then
        local needed = exact and value and math.max(0, numeric - value) or nil
        local progress = value and (' | skill %s/%s'):format(tostring(value), text_cap) or ''
        local remaining = needed and (' | %s remaining'):format(tostring(needed)) or ''
        notice(('Cap: %s | %s Lv%s rank %s%s%s'):format(active.name,
            tostring(player.main_job), tostring(player.main_job_level), rank, progress, remaining))
    else
        notice('Cap: ' .. active.name .. ' | unknown main-job skill rank; FFXI capped flag still monitored.')
    end
end

local function is_capped(player)
    if not active then return false end
    local override = manual_caps[active.key]
    return observed_caps[active.key] == true
        or (override ~= nil and current_skill(player) ~= nil and current_skill(player) >= override)
end

local function cleanup_rest()
    if rest_owned then
        local player = windower.ffxi.get_player()
        if player and player.status == 33 then
            windower.send_command('input /heal off')
        end
    end
    rest_owned = false
end

local function stop(reason)
    if not active then return end
    cleanup_rest()
    notice('Stopped ' .. active.name .. ': ' .. reason .. ' (' .. casts .. ' actions).')
    active = nil
    phase = 'idle'
    paused_notice = nil
    next_action = 0
end

local function player_safe(info, player)
    if not info or not info.logged_in or not player or not player.vitals then return false end
    if info.menu_open or info.chat_open then return false end
    if not player.vitals.hp or player.vitals.hp <= 0 then return false end
    if player.status ~= 0 and player.status ~= 33 then return false end
    return true
end

-- Seed the whole-skill boundary from the most recent packet or Windower
-- player values, so the first update is not mistaken for a huge skill gain.
local function seed_whole_skill(player, key)
    local value = packet_levels[key] or (player and player.skills and player.skills[key])
    if value ~= nil then whole_skill_levels[key] = math.floor(tonumber(value) or 0) end
end

local function book_inventory()
    local items = windower.ffxi.get_items(0)
    return items and (items.inventory or items) or nil
end

local function inventory_books(player)
    local slots = book_inventory()
    local eligible, skipped, first = 0, 0, nil
    if not slots then return nil end
    -- Slot order is deterministic and avoids arbitrarily selecting a different
    -- stack when FFXI moves or consumes an item from inventory.
    for slot = 1, 80 do
        local entry = slots[slot]
        local book = entry and book_by_id[entry.id]
        if book and (entry.count or 0) > 0 then
            if observed_caps[book.key] == true or not player.skills or player.skills[book.key] == nil then
                skipped = skipped + entry.count
            else
                eligible = eligible + entry.count
                if not first then first = {slot=slot, id=entry.id, before=entry.count, book=book} end
            end
        end
    end
    return eligible, skipped, first
end

local function stop_books(reason)
    if not book_run then return end
    notice(('Books stopped: %s | %d used.'):format(reason, book_run.used))
    book_run = nil
end

local function start_books()
    local player, info = windower.ffxi.get_player(), windower.ffxi.get_info()
    if not player or not player.skills or not info or not info.logged_in then
        notice('Log in before using skill-up books.'); return
    end
    refresh_owner(player)
    local eligible, skipped = inventory_books(player)
    if eligible == nil then notice('Unable to read Inventory; no books used.'); return end
    if eligible == 0 then
        notice(('No eligible skill-up books in Inventory (%d capped/unavailable skipped).'):format(skipped))
        return
    end
    if active then stop('switching to books') end
    if book_run then stop_books('restarting') end
    for _, book in ipairs(book_list) do seed_whole_skill(player, book.key) end
    book_run = {
        owner = owner_identity(player), zone = info.zone,
        next_action = os.time() + 1, started = os.time(),
        used = 0, skipped = skipped, pending = nil,
    }
    notice(('Books started: %d eligible in Inventory | %d capped/unavailable skipped.'):format(eligible, skipped))
end

local function tick_books()
    local session = book_run
    if not session then return end
    local now = os.time()
    if now - session.started >= 3600 then stop_books('60-minute safety limit'); return end
    local info, player = windower.ffxi.get_info(), windower.ffxi.get_player()
    if not info or not info.logged_in or not player then stop_books('logged out'); return end
    if owner_identity(player) ~= session.owner or info.zone ~= session.zone then
        stop_books('character, job, level, or zone changed'); return
    end
    local inventory = book_inventory()
    if not inventory then stop_books('Inventory unavailable'); return end
    if session.pending then
        local pending = session.pending
        local slot_item = inventory[pending.slot]
        local left = (slot_item and slot_item.id == pending.id) and (slot_item.count or 0) or 0
        if left < pending.before then
            session.used = session.used + 1
            session.pending = nil
            session.next_action = now + 2
            debug(('Book used: %s (%d total)'):format(pending.book.name, session.used))
        elseif observed_caps[pending.book.key] == true then
            session.pending = nil
            session.next_action = now + 1
        elseif now - pending.sent >= 12 then
            stop_books('no Inventory confirmation for ' .. pending.book.name .. '; check item-use messages')
        end
        return
    end
    if now < session.next_action or not player_safe(info, player) or player.status ~= 0 then return end
    local available, skipped, next_book = inventory_books(player)
    if available == nil then stop_books('Inventory unavailable'); return end
    if not next_book then
        stop_books(('finished (%d capped/unavailable books left untouched)'):format(skipped))
        return
    end
    session.pending = next_book
    next_book.sent = now
    windower.send_command('input /item "' .. next_book.book.name .. '" <me>')
end

local function spell_for_player(player, mode)
    local known = windower.ffxi.get_spells()
    if not known then return nil end
    for _, name in ipairs(mode.spells) do
        local spell = res.spells:with('en', name)
        if spell and known[spell.id] then
            local levels = spell.levels or {}
            local main_id = tonumber(player.main_job_id)
            local sub_id = tonumber(player.sub_job_id)
            local can_main = main_id and levels[main_id] and player.main_job_level >= levels[main_id]
            local can_sub = sub_id and levels[sub_id] and player.sub_job_level and player.sub_job_level >= levels[sub_id]
            if can_main or can_sub then return spell end
        end
    end
    return nil
end

local function start(mode_name, minutes)
    local mode = modes[mode_name]
    local player = windower.ffxi.get_player()
    local info = windower.ffxi.get_info()
    if not mode then notice('Unknown mode: ' .. tostring(mode_name)); return end
    if not info or not info.logged_in or not player or not player.vitals then
        notice('Log in before starting a training session.'); return
    end
    if minutes == nil then minutes = DEFAULT_MINUTES end
    if type(minutes) ~= 'number' or minutes <= 0 or minutes > 1440 then
        notice('Duration must be between 1 and 1440 minutes.'); return
    end
    if not player.skills or player.skills[mode.key] == nil then
        notice(mode.name .. ' skill is not available to this job.'); return
    end
    local spell = spell_for_player(player, mode)
    if not spell then
        notice('No usable spell found for ' .. mode.name .. ' on this job.'); return
    end
    if active then stop('switching modes') end
    if book_run then stop_books('switching to ' .. mode.name) end
    refresh_owner(player)
    active = mode
    active.spell = spell
    last_mode, last_minutes = mode_name, minutes
    trained_name, trained_job, trained_level = player.name, player.main_job, player.main_job_level
    started_at = os.time()
    expires_at = started_at + math.floor(minutes * 60)
    next_action = started_at + 1
    next_tick = 0
    phase = 'idle'
    rest_attempts, rest_owned, casts, paused_notice = 0, false, 0, nil
    announced_cap = nil
    seed_whole_skill(player, mode.key)
    notice(('%s started | %s | %s | skill %s | %dm limit'):format(
        mode.name, player.name, spell.en, tostring(current_skill(player)), minutes))
    report_calculated_cap(player)
    if is_capped(player) then stop('skill already capped') end
end

local function request_rest(now, retry)
    phase = 'request_rest'
    rest_owned = true
    rest_attempts = rest_attempts + 1
    rest_command_at = now
    next_action = now + 3
    windower.send_command('input /heal on')
    debug((retry and 'Retrying' or 'Requesting') .. ' /heal on')
end

local function request_stand(now)
    phase = 'request_stand'
    rest_command_at = now
    rest_attempts = 1
    next_action = now + 3
    windower.send_command('input /heal off')
    debug('MP recovered; requesting /heal off')
end

local function tick()
    if not active then tick_books(); return end
    local now = os.time()
    if now >= expires_at then stop('session time limit'); return end
    if now < next_tick then return end
    next_tick = now + 1
    local info, player = windower.ffxi.get_info(), windower.ffxi.get_player()
    if not info or not info.logged_in or not player then stop('logged out'); return end
    if trained_name ~= player.name or trained_job ~= player.main_job or trained_level ~= player.main_job_level then
        stop('character, job, or level changed'); return
    end
    if is_capped(player) then stop('skill cap reached'); return end
    if not player_safe(info, player) then
        if not paused_notice then
            paused_notice = true
            debug('Paused for game status, menu, or chat.')
        end
        return
    end
    paused_notice = nil
    local mp = player.vitals.mp or 0
    local max_mp = player.vitals.max_mp or 0
    local percent = max_mp > 0 and math.floor(mp * 100 / max_mp) or 0

    -- Rest state is observed, not assumed from timeouts. Do not stand up from manual resting.
    if phase == 'request_rest' then
        if player.status == 33 then
            phase = 'resting'
            debug('Resting confirmed')
        elseif now - rest_command_at >= 9 then
            if rest_attempts >= MAX_REST_ATTEMPTS then stop('unable to enter resting state')
            else request_rest(now, true) end
        end
        return
    elseif phase == 'resting' then
        if player.status ~= 33 then
            -- Another controller/user interrupted rest. Return to ordinary checks.
            rest_owned = false
            phase = 'idle'
            next_action = now + 2
        elseif percent >= RESUME_AT_PERCENT then
            request_stand(now)
        end
        return
    elseif phase == 'request_stand' then
        if player.status == 0 then
            rest_owned = false
            phase = 'idle'
            next_action = now + 2
            debug('Standing confirmed')
        elseif now - rest_command_at >= 9 then
            if rest_attempts >= MAX_REST_ATTEMPTS then stop('unable to stand after resting')
            else
                rest_attempts = rest_attempts + 1
                rest_command_at = now
                windower.send_command('input /heal off')
            end
        end
        return
    end

    if phase == 'cooldown' then
        if now < next_action then return end
        phase = 'idle'
    end
    if now < next_action or player.status ~= 0 then return end

    if active == modes.summoning then
        local pet = windower.ffxi.get_mob_by_target('pet')
        if pet then
            if pet.name ~= 'Carbuncle' then
                stop('another pet is active; will not release it')
                return
            end
            windower.send_command('input /pet "Release" <me>')
            next_action = now + 4
            phase = 'cooldown'
            casts = casts + 1
            return
        end
        if player.mob and player.mob.pet_index and player.mob.pet_index ~= 0 then
            return -- Pet index still occupied, avoid summoning until despawn confirmed.
        end
    end

    local spell = active.spell
    local spell_mp = spell.mp_cost or 0
    if spell_mp > 0 and (mp < spell_mp or percent <= REST_BELOW_PERCENT) then
        request_rest(now, false)
        return
    end
    local recasts = windower.ffxi.get_spell_recasts() or {}
    if (recasts[spell.recast_id] or 0) > 0 then return end
    windower.send_command('input /ma "' .. spell.en .. '" <me>')
    casts = casts + 1
    phase = 'cooldown'
    -- Conservative cast+recast buffer; confirmation from 0x062 is used for the cap.
    next_action = now + math.max((spell.cast_time or 2) + 2, (spell.recast or 5) + 1)
end

local function status()
    if book_run then
        local player = windower.ffxi.get_player()
        local count, skipped = player and inventory_books(player)
        local current = book_run.pending and book_run.pending.book.name or 'selecting next book'
        notice(('Books | used %d | remaining %s | skipped %s | %s'):format(
            book_run.used, tostring(count or '?'), tostring(skipped or '?'), current))
        return
    end
    if not active then notice('Idle. Type //st help for modes.'); return end
    local player = windower.ffxi.get_player()
    local remaining = math.max(0, expires_at - os.time())
    local cap_value = player and cap_text(player, active) or 'unknown'
    local packet_state = observed_caps[active.key] == nil and 'pending'
        or (observed_caps[active.key] and 'capped' or 'uncapped')
    notice(('%s on %s | %s | skill %s/%s | server %s | MP %s/%s | %dm %02ds left | %d actions'):format(
        active.name, trained_name, phase, tostring(current_skill(player) or '?'), cap_value, packet_state,
        tostring(player and player.vitals and player.vitals.mp or '?'),
        tostring(player and player.vitals and player.vitals.max_mp or '?'),
        math.floor(remaining / 60), remaining % 60, casts))
end

local function cap_command(arg)
    if not active then notice('Start a mode before setting its cap override.'); return end
    if arg and arg:lower() == 'auto' then
        manual_caps[active.key] = nil
        announced_cap = nil
        notice('Numeric override removed; using calculated cap and server capped flag.')
        report_calculated_cap(windower.ffxi.get_player())
    else
        local val = tonumber(arg)
        if not val or val < 1 or val > 999 or val ~= math.floor(val) then
            notice('Use //st cap <1-999> or //st cap auto.'); return
        end
        manual_caps[active.key] = val
        announced_cap = nil
        notice('Manual ' .. active.name .. ' cap set to ' .. val .. '.')
        if is_capped(windower.ffxi.get_player()) then stop('numeric skill cap reached') end
    end
end

windower.register_event('prerender', tick)

-- Passive packet observation only; there is no packet injection.  A *server*
-- capped flag, rather than an estimated numeric cap, decides when to stop.
windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
    if injected or blocked or (id ~= 0x062 and id ~= 0x061 and id ~= 0x0DF) then return end
    local ok, packet = pcall(packets.parse, 'incoming', data)
    if not ok or type(packet) ~= 'table' then return end
    local player = windower.ffxi.get_player()
    if not player then return end
    refresh_owner(player)

    if id == 0x061 or id == 0x0DF then
        local ml = tonumber(packet['Master Level'])
        if ml and ml >= 0 and ml <= 50 and player.main_job_level == 99 then
            if master_level ~= ml then
                master_level = ml
                if active then report_calculated_cap(player) end
            end
        end
        return
    end

    -- The same 0x062 update covers the 33 book skills and our four loop modes.
    for _, book in ipairs(book_list) do
        local key, name = book.key, book.skill_name
        local level = tonumber(packet[name .. ' Level'])
        local capped = packet[name .. ' Capped']
        if level then
            local prior = whole_skill_levels[key]
            packet_levels[key] = level
            local whole = math.floor(level)
            if prior ~= nil and whole > prior and
                    ((active and active.key == key) or book_run) then
                local mode = active and active.key == key and active or book
                local total = cap_text(player, mode)
                notice(('Congratulations! %s %d/%s (+%d)'):format(name, whole, total, whole - prior))
            end
            whole_skill_levels[key] = whole
        end
        if capped ~= nil then
            observed_caps[key] = (capped == true or capped == 1)
            if observed_caps[key] and level then server_cap_levels[key] = level end
        end
    end
    if active then
        report_calculated_cap(player)
        if is_capped(player) then stop('FFXI reports skill capped') end
    end
end)

windower.register_event('zone change', function()
    if active then stop('zoning') end
    if book_run then stop_books('zoning') end
end)

local function parse_minutes(value)
    if value == nil then return DEFAULT_MINUTES end
    local number = tonumber(value)
    if not number or number < 1 or number > 1440 or number ~= math.floor(number) then
        notice('Duration must be a whole number between 1 and 1440 minutes.')
        return nil
    end
    return number
end

local commands = {}
commands.help = function() help() end
commands.status = function() status() end
commands.stop = function()
    if active then stop('user request')
    elseif book_run then stop_books('user request')
    else notice('Already stopped.') end
end
commands.books = function() start_books() end
commands.restart = function()
    if not last_mode then notice('No previous session to restart.'); return end
    start(last_mode, last_minutes)
end
commands.cap = function(value) cap_command(value) end
commands.debug = function(value)
    if value == 'on' then debug_enabled = true
    elseif value == 'off' then debug_enabled = false
    else notice('Use //st debug on|off.'); return end
    notice('Debug ' .. (debug_enabled and 'on' or 'off') .. '.')
end
commands.unload = function()
    if active then stop('unloading') end
    if book_run then stop_books('unloading') end
    notice('Unloading.')
    windower.send_command('lua unload SkillTrainer')
end
for mode_name in pairs(modes) do
    local name = mode_name
    commands[name] = function(value)
        local minutes = parse_minutes(value)
        if minutes then start(name, minutes) end
    end
end
windower.register_event('addon command', function(command, arg)
    local command_name = (command or 'help'):lower()
    local handler = commands[command_name]
    if handler then handler(arg) else notice('Unknown command: ' .. command_name); help() end
end)

windower.register_event('unload', function()
    if active then cleanup_rest() end
    book_run = nil
end)
