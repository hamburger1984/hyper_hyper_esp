print("ChipID: "..string.format("%06x", node.chipid()))

if file.exists("app.lc") then
    app = require("app")
    app.start()
else
    print("could not find app.lua.")
end
