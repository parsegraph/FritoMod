
function GetScale(controlDistance, otherUnit)
    if not otherUnit then
        otherUnit = "TARGET";
    end;
    local zoneName = GetMapInfo();
    local zone = {
        controlDistance = controlDistance,
        point = { GetPlayerMapPosition("player") },
        otherPoint = { GetPlayerMapPosition(otherUnit) }
    }
    if zone.otherPoint[1] == 0 and zone.otherPoint[2] == 0 then
        error("Bad OtherPoint - Used UnitID: " .. otherUnit);
    end;
    zone.distance = distance(zone.point, zone.otherPoint);
    zone.scale = zone.controlDistance / zone.distance;
    local releaser = MasterLog:Pipe("PARTY");
    debug("Scale for Zone:", zoneName, "Control Distance:", zone.controlDistance);
    debug("Point:", unpack(zone.point));
    debug("Other:", unpack(zone.otherPoint));
    debug("Distance:", zone.distance);
    debug("Calculated Scale:", zone.scale);
    releaser();
    MAP_SCALES[zoneName] = zone;
end;

MAP_SCALES = {
    ShattrathCity = {
        controlDistance = 30,
        point = {.62223833799362, .36659386754036},
        otherPoint = {.60383039712906, .34148687124252}
    }
};
