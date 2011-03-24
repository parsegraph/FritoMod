local Suite=CreateTestSuite("Strings-Split");

function Suite:TestSplitByCaseTrivialCases()
    local s = Strings.SplitByCase;
    Assert.Equals({"caps"}, s("caps"), "Short java-case");
    Assert.Equals({"Caps"}, s("Caps"), "Short Camel-case");
    Assert.Equals({"CAPS"}, s("CAPS"), "Short Upper-case");
end;

function Suite:TestSplitByCase()
    local s = Strings.SplitByCase;
    Assert.Equals({"The", "Simple", "Test"}, s("TheSimpleTest"), "Simple proper-case");
    Assert.Equals({"the", "Simple", "Test"}, s("theSimpleTest"), "Simple camel-case");
end;

function Suite:TestSplitByCaseWithAcronyms()
    local s = Strings.SplitByCase;
    Assert.Equals({"FOO", "Simple", "Test"}, s("FOOSimpleTest"), "Leading acronym");
    Assert.Equals({"a", "FOO", "Simple", "Test"}, s("aFOOSimpleTest"), "Sandwiched acronym");
    Assert.Equals({"the", "Simple", "FOO"}, s("theSimpleFOO"), "Trailing acronym");
end;

function Suite:TestSplitByCaseIgnoresWhitespace()
    local s = Strings.SplitByCase;
    Assert.Equals({"  caps  "}, s("  caps  "), "Both leading and trailing whitespace");
    Assert.Equals({"  caps"}, s("  caps"), "Leading whitespace");
    Assert.Equals({"caps  "}, s("caps  "), "Trailing whitespace");
    Assert.Equals({"ca  ps"}, s("ca  ps"), "Internal whitespace");
    local spaces = (" "):rep(5);
    Assert.Equals({spaces}, s(spaces), "Only whitespace");
end;

function Suite:TestSplitByCasePersistsSpecialValues()
    local s = Strings.SplitByCase;
    Assert.Equals({"foo1234", "Bar"}, s("foo1234Bar"), "Lower-cased special values");
    Assert.Equals({"black", "FOO42", "Red"}, s("blackFOO42Red"), "Sandwiched upper-case symbols");
    Assert.Equals({"black", "FOO42"}, s("blackFOO42"), "Trailing upper-case symbols");
    Assert.Equals({"black", "Foo42"}, s("blackFoo42"), "Trailing lower-case symbols");
end;

function Suite:TestSplitByCaseCoercesValues()
    local s = Strings.SplitByCase;
    Assert.Equals({"42"}, s(42), "Number value");
    Assert.Equals({"false"}, s(false), "Boolean value");
end;

function Suite:TestSplitByCaseFailsOnNil()
    Assert.Exception("SplitByCase throws on nil", Strings.SplitByCase, nil);
end;

function Suite:TestSplitByCaseHandlesEmptyString()
    local s = Strings.SplitByCase;
    Assert.Equals({}, s(""), "Empty string");
end;

function Suite:TestJoinProperCaseTrivalCases()
    local s = Strings.JoinProperCase;
    Assert.Equals("Foo", s({"Foo"}), "Proper case");
    Assert.Equals("Foo", s({"FOO"}), "Upper case");
    Assert.Equals("Foo", s({"foo"}), "Lower case");
    Assert.Equals("Foo", s({"FoO"}), "Mixed case");
    Assert.Equals("42", s({42}), "Coerced numbers");
    Assert.Equals("False", s({false}), "Coerced false boolean");
    Assert.Equals("", s({}), "Empty list");
end;

function Suite:TestJoinProperCaseComplexCases()
    local s = Strings.JoinProperCase;
    Assert.Equals("TheGreatExample", s({"The", "Great", "Example"}), "No-op case");
    Assert.Equals("TheGreatExample", s({"ThE", "GREAT", "example"}), "Mixed cases");
    Assert.Equals("GreatAExample", s({"great", "a", "example"}), "Lower case");
    Assert.Equals("TheGreatA", s({"the", "great", "a"}), "Trailing one-letter word");
    Assert.Equals("GreatExample", s({"", "great", "", "example", ""}), "Spurious empty strings");
end;

function Suite:TestJoinCamelCaseTrivalCases()
    local s = Strings.JoinCamelCase;
    Assert.Equals("foo", s({"Foo"}), "Proper case");
    Assert.Equals("foo", s({"FOO"}), "Upper case");
    Assert.Equals("foo", s({"foo"}), "Lower case");
    Assert.Equals("foo", s({"FoO"}), "Mixed case");
    Assert.Equals("42", s({42}), "Coerced numbers");
    Assert.Equals("false", s({false}), "Coerced false boolean");
    Assert.Equals("", s({}), "Empty list");
end;

function Suite:TestJoinCamelCaseComplexCases()
    local s = Strings.JoinCamelCase;
    Assert.Equals("theGreatExample", s({"The", "Great", "Example"}), "No-op case");
    Assert.Equals("theGreatExample", s({"ThE", "GREAT", "example"}), "Mixed cases");
    Assert.Equals("greatAExample", s({"great", "a", "example"}), "Sandwiched one-letter word");
    Assert.Equals("theGreatA", s({"the", "great", "a"}), "Trailing one-letter word");
    Assert.Equals("greatExample", s({"", "great", "", "example", ""}), "Spurious empty strings");
    Assert.Equals("great_Example", s({"great", "_", "example"}), "Suspicious delimiter");
end;

function Suite:TestJoinSnakeCaseTrivalCases()
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

function Suite:TestJoinSnakeCaseComplexCases()
    local s = Strings.JoinSnakeCase;
    Assert.Equals("the_great_example", s({"The", "Great", "Example"}), "No-op case");
    Assert.Equals("the_great_example", s({"ThE", "GREAT", "example"}), "Mixed cases");
    Assert.Equals("great_a_example", s({"great", "a", "example"}), "Sandwiched one-letter word");
    Assert.Equals("the_great_a", s({"the", "great", "a"}), "Trailing one-letter word");
    Assert.Equals("great_example", s({"", "great", "", "example", ""}), "Spurious empty strings");
    Assert.Equals("great___example", s({"great", "_", "example", ""}), "Spurious delimiters");
end;

function Suite:TestConvertersToSnakeCase()
    Assert.Equals("the_great_example", Strings.ProperToSnakeCase("TheGreatExample"), "Proper to Snake");
    Assert.Equals("the_great_example", Strings.CamelToSnakeCase("theGreatExample"), "Camel to Snake");
end;

function Suite:TestConvertersToCamelCase()
    Assert.Equals("theGreatExample", Strings.ProperToCamelCase("TheGreatExample"), "Proper to Camel");
    Assert.Equals("theGreatExample", Strings.SnakeToCamelCase("the_great_example"), "Snake to Camel");
end;

function Suite:TestConvertersToProperCase()
    Assert.Equals("TheGreatExample", Strings.CamelToProperCase("theGreatExample"), "Camel to Proper");
    Assert.Equals("TheGreatExample", Strings.SnakeToProperCase("the_great_example"), "Snake to Proper");
end;
