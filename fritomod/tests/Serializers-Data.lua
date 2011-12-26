local Suite=CreateTestSuite("fritomod.Serializers-Data");

local function Check(...)
    Assert.Equals({...}, {Serializers.ReadData(Serializers.WriteData(...))});
end

function Suite:TestWriteAString()
    Assert.Equals("s7No time", Serializers.WriteData("No time"));
end;

function Suite:TestWriteANumber()
    Assert.Equals(("n%f"):format(3.14), Serializers.WriteData(3.14));
end;

function Suite:TestWriteABoolean()
    Assert.Equals("BbB", Serializers.WriteData(true,false,true));
end;

function Suite:TestWriteATable()
    Assert.Equals("tks2nos4time", Serializers.WriteData({
        no="time",
    }));
end;

function Suite:TestWriteATableWithANestedTable()
    Assert.Equals("tks6nestedtks4deeptks6answern42", Serializers.WriteData({
        nested={
            deep={
                answer=42
            }
        }
    }));
end;

function Suite:TestReadAString()
    Assert.Equals("No time", Serializers.ReadData("s7No time"));
end;

function Suite:TestReadANumber()
    Assert.Equals(3.14, Serializers.ReadData(("n%f"):format(3.14)));
end;

function Suite:TestReadABoolean()
    Assert.Equals(true, Serializers.ReadData("B"));
    Assert.Equals(false, Serializers.ReadData("b"));
end;

function Suite:TestReadATable()
    Assert.Equals({no="time"}, Serializers.ReadData("tks2nos4time"));
end;

function Suite:TestReadANestedTable()
    Assert.Equals({
        nested={
            deep={
                answer=42
            }
        }
    }, Serializers.ReadData("tks6nestedtks4deeptks6answern42"));
end;

function Suite:TestReadHandlesTablesWithMultipleKeys()
    local original = {
        name = "My name!",
        index = 23,
        data = "Some content."
    };
    local retrieved = Serializers.ReadData(Serializers.WriteData(original));
    Assert.Equals(original, retrieved);
end;
