local StringsTests = ReflectiveTestSuite:New("FritoMod_Utilities.Strings");

function listsEqual(list, otherList)
    assert(type(list) == "table", "list is not a table");
    assert(type(otherList) == "table", "otherList is not a table");
    if #list ~= #otherList then
        return false;
    end;
    for i=1, #list do
        if list[i] ~= otherList[i] then
            return false;
        end;
    end;
    return true;
end;

function StringsTests:TestListsEqual()
    assert(not listsEqual({1}, {2}), "Single-item unequal lists");
    assert(listsEqual({1}, {1}), "Single-item equal lists");
    assert(listsEqual({1,2,3}, {1,2,3}), "Equal lists");
    assert(not listsEqual({1,2,3}, {2}), "Mixed-length unequal lists");
end;

function StringsTests:TestSplitByCaseTrivialCases()
    assert(listsEqual(Strings.SplitByCase("caps"), {"caps"}), "Short java-case");
    assert(listsEqual(Strings.SplitByCase("Caps"), {"caps"}), "Short Camel-case");
    assert(listsEqual(Strings.SplitByCase("CAPS"), {"caps"}), "Short Upper-case");
    assert(listsEqual(Strings.SplitByCase("caps"), {"caps"}), "No-op case");
end;

function StringsTests:TestSplitByCase()
    assert(listsEqual(Strings.SplitByCase("TheSimpleTest"), {"the", "simple", "test"}), "Simple proper-case");
    assert(listsEqual(Strings.SplitByCase("theSimpleTest"), {"the", "simple", "test"}), "Simple camel-case");
end;

function StringsTests:TestSplitByCaseWithAcronyms()
    assert(listsEqual(Strings.SplitByCase("FOOSimpleTest"), {"foo", "simple", "test"}), "Leading acronym");
    assert(listsEqual(Strings.SplitByCase("FOOSimpleTest"), {"a", "foo", "simple", "test"}), "Sandwiched acronym");
    assert(listsEqual(Strings.SplitByCase("theSimpleFOO"), {"the", "simple", "foo"}), "Trailing acronym");
end;

function StringsTests:TestSplitByCaseIgnoresWhitespace()
    assert(listsEqual(Strings.SplitByCase("  caps  "), {"  caps  "}), "Both leading and trailing whitespace");
    assert(listsEqual(Strings.SplitByCase("  caps"), {"  caps"}), "Leading whitespace");
    assert(listsEqual(Strings.SplitByCase("caps  "), {"caps  "}), "Trailing whitespace");
    assert(listsEqual(Strings.SplitByCase("ca  ps"), {"ca ps"}), "Internal whitespace");
    local spaces = (" "):rep(5);
    assert(listsEqual(Strings.SplitByCase(spaces), {spaces}), "Only whitespace");
end;

function StringsTests:TestSplitByCaseCoercesValues()
    assert(listsEqual(Strings.SplitByCase(42), {"42"}), "Number value");
    assert(listsEqual(Strings.SplitByCase(Noop), {tostring(Noop)}), "Function value");
    assert(listsEqual(Strings.SplitByCase(false), {"false"}), "Boolean value");
end;

function StringsTests:TestSplitByCaseFailsOnNil()
    assert(not pcall(Strings.SplitByCase, nil), "SplitByCase throws on nil");
end;

function StringsTests:TestSplitByCaseHandlesEmptyString()
    assert(listsEqual(Strings.SplitByCase(""), {""}), "Empty string");
end;

