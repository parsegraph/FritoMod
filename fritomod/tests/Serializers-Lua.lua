local Suite=CreateTestSuite("fritomod.Serializers-Lua");

function Suite:TestWriteAString()
    Assert.Equals('"No time"', Serializers.WriteLua("No time"));
end;

function Suite:TestWriteANumber()
    Assert.Equals(("%f"):format(3.14), Serializers.WriteLua(3.14));
end;

function Suite:TestWriteABoolean()
    Assert.Equals("true", Serializers.WriteLua(true));
end;

local tableOutput=[[{
	["no"] = "time",
}]];

function Suite:TestWriteATable()
    Assert.Equals(tableOutput, Serializers.WriteLua({
        no="time",
    }));
end;

local deepTableOutput=[[{
	["nested"] = {
		["deep"] = {
			["answer"] = 42,
		},
	},
}]];

function Suite:TestWriteATableWithANestedTable()
    Assert.Equals(deepTableOutput, Serializers.WriteLua({
        nested={
            deep={
                answer=42
            }
        }
    }));
end;

function Suite:TestReadingLuaData()
    local t = {
        foo = "Notime",
        bar = {
            baz = "Hello!",
            num = 42
        }
    };

    local retrieved = Serializers.ReadLua(Serializers.WriteLua(t));

    assert(retrieved.foo == "Notime");
    assert(retrieved.bar.baz == "Hello!");
    assert(retrieved.bar.num == 42);
end;
