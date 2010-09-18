Channel = OOP.Class(Log);
local Channel = Channel;

function Channel:__Init(channelName)
    Channel.__super.__Init(self);
    self.channelName = channelName;
    self:Pipe(channelName);
    self.memberNames = {};
end;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function Channel:GetMembers()
    return self.members;
end;

function Channel:SetMembers(members)
    self.members = members;
end;

-------------------------------------------------------------------------------
--
--  Members
--
-------------------------------------------------------------------------------

function Channel:AddMember(member)
    table.insert(self.members, member);
end;

function Channel:RemoveMember(member)
    self.members = ListUtil:RemoveItem(self.members, member);
end;

-------------------------------------------------------------------------------
--
--  Moderator
--
-------------------------------------------------------------------------------

function Channel:GetModerator()
    return self.moderator;
end;

function Channel:SetModerator(moderator)
    self.moderator = moderator;
end;
