StyleClient = OOP.MixinLibrary();
local StyleClient = StyleClient;

-- Enumeration used in our AddComputedValue calls
StyleClient.CHANGE_SIZE = "ChangeLayout";
StyleClient.CHANGE_LAYOUT = "ChangeVisual";

-------------------------------------------------------------------------------
--
--  Overriddable Methods: StyleClient
--
-------------------------------------------------------------------------------

function StyleClient:ComputeValue(valueName)
    -- OVERRIDE ME: Compute any values here. 
    -- Be sure to call super()'s method if you're unable to compute a value.
end;

function StyleClient:FetchDefaultFromTable(valueName)
    -- OVERRIDE ME: Return a default value given the valueName as the key.
    -- Be sure to call super()'s if your defaults fail.
end;

function StyleClient:GetMediaKeyName(valueName)
    -- OVERRIDE ME: Return the MediaLibrary's name for the given valueName.
    -- Be sure to call super()'s method if you're unable to compute a value.
end;

-------------------------------------------------------------------------------
--
--  GetComputed
--
-------------------------------------------------------------------------------

-- Finds a value given the valueName using the full power of the StyleClient. It will return the first
--     non-nil value found, in this order of precedence:
-- 1. Explicit values, those that are set on the object.
-- 2. Computed values, those that are determined by the client, potentially using other styles as 
--     a guideline.
-- 3. Templates, other StyleClients that are given to use as a template for this object. The
--  template's GetComputed will be called, so these may chain.
-- 4. Defaults, those that are likely set on the object's class, and should be arbitrary.
--
-- If no value is found, and failSilently is not set, then an error will be thrown.
function StyleClient:GetComputed(valueName, useExplicit, failSilently)
    local value;
    
    -- First, use explicit values.
    if useExplicit then
        value = self:GetExplicit(valueName);
    end;
    if value ~= nil then
        return value;
    end;
    
    -- Attempt to compute one if there's no explicit.
    value = self:ComputeValue(valueName);
    if value ~= nil then
        return value;
    end;
    
    -- Use the template to get a proper value.
    if self:GetTemplate() then
        value = self:GetTemplate():GetComputed(valueName, useExplicit, true);
    end;
    if value ~= nil then
        return value;
    end;
    
    -- Finally, seek a default.
    value = self:GetDefault(valueName);
    if value ~= nil then
        return value;
    end;
    
    if not failSilently then
        error("StyleClient: No value produced for valueName '" .. valueName .. "'");
    end;
end;

-------------------------------------------------------------------------------
--
--  Getters and Setters
--
-------------------------------------------------------------------------------

------------------------------------------
--  Template
------------------------------------------

function StyleClient:GetTemplate()
    return self.template;
end;

function StyleClient:SetTemplate(template)
    if self.template == template then
        return;
    end;
    self.template = template;
    if self:IsInvalidating() then
        self:InvalidateSize();
        self:InvalidateLayout();
    end;
end;

------------------------------------------
--  Explicit (Get/Set)
------------------------------------------

-- Gets the explicit value for the valueName, if any is found.
--
-- This will follow MediaLibrary keys.
function StyleClient:GetExplicit(valueName)
    if not self.explicitValues then
        return;
    end;
    return self:FollowMediaLibraryKey(valueName, self.explicitValues[valueName], true);
end;

-- Sets an explicit value. valueName is the key (e.g. "font", "width"), and value is the value
-- you wish to use for it.
--
-- Notice that with MediaLibrary style rules, your value is _not_ MediaLibrary's value, but simply
-- the keyname. The transformation from the key to the value in MediaLibrary will be done on 
-- GetX calls.
function StyleClient:SetExplicit(valueName, value, changeType)
    if not self.explicitValues then
        self.explicitValues = {};
    end;
    if value == self.explicitValues[valueName] then
        -- If the value is the same as our current value, do nothing.
        return;
    end;
    self:DoStyleChange(valueName, value, self.explicitValues[valueName]);
    if not self:IsInvalidating() then
        return;
    end;
    if changeType == StyleClient.CHANGE_SIZE then
        -- This is a layout change, so update our dimensions.
            self:InvalidateSize();
    elseif changeType == StyleClient.CHANGE_LAYOUT then 
        -- This is a visual change, so just redraw.
        self:InvalidateLayout();
    else
        error("StyleClient: Unexpected changeType: " .. tostring(changeType));
    end;
end;

function StyleClient:DoStyleChange(valueName, newValue, oldValue)
    if oldValue and type(oldValue) == "table" and FritoLib.OOP.inherits(oldValue, InvalidatingForwarder) then
        oldValue:RemoveInvalidating(self);
    end;
    self.explicitValues[valueName] = newValue;
    if newValue and type(newValue) == "table" and FritoLib.OOP.inherits(newValue, InvalidatingForwarder) then
        newValue:AddInvalidating(self);
    end;
end;

------------------------------------------
--  Default (Read-only)
------------------------------------------

-- Gets a default. Notice that this will follow MediaLibrary keys. 
function StyleClient:GetDefault(valueName)
    local value = self:FetchDefaultFromTable(valueName);
    local mediaType = self:GetMediaKeyName(valueName);
    if not mediaType then
        -- It's not a key value, so just return it as-is.
        return value;
    end;
    -- It is a key value, so use it as a key, or retrieve a default directly.
    if value ~= nil then
        return self:FollowMediaLibraryKey(valueName, value);
    end;
    return MediaLibrary:GetDefault(mediaType);
end;

-------------------------------------------------------------------------------
--
--  Static Utility Functions
--
-------------------------------------------------------------------------------

function StyleClient.AddComputedValue(class, valueName, visualProperty)
    if not class["Get" .. valueName] then
        class["Get" .. valueName] = function(self)
            return self:GetComputed(valueName, true);
        end;
    end;
    if not class["GetExplicit" .. valueName] then
        class["GetExplicit" .. valueName] = function(self)
            return self:GetExplicit(valueName);
        end;
    end;
    if not class["Set" .. valueName] then
        class["Set" .. valueName] = function(self, value)
            return self:SetExplicit(valueName, value, visualProperty);
        end;
    end;
    if not class["GetComputed" .. valueName] then
        class["GetComputed" .. valueName] = function(self)
            return self:GetComputed(valueName, false);
        end;
    end;
    if not class["Clear" .. valueName] then
        class["Clear" .. valueName] = function(self)
            return self:SetExplicit(valueName, nil, visualProperty);
        end;
    end;
end;

-------------------------------------------------------------------------------
--
--  Utility Methods
--
-------------------------------------------------------------------------------

function StyleClient:IsInvalidating()
    if self.isInvalidating == nil then
        self.isInvalidating = self.InvalidateLayout and self.InvalidateSize;
    end;
    return self.isInvalidating;
end;

-- An internal method. Given a valueType (The style name on the object), this will get the 
-- MediaLibrary's keyname of it, and then follow it to return the true value of the style, instead
-- of MediaLibrary's key.
--
-- While the process is complicated, this means that when you set values, you give keys, and when
-- you get values, you'll get values, so it's intuitive.
function StyleClient:FollowMediaLibraryKey(valueType, value, ignoreDefault)
    local mediaType = self:GetMediaKeyName(valueType);
    if not mediaType then
        return value;
    end;
    if ignoreDefault then
        return MediaLibrary:GetExplicit(mediaType, value);
    end
    return MediaLibrary:Get(mediaType, value, ignoreDefault);
end;
