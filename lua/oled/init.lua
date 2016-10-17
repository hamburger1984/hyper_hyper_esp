print("ChipID: "..string.format("%06x", node.chipid()))

local function initialize()
    app = require("app")
    app.start()
end

if file.exists("app.lc") then
    tmr.alarm(0, 4000, tmr.ALARM_SINGLE, function() initialize() end)
else
    print("could not find app.lc")
end
