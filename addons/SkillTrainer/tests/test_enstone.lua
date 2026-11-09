-- Windower-free behavior checks for SkillTrainer named-target support.
local events, output, chat, clock = {}, {}, {}, 1700
local player = {
 name='Clairvaux', main_job='PLD', main_job_id=7, main_job_level=50,
 sub_job='RDM', sub_job_id=5, sub_job_level=25, status=0,
 skills = {healing_magic=110, enhancing_magic=95, singing=nil, summoning_magic=nil},
 vitals = {hp=400,max_hp=400,mp=350,max_mp=350},
}
local info = {logged_in=true,menu_open=false,chat_open=false,zone=230}
local mob = {id=12345,name='Myrr',hpp=100}
local names = {Barstone=100, Barstonra=101, Barfire=102, Barfira=103, Protect=104, Shell=105, Enstone=113,
    Enthunder=106, Regen=107, Aquaveil=108, Blink=109, Cure=110, ['Army\'s Paeon']=111, Carbuncle=112}
local spells, owned = {}, {}
for name,id in pairs(names) do
 spells[name]={id=id,en=name,mp_cost=name=='Protect' and 9 or 10,cast_time=1,recast=5,recast_id=id,levels={[3]=1}}
 owned[id]=true
end
-- Enstone is learned through RDM at level 18; Protect is PLD-compatible.
spells.Enstone.levels={[5]=18}
spells.Protect.levels={[7]=1}
spells.Shell.levels={[7]=1}
local skills={}
for _, entry in ipairs({{33,'Healing Magic'}, {34,'Enhancing Magic'}, {40,'Singing'}, {38,'Summoning Magic'}}) do
 skills[entry[1]]={en=entry[2]}
end
local items={}
for i=6147,6179 do items[i]={en='Tome '..i} end
local resources={items=items,skills=skills,spells=setmetatable({}, {__index={with=function(_,key,name) return spells[name] end}})}
package.preload['resources']=function()return resources end
package.preload['chat']=function() string.color=function(str,color)return str end return {} end
package.preload['packets']=function()return {parse=function(direction,data) return data end} end
local previous_time=os.time
os.time=function()return clock end
windower={}
windower.register_event=function(name,fn) events[name]=fn end
windower.add_to_chat=function(channel,text) assert(channel==0); chat[#chat+1]=text end
windower.send_command=function(cmd) output[#output+1]=cmd end
windower.ffxi={
 get_player=function()return player end,
 get_info=function()return info end,
 get_spells=function()return owned end,
 get_spell_recasts=function() return {} end,
 get_mob_by_name=function(name) if mob and name == mob.name then return mob end end,
 get_mob_by_target=function()return nil end,
 get_items=function()return {} end,
}
local function advance(s)
  for _=1,s do clock=clock+1; events.prerender() end
end
local function command(a,b) events['addon command'](a,b) end
local function assert_command(s)
 assert(output[#output]==s, 'Expected command '..s..' got '..tostring(output[#output]))
end
_addon = {}
local source = debug.getinfo(1, 'S').source:sub(2)
local directory = source:match('^(.*)[/\\][^/\\]+$') or '.'
dofile(directory .. '/../SkillTrainer.lua')
assert(#output==0, 'never cast on load')
local function last_command(expected)
 assert(output[#output]==expected, 'Expected '..expected..', got '..tostring(output[#output]))
end
command('target','me')
command('spell','Enstone')
assert(#output==0, 'setting spell does not cast')
command('enhancing','5')
advance(2)
last_command('input /ma "Enstone" <me>')
command('status')
assert(chat[#chat]:find('target self', 1, true) and chat[#chat]:find('spell Enstone',1,true), 'status reflects selected Enstone and self')
local n=#output
command('target','Myrr')
command('status')
assert(chat[#chat]:find('target self',1,true),'cannot direct selected Enstone to Myrr')
assert(#output==n,'target change alone never casts')
command('spell','auto')
advance(3)
last_command('input /ma "Protect" <me>')
command('target','Myrr')
advance(3)
last_command('input /ma "Protect" "Myrr"')
command('spell','Enstone') -- Must not override named target with a self-only spell.
command('status')
assert(chat[#chat]:find('spell Protect',1,true) and chat[#chat]:find('target Myrr',1,true), 'failed Enstone choice preserves named target')
command('target','me')
command('spell','enstone') -- lowercase must resolve canonical name
advance(3)
last_command('input /ma "Enstone" <me>')
local old=#output
command('spell','unapproved;input')
advance(1)
assert(#output==old,'invalid spell choice must not inject a command')
command('stop')
command('enhancing','5') -- Preference persists across sessions for this client.
advance(2)
last_command('input /ma "Enstone" <me>')
-- MP recovery and resumption are inherited from the existing training state machine.
player.vitals.mp=30
advance(15)
last_command('input /heal on')
player.status=33
advance(2)
player.vitals.mp=330
advance(2)
last_command('input /heal off')
player.status=0
advance(4)
last_command('input /ma "Enstone" <me>')
command('stop')
command('spell','auto')
command('enhancing','5')
advance(2)
last_command('input /ma "Protect" <me>')
local before=#output
local pkt={['Enhancing Magic Level']=98,['Enhancing Magic Capped']=true}
events['incoming chunk'](0x062,pkt,nil,false,false)
advance(15)
assert(#output==before, 'server cap stops casts after training')
os.time=previous_time
print('PASS: PLD/RDM Enstone preference, named target guard, auto restore, invalid input, restart, MP rest/stand, cap stop')
