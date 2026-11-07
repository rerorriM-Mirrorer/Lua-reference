-- Windower-free behavior checks for SkillTrainer named-target support.
local events, output, chat, clock = {}, {}, {}, 1700
local player = {
 name='Lionstag', main_job='WHM', main_job_id=3, main_job_level=55,
 sub_job='RDM', sub_job_id=5, sub_job_level=25, status=0,
 skills = {healing_magic=110, enhancing_magic=95, singing=nil, summoning_magic=nil},
 vitals = {hp=400,max_hp=400,mp=350,max_mp=350},
}
local info = {logged_in=true,menu_open=false,chat_open=false,zone=230}
local mob = {id=12345,name='Myrr',hpp=100}
local names = {Barstone=100, Barstonra=101, Barfire=102, Barfira=103, Protect=104, Shell=105,
    Enthunder=106, Regen=107, Aquaveil=108, Blink=109, Cure=110, ['Army\'s Paeon']=111, Carbuncle=112}
local spells, owned = {}, {}
for name,id in pairs(names) do
 spells[name]={id=id,en=name,mp_cost=name=='Protect' and 9 or 10,cast_time=1,recast=5,recast_id=id,levels={[3]=1}}
 owned[id]=true
end
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
local addon = directory .. '/../SkillTrainer.lua'
dofile(addon)
assert(#output == 0,'addon load must not cast')
command('target','Myrr')
command('enhancing','5')
assert(#output == 0,'start should not cast immediately')
advance(2)
assert_command('input /ma "Protect" "Myrr"')
assert(#output == 1,'one named cast')
local first=#output
mob=nil
advance(12)
assert(#output == first,'no cast while named target missing')
local wait_count=0
for _,msg in ipairs(chat) do if msg:find('Waiting for target Myrr',1,true) then wait_count=wait_count+1 end end
assert(wait_count==1,'missing target report only once')
mob={id=456,name='Myrr',hpp=100,distance=500}
advance(2)
assert(#output==first,'no cast when visible but beyond 20 yalms')
mob.distance=100
advance(2)
assert(#output==2,'resumes when target reappears')
assert_command('input /ma "Protect" "Myrr"')
-- Reverting to self changes the spell selection, without reloading.
command('target','me')
advance(3)
assert_command('input /ma "Barstone" <me>')
local preceding=#output
command('target','Myrr;input /ma "Cure" <me>')
command('status')
assert(chat[#chat]:find('target self',1,true),'malicious target rejected')
assert(#output==preceding,'target command itself must not issue casts')
command('stop')
-- Named Cure is supported and comes from the healing spell list.
command('target','Myrr')
command('healing','5')
advance(3)
assert_command('input /ma "Cure" "Myrr"')
command('stop')
-- Self-only modes must ignore named target.
player.skills.singing=20
command('singing','2')
advance(3)
assert_command('input /ma "Army\'s Paeon" <me>')
command('stop')
-- If external target is set with a running session, swap to Protect safely.
command('target','me')
command('enhancing','2')
advance(3)
assert_command('input /ma "Barstone" <me>')
command('target','Myrr')
advance(3)
assert_command('input /ma "Protect" "Myrr"')
command('stop')
-- Existing stop-on-server-cap behavior remains, independent of target.
command('enhancing','2')
local prior=#output
local pkt={['Enhancing Magic Level']=98,['Enhancing Magic Capped']=true}
events['incoming chunk'](0x062,pkt,nil,false,false)
advance(12)
assert(#output == prior,'capped skill must prevent further commands')
assert(chat[#chat]:find('Stopped Enhancing Magic',1,true),'skill cap stop')
os.time=previous_time
print('PASS: target casting, missing target pause/resume, self fallback, injection guard, Cure, song isolation, mid-session switch, cap stop')
