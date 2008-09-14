Channel = FritoLib.OOP.Class(Log);

function Channel.prototype:init(channelName)
    Channel.super.prototype.init(self);
    self.channelName = channelName;
    self:Pipe(channelName);
    self.memberNames = {};
end;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function Channel.prototype:GetMembers()
    return self.members;
end;

function Channel.prototype:SetMembers(members)
    self.members = members;
end;

-------------------------------------------------------------------------------
--
--  Members
--
-------------------------------------------------------------------------------

function Channel.prototype:AddMember(member)
    table.insert(self.members, member);
end;

function Channel.prototype:RemoveMember(member)
    self.members = ListUtil:RemoveItem(self.members, member);
end;

-------------------------------------------------------------------------------
--
--  Moderator
--
-------------------------------------------------------------------------------

function Channel.prototype:GetModerator()
    return self.moderator;
end;

function Channel.prototype:SetModerator(moderator)
    self.moderator = moderator;
end;