function StringsTests:TestSplitByDelimiter()
    assert(listsEqual(Strings.SplitByDelimiter(""), {""}), "Empty string");
    assert(listsEqual(Strings.SplitByDelimiter("foo"), {"foo"}), "No delimiters");
    assert(listsEqual(Strings.SplitByDelimiter("Foo"), {"Foo"}), "No delimiters, mixed capitalization");
    assert(listsEqual(Strings.SplitByDelimiter("Foo_Time"), {"Foo", "Time"}), "Simple delimiters");
    assert(listsEqual(Strings.SplitByDelimiter("Foo_Time_Base_Bar"), {"Foo", "Time", "Base", "Bar"}), "Complex delimiter");
    assert(listsEqual(Strings.SplitByDelimiter("Foo___Time"), {"Foo", "Time"}), "Wide delimiter");
    assert(listsEqual(Strings.SplitByDelimiter("___"), {}), "Only delimiter");
    assert(listsEqual(Strings.SplitByDelimiter("___Foo"), {"Foo"}), "Leading delimiter");
    assert(listsEqual(Strings.SplitByDelimiter("Foo___"), {"Foo"}), "Trailing delimiter");
    assert(listsEqual(Strings.SplitByDelimiter(" ", "No Time"), {"No", "Time"}), "Custom delimiter");
    assert(not pcall(Strings.SplitByDelimiter, nil), "SplitByDelimiter fails on nil arguments");
end;

function StringsTests:TestSplitByDelimiterCoercesValues()
    assert(listsEqual(Strings.SplitByDelimiter(3, "2223444"), {"222", "444"}), "Coerced delimiter");
    assert(listsEqual(Strings.SplitByDelimiter("3", 2223444), {"222", "444"}), "Coerced string");
    assert(listsEqual(Strings.SplitByDelimiter(false, "truefalsetrue"), {"true", "true"}), "False as delimiter");
end;

function StringsTests:TestJoinProperCaseTrivalCases()
    local strFunc = Strings.JoinProperCase;
    assert("Foo" == strFunc({"Foo"}), "Proper case");
    assert("Foo" == strFunc({"FOO"}), "Upper case");
    assert("Foo" == strFunc({"foo"}), "Lower case");
    assert("Foo" == strFunc({"FoO"}), "Mixed case");
    assert("42" == strFunc({42}), "Coerced numbers");
    assert("False" == strFunc({false}), "Coerced false boolean");
    assert("" == strFunc({}), "Empty list");
end;

function StringsTests:TestJoinProperCaseComplexCases()
    local strFunc = Strings.JoinProperCase;
    assert("TheGreatExample" == strFunc({"The", "Great", "Example"}), "No-op case"); 
    assert("TheGreatExample" == strFunc({"ThE", "GREAT", "example"}), "Mixed cases"); 
    assert("GreatAExample" == strFunc({"great", "a", "example"}), "Sandwiched one-letter word");
    assert("TheGreatA" == strFunc({"the", "great", "a"}), "Trailing one-letter word");
    assert("GreatExample" == strFunc({"", "great", "", "example", ""}), "Spurious empty strings");
end;

function StringsTests:TestJoinCamelCaseTrivalCases()
    local strFunc = Strings.JoinCamelCase;
    assert("foo" == strFunc({"Foo"}), "Proper case");
    assert("foo" == strFunc({"FOO"}), "Upper case");
    assert("foo" == strFunc({"foo"}), "Lower case");
    assert("foo" == strFunc({"FoO"}), "Mixed case");
    assert("42" == strFunc({42}), "Coerced numbers");
    assert("false" == strFunc({false}), "Coerced false boolean");
    assert("" == strFunc({}), "Empty list");
end;

function StringsTests:TestJoinCamelCaseComplexCases()
    local strFunc = Strings.JoinCamelCase;
    assert("theGreatExample" == strFunc({"The", "Great", "Example"}), "No-op case"); 
    assert("theGreatExample" == strFunc({"ThE", "GREAT", "example"}), "Mixed cases"); 
    assert("greatAExample" == strFunc({"great", "a", "example"}), "Sandwiched one-letter word");
    assert("theGreatA" == strFunc({"the", "great", "a"}), "Trailing one-letter word");
    assert("GreatExample" == strFunc({"", "great", "", "example", ""}), "Spurious empty strings");
    assert("Great_Example" == strFunc({"great", "_", "example"}), "Spurious delimiters");
end;

