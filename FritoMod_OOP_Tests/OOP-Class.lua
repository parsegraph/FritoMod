if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_OOP/OOP-Class";
end;

local ClassTests = ReflectiveTestSuite:New("FritoMod_OOP.OOP.Class");

function ClassTests:TestSimpleClass()
    local Base = OOP.Class();
    local flag = Tests.Flag();
    function Base:DoSomething()
        flag:Raise();
    end;
    Base:New():DoSomething();
    flag:Assert("Function was called");
end;

function ClassTests:TestInheritance()
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

function ClassTests:TestDeepHierarchy()
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

    assert(counter:Count() == 4, "DoSomething fired four times");
end;

function ClassTests:TestAddConstructor()

    local Base = OOP.Class();

    Base:AddConstructor(function(instance)
       instance.flag = true;
    end);

    Base:New();
    local x = Base:New();

    assert(x.flag, "Flag was set on the instance");
    assert(not Base.flag, "Class was not affected");
end;

function ClassTests:TestAddMixin()
    local Base = OOP.Class();
    Base:AddMixin(function(class)
       class.flag = true;
    end);

    assert(Base:New().flag, "Mixin added functionality");
end;

function ClassTests:TestAddMixinWithConstructor()
    local Base = OOP.Class();
    Base:AddMixin(function(class)
       class.instances = 0;
       return function(instance)
          class.instances = class.instances + 1;
       end;
    end);

    Base:New();
    Base:New();
    assert(Base.instances == 2, "Returned constructor was fired twice");
end;
