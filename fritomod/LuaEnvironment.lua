if nil ~= require then
	require "fritomod/basic";
	require "fritomod/currying";
	require "fritomod/OOP-Class";
	require "fritomod/OOP";
	require "fritomod/Functions";
	require "fritomod/Lists";
end;

LuaEnvironment=OOP.Class();

function LuaEnvironment:Constructor(globals, parent)
	if parent then
		assert(OOP.InstanceOf(LuaEnvironment, parent), "parent must be a LuaEnvironment");
		self.parent = parent;
	end;

	globals = globals or _G;
	local env = self;
	self.globals=setmetatable({}, {
		__index=function(self, name)
			-- We use a function to hide the reference to globals.
			local value = env:Get(name);
			if value == nil then
				value = globals[name];
			end;
			return value;
		end,

		__newindex = function(self, name, value)
			return env:Set(name, value);
		end
	});

	-- Ordered list of loader functions, which provide ways
	-- to load a module specified by name.
	self.loaders={};

	-- Table of loaded modules, mapped by module name. If a module
	-- has been loaded, it will be set to true in this table.
	self.loaded={};

	-- Table of proxy functions, mapped by name.
	self.proxies = {};

	-- Ordered list of injected tables and functions.
	self.injected = {};

	-- Table of exported variables, mapped by name.
	self.exported = {};

	-- Override some globals to call our methods instead
	self:Set("_G", self.globals);
	self:Set("require",    Curry(self, "Require"));
	self:Set("loadfile",   Curry(self, "LoadModule"));
	self:Set("loadstring", Curry(self, "LoadString"));
end;

-- Get the value in this environment with the specified name. Proxies, lazy values,
-- injected tables, and parents will all be invoked if necessary to retrieve this
-- value.
function LuaEnvironment:Get(name)
	local value = rawget(self.globals, name);
	if value ~= nil then
		return value;
	end;
	if self.proxies[name] then
		local proxy = self.proxies[name];
		value = proxy(name);
		if value ~= nil then
			return value;
		end;
	end;
	for _, injected in ipairs(self.injected) do
		if type(injected) == "table" then
			value = injected[name];
		else
			value = injected(name);
		end;
		if value ~= nil then
			return value;
		end;
	end;
	if self.parent then
		value = self.parent:Get(name);
		if value ~= nil then
			return value;
		end;
	end;
	assert(value == nil, "Non-nil values must not be discarded");
	return nil;
end;

-- Set the environment variable with the specified name to the specified
-- value. If the name has been exported, this operation will be forwarded
-- to the parent.
function LuaEnvironment:Set(name, value)
	if self.exported[name] then
		return self.parent:Set(name, value);
	end;
	rawset(self.globals, name, value);
end;

-- Change the environment variable with the specified name to the
-- specified value. This method behaves identically to :Set, but
-- a function will be returned to undo this operation.
function LuaEnvironment:Change(name, value)
	local old = self:Get(name);
	self:Set(name, value);
	return Functions.OnlyOnce(self, "Set", name, old);
end;

-- Export the variable with the specified name to the parent environment.
-- Subsequent set operations will be forwarded to the parent, bypassing
-- this environment's table.The value will be immediately forwarded to
-- the parent.
--
-- The LuaEnvironment must have a parent, otherwise this operation will
-- fail with an exception.
function LuaEnvironment:Export(name)
	if type(name) == "table" and #name > 0 then
		for i=1, #name do
			self:Export(name[i]);
		end;
		return;
	end;
	if self.exported[name] then
		return;
	end;
	assert(self.parent, "Refusing to export without a parent");
	self.exported[name] = true;
	local value = self.globals[name];
	rawset(self.globals, name, nil);
	self.parent:Set(name, value);
end;

-- Provide a proxy for the specified name. If the specified name
-- is not present within this environment's globals table, then
-- this proxy will be used to provide it. Subsequent accesses of
-- the named variable will also invoke the proxy. As a result,
-- different values may be returned for the same name with the
-- same proxy.
--
-- No set operation is implied by this method; it is up to clients
-- to set this value within an environment. Otherwise, invocations
-- will continue to defer to the proxy for a value.
--
-- If the specified name is a list, then each name within that
-- list will be proxied.
function LuaEnvironment:Proxy(name, provider, ...)
	provider = Curry(provider, ...);
	if type(name) == "table" and #name > 0 then
		local removers = {};
		for i=1, #name do
			table.insert(removers, self:Proxy(name[i], provider));
		end;
		return Functions.OnlyOnce(Lists.CallEach, removers);
	end;
	self.proxies[name] = provider;
	return Functions.OnlyOnce(function()
		self.proxies[name] = nil;
	end);
end;

-- Provide a lazy value for the specified name. When the name is
-- Subsequently retrieved, the specified provider function will be
-- invoked to create it. The returned value, if true, will be set
-- within this environment, and the proxy will not be used again.
function LuaEnvironment:Lazy(name, provider, ...)
	provider = Curry(provider, ...);
	return self:Proxy(name, function(self, name)
		local value = provider(name);
		if value == nil then
			return nil;
		end;
		self:Set(name, value);
		self.proxies[name] = nil;
		return value;
	end, self);
end;

-- Inject the specified function or table into this environment.
-- If no value or proxied value can be found for a given name,
-- these injected values will be invoked. Each injected value
-- will be called with the given name. If it returns a non-nil
-- value, it will be used as the variable.
--
-- No set operation is implied by this method; it is up to clients
-- to set this value within an environment. Otherwise, invocations
-- will continue to defer to this injected for a value.
function LuaEnvironment:Inject(injected, ...)
	if type(injected) ~= "table" or select("#", ...) > 0 then
		injected = Curry(injected, ...);
	end;
	return Lists.Insert(self.injected, injected);
end;

function LuaEnvironment:AddLoader(loader, ...)
	loader=Curry(loader, ...);
	return Lists.Insert(self.loaders, loader);
end;

function LuaEnvironment:LoadFunction(runner, ...)
	runner=Curry(runner, ...);
	setfenv(runner, self.globals);
	return runner;
end;

function LuaEnvironment:Run(runner, ...)
	if type(runner) == "string" and select("#", ...) == 0 then
		return self:LoadString(runner)();
	end;
	return self:LoadFunction(runner, ...)();
end;

function LuaEnvironment:LoadString(str)
	return self:LoadFunction(loadstring(str));
end;

function LuaEnvironment:LoadModule(file)
	local errors = {};
	for _, loader in ipairs(self.loaders) do
		local runner, err = loader(self, file);
		if IsCallable(runner) then
			return self:LoadFunction(runner);
		elseif runner==false then
			return Noop;
		elseif err then
			errors[loader] = err;
		end;
	end;
	local str = "Could not load: "..file;
	for loader, err in pairs(errors) do
		str = str .. "\nError from loader: " .. err;
	end;
	error(str);
end;

function LuaEnvironment:Require(name)
	if self.loaded[name] then
		return;
	end;
	local runner=self:LoadModule(name);
	if runner ~= Noop then
		self:OnRequireLoading(name);
		runner();
		self.loaded[name]=true;
		self:OnRequireFinish(name);
	end;
end;

-- Hook that is run immediately before requiring the specified file.
function LuaEnvironment:OnRequireLoading(package)
	-- Noop. Free to implement as a listener.
end;

-- Hook that is run immediately after successfully requiring the specified file.
function LuaEnvironment:OnRequireFinish(package)
	-- Noop. Free to implement as a listener.
end;

-- vim: set noet :
