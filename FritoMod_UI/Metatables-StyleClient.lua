if nil ~= require then
	require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Metatables";

    require "FritoMod_Collections/Lists";
end;

if Metatables == nil then
	Metatables = {};
end;

local function StyleName(s)
	assert(s ~= nil, "style must not be nil");
	return tostring(s):lower();
end;

local function FunctionTable(t, container)
	return ForcedFunction(t, function(style, func, ...)
		style = StyleName(style);
		func = Curry(func, ...);
		container[style] = func;
	end);
end;

function Metatables.StyleClient(t)
	if not t then
		t = {};
	end;
	assert(type(t) == "table", "t must be a table. Type: " .. type(t));
	t.Inherits = ForcedFunction(t, Lists.Insert, t);

	local computedStyles = {};
	t.ComputedStyle = FunctionTable(t, computedStyles);
	t._computedStyles = computedStyles;

	local translatedStyles = {};
	t.TranslatedStyle = FunctionTable(t, translatedStyles);
	t._translatedStyles = translatedStyles;
	
	local processedStyles = {};
	t.ProcessedStyle = FunctionTable(t, processedStyles);

	local explicitStyles = {};
	t._explicitStyles = explicitStyles;
	return setmetatable(t, {
		__index = function(self, key)
			if key == nil then
				return nil;
			end;
			key = StyleName(key);
			local v = explicitStyles[key];
			if v == nil then
				local c = computedStyles[key] or Noop;
				v = c(key);
				if v == nil then
					for i=#self,1,-1 do
						v = self[i][key];
						if v ~= nil then
							break;
						end;
					end;
				end;
			end;
			local t = translatedStyles[key] or Functions.Return;
			return t(v);
		end,
		__newindex = function(self, key, value)
			key = StyleName(key);
			local p = processedStyles[key];
			if p then
				local rv = p(value);
				if rv ~= nil then
					value = rv;
				end;
			end;
			explicitStyles[key] = value;
		end
	});
end;
