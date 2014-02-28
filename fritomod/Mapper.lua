-- Maps source data to automatically generated content.
--
-- It's often useful to have a list or table of data that needs to be
-- transformed to some other form. One of the most common examples of this
-- is a list of data that you wish to be displayed visually. Mapper provides
-- a structured means to create these mappings, efficiently and automatically.
--
-- A Mapper consists of three components:
-- 1. a number of sources
-- 2. a number of destinations
-- 3. a mapper
--
-- Sources may be a table or a function that produces an iterator. These sources
-- provide the data that will be transformed.
--
-- Destinations may also be a table or a function that expects (key, content) for every
-- generated pair form source.
--
-- The mapper function performs the transformation, taking (data, key) and returning the
-- generated content.
--
-- Multiple sources and destinations are allowed. As these compoenents are added, the
-- mapping will be updated accordingly. Similarly, the mapper itself can be changed, which
-- will cause the mappings to be regenerated.

if nil ~= require then
    require "fritomod/currying";
    require "fritomod/OOP-Class";
    require "fritomod/Functions";
    require "fritomod/Tables";
    require "fritomod/Lists";
    require "fritomod/ListenerList";
    require "fritomod/Mixins-Log";
    require "fritomod/Mixins-Invalidating";
end;

Mapper = OOP.Class("Mapper",
    Mixins.Log,
    Mixins.Invalidating
);

function Mapper:Constructor()
    self.contentFor = {};
    self:AddDestructor(Seal(self, "SetMapper", nil));

    self:OnValidate(self, "Build");

    -- Call validate to properly sync up our state.
    self:Validate();
end;

function Mapper:ContentFor(data)
    self:logEnterf("Building content for", data);
    assert(data ~= nil, "Data must not be nil");
    self.contentFor[data] = self:Mapper()(data, self.contentFor[data]);
    self:logLeave();
    return self.contentFor[data];
end;

function Mapper:RemoveContentFor(data)
    if data == nil then
        return;
    end;
    local content = self.contentFor[data];
    if content then
        self:logEnterf("Removing content for", data);
        self:Mapper()(nil, content);
        self.contentFor[data] = nil;
        self:logLeave();
    end;
end;

function Mapper:Build()
    if not self:Mapper() then
        self:logcf("Mapping builds", "I received a request to build mapped values, but I don't have a mapper.");
        self.mapped = {};
        return;
    end;

    self:logEnter("Mapping builds", "I'm rebuilding my mapped values.")

    self.mapped = {};
    local oldMapped = self.mapped or {};
    local seenData = {};

    if self:Source() then
        for key, data in pairs(self:Source()) do
            self.mapped[key] = self:ContentFor(data);
            seenData[data] = true;
        end;
    end;

    for data, _ in pairs(self.contentFor) do
        if not seenData[data] then
            self:RemoveContentFor(data);
        end;
    end;

    self:logLeave();
end;

function Mapper:Get()
    if self:IsInvalidated() then
        self:Validate();
    end;
    return self.mapped;
end;
Mapper.GetMapped = Mapper.Get;

OOP.Property(Mapper, "Source", function(self, commit, value)
    commit(value);
    self:Invalidate();
end);

function Mapper:SetMapper(mapper, ...)
    if self:Mapper() then
        Tables.EachK(self.contentFor, self, "RemoveContentFor");
    end;
    if mapper ~= nil or select("#", ...) > 0 then
        self.mapper = Curry(mapper, ...);
    end;
    self:Invalidate();
end;

function Mapper:GetMapper()
    return self.mapper;
end;
Mapper.Mapper = Mapper.GetMapper;

-- vim: set et :
