local testManager = TestManager:GetInstance();
local releaser = testManager:SetActiveTestGroup("FritoMod_Utilities.StringUtil");

------------------------------------------
--  SplitByCase
------------------------------------------

testManager:AddListTest({"the", "simple", "test"},
    StringUtil, "SplitByCase", "TheSimpleTest"
);

testManager:AddListTest({"the", "simple", "test"},
    StringUtil, "SplitByCase", "theSimpleTest"
);

testManager:AddListTest({"foo", "simple", "test"},
    StringUtil, "SplitByCase", "FOOSimpleTest"
);

testManager:AddListTest({"a", "foo", "simple", "test"},
    StringUtil, "SplitByCase", "aFOOSimpleTest"
);

testManager:AddListTest({"the", "simple", "foo"},
    StringUtil, "SplitByCase", "theSimpleFOO"
);

testManager:AddListTest({"caps"},
    StringUtil, "SplitByCase", "CAPS"
);

testManager:AddListTest({"caps"},
    StringUtil, "SplitByCase", "Caps"
);

testManager:AddListTest({"caps"},
    StringUtil, "SplitByCase", "caps"
);

------------------------------------------
--  SplitByDelimiter
------------------------------------------

testManager:AddListTest({"the", "simple", "foo"},
    StringUtil, "SplitByDelimiter", "the_simple_foo"
);

testManager:AddListTest({"the", "simple", "foo"},
    StringUtil, "SplitByDelimiter", "the___simple____foo"
);

testManager:AddListTest({"the", "simple", "foo"},
    StringUtil, "SplitByDelimiter", "_the_simple_foo"
);

testManager:AddListTest({"the", "simple", "foo"},
    StringUtil, "SplitByDelimiter", "the_simple_foo_"
);

testManager:AddListTest({"the", "simple", "foo"},
    StringUtil, "SplitByDelimiter", "THE_SIMPLE_FOO"
);

------------------------------------------
--  JoinProperCase
------------------------------------------

testManager:AddConstantTest("AGreatExample",
    StringUtil, "JoinProperCase", {"a", "great", "example"}
);

testManager:AddConstantTest("AGreatExample",
    StringUtil, "JoinProperCase", {"a", "GREAT", "example"}
);

testManager:AddConstantTest("TheGreatExample",
    StringUtil, "JoinProperCase", {"the", "great", "example"}
);

------------------------------------------
--  JoinCamelCase
------------------------------------------

testManager:AddConstantTest("theGreatExample",
    StringUtil, "JoinCamelCase", {"the", "great", "example"}
);

testManager:AddConstantTest("theGreatExample",
    StringUtil, "JoinCamelCase", {"the", "GREAT", "example"}
);

testManager:AddConstantTest("aGreatExample",
    StringUtil, "JoinCamelCase", {"a", "great", "example"}
);

------------------------------------------
--  JoinSnakeCase
------------------------------------------

testManager:AddConstantTest("a_great_example",
    StringUtil, "JoinSnakeCase", {"a", "great", "example"}
);

testManager:AddConstantTest("the_great_example",
    StringUtil, "JoinSnakeCase", {"the", "great", "example"}
);

testManager:AddConstantTest("the_great_example",
    StringUtil, "JoinSnakeCase", {"the", "GREAT", "example"}
);

------------------------------------------
--  ProperTo<foo>Case
------------------------------------------

testManager:AddConstantTest("theGreatExample",
    StringUtil, "ProperToCamelCase", "TheGreatExample"
);

testManager:AddConstantTest("the_great_example",
    StringUtil, "ProperToSnakeCase", "TheGreatExample"
);

------------------------------------------
--  CamelTo<foo>Case
------------------------------------------

testManager:AddConstantTest("the_great_example",
    StringUtil, "CamelToSnakeCase", "theGreatExample"
);

testManager:AddConstantTest("TheGreatExample",
    StringUtil, "CamelToProperCase", "theGreatExample"
);

------------------------------------------
--  SnakeTo<foo>Case
------------------------------------------

testManager:AddConstantTest("TheGreatExample",
    StringUtil, "SnakeToProperCase", "the_great_example"
);

testManager:AddConstantTest("theGreatExample",
    StringUtil, "SnakeToCamelCase", "the_great_example"
);

------------------------------------------
--  ProperNounize
------------------------------------------

testManager:AddConstantTest("Proper",
    StringUtil, "ProperNounize", "pRoPeR"
);

testManager:AddConstantTest("F",
    StringUtil, "ProperNounize", "f"
);

testManager:AddConstantTest("_foo",
    StringUtil, "ProperNounize", "_FOO"
);

------------------------------------------
--  ConvertToBase
------------------------------------------

testManager:AddConstantTest("1000",
    StringUtil, "ConvertToBase", 2, 16
);

testManager:AddConstantTest("100",
    StringUtil, "ConvertToBase", 16, 256
);

testManager:AddConstantTest("-100",
    StringUtil, "ConvertToBase", 16, -256
);

------------------------------------------
--  Concat
------------------------------------------

testManager:AddConstantTest("A B C",
    StringUtil, "Concat", "A", "B", "C"
);

testManager:AddConstantTest("A",
    StringUtil, "Concat", "A"
);

releaser();
