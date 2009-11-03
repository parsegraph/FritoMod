if nil ~= require then
    require "FritoMod_OOP/OOP/Class";
end;

NumberBuilder = OOP.Class();

function NumberBuilder:Constructor()
    self.staged = 0;
    self.qualifier = 1;
    self.committed = {};
end;

function NumberBuilder:Clear()
    self.lastMagnitude = nil;
    self.staged = 0;
    self.qualifier = 1;
    self.committedValue = 0;
end;

function NumberBuilder:GetValue()
    self:Commit();
    return self.qualifier * self.committedValue;
end;

function NumberBuilder:SetQualifier(qualifier)
    self.qualifier = qualifier;
end;

function NumberBuilder:GetQualifier()
    return self.qualifier;
end;

function NumberBuilder:Commit(magnitude)
    magnitude = magnitude or 1;
    if self.staged == 0 then
        return;
    end;
    self.committedValue = self.committedValue + (self.staged * magnitude);
    self.staged = 0;
end;

function NumberBuilder:Stage(value)
    self.staged = self.staged + value;
end;

function NumberBuilder:GetStaged()
    return self.staged;
end;

function NumberBuilder:Magnitude(magnitude)
    if self.lastMagnitude then
        assert(self.lastMagnitude > magnitude, "Magnitude is out of sequence.");
    end;
    self.lastMagnitude = magnitude;
    self:Commit(magnitude);
end;
