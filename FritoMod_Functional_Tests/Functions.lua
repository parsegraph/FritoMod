if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Functional/Functions";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Functional.Functions");

function Suite:TestReturn()
    local returned = {Functions.Return(1,2,3)};
    Assert.Equals({1,2,3}, returned, "Return returns provided arguments");
end;

function Suite:TestValues()
    local returner = Functions.Values(true);
    Assert.Equals(true, returner(), "Values returns given value");
    returner = Functions.Values(1, 2, 3);
    Assert.Equals({1,2,3}, {returner()}, "Values can return multiple values");
    Assert.Exception("Values rejects nil value", Functions.Values, nil);
    Assert.Exception("Values rejects intermediate nil values", Functions.Values, 1, nil, 3);
end;

function Suite:TestValuesSealsItsReturnedFunction()
    local returner = Functions.Values(true);
    Assert.Exception("Values rejects passed arguments", returner, {1,2});
end;

function Suite:TestToggle()
    local value = Tests.Value(false);
    local function Perform(newValue)
        return Curry(value.Set, value.Set(newValue));
    end;
    local toggle = Functions.Toggle(Perform, true);
    toggle();
    value.Assert(true);
    toggle();
    value.Assert(false);
    toggle();
    value.Assert(true);
end;

function Suite:TestUndoable()
    local flag = Tests.Flag();
    local undoable = Functions.Undoable(flag.Raise, flag.Clear);
    local remover = undoable();
    flag.Assert("Undoable initially calls performer");
    remover();
    flag.AssertUnset("Undoable's returned remover undoes performed action");
end;

function Suite:TestUndoablesNonStandardCurryingRules()
    local list = {};
    local undoable = Functions.Undoable(table.insert, table.remove, list);
    local remover = undoable("Foo");
    Assert.Equals({"Foo"}, list, "Undoable passes curried arguments to performer");
    remover(1);
    Assert.Equals({}, list, "Undoable also passes curried arguments to remover");
end;

function Suite:TestUndoableDoesntCorruptAfterMultipleRuns()
    local flag = Tests.Flag();
    local undoable = Functions.Undoable(flag.Raise, flag.Clear);
    undoable()();
    local remover = undoable();
    flag.Assert("Undoable still performs after multiple invocations");
    remover();
    flag.AssertUnset("Undoable's remover functions after first invocations");
end;

function Suite:TestUndoablesRemoverFiresOnlyOnce()
    local flag = Tests.Flag();
    local undoable = Functions.Undoable(flag.Raise, flag.Clear);
    local remover = undoable();
    remover();
    flag.AssertUnset("Flag is unset after first remover invocation");
    flag.Raise();
    remover();
    flag.Assert("Remover is a no-op after first invocation");
end;

-- Creates a single global for use with testing.
function Suite:TestSetupHookTests()
    AGlobalFunctionNoOneShouldEverUse = function(stuff)
        Assert.Equals(4, stuff, "Internal global receives externally received value");
        return stuff;
    end;
end;

function Suite:TestHookGlobal()
    local counter = Tests.Counter();
    local remover = Functions.HookGlobal("AGlobalFunctionNoOneShouldEverUse", function(stuff)
        counter.Hit();
        Assert.Equals(2, stuff, "Wrapped function receives externally received value");
        return stuff * 2;
    end);
    local result = AGlobalFunctionNoOneShouldEverUse(2);
    Assert.Equals(4, result, "Wrapped global returns internally returned value");
    remover();
    result = AGlobalFunctionNoOneShouldEverUse(4);
    Assert.Equals(4, result, "Wrapped global returns original value when hook is removed");
    counter.Assert(1, "Hook function only fires once");
end;

function Suite:TestHookGlobalFailsWhenIntermediatelyModified()
    local remover = Functions.HookGlobal("AGlobalFunctionNoOneShouldEverUse", Noop);
    local original = AGlobalFunctionNoOneShouldEverUse;
    AGlobalFunctionNoOneShouldEverUse = nil;
    Assert.Exception("HookGlobal fails when global is modified between calls", remover);
    AGlobalFunctionNoOneShouldEverUse = original;
    remover();
