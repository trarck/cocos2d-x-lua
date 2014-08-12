-- require "cocos2dx.Cocos2d"
-- require "cocos2dx.Cocos2dConstants"
require "cocos2dx.class"

-- cclog
cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function initGLView()
    local director = cc.Director:getInstance()
    local glView = director:getOpenGLView()
    if nil == glView then
        glView = cc.GLView:create("CCLua")
        director:setOpenGLView(glView)
    end

    -- glView:setDesignResolutionSize(480, 320, cc.ResolutionPolicy.NO_BORDER)
    --
    -- --turn on display FPS
    -- director:setDisplayStats(true)
    --
    -- --set FPS. the default value is 1.0/60 if you don't call this
    -- director:setAnimationInterval(1.0 / 60)
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
	
	initGLView()
	
    local scene=cc.Scene:create()

    cc.Director:getInstance():runWithScene(scene)

	cc.MenuItemFont:setFontName("Marker Felt")

	local function menuCallback1(sender)
		cclog("test1")
	end
	
    local item1 = cc.MenuItemFont:create("test1")
    item1:registerScriptTapHandler(menuCallback1)

    item1:setFontSizeObj(20)
	
    local  menu = cc.Menu:create()

    menu:addChild(item1)
	
	menu:alignItemsVertically()

    scene:addChild(menu)
	
	local TestA=class();
	
	function TestA:ctor()
		print("TestA:ctor")
		self.ma=10
	end
	
	function TestA:funa()
		print("TestA:funa")
		cclog("ma:%d",self.ma)
	end
    
	local ta=TestA.new()
	
	ta:funa()
	
	local TestB=class(TestA)
	
	function TestB:ctor()
		print("TestB:ctor")
	end
	
	function TestB:funb()
		print("TestB:funb")
		self:funa()
	end
	
	local tb=TestB.new()
	
	tb:funb()
	
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
