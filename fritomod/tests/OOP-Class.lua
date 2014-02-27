local Suite = CreateTestSuite("fritomod.OOP-Class");

function Suite:TestSimpleClass()
	local Base = OOP.Class();
	local flag = Tests.Flag();
	function Base:DoSomething()
	   flag:Raise();
	end;
	Base:New():DoSomething();
	flag:Assert("Function was called");
end;

function Suite:TestToString()
	local Base = OOP.Class();

    assert(tostring(Base):match([[^Subclass of Object]]), tostring(Base));

    local obj = Base:New();
    assert(tostring(obj):match([[^subclass:Object]]), tostring(obj));

    function Base:ClassName()
        return "Base";
    end;

    assert(tostring(Base):match([[^%Base]]), tostring(Base));
    assert(tostring(obj):match([[^%Base]]), tostring(obj));
end;

function Suite:TestInheritance()
	local Base = OOP.Class();
	local baseFlag = Tests.Flag();
	function Base:DoSomething()
		baseFlag:Raise();
	end;

	local derivedFlag = Tests.Flag();
	local Derived = OOP.Class(Base);
	function Derived:DoSomething()
		derivedFlag:Raise();
	end;
	Derived:New():DoSomething();
	assert(not baseFlag:IsSet(), "Base function is completely overridden");
	assert(derivedFlag:IsSet(), "Derived function is called");
end;

function Suite:TestDeepHierarchy()
	local Base = OOP.Class();
	local counter = Tests.Counter();
	function Base:DoSomething()
		counter:Hit();
	end;

	Base:New():DoSomething();

	local Middle = OOP.Class(Base);
	Middle:New():DoSomething();

	local Higher = OOP.Class(Middle);
	Higher:New():DoSomething();

	local Derived = OOP.Class(Higher);
	Derived:New():DoSomething();

	counter.Assert(4, "DoSomething fired four times");
end;

function Suite:TestAddConstructor()
	local Base = OOP.Class();

	Base:AddConstructor(function(instance)
	   instance.flag = true;
	end);

	Base:New();
	local x = Base:New();

	assert(x.flag, "Flag was set on the instance");
	assert(not Base.flag, "Class was not affected");
end;

function Suite:TestAddMixin()
	local Base = OOP.Class();
	Base:AddMixin(function(class)
	   class.flag = true;
	end);

	assert(Base:New().flag, "Mixin added functionality");
end;

function Suite:TestAddMixinWithConstructor()
	local Base = OOP.Class();
	Base:AddMixin(function(class)
	   class.instances = Tests.Counter();
	   return class.instances.Hit;
	end);

	Base:New();
	Base:New();
	Base.instances.Assert(2, "Returned constructor was fired twice");
end;

function Suite:TestClassDestructor()
    local C = OOP.Class();
    local f = Tests.Flag();
    C:AddConstructor(f.Raise);
    local i = C:New();
    f:Assert();
    i:Destroy();
    f:AssertUnset();
end;

function Suite:TestInstanceDestructor()
    local C = OOP.Class();
    local f = Tests.Flag();
    local i = C:New();
    i:AddDestructor(f.Toggle);
    i:Destroy();
    f:Assert();
end;

function Suite:TestClassDestructorWithMultipleInstances()
    local C = OOP.Class();
    local f = Tests.Flag();
    C:AddDestructor(f.Toggle);
    C:New():Destroy();
    f:AssertSet();
    C:New():Destroy();
    f:AssertUnset();
end;

function Suite:TestDestructorOrdering()
    local C = OOP.Class();

    local order = {};
    function C:Destroy()
        table.insert(order, "Method");
        C.super.Destroy(self);
    end;

    C:AddDestructor(Seal(table.insert, order, "Class"));

    local i = C:New();
    i:AddDestructor(Seal(table.insert, order, "Instance"));

    i:Destroy();
    Assert.Equals({"Method", "Instance", "Class"}, order);
end;
