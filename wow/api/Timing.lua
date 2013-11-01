function GetTime()
    -- I originally had this return a constant, or return os.time(), but if
    -- a platform implements this method in its own way, then the time will
    -- be forced to shift. Since this breaks the monotonic nature of this clock,
    -- I prefer to just crash and burn.

    error("GetTime is not implemented");
end;
