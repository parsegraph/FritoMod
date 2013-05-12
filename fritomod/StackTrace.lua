if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/Lists";
end;

StackTrace=OOP.Class();

local function BlizzardStackTrace()
	assert(debugstack, "BlizzardStackTrace requires debugstack() to be available");
	return Lists.Map({("\n"):split(debugstack(4))}, function(stackLevel)
		local level={};
		local what, lineNum, funcInfo=(":"):split(stackLevel, 3);
		if what:find("^\\[C\\]$") then
			level.what="C";
			-- C functions don't have accessible line numbers.
			funcInfo=lineNum;
			lineNum=nil;
		elseif what:find("^\\(tail call\\)$") then
			level.namewhat="";
			-- Tail calls don't have any useful information.
			funcInfo, lineNum=nil;
		end;
		if what:find('^\\[string') then
			level.source=select(2, what:find([[^\[string "([^"]+)"\]$]]));
		else
			level.source=what;
		end;
		if funcInfo then
			if funcInfo:find("^ in main chunk$") then
				level.what="main";
			else
				local namewhat, name=select(2, funcInfo:find("^ in ([%a]+) (.+)$"));
				if name=="`?'" then
					level.what="Lua";
				else
					level.what="Lua";
					level.namewhat=namewhat;
					level.name=name;
				end;
			end;
		end;
		level.lineNum=lineNum;
		level.namewhat=level.namewhat or "";
		return level;
	end);
end;

local MAX_STACK_TRACE=999;
-- Returns the full stack trace, or up to MAX_STACK_TRACE levels of stack trace information. Each
-- stack level is represented by a table containing information provided by debug.getinfo.
--
-- returns
--	 a list of stack levels. Stack levels are in the format specified by debug.getinfo
-- throws
--	 if debug.getinfo is not available
local function LuaStackTrace()
	assert(debug and debug.getinfo, "FullStackTrace is not available without debug");
	local stackTrace = {};
	for i=4, MAX_STACK_TRACE do
		local stackLevel = debug.getinfo(i);
		if not stackLevel then
			break;
		end;
		if nil == stackLevel.name then
			stackLevel.name = ("<%s:%d>"):format(stackLevel.short_src, stackLevel.linedefined);
			stackLevel.namewhat = "function";
		end;
		table.insert(stackTrace, stackLevel);
	end;
	return stackTrace;
end;

function StackTrace:Constructor(stack)
	if stack then
		self.stack=Lists.Clone(stack);
	elseif debugstack then
		self.stack=BlizzardStackTrace();
	elseif debug then
		self.stack=LuaStackTrace();
	else
		error("No stack trace is available");
	end;
end;

function StackTrace:GetStack()
	return Lists.Clone(self.stack);
end;

function StackTrace:Skip(count)
	return StackTrace:New(Lists.Pop(self:GetStack(), count));
end;

function StackTrace:Head(count)
	return StackTrace:New(Lists.Head(self:GetStack(), count));
end;

function StackTrace:Tail(count)
	return StackTrace:New(Lists.Tail(self:GetStack(), count));
end;

function StackTrace:Filter(func, ...)
	return StackTrace:New(Lists.FilterValues(self:GetStack(), func, ...));
end;

