if nil ~= require then
	require "fritomod/currying";
	require "fritomod/Functions";
	require "fritomod/OOP-Class";
	require "fritomod/Lists";
end;

ToggleDispatcher=OOP.Class();

function ToggleDispatcher:Constructor(name)
	self.name=name or tostring(self);
	self.listeners={};
	self.deadListeners={};
	self.resetters={};
end;

function ToggleDispatcher:AddInstaller(func, ...)
	self.installers=self.installers or {};
	return Lists.Insert(self.installers, Curry(func, ...));
end;

function ToggleDispatcher:Install()
	trace("Installing dispatcher %q", self.name);
	if self.installers then
		self.uninstallers=Lists.MapCall(self.installers);
	end;
end;

function ToggleDispatcher:Uninstall()
	trace("Uninstalling dispatcher %q", self.name);
	if self.uninstallers then
		Lists.CallEach(self.uninstallers);
		self.uninstallers=nil;
	end;
end;

function ToggleDispatcher:Add(listener, ...)
	listener=Curry(listener, ...);
	if #self.listeners - #self.deadListeners <= 0 then
		self:Install();
	end;
	table.insert(self.listeners, listener);
	return Functions.OnlyOnce(function()
		table.insert(self.deadListeners, listener);
		if not self.iterating then
			self:CleanUp();
		end;
	end);
end;

function ToggleDispatcher:HasListeners()
	return #self.listeners > 0;
end;

function ToggleDispatcher:Fire(...)
	self:Reset();
	self.iterating=true;
	trace("Firing dispatcher %q", self.name);
	for _, listener in ipairs(self.listeners) do
		self:_FireListener(listener, ...);
	end;
	self.iterating=false;
	self:CleanUp();
end;

function ToggleDispatcher:_FireListener(listener, ...)
	if Lists.Contains(self.deadListeners, listener) then
		return;
	end;
	local resetter=listener(...);
	if resetter then
		table.insert(self.resetters, resetter);
		self.resetters[listener]=resetter;
		self.resetters[resetter]=listener;
	end;
end;

function ToggleDispatcher:CleanUp()
	assert(not self.iterating, "Cannot clean during iteration");
	for _, deadListener in ipairs(self.deadListeners) do
		Lists.Remove(self.listeners, deadListener);
		if self.resetters[deadListener] then
			local resetter=self.resetters[deadListener];
			Lists.Remove(self.resetters, resetter);
			self.resetters[deadListener]=nil;
			self.resetters[resetter]=nil;
		end;
	end;
	if #self.listeners == 0 and self.Uninstall then
		self:Uninstall();
	end;
end;

function ToggleDispatcher:Reset(...)
	trace("Resetting dispatcher %q", self.name);
	for _, resetter in ipairs(self.resetters) do
		if self.resetters[resetter] then
			resetter(...);
		end;
	end;
	self.resetters={};
	self:CleanUp();
end;
