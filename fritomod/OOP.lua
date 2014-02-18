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

function OOP.InstanceOf(class, instance)
    if OOP.IsInstance(class) and OOP.IsClass(instance) then
        return OOP.InstanceOf(instance, class);
    end;
	if not OOP.IsInstance(instance) then
		return false;
	end;
	local candidateClass = instance.class;
	while true do
		if candidateClass == class then
			return true;
		end;
		local super = candidateClass.super;
		if super ~= nil and super ~= candidateClass then
			candidateClass = super;
		else
			break;
		end;
	end;
	return false;
end;
OOP.Instanceof = OOP.InstanceOf;

function OOP.IsInstance(candidate, class)
    if class ~= nil then
        return OOP.InstanceOf(class, candidate);
    end;
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
	return IsCallable(rawget(candidate,"New"));
end;

function OOP.IsDestroyed(obj)
	if type(obj) ~= "table" then
		return false;
	end;
    return obj.destroyed == true;
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

function OOP.Property(class, name, setter, ...)
    if setter ~= nil or select("#", ...) > 0 then
        setter = Curry(setter, ...);
    else
        setter = Noop;
    end;
    class:AddConstructor(function(self)
        local value;
        self[name] = function(self, ...)
            if select("#", ...) == 0 then
                return value;
            end;
            local newValue = ...;
            if value == newValue then
                return;
            end;
            local invoked = false;
            local function Commit(...)
                invoked = true;
                if select("#", ...) == 0 then
                    value = newValue;
                else
                    value = ...;
                end;
            end;
            setter(self, newValue, Commit);
            if not invoked then
                Commit();
            end;
        end;

        self["Get" .. name] = function(self)
            return self[name](self);
        end;

        self["Set" .. name] = function(self, newValue)
            return self[name](self, newValue);
        end;
    end);
end;

-- Invoke the specified destructor if any of the specified objects are destroyed.
--
-- This does extra work to ensure all destructors are cleaned up once the first one is
-- invoked.
function OOP.ShareFate(owners, dtor, ...)
    if OOP.IsInstance(owners) then
        return OOP.ShareFate({owners}, dtor, ...);
    end;

    dtor = Curry(dtor, ...);
    local destructors = {dtor};
    local destroyer = Functions.OnlyOnce(Lists.CallEach, destructors);

    for _, owner in ipairs(owners) do
        table.insert(destructors, owner:AddDestructor(destroyer));
    end;
end;
