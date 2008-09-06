API.Unit = {};
local Unit = API.Unit;

Unit.factions = {
    HORDE = "horde",
    ALLIANCE = "alliance"
}

Unit.ids = {
    PLAYER = "player",
    TARGET = "target",
    FOCUS = "focus",
    MOUSEOVER = "mouseover"
};

function Unit:FetchByName(name, realm)
    
end;

function Unit:FetchByID(id)

end;

function Unit:Player()
    return Unit:FetchByID
end;
