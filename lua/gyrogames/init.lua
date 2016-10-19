print("ChipID: "..string.format("%06x", node.chipid()))

-- compiled:
--config = require("config")
--i2c_helper = require("i2c_helper")
--oled = require("oled")
--mpu9250 = require("mpu9250")

-- uncompiled:
config = loadfile("config.lua")()
i2c_helper = loadfile("i2c_helper.lua")()
oled = loadfile("oled.lua")()
mpu9250 = loadfile("mpu9250.lua")()

i2c_helper.initialize()
oled.initialize()
mpu9250.initialize()

function readMPU()
    acc_x, acc_y, acc_z = mpu9250.read_acceleration()
    ori_x, ori_y, ori_z = mpu9250.read_orientation()
    t = mpu9250.read_temperature()

    --print(string.format("x %6d, y %6d, z %6d .. x %6d, y %6d, z %6d .. t %d", acc_x, acc_y, acc_z, ori_x, ori_y, ori_z, t))
    oled.setMPU(acc_x, acc_y, acc_z, ori_x, ori_y, ori_z, t)
end

function renderOLED()
    oled.render()
end

tic = true

function step()
    if tic then
        readMPU()
    else
        renderOLED()
    end
    tic = not tic
end


function run()
    local stepper = tmr.create()
    stepper:register(25, tmr.ALARM_AUTO, function(t) step(); end)
    stepper:start()
end

run()