end;

function Suite:TestSpyGlobal()
    local counter = Tests.Counter();
    local remover = Functions.SpyGlobal("AGlobalFunctionNoOneShouldEverUse", function(stuff)
        counter.Hit();
        Assert.Equals(4, stuff, "Spied global receives original value");
        return stuff * 2;
    end);
    local result = AGlobalFunctionNoOneShouldEverUse(4);
    Assert.Equals(4, result, "Spied global returns original value");
    remover();
    result = AGlobalFunctionNoOneShouldEverUse(4);
    Assert.Equals(4, result, "Spied global returns original value after removal");
    counter.Assert(1, "Spy function only fires once");
end;

function Suite:TestSpyGlobalFailsWhenIntermediatelyModified()
    local remover = Functions.SpyGlobal("AGlobalFunctionNoOneShouldEverUse", Noop);
    local original = AGlobalFunctionNoOneShouldEverUse;
    AGlobalFunctionNoOneShouldEverUse = nil;
    Assert.Exception("SpyGlobal fails when global is modified between calls", remover);
    AGlobalFunctionNoOneShouldEverUse = original;
    remover();
end;

-- Cleans up the global we used in the previous tests.
function Suite:TestClearGlobal()
    AGlobalFunctionNoOneShouldEverUse = nil;
end;

function Suite:TestOnlyOnce()
    local counter = Tests.Counter();
    local Wrapped = Functions.OnlyOnce(counter.Hit);
    Wrapped();
    counter.Assert(1, "OnlyOnce invokes wrapped function on first call");
    Wrapped();
    counter.Assert(1, "Subsequent calls do not invoke the wrapped function");
end;

function Suite:TestSpy()
    local function Sum(a, b)
        return a + b;
    end;
    local observedValue = nil
    local ObservedSum = Functions.Spy(Sum, function(a, b)
        observedValue = b;
    end);
    Assert.Equals(3, ObservedSum(1, 2), "Wrapped function returns appropriate value");
    Assert.Equals(2, observedValue, "Observer is called with arguments");
end;

function Suite:TestSpyIsCalledBeforeWrapped()
    local observerFlag = Tests.Flag();
    local function Wrapped()
        assert(observerFlag.IsSet(), "Observer is fired before wrapped");
    end;
    local ObservedFunc = Functions.Spy(Wrapped, function()
        observerFlag.Raise();
    end);
    ObservedFunc();
end;

function Suite:TestSpyWithUndoable()
    local value = Tests.Value(false);
    local list = {};
    local undoable = Functions.Spy(Lists.Insert, function(passedList, insertedValue)
        Assert.Equals(list, passedList, "Observer is properly given shared curried arguments");
        return Curry(value.Set, value.Set(insertedValue));
    end, list);
    local remover = undoable(true);
    Assert.Equals({true}, list, "Undoable's wrapped function is properly curried and called");
    value.Assert(true, "Observer is properly curried and called");
    remover();
    Assert.Equals({}, list, "Observed undoable's remover is properly called");
    value.Assert(false, "Observer's returned remover is properly curried and called");
end;

function Suite:TestSpyUndoablePerformsAfterRepeatedInvocations()
    local value = Tests.Value(false);
    local list = {};
    local undoable = Functions.Spy(Lists.Insert, function(list, insertedValue)
        return Curry(value.Set, value.Set(insertedValue));
    end, list);
    undoable(true)();
    local remover = undoable(true);
    Assert.Equals({true}, list, "Undoable's wrapped function is properly curried and called");
    value.Assert(true, "Observer is properly curried and called");
    remover();
    Assert.Equals({}, list, "Observed undoable's remover is properly called");
    value.Assert(false, "Observer's returned remover is properly curried and called");
end;

function Suite:TestChain()
    local value = Tests.Value(1);
    local chained = Functions.Chain(value.Set, function(providedValue)
        value.Assert(2, "Chain first passes value to wrapped function");
        Assert.Equals(1, providedValue, "Chain sends received value to receiver");
        return 3;
    end);
    Assert.Equals(3, chained(2), "Chain ultimately returns value returned from receiver");
