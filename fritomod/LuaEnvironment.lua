-- An object-oriented view into a Lua scripting context
--
-- LuaEnvironments provide environments for global access to
-- Lua code. This environment originally was created for testing
-- purposes, since it would isolate global acceses, preventing
-- leakage from broken test cases. It has since expanded to be a
-- more general-purpose environment.
--
-- When Lua code is executed, it is setfenv'd into this environment.
-- setfenv allows us to redirect global gets and sets to a table
-- of our choosing. We exploit this functionality to add several
-- different ways to provide global values:
--
-- * Name-specific proxying
-- * Table-wide proxying
-- * Parent access
--
-- See :Proxy, :Lazy, and :Inject for more details.
--
-- Set operations (global sets if within Lua code) will affect only
-- this environment. If you want a global set to affect a parent's
-- environment (such as affecting the true globals table), then you
-- will need to use :Export.
--
-- Importing named modules is supported by require, and it behaves
-- similarly to the real Lua counterpart.
if nil ~= require then
	require "fritomod/basic";
	require "fritomod/currying";
	require "fritomod/OOP-Class";
	require "fritomod/OOP";
	require "fritomod/Functions";
	require "fritomod/Lists";
	require "fritomod/FauxLuaEnvironment";
end;

LuaEnvironment = OOP.Class("LuaEnvironment");

function LuaEnvironment:Constructor(parent)
	if OOP.InstanceOf(LuaEnvironment, parent) then
		self.parent = parent;
	else
		if not parent then
			parent = _G;
		end;
        self.parent = FauxLuaEnvironment:New(parent);
	end;
	assert(self.parent, "Parent must be provided");

	local env = self;
	self.globals = setmetatable({}, {
		__index = function(self, name)
			return env:Get(name);
		end,

		__newindex = function(self, name, value)
			return env:Set(name, value);
		end
	});

	-- Ordered list of loader functions, which provide ways
	-- to load a module specified by name.
	self.moduleLoaders = {};

	-- Table of loaded modules, mapped by module name. If a module
	-- has been loaded, it will be set to true in this table.
	self.modulesLoaded = {};

	-- Table of proxy functions, mapped by name.
	self.proxies = {};

	-- Ordered list of injected tables and functions.
	self.injected = {};

	-- Table of exported variables, mapped by name.
	self.exported = {};

	self.metadata = {};

	-- Override some globals to call our methods instead
	self:Set("_G",         self.globals);
	self:Set("require",    Curry(self, "Require"));
	self:Set("loadfile",   Curry(self, "LoadModule"));
	self:Set("loadstring", Curry(self, "LoadString"));
end;

function LuaEnvironment:Globals()
	return self.globals;
end;

-- Arbitrary storage for use with connectors that are aware of the environment.
function LuaEnvironment:Metadata()
	return self.metadata;
end;

function LuaEnvironment:SetParser(parser, ...)
	if parser or select("#", ...) > 0 then
		self.parser = Curry(parser, ...);
	else
		self.parser = nil;
	end;
end;

function LuaEnvironment:GetParser()
	if self.parser then
		return self.parser;
	end;
	return function(text, name)
		if _VERSION == "Lua 5.1" then
			return self:LoadFunction(assert(loadstring(text)));
		end;
		return load(text, name, "t", self:Globals());
	end;
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
	return self.parent:Get(name);
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
	local remover;
	remover = self:Proxy(name, function(self, name)
		local value = provider(name);
		if value == nil then
			return nil;
		end;
		self:Set(name, value);
		remover();
		return value;
	end, self);
	return remover;
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

-- Adds a module loader into this enivronment. It will be used to
-- provide modules for LoadModule.
--
-- The module loader should expect a given module name as the only
-- argument.
--
-- If the module loader successfully loads that module, then a function
-- should be returned.
--
-- If the module loader does not support the name, then nil should be
-- returned.
--
-- If the module loader supports the name, but failed to load it, then
-- false, followed by an error message, should be returned.
--
-- Errors from module loaders will cause module loading to immediately
-- fail, whereas unsupported names will be passed up to parents. If a
-- module is not supported by any module loader in the entire hierarchy,
-- an error will be thrown.
function LuaEnvironment:AddLoader(loader, ...)
	loader = Curry(loader, ...);
	return Lists.Insert(self.moduleLoaders, loader);
end;

-- Loads this environment into the specified function. Global accesses from
-- that function will defer to this environment. Require calls will alsod
-- defer to this environment.
--
-- setfenv will only affect the immediate function provided; functions that
-- are invoked within the specified function will use their own environment,
-- unless they were created within the specified function.
--
-- setfenv was removed in Lua 5.2, so this function will not work if you're
-- running that version. There are ways to emulate setfenv's behavior, but
-- it's hackish so I'd prefer not to have it here.
function LuaEnvironment:LoadFunction(runner)
	assert(setfenv ~= nil, "setfenv must be defined for LoadFunction to work");
	assert(type(runner) == "function",
		"runner must be a function (curried methods are not allowed)");
	-- We must setfenv before we curry, since currying will introduce
	-- an intermediate function.
	setfenv(runner, self.globals);
	return runner;
end;

function LuaEnvironment:Run(runner, ...)
	if type(runner) == "string" then
		return assert(self:LoadString(runner))(...);
	end;
	return self:LoadFunction(runner)(...);
end;

function LuaEnvironment:LoadString(str, source)
	return self:GetParser()(str, source);
end;

-- Returns a function that will Load a named module into this environment.
-- Named modules, typically things like files in a filesystem, are provided as
-- a convenient way to load a logical group of code into this environment.
--
-- Modules are provided by module loaders - these are added to this
-- environment via :AddLoader. If no module loader supports the specified
-- name, then the parent's module loaders will be used.
--
-- A name that was not supported by any loader will cause an error.
function LuaEnvironment:LoadModule(name)
	assert(name, "Module name must not be falsy");
	local errors = {};
	for _, loader in ipairs(self.moduleLoaders) do
		local runner, err = loader(name);
		if runner then
			return self:LoadFunction(runner);
		elseif err then
			errors[loader] = err;
			errors.__hadErrors = true;
		end;
	end;
	if errors.__hadErrors then
		errors.__hadErrors = nil;
		local str = "Could not load module: "..name;
		for loader, err in pairs(errors) do
			err = tostring(err);
			str = str .. "\nError from loader: " .. err;
		end;
		error(str);
	end;
	return self:LoadFunction(self.parent:LoadModule(name));
end;

-- Returns whether the named module has been loaded. A module is considered
-- if this environment has loaded it, or a parent environment has loaded it.
function LuaEnvironment:IsLoaded(name)
	return self.modulesLoaded[name]
		or self.parent:IsLoaded(name);
end;

-- Conditionally load a module. The module will be loaded into this environment
-- if it has not been previously loaded. See :IsLoaded and :LoadModule
function LuaEnvironment:Require(name)
	self:OnRequireLoading(name);
	if self:IsLoaded(name) then
		self:OnRequireLoaded(name);
		return;
	end;
	local runner = self:LoadModule(name);
	if runner ~= Noop then
		runner();
		self.modulesLoaded[name]=true;
		self:OnRequireLoaded(name);
	end;
end;

-- Hook that is run immediately before requiring the specified named module.
function LuaEnvironment:OnRequireLoading(name)
	-- Noop. Free to implement as a listener.
end;

-- Hook that is run immediately after successfully
-- requiring the specified named module.
function LuaEnvironment:OnRequireLoaded(name)
	-- Noop. Free to implement as a listener.
end;

-- vim: set noet :
