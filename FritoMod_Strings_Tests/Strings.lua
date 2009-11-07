if nil ~= require then
    require "FritoMod_Functional/currying";

    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Strings/Strings";
end;

local StringsTests = ReflectiveTestSuite:New("FritoMod_Strings.Strings");

function StringsTests:TestJoin()
    local j = Curry(Strings.Join, " ");
    Assert.Equals("2 3 4", j({2,3,4}), "Simple group");
end;

function StringsTests:TestPrettyPrint()
    local p = Strings.PrettyPrint;
    Assert.Equals('"Foo"', p("Foo"), "Printing a string");
    Assert.Equals('""', p(""), "Empty string");
    Assert.Equals("42", p(42), "Printing a number");
    Assert.Equals("False", p(false), "Printing a boolean");
    Assert.Equals("<nil>", p(nil), "Printing nil");
    Assert.Equals(p({1,2,3}), "[<3 items> 1, 2, 3]", "Printing a list");
    Assert.Equals("{<empty>}", p({}), "Empty list");
end;

function StringsTests:TestPrettyPrintWithGlobalFunction()
    local p = Strings.PrettyPrint;
    Assert.Equals("Function@Noop", p(Noop), "Global functions are named");
end;

function StringsTests:TestSplitByCaseTrivialCases()
    local s = Strings.SplitByCase;
    Assert.Equals({"caps"}, s("caps"), "Short java-case");
    Assert.Equals({"Caps"}, s("Caps"), "Short Camel-case");
    Assert.Equals({"CAPS"}, s("CAPS"), "Short Upper-case");
end;

function StringsTests:TestSplitByCase()
    local s = Strings.SplitByCase;
    Assert.Equals({"The", "Simple", "Test"}, s("TheSimpleTest"), "Simple proper-case");
    Assert.Equals({"the", "Simple", "Test"}, s("theSimpleTest"), "Simple camel-case");
end;

function StringsTests:TestSplitByCaseWithAcronyms()
    local s = Strings.SplitByCase;
    Assert.Equals({"FOO", "Simple", "Test"}, s("FOOSimpleTest"), "Leading acronym");
    Assert.Equals({"a", "FOO", "Simple", "Test"}, s("aFOOSimpleTest"), "Sandwiched acronym");
    Assert.Equals({"the", "Simple", "FOO"}, s("theSimpleFOO"), "Trailing acronym");
end;

function StringsTests:TestSplitByCaseIgnoresWhitespace()
    local s = Strings.SplitByCase;
    Assert.Equals({"  caps  "}, s("  caps  "), "Both leading and trailing whitespace");
    Assert.Equals({"  caps"}, s("  caps"), "Leading whitespace");
    Assert.Equals({"caps  "}, s("caps  "), "Trailing whitespace");
    Assert.Equals({"ca  ps"}, s("ca  ps"), "Internal whitespace");
    local spaces = (" "):rep(5);
    Assert.Equals({spaces}, s(spaces), "Only whitespace");
end;

function StringsTests:TestSplitByCasePersistsSpecialValues()
    local s = Strings.SplitByCase;
    Assert.Equals({"foo1234", "Bar"}, s("foo1234Bar"), "Lower-cased special values");
    Assert.Equals({"black", "FOO42", "Red"}, s("blackFOO42Red"), "Sandwiched upper-case symbols");
    Assert.Equals({"black", "FOO42"}, s("blackFOO42"), "Trailing upper-case symbols");
    Assert.Equals({"black", "Foo42"}, s("blackFoo42"), "Trailing lower-case symbols");
end;

function StringsTests:TestSplitByCaseCoercesValues()
    local s = Strings.SplitByCase;
    Assert.Equals({"42"}, s(42), "Number value");
    Assert.Equals({"false"}, s(false), "Boolean value");
end;

function StringsTests:TestSplitByCaseFailsOnNil()
    Assert.Exception("SplitByCase throws on nil", Strings.SplitByCase, nil);
end;

function StringsTests:TestSplitByCaseHandlesEmptyString()
    local s = Strings.SplitByCase;
    Assert.Equals({}, s(""), "Empty string");
end;

function StringsTests:TestSplitByDelimiter()
    local s = Strings.SplitByDelimiter;
    Assert.Equals({""}, s(""), "Empty string");
    Assert.Equals({"foo"}, s("foo"), "No delimiters");
    Assert.Equals({"Foo"}, s("Foo"), "No delimiters, mixed capitalization");
    Assert.Equals({"Foo", "Time"}, s("Foo_Time"), "Simple delimiters");
    Assert.Equals({"Foo", "Time", "Base", "Bar"}, s("Foo_Time_Base_Bar"), "Complex delimiter");
    Assert.Equals({"Foo", "Time"}, s("Foo___Time"), "Wide delimiter");
    Assert.Equals({""}, s("___"), "Only delimiter");
    Assert.Equals({"Foo"}, s("___Foo"), "Leading delimiter");
    Assert.Equals({"Foo"}, s("Foo___"), "Trailing delimiter");
    Assert.Equals({"No", "Time"}, s(" ", "No Time"), "Custom delimiter");
    Assert.Exception("SplitByDelimiter fails on nil arguments", Strings.SplitByDelimiter, nil);
end;

function StringsTests:TestSplitByDelimiterCoercesValues()
    local s = Strings.SplitByDelimiter;
    Assert.Equals({"222", "444"}, s(3, "2223444"), "Coerced delimiter");
    Assert.Equals({"222", "444"}, s("3", 2223444), "Coerced string");
    Assert.Equals({"true", "true"}, s(false, "truefalsetrue"), "False as delimiter");
end;