end;

function Suite:TestNiftyChainExample()
    local queue = {};
    local function Push(value)
        table.insert(queue, value);
        return Curry(Lists.Remove, queue, value);
    end;
    Push(true);
    local remover = Push(true);
    remover();
    remover();
    Assert.Size(0, queue, "Remover is not idempotent, so many values are removed");
    local safePush = Functions.Chain(Push, Functions.OnlyOnce);
    safePush(true);
    remover = safePush(true);
    remover();
    remover();
    Assert.Size(1, queue, "Chain and OnlyOnce allow idempotent functions");
end;

function Suite:TestLazyInitialState()
    local initializerFlag = Tests.Flag();
    local uninitializerFlag = Tests.Flag();
    local value = nil;
    local function Wrapped(element)
        assert(initializerFlag.IsSet(), "Initializer is set before wrapped is called");
        Assert.Equals(true, element, "Correct value was passed to wrapped function");
        value = element;
    end;
    local func = Functions.Lazy(Wrapped, function()
        assert(not initializerFlag.IsSet(), "Initializer is never called redundantly");
        initializerFlag.Raise();
        return function()
            assert(initializerFlag.IsSet(), "Uninitializer is never called redundantly");
            initializerFlag.Clear();
            uninitializerFlag.Raise();
        end;
    end);
    local remover = func(true);
    assert(initializerFlag.IsSet(), "Initialization is performed on first invocation");
    Assert.Equals(true, value, "Wrapped function was called on first invocation");
    remover();
    assert(not initializerFlag.IsSet(), "Initialization is undone after remover is called");
    assert(uninitializerFlag.IsSet(), "Initialization is undone after remover is called");
end;

function Suite:TestLazyWithNesting()
    local items = {};
    local counter = Tests.Counter();
    local uninitializerFlag = Tests.Flag();
    local func = Functions.Lazy(Curry(Lists.Insert, items), function()
        counter.Hit();
        return uninitializerFlag.Raise;
    end);
    local remover = func("A");
    counter.Assert(1, "Initializer called after first insertion");
    local otherRemover = func("B");
    counter.Assert(1, "Initializer is only called once");
    remover();
    Assert.Equals({"B"}, items, "Items contains one call");
    assert(not uninitializerFlag.IsSet(), "Uninitializer has not been called during intermediate removals");
    otherRemover();
    assert(uninitializerFlag.IsSet(), "Uninitializer is called after all elements removed");
    Assert.Equals({}, items, "Items contains nothing");
end;

function Suite:TestLazyRenews()
    local items = {};
    local startedCounter = Tests.Counter();
    local stoppedCounter = Tests.Counter();
    local func = Functions.Lazy(Curry(Lists.Insert, items), function()
        startedCounter.Hit();
        return stoppedCounter.Hit;
    end);
    startedCounter.Assert(0);
    stoppedCounter.Assert(0);
    local remover = func("A");
    startedCounter.Assert(1);
    stoppedCounter.Assert(0);
    remover();
    startedCounter.Assert(1);
    stoppedCounter.Assert(1);
    remover = func("B");
    startedCounter.Assert(2);
    stoppedCounter.Assert(1);
    remover();
    startedCounter.Assert(2);
    stoppedCounter.Assert(2);
end;

function Suite:TestInstall()
    local counter = Tests.Counter();
    local installer = Functions.Install(Functions.Undoable(
        counter.Hit,
        counter.Clear
    ));
    local remover = installer();
    counter.Assert(1, "Install fires installer on first invocation");
    remover();
    counter.Assert(0, "Install fires uninstaller on last removal");
end;

function Suite:TestInstallWithLotsOfIntermediateRemovals()
    local counter = Tests.Counter();
    local installer = Functions.Install(Functions.Undoable(
        counter.Hit,
        counter.Clear
    ));
    local remover = installer();
    counter.Assert(1, "Install fires installer on first invocation");
    installer()();
    installer()();
    remover();
    counter.Assert(0, "Install fires uninstaller on last removal");
end;
