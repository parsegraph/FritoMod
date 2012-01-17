if nil ~= require then
	require "fritomod/currying";

	require "fritomod/tests/Mixins-ArrayTests";
	require "fritomod/tests/Mixins-ComparableIteration";
end;

local Suite=CreateTestSuite("fritomod.Strings");

function Suite:TestStringGet()
	local s="abcde";
	Assert.Equals("c", Strings.Get(s, 3));
end;

function Suite:TestUpperCasingAString()
	local s="abcde";
	Assert.Equals(s:upper(), Strings.JoinArray("", Strings.Map(s, "upper")));
end;

function Suite:TestStartsWith()
	Assert.True(Strings.StartsWith("ABC", "A"), "Strings that start with the given value must match");
	Assert.True(Strings.StartsWith("A", "A"), "Whole match must still match");
	Assert.True(Strings.StartsWith("A", {"B", "A"}), "Lists can be used for multiple options");
	Assert.False(Strings.StartsWith("B", "A"), "Things that don't match return false");
	Assert.False(Strings.StartsWith("", "A"), "Empty string must not cause chaos");
	Assert.False(Strings.StartsWith("A", "[A]"), "Regular expressions must be interpreted as plaintext");
	Assert.False(Strings.StartsWith("A", {"B", "C"}), "Things that don't match anything in the list must return false");
	Assert.Exception("Empty matching string must violently crash", Strings.StartsWith, "A", "");
	Assert.Exception("Empty matching string list must violently crash", Strings.StartsWith, "A", {});
end;

function Suite:TestEndsWith()
	Assert.True(Strings.EndsWith("ABC", "C"), "Strings that end with the given value must match");
	Assert.True(Strings.EndsWith("A", "A"), "Whole match must still match");
	Assert.True(Strings.EndsWith("A", {"B", "A"}), "Lists can be used for multiple options");
	Assert.False(Strings.EndsWith("B", "A"), "Things that don't match return false");
	Assert.False(Strings.EndsWith("", "A"), "Empty string must not cause chaos");
	Assert.False(Strings.EndsWith("A", "[A]"), "Regular expressions must be interpreted as plaintext");
	Assert.False(Strings.EndsWith("A", {"B", "C"}), "Things that don't match anything in the list must return false");
	Assert.Exception("Empty matching string must violently crash", Strings.EndsWith, "A", "");
	Assert.Exception("Empty matching string list must violently crash", Strings.EndsWith, "A", {});
end;

function Suite:TestJoin()
	local j = Curry(Strings.JoinArray, " ");
	Assert.Equals("2 3 4", j({2,3,4}), "Simple group");
end;

function Suite:TestPretty()
	local p = Strings.Pretty;
	Assert.Equals('"Foo"', p("Foo"), "Printing a string");
	Assert.Equals('""', p(""), "Empty string");
	Assert.Equals("42", p(42), "Printing a number");
	Assert.Equals("False", p(false), "Printing a boolean");
	Assert.Equals("<nil>", p(nil), "Printing nil");
	Assert.Equals(p({1,2,3}), "[<3 items> 1, 2, 3]", "Printing a list");
	Assert.Equals("{<empty>}", p({}), "Empty list");
end;

function ThisFunctionWillNeverEverBeCalled()

end;

function Suite:TestPrettyWithGlobalFunction()
	local p = Strings.Pretty;
	Assert.Equals("Function@ThisFunctionWillNeverEverBeCalled", p(ThisFunctionWillNeverEverBeCalled), "Global functions are named");
end;

function Suite:TestSplitByDelimiter()
	local s = Curry(Strings.SplitByDelimiter, "_");
	Assert.Equals({"Foo", "Time"}, s("Foo_Time"), "Simple delimiters");
end;

function Suite:TestSplitByDelimiterNoopCase()
	local s = Curry(Strings.SplitByDelimiter, " ");
	Assert.Equals({""}, s(""), "Empty string");
end;

function Suite:TestSplitByDelimiterWithEmptyStringDelimiter()
	Assert.Equals({'t', 'e', 's', 't'}, Strings.SplitByDelimiter("", "test"));