function StringsTests:TestJoinProperCaseTrivalCases()
    local s = Strings.JoinProperCase;
    Assert.Equals("Foo", s({"Foo"}), "Proper case");
    Assert.Equals("Foo", s({"FOO"}), "Upper case");
    Assert.Equals("Foo", s({"foo"}), "Lower case");
    Assert.Equals("Foo", s({"FoO"}), "Mixed case");
    Assert.Equals("42", s({42}), "Coerced numbers");
    Assert.Equals("False", s({false}), "Coerced false boolean");
    Assert.Equals("", s({}), "Empty list");
end;

function StringsTests:TestJoinProperCaseComplexCases()
    local s = Strings.JoinProperCase;
    Assert.Equals("TheGreatExample", s({"The", "Great", "Example"}), "No-op case");
    Assert.Equals("TheGreatExample", s({"ThE", "GREAT", "example"}), "Mixed cases");
    Assert.Equals("GreatAExample", s({"great", "a", "example"}), "Lower case");
    Assert.Equals("TheGreatA", s({"the", "great", "a"}), "Trailing one-letter word");
    Assert.Equals("GreatExample", s({"", "great", "", "example", ""}), "Spurious empty strings");
end;

function StringsTests:TestJoinCamelCaseTrivalCases()
    local s = Strings.JoinCamelCase;
    Assert.Equals("foo", s({"Foo"}), "Proper case");
    Assert.Equals("foo", s({"FOO"}), "Upper case");
    Assert.Equals("foo", s({"foo"}), "Lower case");
    Assert.Equals("foo", s({"FoO"}), "Mixed case");
    Assert.Equals("42", s({42}), "Coerced numbers");
    Assert.Equals("false", s({false}), "Coerced false boolean");
    Assert.Equals("", s({}), "Empty list");
end;

function StringsTests:TestJoinCamelCaseComplexCases()
    local s = Strings.JoinCamelCase;
    Assert.Equals("theGreatExample", s({"The", "Great", "Example"}), "No-op case");
    Assert.Equals("theGreatExample", s({"ThE", "GREAT", "example"}), "Mixed cases");
    Assert.Equals("greatAExample", s({"great", "a", "example"}), "Sandwiched one-letter word");
    Assert.Equals("theGreatA", s({"the", "great", "a"}), "Trailing one-letter word");
    Assert.Equals("greatExample", s({"", "great", "", "example", ""}), "Spurious empty strings");
    Assert.Equals("great_Example", s({"great", "_", "example"}), "Suspicious delimiter");
end;

function StringsTests:TestJoinSnakeCaseTrivalCases()
    local s = Strings.JoinSnakeCase;
    Assert.Equals("foo", s({"Foo"}), "Proper case");
    Assert.Equals("foo", s({"FOO"}), "Upper case");
    Assert.Equals("foo", s({"foo"}), "Lower case");
    Assert.Equals("foo", s({"FoO"}), "Mixed case");
    Assert.Equals("42", s({42}), "Coerced numbers");
    Assert.Equals("false", s({false}), "Coerced false boolean");
    Assert.Equals("", s({}), "Empty list");
    Assert.Equals("_", s({"_"}), "Only delimiter");
end;

function StringsTests:TestJoinSnakeCaseComplexCases()
    local s = Strings.JoinSnakeCase;
    Assert.Equals("the_great_example", s({"The", "Great", "Example"}), "No-op case");
    Assert.Equals("the_great_example", s({"ThE", "GREAT", "example"}), "Mixed cases");
    Assert.Equals("great_a_example", s({"great", "a", "example"}), "Sandwiched one-letter word");
    Assert.Equals("the_great_a", s({"the", "great", "a"}), "Trailing one-letter word");
    Assert.Equals("great_example", s({"", "great", "", "example", ""}), "Spurious empty strings");
    Assert.Equals("great___example", s({"great", "_", "example", ""}), "Spurious delimiters");
end;

function StringsTests:TestConvertersToSnakeCase()
    Assert.Equals("the_great_example", Strings.ProperToSnakeCase("TheGreatExample"), "Proper to Snake");
    Assert.Equals("the_great_example", Strings.CamelToSnakeCase("theGreatExample"), "Camel to Snake");
end;

function StringsTests:TestConvertersToCamelCase()
    Assert.Equals("theGreatExample", Strings.ProperToCamelCase("TheGreatExample"), "Proper to Camel");
    Assert.Equals("theGreatExample", Strings.SnakeToCamelCase("the_great_example"), "Snake to Camel");
end;

function StringsTests:TestConvertersToProperCase()
    Assert.Equals("TheGreatExample", Strings.CamelToProperCase("theGreatExample"), "Camel to Proper");
    Assert.Equals("TheGreatExample", Strings.SnakeToProperCase("the_great_example"), "Snake to Proper");
end;

function StringsTests:TestProperNounize()
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

function StringsTests:TestConvertToBase()
    local c = Strings.ConvertToBase;
    Assert.Equals("2345", c(10, 2345), "2345, base 10");
    Assert.Equals("10000", c(2, 16), "16, base 2");
    Assert.Equals("1111", c(2, 15), "15, base 2");
    Assert.Equals("100", c(16, 256), "256, base 16");
    Assert.Equals("-100", c(16, -256), "-256, base 16");
    Assert.Equals("FF", c(16, 255), "255, base 16");
end;

function StringsTests:TestConcat()
    local c = Strings.Concat;
    Assert.Equals("a", c("a"), "No-op case");
    Assert.Equals("a b", c("a", "b"), "Two words");
    Assert.Equals("a b c", c("a", "b", "c"), "Multiple words");
    Assert.Equals("a  b", c("a ", "b"), "Spurious spaces");
end;
