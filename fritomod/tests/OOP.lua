if nil ~= require then
	require "fritomod/OOP-Class";
end;

local Suite = CreateTestSuite("fritomod.OOP");

function Suite:TestIsClass()
	assert(OOP.IsClass(OOP.Class()), "class is a class");
	assert(not OOP.IsClass(nil), "IsClass gracefully handles nil values");
	assert(not OOP.IsClass("No time"), "IsClass gracefully handles non-table values");
	assert(not OOP.IsClass({}), "Tables are not classes");
	assert(not OOP.IsClass(OOP.Class():New()), "Instances are not classes");
end;

function Suite:TestIsInstance()
	local Base = OOP.Class();
	assert(OOP.IsInstance(OOP.Class():New()), "Instance is an instance");
	assert(not OOP.IsInstance(nil), "IsInstance gracefully handles nil values");
	assert(not OOP.IsInstance("No time"), "IsInstance gracefully handles non-table values");
	assert(not OOP.IsInstance({}), "Tables are not instances");
	assert(not OOP.IsInstance(OOP.Class()), "classes are not instances");
end;

function Suite:TestInstanceOf()
	local Base = OOP.Class();
	local Derived = OOP.Class(Base);

	local foo = Base:New();
	assert(OOP.InstanceOf(Base, foo), "foo is an instance of Base");
	assert(not OOP.InstanceOf(Derived, foo), "foo is not an instance of Derived");

	local bar = Derived:New();
	assert(OOP.InstanceOf(Base, bar), "bar is an instance of Base");
	assert(OOP.InstanceOf(Derived, bar), "bar is an instance of Derived");

end;

function Suite:TestInstanceOfThrowsOnBadClass()
	local Base = OOP.Class();
	assert(OOP.InstanceOf(Base, Base:New()), "Base's instances are instances of Base");
	assert(OOP.InstanceOf(Base, OOP.Class(Base):New()), "Base's derived instances are instances of Base");
	assert(not OOP.InstanceOf(Base, OOP.Class():New()), "Foreign instances are not instances of Base");
	Assert.Exception("InstanceOf rejects nil classes", OOP.InstanceOf, nil, Base:New());
	Assert.Exception("InstanceOf rejects non-class objects", OOP.InstanceOf, {}, Base:New());
	assert(not OOP.InstanceOf(Base, nil), "InstanceOf gracefully handles nil objects");
	assert(not OOP.InstanceOf(Base, "No time"), "InstanceOf gracefully handles invalid objects");
	assert(not OOP.InstanceOf(Base, OOP.Class()), "InstanceOf gracefully handles class objects");
end;

function Suite:TestIsInstanceHandlesDefensiveTables()
	local t=setmetatable({}, {
		__index=function()
			error("I'm defensive!");
		end
	});
	OOP.IsClass(t);
end;

function Suite:TestIsClassHandlesDefensiveTables()
	local t=setmetatable({}, {
		__index=function()
			error("I'm defensive!");
		end
	});
	OOP.IsInstance(candidate);
end;