end;

function Suite:TestSplitByDelimiterHandlesEmptyString()
	Assert.Equals({""}, Strings.SplitByDelimiter(" ", ""));
end;

function Suite:TestSplitByDelimiterWithoutDelimiters()
	local s = Curry(Strings.SplitByDelimiter, " ");
	Assert.Equals({"foo"}, s("foo"), "No delimiters");
	Assert.Equals({"Foo"}, s("Foo"), "No delimiters, mixed capitalization");
end;

function Suite:TestSplitByDelimiterFailsOnNil()
	Assert.Exception("SplitByDelimiter fails on nil arguments", Strings.SplitByDelimiter, nil);
	Assert.Exception("SplitByDelimiter fails on nil arguments", Strings.SplitByDelimiter, " ", nil);
end;

function Suite:TestSplitByDelimiterWithEdgeCaseDelimiters()
	local s = Curry(Strings.SplitByDelimiter, "_");
	Assert.Equals({""}, s("___"), "Only delimiter");
	Assert.Equals({"Foo"}, s("___Foo"), "Leading delimiter");
	Assert.Equals({"Foo"}, s("Foo___"), "Trailing delimiter");
end;

function Suite:TestSplitByDelimiterComplexCases()
	local s = Curry(Strings.SplitByDelimiter, "_");
	Assert.Equals({"Foo", "Time", "Base", "Bar"}, s("Foo_Time_Base_Bar"), "Complex delimiter");
	Assert.Equals({"Foo", "Time"}, s("Foo___Time"), "Wide delimiter");
	Assert.Equals({"No", "Time"}, Strings.SplitByDelimiter(" ", "No Time"), "Custom delimiter");
end;

function Suite:TestSplitByDelimiterCoercesValues()
	local s = Strings.SplitByDelimiter;
	Assert.Equals({"222", "444"}, s(3, "2223444"), "Coerced delimiter");
	Assert.Equals({"222", "444"}, s("3", 2223444), "Coerced string");
	Assert.Equals({"true", "true"}, s(false, "truefalsetrue"), "False as delimiter");
end;

function Suite:TestProperNounize()
	local p = Strings.ProperNounize;
	Assert.Equals("Proper", p("Proper"), "No-op case");
	Assert.Equals("Proper", p("proper"), "Lower case");
	Assert.Equals("Proper", p("PROPER"), "Upper case");
	Assert.Equals("Proper", p("pRoPeR"), "Mixed case");
	Assert.Equals("P", p("P"), "One letter, upper");
	Assert.Equals("P", p("p"), "One letter, lower");
	Assert.Equals("1", p("1"), "Number");
	Assert.Equals("1234", p("1234"), "Number");
	Assert.Equals("1234", p(1234), "Number, coerced");
	Assert.Equals("_foo", p("_FOO"), "Symbol with words");
end;

function Suite:TestConvertToBase()
	local c = Strings.ConvertToBase;
	Assert.Equals("2345", c(10, 2345), "2345, base 10");
	Assert.Equals("10000", c(2, 16), "16, base 2");
	Assert.Equals("1111", c(2, 15), "15, base 2");
	Assert.Equals("100", c(16, 256), "256, base 16");
	Assert.Equals("-100", c(16, -256), "-256, base 16");
	Assert.Equals("ff", c(16, 255), "255, base 16");
end;

function Suite:TestJoinValues()
	local c = Curry(Strings.JoinValues, " ");
	Assert.Equals("a", c("a"), "No-op case");
	Assert.Equals("a b", c("a", "b"), "Two words");
	Assert.Equals("a b c", c("a", "b", "c"), "Multiple words");
	Assert.Equals("a  b", c("a ", "b"), "Spurious spaces");
end;

function Suite:TestColonTime()
	local f = Strings.FormatColonTime;
	Assert.Equals("1", f(1));
	Assert.Equals("24", f(24));
	Assert.Equals("1:04", f(64));
	Assert.Equals("1:00:00", f(60 * 60));
end;
