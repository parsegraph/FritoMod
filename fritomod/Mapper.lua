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
end;

Mapper = OOP.Class("Mapper", Mixins.Log);

function Mapper:Constructor()
    self.listeners = ListenerList:New();

    self.sources = {};
    self.destinations = {};

    -- Authoritative view of the content, keyed by source keys to the
    -- underlying original data.
    self.aggregate = {};
end;

function Mapper:SetMapper(mapper, ...)
    self.mapper = Curry(mapper, ...);
    self.mappings = {};
    self:Update();
end;

-- Add the specified source to this mapper. If the source is a table, then
-- its keys and values will be used as source data.
--
-- Otherwise, the source should return an iterator function.
function Mapper:AddSource(src, ...)
    if select("#", ...) > 0 or type(src) ~= "table" then
        -- It has to be an iterator function.
        return self:AddSourceIterator(src, ...);
    end;
    return self:AddSourceIterator(Tables.SmartIterator, src);
end;
Mapper.AddSrc = Mapper.AddSource;

function Mapper:AddSourceList(src)
    return self:AddSourceIterator(Lists.ValueIterator, src);
end;

function Mapper:AddSourceTable(src)
    return self:AddSourceIterator(Tables.PairIterator, src);
end;

function Mapper:AddSourceIterator(src, ...)
    src = Curry(src, ...);
    local remover = Lists.Insert(self.sources, src);
    self:Update();
    return Functions.OnlyOnce(function(self)
        remover();
        self:Update();
    end, self);
end;

function Mapper:AddDestination(dest, ...)
    if select("#", ...) == 0 and type(dest) == "table" then
        -- Assume we intend to populate the specified table.
        return self:AddDestination(Tables.Set, dest);
    end;

    dest = Curry(dest, ...);
    local remover = Lists.Insert(self.destinations, dest);

    -- Push our data to the underlying destination
    self:Update();

    return remover;
end;
Mapper.AddDest = Mapper.AddDestination;

function Mapper:ContentFor(key, data)
    self.mappings[data] = self.mapper(data, self.mappings[data]);
    return self.mappings[data];
end;

function Mapper:Update()
    if not self.mapper then
        -- No mapper, so there won't be any mappings.
        return;
    end;

    self:logEnter("Mapping updates", "Updating mapper");

    local oldAggregate = self.aggregate;
    local aggregate = {};

    self:logEnter(nil, "Aggregating from", #self.sources, "source(s)");
    -- Get the full view of available data
    for _, source in ipairs(self.sources) do
        for key, data in source() do
            if data == nil then
                data = key;
                table.insert(aggregate, data);
            else
                aggregate[key] = data;
            end;
        end;
    end;
    self:logLeave();

    -- Push the new aggregate to be live. I do this here for atomicity
    self.aggregate = aggregate;

    self:logEnter("Pushing mapped values to destinations");
    -- Push all added and modified keys
    for key, data in pairs(aggregate) do
        assert(data ~= nil);
        local content = self:ContentFor(key, data);
        Lists.CallEach(self.destinations, key, content);

        -- I'm using the oldAggregate as a register of deleted keys. If a key
        -- still remains in oldAggregate after this loop, then it was deleted
        oldAggregate[key] = nil;
    end;

    -- Push all deleted keys to destinations
    for key, data in pairs(oldAggregate) do
        Lists.CallEach(self.destinations, key, nil);
    end;
    self:logLeave();

    self:logEnter("Firing mapper listeners");
    self.listeners:Fire();
    self:logLeave();

    self:logLeave();
end;

function Mapper:OnUpdate(func, ...)
    return self.listeners:Add(func, ...);
end;

function Mapper:ClassName()
	return "fritomod/Mapper";
end;

-- vim: set et :
