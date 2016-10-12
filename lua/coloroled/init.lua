print("ChipID: "..string.format("%06x", node.chipid()))

if file.exists("app.lc") and
    file.exists("config.lc") and
    file.exists("coloroled.lc") and
    file.exists("setup.lc") then

    config = require("config")

    display = require("coloroled")
    app = require("app")
    setup = require("setup")

    display.initialize()
    display.text(255, 255, 0, "Hello!", "large", 20)
    display.border(0, 255,   0, 0)
    display.border(0, 200,   0, 1)
    display.border(0, 155,   0, 2)
    display.border(0, 100,  25, 3)
    display.border(0,  75,  50, 4)
    display.border(0,  50, 100, 5)
    display.border(0,  25, 155, 6)
    display.border(0,   0, 200, 7)
    app.start()
    setup.start()
else
    print("Could not find all required files.")
end