function StringsTests:TestJoinSnakeCaseTrivalCases()
    local strFunc = Strings.JoinSnakeCase;
    assert("foo" == strFunc({"Foo"}), "Proper case");
    assert("foo" == strFunc({"FOO"}), "Upper case");
    assert("foo" == strFunc({"foo"}), "Lower case");
    assert("foo" == strFunc({"FoO"}), "Mixed case");
    assert("42" == strFunc({42}), "Coerced numbers");
    assert("false" == strFunc({false}), "Coerced false boolean");
    assert("" == strFunc({}), "Empty list");
    assert("_" == strFunc({"_"}), "Only delimiter");
end;

function StringsTests:TestJoinSnakeCaseComplexCases()
    local strFunc = Strings.JoinCamelCase;
    assert("the_great_example" == strFunc({"The", "Great", "Example"}), "No-op case"); 
    assert("the_great_example" == strFunc({"ThE", "GREAT", "example"}), "Mixed cases"); 
    assert("great_a_example" == strFunc({"great", "a", "example"}), "Sandwiched one-letter word");
    assert("the_great_a" == strFunc({"the", "great", "a"}), "Trailing one-letter word");
    assert("great_example" == strFunc({"", "great", "", "example", ""}), "Spurious empty strings");
    assert("great___example" == strFunc({"great", "_", "example", ""}), "Spurious delimiters");
end;

function StringsTests:TestConvertersToSnakeCase()
    assert(Strings.ProperToSnakeCase("TheGreatExample") == "the_great_example", "Proper to Snake");
    assert(Strings.CamelToSnakeCase("theGreatExample") == "the_great_example", "Camel to Snake");
end;

function StringsTests:TestConvertersToCamelCase()
    assert(Strings.ProperToCamelCase("TheGreatExample") == "theGreatExample", "Proper to Camel");
    assert(Strings.SnakeToCamelCase("the_great_example") == "theGreatExample", "Snake to Camel");
end;

function StringsTests:TestConvertersToProperCase()
    assert(Strings.CamelToProperCase("theGreatExample") == "TheGreatExample", "Camel to Proper");
    assert(Strings.SnakeToProperCase("the_great_example") == "TheGreatExample", "Snake to Proper");
end;

function StringsTests:TestProperNounize()
    assert(Strings.ProperNounize("Proper") == "Proper", "No-op case");
    assert(Strings.ProperNounize("proper") == "Proper", "Lower case");
    assert(Strings.ProperNounize("PROPER") == "Proper", "Upper case");
    assert(Strings.ProperNounize("pRoPeR") == "Proper", "Mixed case");
    assert(Strings.ProperNounize("P") == "P", "One letter, upper");
    assert(Strings.ProperNounize("p") == "p", "One letter, lower");
    assert(Strings.ProperNounize("1") == "1", "Number");
    assert(Strings.ProperNounize("1234") == "1234", "Number");
    assert(Strings.ProperNounize(1234) == "1234", "Number, coerced");
    assert(Strings.ProperNounize("_FOO") == "_foo", "Symbol with words");
end;

function StringsTests:TestConvertToBase()
    assert(Strings.ConvertToBase(10, 2345) == "2345", "2345, base 10");
    assert(Strings.ConvertToBase(2, 16) == "10000", "16, base 2");
    assert(Strings.ConvertToBase(2, 15) == "1111", "15, base 2");
    assert(Strings.ConvertToBase(16, 256) == "100", "256, base 16");
    assert(Strings.ConvertToBase(16, -256) == "-100", "-256, base 16");
    assert(Strings.ConvertToBase(16, 255) == "FF", "255, base 16");
end;

function StringsTests:TestConcat()
    assert(Strings.Concat("a") == "a", "No-op case");
    assert(Strings.Concat("a", "b") == "a b", "Two words");
    assert(Strings.Concat("a", "b", "c") == "a b c", "Multiple words");
    assert(Strings.Concat("a ", "b") == "a  b", "Spurious spaces");
end;
