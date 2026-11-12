-- Offline mock regression for Debuffed2's factory settings and aliases.
-- Run from the addon folder: texlua --luaonly tests/defaults_spec.lua
-- No claim of Windower 4, DirectInput, or live game verification.
package.path = './?.lua;' .. package.path
local calls = {}
local ui_w, ui_h = 3840, 2160
local saved = 0
local notifications = {}

local function primitive(props)
    local pos = props and props.pos or {x=0, y=0}
    local size = props and props.size or {width=0,height=0}
    local o = {x=pos.x or 0,y=pos.y or 0,w=size.width or 0,h=size.height or 0,props=props}
    local function do_pos(self, x, y)
        if x == nil then return self.x,self.y end
        self.x,self.y=x,y
    end
    local function do_size(self, w, h)
        if w == nil then return self.w,self.h end
        self.w,self.h=w,h or w
    end
    local handlers={pos=do_pos,size=do_size,pos_x=function(self) return self.x end,pos_y=function(self) return self.y end}
    return setmetatable(o,{__index=function(_,k)
        return handlers[k] or function() end
    end})
end
package.preload.images = function()
    return {new=function(_,props) return primitive(props) end,destroy=function() end}
end
package.preload.texts = function()
    return {new=function(_,props) return primitive(props) end,destroy=function() end}
end
package.preload.config = function()
    return {load=function(t)
        t.save=function() saved=saved+1 end
        return t
    end}
end
package.preload.packets = function() return {} end
package.preload.resources = function() return {spells={},buffs={}} end
package.preload.logger = function() return {} end
package.preload.chat = function()
    string.color=function(s) return s end
    return {}
end
function S(t) return t or {} end
function T(t) return t or {} end
function L(t)
    return setmetatable(t or {},{__index={concat=function(self,sep) return table.concat(self,sep) end}})
end
_addon = {}
windower = {
    addon_path='./',
    file_exists=function() return false end,
    add_to_chat=function(_,line) notifications[#notifications+1]=line end,
    send_command=function(command) calls[#calls+1]=command end,
    get_windower_settings=function() return {ui_x_res=ui_w,ui_y_res=ui_h} end,
    ffxi={get_info=function() return {logged_in=false} end, get_player=function() return {id=1,name='Cioara'} end},
    register_event=function(...)
        local args={...}
        local fn=args[#args]
        for i=1,#args-1 do calls[args[i]]=fn end
    end,
}

assert(loadfile('Debuffed2.lua'))()
assert(_addon.name=='Debuffed2')
assert(_addon.version=='1.0.0.4-debuffed2-test2-cioara-defaults')
assert(table.concat(_addon.commands,',')=='db,db2,debuffed2')
assert(defaults.iconsize==36 and defaults.slots==18 and defaults.wrap==9)
assert(defaults.pos.x==1500 and defaults.pos.y==100)
assert(defaults.draggrid==10 and defaults.targetname==false)
assert(defaults.iconspacing==5 and defaults.timers==true)

calls['addon command']('help')
local saw_alias = false
for _,line in ipairs(notifications) do
    if line:find('Commands %(//db and //db2%)') then saw_alias = true end
end
assert(saw_alias,'Both aliases should appear in chat help')

local Renderer=require('debuffed2_renderer')
local renderer=Renderer.new(defaults)
assert(#renderer.guides==18)
renderer:render(nil,{})
assert(renderer.footprint_width==376 and renderer.footprint_height==97,'Expected 9 columns, 2 rows, 36px icons')
assert(renderer.backdrop.x==1500 and renderer.backdrop.y==100)
assert(renderer.guides[1].x==1506 and renderer.guides[1].y==106)
assert(renderer.guides[10].x==1506 and renderer.guides[10].y==147)
local nx,ny=renderer:constrain_anchor(1512,112,true)
assert(nx==1510 and ny==110,'Snap origin must be absolute')
ui_w,ui_h=960,540
renderer:sync_position(false)
assert(renderer.backdrop.x==584,'Position must bound on smaller clients')
renderer:flush_position()
assert(defaults.pos.x==584 and saved==1,'Clamped anchor must be saved')
-- Layout calculations come from current unscaled icon dimensions and the
-- same parent anchor, not from the previous layout's rounded pixel results.
for _,width in ipairs({3840,1600,1280,960}) do
    ui_w,ui_h=width,720
    for _,size in ipairs({12,24,36,96,36}) do
        defaults.iconsize=size
        renderer:layout()
        local fw=12+9*size+8*5
        local fh=12+2*size+5+8
        assert(renderer.footprint_width==fw and renderer.footprint_height==fh)
        local x,y=renderer.backdrop:pos()
        assert(x>=0 and x<=math.max(0,width-fw))
        assert(y>=0 and y<=math.max(0,720-fh))
        local gx,gy=renderer.guides[1]:pos()
        assert(gx==x+6 and gy==y+6)
        local tenth_x,tenth_y=renderer.guides[10]:pos()
        assert(tenth_x==x+6 and tenth_y==y+6+size+5)
    end
end
renderer:flush_position()
renderer:destroy()
print('PASS: Debuffed2 factory 36px / 18 slots / wrap9 / position 1500,100, both aliases, shared grid, 4 window widths, 4 icon sizes, saved bound')
