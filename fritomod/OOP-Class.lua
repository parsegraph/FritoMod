if nil ~= require then
	require "fritomod/basic";
	require "fritomod/currying";
	require "fritomod/OOP";
	require "fritomod/Lists";
	require "fritomod/log";
end;

local CLASS_METATABLE = {
	-- A default constructor. This is called after all constructors are used,
	-- and will only be called on the immediate class that's being created;
	-- it is each constructor's responsibility to either call their parent's
	-- constructor, or perform any action that the parent constructor is tasked
	-- to do.
	--
	-- This should be overridden in most cases by whatever construction you wish
	-- to do, and the signature used here does not need to be preserved. Any
	-- return value is ignored.
	Constructor = function(self)
		-- noop
	end,

	-- Calls all constructors on the specified object.
	--
	-- object
	--	 the object that is constructed
	-- throws
	--	 if object is falsy
	ConstructObject = function(klass, object, ...)
		assert(object, "Object must not be falsy");
		local constructors = rawget(klass, "__constructors");
		if not constructors then
			return;
		end;
		for i, constructor in ipairs(constructors) do
			Log.Entercf(klass, tostring(klass) .. " constructor invocations", "Invoking constructor " .. i);
			local destructor = constructor(object, ...);
			if IsCallable(destructor) then
				object:AddDestructor(destructor);
			end;
			Log.Leave();
		end;
	end,

	-- Add a mixin to this class. A mixin is a callable should expect the signature
	-- mixinFunc(class). A mixin is expected to add some functionality to a class.
	--
	-- mixinFunc
	--	 The function that performs the work of the mixin. It is called immediately.
	--
	--	 If the mixinFunc returns a callable, then that callable will be invoked
	--	 for every instance of the class. It should expect the signature
	--	 "callable(object)"
	-- ...
	--	 any arguments that are curried to mixinFunc
	AddMixin = function(self, mixinFunc, ...)
		mixinFunc = Curry(mixinFunc, ...);
		local constructor = mixinFunc(self);
		if constructor then
			self:AddConstructor(constructor);
		end;
	end,

	-- Adds the specified constructor function to this class. The constructor will be called
	-- for all created instances of this class, but before the instance's actual constructor
	-- is invoked.
	--
	-- The return value, if callable, will be treated as a destructor. It will be invoked when
	-- the object's Destroy method is called.
	AddConstructor = function(self, constructorFunc, ...)
		constructorFunc = Curry(constructorFunc, ...);
		-- Use rawget here to ensure we don't get the constructors for this class, instead of
		-- deferring to a super class.
		local constructors = rawget(self, "__constructors");
		if not constructors then
			constructors = {};
			rawset(self, "__constructors", constructors);
		end;
		return Lists.Insert(constructors, constructorFunc);
	end,

	-- Adds the specified destructor function to this class or instance. Instance-specific
	-- destructors will be invoked when Destroy is called.
	--
	-- Note that the instance reference will be provided only to class-specific destructors.
	-- If you need (or do not need) the instance reference, then you should explicitly
	-- Seal or Curry it accordingly.
	AddDestructor = function(self, destructor, ...)
		if not IsCallable(destructor) and select("#", ...) == 0 and type(destructor) == "table" and destructor.Destroy then
			return self:AddDestructor(destructor, "Destroy");
		end;
		destructor = Curry(destructor, ...);

		if OOP.IsClass(self) then
			return self:AddConstructor(function(instance)
				return Seal(destructor, instance);
			end);
		end;
		local destructors = rawget(self, "__destructors");
		if not destructors then
			destructors = {};
			rawset(self, "__destructors", destructors);
		end;
		return Lists.Insert(destructors, destructor);
	end,

	ClassName = function(self)
		return "Object";
	end,

	ID = function(self)
		if self.id then
			if self.idParent then
				return self.numericId .. " - " .. tostring(self.id)  .. " - " .. tostring(self.idParent);
			end;
			return self.numericId .. " - " .. tostring(self.id);
		end;
		return self.numericId;
	end,
	Id = function(...)
		return self:ID(...);
	end,

	SetID = function(self, newId, parent)
		self.id = newId;
		self.idParent = parent;
	end,
	SetId = function(...)
		return self:SetID(...);
	end,

	-- Destroy this object. All instance-specific destructors will be run, then all class-
	-- specific destructors will be run.
	--
	-- Subclasses that override this method should always invoke it once their destruction
	-- has completed.
	Destroy = function(self)
		local function RunDestructors(destructors)
			if not destructors then
				return;
			end;
			while #destructors > 0 do
				local dtor = table.remove(destructors, #destructors);
				dtor();
			end;
		end;

		Log.Entercf(self, self:ClassName() .. " Destructions", "Destroying", self);

		-- Allow spurious invocations of Destroy
		rawset(self, "Destroy", Noop);

		-- Use rawget so we don't get the class-specific destructors
		RunDestructors(rawget(self, "__destructors"));

		rawset(self, "AddDestructor",
			Seal(error, "Destructors cannot be added to a destroyed object")
		);

		-- Allow detection from OOP.IsDestroyed
		rawset(self, "destroyed", true);

		Log.Leave();
	end
}

-- Creates a new instance of this class.
local function New(class, ...)
	Log.Enter(class, class:ClassName() .. " Creations", "Creating new " .. class:ClassName());

	local numericId = rawget(class, "__idcount") or 1;
	rawset(class, "__idcount", numericId + 1);
	local instance = {
		__index = class,
		__tostring = function(self)
			return self:ToString();
		end,
		numericId = numericId,
		class=class
	};
	setmetatable(instance, instance);

	function instance:ToString()
		local str;
		if rawget(self, "ClassName") or rawget(self.class, "ClassName") then
			str = self:ClassName() .. " ".. tostring(self:ID());
		else
			str ="subclass:".. self:ClassName() .. " " .. Reference(self);
		end;
		return str;
	end;

	local function Initialize(class, ...)
		if class.super then
			Initialize(class.super, ...);
		end;
		class:ConstructObject(instance, ...);
	end;
	Initialize(class, ...);

	instance:Constructor(...);

	Log.Logf(instance, instance, "created.");
	Log.Leave();
	return instance;
end

-- Creates a callable table that creates instances of itself when invoked. This is analogous
-- to classes: a super-class may be provided in the arguments, and that class will act as the
-- default source of methods for the returned class.
--
-- You may also provide other functions in the arguments. These functions act as mixins, and are
-- allowed to add functionality to this class. If they return a callable, that callable will be
-- invoked on every instance of this class.
--
-- ...
--	 Any mixins, and up to one super class, that should be integrated into this class.
-- throws
--	 if any provided argument is not either a mixin or a class
--	 if more than one super-class is provided (multiple inheritance in this manner is not supported)
function OOP.Class(...)
	local class = {};
	class.__index = CLASS_METATABLE;
	class.New = New;
	function class:__tostring()
		if rawget(self, "ClassName") then
			return self:ClassName();
		end;
		return "Subclass of "..self:ClassName().."@"..Reference(self);
	end;
	setmetatable(class, class);

	for n = 1, select('#', ...) do
		local mixinOrClass = select(n, ...);
		if not mixinOrClass then
			error("Mixin or class is falsy. Index " .. n);
		end;
		if OOP.IsClass(mixinOrClass) then
			--  It's a class, so make it our super class.
			assert(not class.super, "Class cannot have more than one super class");
			class.super = mixinOrClass;
			class.__index = class.super;
		elseif IsCallable(mixinOrClass) then
			local constructor = mixinOrClass(class);
			if IsCallable(constructor) then
				class:AddConstructor(constructor);
			end;
		elseif type(mixinOrClass) == "string" then
			local className = mixinOrClass;
			function class:ClassName()
				return className;
			end;
		else
			error(("Object is not a mixin or super-class: %s"):format(tostring(mixinOrClass)));
		end;
	end

	if not class.super then
		class.super = CLASS_METATABLE;
	end;

	return class;
end;

local AtomClass = OOP.Class("Atom");
function OOP.Atom()
	return AtomClass:New();
end;

-- vim: set noet :
