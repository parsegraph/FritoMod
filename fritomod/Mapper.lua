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

-- Special internal flag that a mapping has duplicate values.
local HAS_DUPLICATES = {};

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

    self.mapMeta = {};
    self.mapDuplicatesMeta = {};
    self:EnableWeakReferences();

    self:UseValueMapping();
    self:DisallowReuse();
end;

function Mapper:SetMapper(mapper, ...)
    self.mapper = Curry(mapper, ...);

    self.mappings = nil;
    self.duplicates = nil;

    self:Update();
end;

function Mapper:UseKeyMapping()
    self.chooser = function(k, v)
        return k;
    end;
    self:Update();
end;

function Mapper:UseValueMapping()
    self.chooser = function(k, v)
        if v == nil then
            return k;
        end;
        return v;
    end;
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

function Mapper:DisallowReuse()
    if not self.allowReuse then
        return;
    end;
    self.allowReuse = false;

    if self.mappings then
        -- We no longer allow reuse, so we need to remove
        -- any reused values from our mappings.
        local seen = {};
        for k,v in pairs(self.mappings) do
            -- We don't care about primitive values.
            if not IsPrimitive(v) and seen[v] then
                self.mappings[k] = nil;
            else
                seen[v] = true;
            end;
        end;
    end;
    self:Update();
end;

function Mapper:AllowReuse()
    if self.allowReuse then
        return;
    end;
    self.allowReuse = true;

    if self.mappings then
        -- We now allow reuse, so pull duplicates into mappings
        -- and clear the duplicates table.
        for k,v in pairs(self.mappings) do
            if v == HAS_DUPLICATES then
                self.mappings[k] = self.duplicates[k][1];
            end;
        end;
        self.duplicates = nil;
    end;
    self:Update();
end;

-- Prepare thsi mapper for an update.
function Mapper:Prepare()
    -- Maps original data to generated content. The keys are weak, so if
    -- original data is no longer used elsewhere, our mapping will eventually
    -- disappear here. This keeps things tidy, while also allowing us to be
    -- efficient if values are reused.
    if not self.mappings then
        self.mappings = setmetatable({}, self.mapMeta);
    end;
    if not self.allowReuse then
        if not self.duplicates then
            self.duplicates = setmetatable({}, self.mapMeta);
        end;
        self.uses = setmetatable({}, self.mapMeta);
    end;
end;

function Mapper:ContentFor(data)
    assert(type(self.mappings) == "table", "Mappings not present");

    if self.allowReuse then
        local content = self.mappings[data];
        if content == nil then
            content = self.mapper(data);
            self.mappings[data] = content;
        end;
        assert(content ~= HAS_DUPLICATES);
        return content;
    end;

    local uses = self.uses[data];
    uses = uses or 0;
    if uses == 0 then
        local content = self.mappings[data];
        if content == nil then
            -- We've never seen this data before.
            content = self.mapper(data);
            self.mappings[data] = content;
        end;
        if content ~= HAS_DUPLICATES then
            self.uses[data] = 1;
            return content;
        end;
    elseif uses == 1 then
        -- We've only used this content once before.
        local firstContent = assert(self.mappings[data]);
        if firstContent ~= HAS_DUPLICATES then
            -- Push this value into the duplicates table.
            self.duplicates[data] = setmetatable({firstContent}, self.mapDuplicatesMeta);
        end;
    end;

    local contentList = self.duplicates[data];
    assert(#contentList >= uses);

    local content = contentList[uses + 1];
    if content == nil then
        content = self.mapper(data);
        table.insert(contentList, content);
    end;
    self.uses[data] = uses + 1;
    return content;
end;

function Mapper:Update()
    if not self.mapper then
        -- No mapper, so there won't be any mappings.
        return;
    end;

    self:Prepare();

    self:DisableWeakReferences();

    local oldAggregate = self.aggregate;
    local aggregate = {};

    trace("Aggregating sources for mapping");
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

    -- Push the new aggregate to be live. I do this here for atomicity
    self.aggregate = aggregate;

    trace("Pushing mapped values to destinations");
    -- Push all added and modified keys
    for key, data in pairs(aggregate) do
        assert(data ~= nil);
        local content = self:ContentFor(self.chooser(key, data));
        Lists.CallEach(self.destinations, key, content);

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

    self.uses = nil;
    self:EnableWeakReferences();
end;

function Mapper:OnUpdate(func, ...)
    return self.listeners:Add(func, ...);
end;

function Mapper:DisableWeakReferences()
    self.mapMeta.__mode = "";
    self.mapDuplicatesMeta.__mode = "";
end;

function Mapper:EnableWeakReferences()
    self.mapMeta.__mode = "k";
    self.mapDuplicatesMeta.__mode = "v";
end;

-- vim: set et :
