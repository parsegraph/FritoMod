if nil ~= require then
	require "Metatables";
	require "OOP-Class";
	require "wow/Frame";
	require "wow/Button";
end;

local frameTypes={
    frame=WoW.Frame,
    button=WoW.Button,
};

function CreateFrame(fType, name, parent, inherited)
	if type(fType) ~= "string" then
		error("fType must be a string. type: "..type(fType));
	end;
	fType=string.lower(fType);
	if not frameTypes[fType] then
		error("fType is unknown. fType: "..fType);
	end;
	local f=frameTypes[fType]:New(parent, inherited);
	if name then
		_G[name]=f;
	end;
	return f;
end;

