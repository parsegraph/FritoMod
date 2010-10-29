if nil ~= require then
	require "Metatables";
	require "OOP-Class";
end;

WoW=WoW or Metatables.Defensive();

WoW.FrameTypes={};
function CreateFrame(fType, name, parent, inherited)
	if type(fType) ~= "string" then
		error("fType must be a string. type: "..type(fType));
	end;
	fType=string.lower(fType);
	if not WoW.FrameTypes[fType] then
		error("fType is unknown. fType: "..fType);
	end;
	local f=WoW.FrameTypes[fType]:New(parent, inherited);
	if name then
		_G[name]=f;
	end;
	return f;
end;

WoW.Frame=OOP.Class();
WoW.FrameTypes.frame=WoW.Frame;
