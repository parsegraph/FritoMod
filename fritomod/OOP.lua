OOP = OOP or {};

-- Integrates a library into a given class. This takes all
-- public (non-double-underscored functions), and adds them
-- to the specified class.
function OOP.IntegrateLibrary(library, class)
	for funcName, func in pairs(library) do
		if not string.match(funcName, "^__") then
			class[funcName] = func;
		end;
	end
end

function OOP.InstanceOf(klass, instance)
    if OOP.IsInstance(klass) and OOP.IsClass(instance) then
        -- Allow confusion between InstanceOf and IsInstance
        return OOP.InstanceOf(instance, klass);
    end;
    assert(OOP.IsClass(klass), "A class must be provided, but I was given " .. tostring(klass) .. ".");
    if not OOP.IsInstance(instance) then
        return false;
    end;
    return instance.class:InheritsClass(klass);
end;
OOP.Instanceof = OOP.InstanceOf;

function OOP.IsInstance(...)
    if select("#", ...) > 1 then
        -- Allow confusion between InstanceOf and IsInstance
        return OOP.InstanceOf(...);
    end;
    local candidate = ...;
	if type(candidate) ~= "table" then
		return false;
	end;
	return OOP.IsClass(rawget(candidate, "class"));
end;

function OOP.IsClass(candidate)
	if type(candidate) ~= "table" then
		return false;
	end;
	if rawget(candidate, "class") then
		return false;
	end;
	return IsCallable(rawget(candidate, "New"));
end;

function OOP.IsDestroyed(obj)
	if type(obj) ~= "table" then
		return false;
	end;
    return obj.destroyed == true;
end;

function OOP.Ancestors(klass)
    if OOP.IsInstance(klass) then
        return OOP.Ancestors(klass.class);
    end;
    local ancestors = {klass};
    while klass.super and klass.super ~= klass do
        table.insert(ancestors, klass.super);
        klass = klass.super;
    end;
    return ancestors;
end;

function OOP.Annihilate(obj)
	local id = obj:ID();
	local name = obj:ToString();
	local DESTROYED_METATABLE = {
		__index = function(self, key)
			if tostring(key):match("^log") then
				return self.class[key];
			end;
			error(name .. " has been destroyed and cannot be reused for getting " .. tostring(key));
		end,
		__newindex = function(self, key)
			error(name .. " has been destroyed and cannot be reused for setting " .. tostring(key));
		end,
		__tostring = function()
			return "destroyed:" .. name;
		end,
	};

	setmetatable(obj, nil);
	for key, _ in pairs(obj) do
		-- Blow everything away, except the class
		if key ~= "class" and tostring(key):match("^log") then
			obj[key] = nil;
		end;
	end;

	-- Allow ToString to be invoked directly
	function obj:ToString()
		return tostring(obj);
	end;

	function obj:ID()
		return id;
	end;
	obj.Id = obj.ID;

	setmetatable(obj, DESTROYED_METATABLE);
end;

function OOP.Property(self, name, setter, ...)
    if OOP.IsClass(self) then
        self:AddConstructor(Headless(OOP.Property, name, setter, ...));
        return;
    end;

    if setter ~= nil or select("#", ...) > 0 then
        setter = Curry(setter, ...);
    else
        setter = Noop;
    end;

    local value = {};

    local reset;
    local function Reset()
        if IsCallable(reset) then
            reset();
        end;
        value = {};
        reset = nil;
    end;
    self:AddDestructor(Reset);

    self[name] = function(self, ...)
        if select("#", ...) == 0 then
            return self["Get" .. name](self, ...);
        end;
        return self["Set" .. name](self, ...);
    end;

    self["GetRaw" .. name] = function(self)
        return unpack(value);
    end;

    if self["Get" .. name] == nil then
        self["Get" .. name] = self["GetRaw" .. name];
    end;

    self["Set" .. name] = function(self, ...)
        local newValue = {...};
        if value and Tables.Equal(value, newValue) then
            return;
        end;

        Reset();

        local invoked = false;
        local function Commit(...)
            invoked = true;
            if select("#", ...) == 0 then
                value = newValue;
            else
                value = {...};
            end;
        end;
        reset = setter(self, Commit, ...);
        if not invoked then
            Commit();
        end;
    end;
end;

Mixins = Mixins or {};
Mixins.Property = OOP.Property;

-- Invoke the specified destructor if any of the specified objects are destroyed.
--
-- This does extra work to ensure all destructors are cleaned up once the first one is
-- invoked.
function OOP.ShareFate(owners, dtor, ...)
    if OOP.IsInstance(owners) then
        return OOP.ShareFate({owners}, dtor, ...);
    end;

    if OOP.IsInstance(dtor) and select("#", ...) == 0 then
        return OOP.ShareFate(owners, dtor, "Destroy");
    end;

    dtor = Curry(dtor, ...);
    local destructors = {};
    local destroyer = Functions.OnlyOnce(function()
        Lists.CallEach(destructors);
        dtor();
        dtor = nil;
    end);

    for _, owner in ipairs(owners) do
        if IsCallable(owner) then
            table.insert(destructors, owner(destroyer));
        else
            table.insert(destructors, owner:AddDestructor(destroyer));
        end;
    end;

    return Functions.OnlyOnce(Lists.CallEach, destructors);
end;
