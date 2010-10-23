Serializers=Serializers or {};

function Serializers.WriteData(...)
    local out="";
    for i=1,select("#", ...) do
        local v=select(i, ...);
        local m;
        if v==true then
            m="B";
        elseif v==false then
            m="b";
        else
            error("Unsupported "..type(v).." value: "..tostring(v));
        end;
        out=out..m;
    end;
    return out;
end;

function Serializers.ReadData(message)
    local data={};
    local dataCount=0;
    local i=Strings.BidiIterator(message);
    while i.Next() do
        local p=i.Value();
        local v;
        if p=="B" then
            v=true;
        elseif p=="b" then
            v=false;
        else
            error("Unsupported "..type(v).." value: "..tostring(v));
        end;
        dataCount=dataCount+1;
        data[dataCount]=v;
    end;
    return unpack(data);
end;
