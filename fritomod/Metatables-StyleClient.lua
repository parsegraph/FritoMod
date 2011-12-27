if nil ~= require then
	require "fritomod/currying";
	require "fritomod/Metatables";
	require "fritomod/Lists";
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
	assert(getmetatable(t) == nil, "t must not have a metatable");
	local styles = {};
	do
		local trash={};
		for k,v in pairs(t) do
			local name = StyleName(k);
			styles[name] = v;
			table.insert(trash,k);
		end;
		for i=1,#trash do
			t[trash[i]] = nil;
		end;
	end;

	t._styles = styles;

	local processors = {};
	t.ProcessedStyle = FunctionTable(t, processors);

	local listeners = {};
	t.AddListener = ForcedFunction(t, Curry(Lists.Insert, listeners));

	local parents = {};
	t._parents = parents;

	local function Update(old)
		local new = t:Compute();
		for k,v in pairs(old) do
			if new[k] ~= old[k] then
				Lists.CallEach(listeners, k, new[k]);
			end;
			new[k] = nil;
		end;
		for k,v in pairs(new) do
			Lists.CallEach(listeners, k, new[k]);
		end;
	end;

	t.Inherits = ForcedFunction(t, function(parent)
		local old = t:Compute();
		local remover = Lists.Insert(parents, parent);
		local lremover = Noop;
		if not parent.Inherits then
			Metatables.StyleClient(parent);
		end;
		local lremover = parent:AddListener(function(key, value)
			if styles[key] == nil then
				-- Cascade! Our effective style has changed.
				Lists.CallEach(listeners, key, value);
			end;
		end);
		Update(old);
		return Functions.OnlyOnce(function()
			local old=t:Compute();
			lremover();
			remover();
			Update(old);
		end);
	end);

	t.Compute = ForcedFunction(t, function(rv)
		rv = rv or {};
		for i=1,#parents do
			if parents[i].Compute then
				parents[i]:Compute(rv);
			end;
		end;
		Tables.Update(rv, styles);
		return rv;
	end);

	return setmetatable(t, {
		__index = function(self, key)
			if key == nil then
				return nil;
			end;
			key = StyleName(key);
			local v = styles[key];
			if v == nil then
				for i=#parents,1,-1 do
					v = parents[i][key];
					if v ~= nil then
						break;
					end;
				end;
			end;
			return v;
		end,
		__newindex = function(self, key, value)
			key = StyleName(key);
			local p = processors[key];
			if p then
				local rv = p(value);
				if rv ~= nil then
					value = rv;
				end;
			end;
			if value == styles[key] then
				return;
			end;
			styles[key] = value;
			-- Intentionally use self[key] to ensure nil values use inherited values.
			Lists.CallEach(listeners, key, self[key]);
		end
	});
end;
