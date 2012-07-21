Labs = Labs or {};

function Labs.Bar()
        local bar, remover;
        function Destroy()
           if bar then
              Frames.Destroy(bar);
              bar = nil;
           end;
           if remover then
              remover();
              remover = nil;
           end;
        end;

        bar = UI.Bar:New(UIParent, {
              width = 200,
              height = 40,
              barColor = "green",
              backgroundColor = {.2, 0, 0, .5}
        });
        Frames.Backdrop(bar, "dialog");


        Anchors.Center(bar, Anchors.Named("Target Health"));

        remover = bar:SetAmount(Amounts.Health("target"));
        return Destroy;
end;
