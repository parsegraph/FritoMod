if nil ~= require then
    require "WoW_UI/Frame-Layout";
end;

Builders = Builders or {};

function Builders.Colored(f,r,g,b,a)
    f:SetTexture(r,g,b);
end;

function Builders.Square(f, size)
    f:SetHeight(size);
    f:SetWidth(size);
end;

function Builders.Centered(f, relative)
    f:SetPoint("CENTER", relative);
end;
