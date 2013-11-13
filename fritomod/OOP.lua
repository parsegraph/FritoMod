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
