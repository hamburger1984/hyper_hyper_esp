print("ChipID: "..string.format("%06x", node.chipid()))

if file.exists("app.lc") and
    file.exists("rgbrotator.lc") and
    file.exists("config.lc") and
    file.exists("setup.lc") then

    config = require("config")

    rgb = require("rgbrotator")
    app = require("app")
    setup = require("setup")

    app.start()
    setup.start()
else
    print("Could not find all required files.")
end
