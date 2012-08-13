if nil ~= require then
	require "fritomod/basic";
	require "fritomod/currying";
	require "fritomod/OOP-Class";
	require "fritomod/Functions";
	require "fritomod/Lists";
end;

LuaEnvironment=OOP.Class();

function LuaEnvironment:Constructor(globals)
	globals = globals or _G;
	local env = self;
	self.globals=setmetatable({}, {
		__index=function(self, k)
			-- We use a function to hide the reference to globals.
			local value = env:Get(k);
			if value == nil then
				value = globals[k];
			end;
			return value;
		end
	});
	self.globals._G=self.globals;
	self.globals.require=Curry(self, "Require");
	self.globals.loadfile=Curry(self, "LoadFile");
	self.globals.loadstring=Curry(self, "LoadString");
	self.loaders={};
	self.loaded={};
	self.proxies = {};
	self.lazyValues = {};
end;

function LuaEnvironment:Get(name)
	local value = rawget(self.globals, name);
	if value ~= nil then
		return value;
	end;
	if self.lazyValues[name] then
		local proxy = self.lazyValues[name];
		value = proxy(name);
		if value ~= nil then
			self:Set(name, value);
			return self:Get(name);
		end;
	end;
	if self.proxies[name] then
		local proxy = self.proxies[name];
		value = proxy(name);
		if value ~= nil then
			return value;
		end;
	end;
	return nil;
end;

function LuaEnvironment:Set(k, v)
	self.globals[k]=v;
end;

function LuaEnvironment:Lazy(name, provider, ...)
	provider = Curry(provider, ...);
	if type(name) == "table" and #name > 0 then
		local removers = {};
		for i=1, #name do
			table.insert(removers, self:Lazy(name[i], provider));
		end;
		return Functions.OnlyOnce(Lists.CallEach, removers);
	end;
	self.lazyValues[name] = provider;
	return Functions.OnlyOnce(function()
		self.lazyValues[name] = nil;
	end);
end;

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

function LuaEnvironment:Change(k, v)
	local old = self:Get(k);
	self:Set(k, v);
	return Functions.OnlyOnce(self, "Set", k, old);
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

function LuaEnvironment:LoadFile(file)
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

function LuaEnvironment:Require(package)
	if self.loaded[package] then
		self:OnRequireIgnored(package);
		return;
	end;
	local runner=self:LoadFile(package);
	if runner ~= Noop then
		self:OnRequireLoading(package);
		runner();
		self.loaded[package]=true;
		self:OnRequireFinish(package);
	else
		self:OnRequireSkipped(package);
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

-- Hook that is run if the package was intentionally skipped by this environment.
function LuaEnvironment:OnRequireSkipped(package)
	-- Noop. Free to implement as a listener.
end;

-- Hook that is run if the package was already loaded and does not need to be required.
function LuaEnvironment:OnRequireIgnored(package)
	-- Noop. Free to implement as a listener.
end;

LuaEnvironment.Loaders={};
local loaders=LuaEnvironment.Loaders;

function loaders.Filesystem(loader, env, package)
	return function(env, package)
		local file=package;
		if not file:find("\.lua$") then
			file=package..".lua";
		end;
		local runner, err=loader(file);
		if runner then
			return runner;
		end;
		return nil, err;
	end;
end;

function loaders.Ignore(...)
	local ignored={...};
	return function(env, package)
		for i=1, #ignored do
			if package==ignored[i] then
				return false;
			end;
		end;
	end;
end;

-- vim: set noet :
