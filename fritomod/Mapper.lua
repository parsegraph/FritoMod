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
end;

Mapper = OOP.Class();

function Mapper:Constructor(mapper, ...)
    self.listeners = ListenerList:New();

    if mapper or select("#", ...) > 0 then
        self.mapper = Curry(mapper, ...);
    end;

    self.sources = {};
    self.destinations = {};

    -- Authoritative view of the content, keyed by source keys to the
    -- underlying original data.
    self.aggregate = {};
end;

function Mapper:SetMapper(mapper, ...)
    self.mapper = Curry(mapper, ...);

    -- Maps original data to generated content. The keys are weak, so if
    -- original data is no longer used elsewhere, our mapping will eventually
    -- disappear here. This keeps things tidy, while also allowing us to be
    -- efficient if values are reused.
    self.mappings = setmetatable({}, {
        __mode = "k"
    });

    self:Update();
end;

function Mapper:UseKeyMapper(mapper, ...)
    mapper = Curry(mapper, ...);
    self:SetMapper(function(value, key)
        return mapper(key);
    end);
end;

function Mapper:UseValueMapper(mapper, ...)
    mapper = Curry(mapper, ...);
    self:SetMapper(function(value, key)
        return mapper(value);
    end);
end;

-- Add the specified source to this mapper. If the source is a table, then
-- its keys and values will be used as source data.
--
-- Otherwise, the source should return an iterator function.
function Mapper:AddSource(src, ...)
    if select("#", ...) == 0 and type(src) == "table" then
        -- Assume we intend to pull values from the specified table.
        return self:AddSource(Tables.PairIterator, src);
    end;

    src = Curry(src, ...);
    local remover = Lists.Insert(self.sources, src);

    self:Update();

    return remover;
end;
Mapper.AddSrc = Mapper.AddSource;

function Mapper:AddDestination(dest, ...)
    if select("#", ...) == 0 and type(dest) == "table" then
        -- Assume we intend to populate the specified table.
        return self:AddDestination(Tables.Set, dest);
    end;

    dest = Curry(dest, ...);
    local remover = Lists.Insert(self.destinations, dest);

    if self.mapper then
        -- Push our data to the underlying destination
        for key, data in pairs(self.aggregate) do
            dest(key, self.mappings[data]);
        end;
    end;

    return remover;
end;
Mapper.AddDest = Mapper.AddDestination;

function Mapper:Update()
    if not self.mapper then
        -- No mapper, so there won't be any mappings.
        return;
    end;
    assert(type(self.mappings) == "table", "Mappings not present");

    local oldAggregate = self.aggregate;
    local aggregate = {};

    trace("Aggregating sources for mapping");
    -- Get the full view of available data
    for _, source in ipairs(self.sources) do
        for key, data in source() do
            if self.mappings[data] == nil and data ~= nil then
                -- This is a new piece of data, so generate content for it
                self.mappings[data] = self.mapper(data, key);
            end;
            aggregate[key] = data;
        end;
    end;

    -- Push the new aggregate to be live. I do this here for atomicity
    self.aggregate = aggregate;

    trace("Pushing mapped values to destinations");
    -- Push all added and modified keys
    for key, data in pairs(aggregate) do
        Lists.CallEach(self.destinations, key, self.mappings[data]);

        -- I'm using the oldAggregate as a register of deleted keys. If a key
        -- still remains in oldAggregate after this loopp, then it was deleted
        oldAggregate[key] = nil;
    end;

    -- Push all deleted keys to destinations
    for key, data in pairs(oldAggregate) do
        Lists.CallEach(self.destinations, key, nil);
    end;

    trace("Firing mapper listeners");
    self.listeners:Fire();
end;

function Mapper:OnUpdate(func, ...)
    return self.listeners:Add(func, ...);
end;

-- vim: set et :
