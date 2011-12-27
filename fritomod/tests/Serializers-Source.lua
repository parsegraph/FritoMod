local Suite=CreateTestSuite("fritomod.Serializers-Source");

function Suite:TestWriteAString()
	Assert.Equals('"No time"', Serializers.WriteSource("No time"));
end;

function Suite:TestWriteANumber()
	Assert.Equals(("%f"):format(3.14), Serializers.WriteSource(3.14));
end;

function Suite:TestWriteABoolean()
	Assert.Equals("true", Serializers.WriteSource(true));
end;

local tableOutput=[[{
	["no"] = "time",
}]];

function Suite:TestWriteATable()
	Assert.Equals(tableOutput, Serializers.WriteSource({
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
	Assert.Equals(deepTableOutput, Serializers.WriteSource({
		nested={
			deep={
				answer=42
			}
		}
	}));
end;

function Suite:TestReadingSourceData()
	local t = {
		foo = "Notime",
		bar = {
			baz = "Hello!",
			num = 42
		}
	};
	Assert.Equals(t, Serializers.ReadSource(Serializers.WriteSource(t)));
end;
