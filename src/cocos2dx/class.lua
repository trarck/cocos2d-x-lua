local _class={}

function objectInstanceofClass(obj, c)
	if c == nil then return false end
	local t = obj._class_type_
	while t do
		if t == c then
			return true
		end
		t = t.super
	end
	return false
end

function getClassName(obj,ns)
	local ctype =obj._class_type_
	
	ns=ns and ns or _G
	
	for key, ct in pairs(ns) do
		print(ctype,ct,key)
		if ctype == ct then
			return key
		end
	end
end

function class(super)
	local class_type={}
	class_type.ctor=false
	class_type.super=super
	class_type.new=function(...)
		local obj={}
		--云风放return obj前，无法再ctor函数中调用函数
		setmetatable(obj,{ __index= _class[class_type]})
		do
			local create
			create = function(c,...)
				if c.super then
					create(c.super,...)
				end
				if c.ctor then
					c.ctor(obj,...)
				end
			end

			create(class_type,...)
		end
		return obj
	end
	
	--extend native object
	class_type.extend=function (nativeObj,...)
		--get peer table
		local peerTable=tolua.getpeer(nativeObj)
		if not peerTable then
			peerTable={}
			tolua.setpeer(nativeObj,peerTable)
		end
		
		setmetatable(peerTable,{__index=_class[class_type]})
		do
			local create
			create = function(c,...)
				if c.super then
					create(c.super,...)
				end
				if c.ctor then
					c.ctor(nativeObj,...)
				end
			end

			create(class_type,...)
		end
		return nativeObj
	end

	local vtbl={}
	--type
	vtbl._class_type_ = class_type

	_class[class_type]=vtbl

	setmetatable(
		class_type,
		{	__newindex=
			function(t,k,v)
				vtbl[k]=v
			end,
			__index=vtbl
		}
	)

	if super then
		setmetatable(vtbl,{__index=
			function(t,k)
				local ret=_class[super][k]
				vtbl[k]=ret
				return ret
			end
		})
	end

	return class_type
end

--[[
local A=class()

local B=class(A)

local C=class(B)

local c=C:new()

local b=B:new()

print(objectInstanceofClass(b,C))

--]]