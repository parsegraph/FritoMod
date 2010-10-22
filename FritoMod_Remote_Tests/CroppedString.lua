local Suite=CreateTestSuite("FritoMod_Remote/CroppedString");
if nil ~= require then
    require "FritoMod_Strings/Strings";
end;

function Suite:TestWritingACroppedString()
    Assert.Equals("0:Notime", Serializers.WriteCroppedString("Notime"));
    local chunks=Serializers.WriteCroppedString("ABCD", 253);
    Assert.NotNil(chunks);
    local chunkGroup=Strings.Split(":", chunks[1], 2)[1];
    Assert.Number(chunkGroup);
    local expectedChunks={};
    for _, v in ipairs({"A","B","C","D"}) do
        table.insert(expectedChunks, chunkGroup..":"..v);
    end;
    Assert.Equals(expectedChunks, chunks);
    local chunks=Serializers.WriteCroppedString({"AB","CD"}, 253);
end;
