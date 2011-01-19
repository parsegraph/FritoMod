local Suite=CreateTestSuite("Serializers-Lua");

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
