if nil ~= require then
	require "fritomod/basic";
	require "fritomod/currying";
	require "fritomod/OOP-Class";
	require "fritomod/Functions";
	require "fritomod/Lists";
end;

LuaEnvironment=OOP.Class();

function LuaEnvironment:Constructor(globals, parent)
	self.parent = parent;
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
		end
	});
	self.globals._G=self.globals;
	self.globals.require=Curry(self, "Require");
	self.globals.loadfile=Curry(self, "LoadModule");
	self.globals.loadstring=Curry(self, "LoadString");
	self.loaders={};
	self.loaded={};
	self.proxies = {};
	self.injected = {};
	self.exported = {};
end;

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

function LuaEnvironment:Set(name, value)
	if self.exported[name] then
		return self.parent:Set(name, value);
	end;
	self.globals[name] = value;
end;

function LuaEnvironment:Change(name, value)
	local old = self:Get(name);
	self:Set(name, value);
	return Functions.OnlyOnce(self, "Set", name, old);
end;

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

function LuaEnvironment:Require(package)
	if self.loaded[package] then
		self:OnRequireIgnored(package);
		return;
	end;
	local runner=self:LoadModule(package);
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

-- vim: set noet :
