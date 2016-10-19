print("ChipID: "..string.format("%06x", node.chipid()))

config = loadfile("config.lua")()

i2c_helper = loadfile("i2c_helper.lua")()
oled = loadfile("oled.lua")()
mpu9250 = loadfile("mpu9250.lua")()

i2c_helper.initialize()
oled.initialize()
mpu9250.initialize()

oled.start()

function printMPU()
    acc_x, acc_y, acc_z = mpu9250.read_acceleration()
    ori_x, ori_y, ori_z = mpu9250.read_orientation()
    t = mpu9250.read_temperature()

    print(string.format("x %5d, y %5d, z %5d .. x %5d, y %5d, z %5d .. t %d", acc_x, acc_y, acc_z, ori_x, ori_y, ori_z, t))
end

printMPU()


function monitorMPU()
    local monitor = tmr.create()
    monitor:register(100, tmr.ALARM_AUTO, function(t) printMPU(); end)
    monitor:start()
end

--if file.exists("config.lc") and
--    file.exists("i2c_helper.lc") and
--    file.exists("mpu9250.lc") then
--
--    config = require("config")
--    i2c_helper = require("i2c_helper")
--    mpu9250 = require("mpu9250")
--
--    i2c_helper.initialize()
--    mpu9250.initialize()
--end
