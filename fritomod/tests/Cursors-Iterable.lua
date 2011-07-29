local Suite=CreateTestSuite("fritomod.Cursors-Iterable");

function Suite:TestCursorOverAList()
    local a={3,4,5};
    local c=Cursors.Iterable:New(a, Lists);
    Assert.Equals(3, c:Length());
    Assert.True(c:AtStart());
    local clone={};
    while c:Next() do
        table.insert(clone, c:Value());
    end;
    Assert.Equals(a, clone);
    Assert.Nil(c:Get());
    Assert.True(c:AtEnd());
    local k,v=c:Previous();
    Assert.Equals(5, v);

    a={4,5,6};
    c:Iterable(a);
    clone={};
    while c:Next() do
        table.insert(clone, c:Value());
    end;
    Assert.Equals(a, clone);
end;

function Suite:TestMarkWithMove()
    local s="The Comanche moon was a portent for disaster";
    local c=Cursors.Iterable:New(s);
    local parts={};
    while c:MoveUntil(Strings.IsLetter) do
        c:Mark();
        c:PeekWhile(Strings.IsLetter);
        table.insert(parts, c:MarkSnippet());
    end;
    Assert.Equals(Strings.Split(" ", s), parts);
end;

function Suite:TestNaiveSplit()
    local s="The Comanche moon was a portent for disaster";
    local parts={};
    local startOfWord;
    for i=1,#s do
        local isLetter=Strings.IsLetter(Strings.CharAt(s, i));
        if not startOfWord then
            startOfWord=i;
        elseif not isLetter then
            table.insert(parts, s:sub(startOfWord, i-1));
            startOfWord=nil;   
        end;
    end;
    if startOfWord then
        table.insert(parts, s:sub(startOfWord));
    end;
    Assert.Equals(Strings.Split(" ", s), parts);
end;
