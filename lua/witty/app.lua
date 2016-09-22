local module = {}

-- Color -- IO Index -- PIN
--   RED           8     15
-- GREEN           6     12
--  BLUE           7     13
red, green, blue = 8, 6, 7


local function init_pins()
    pwm.setup(red, 100, 100)
    pwm.setup(green, 100, 0)
    pwm.setup(blue, 100, 0)

    pwm.start(red)
    pwm.start(green)
    pwm.start(blue)
end

local function color(r, g, b)
    scale=3
    r, g, b = scale*math.min(255, r), scale*math.min(255, g), scale*math.min(255, b)

    r0, g0, b0 = pwm.getduty(red), pwm.getduty(green), pwm.getduty(blue)

    dr, dg, db = r-r0, g-g0, b-b0

    steps = 8
    sr, sg, sb = dr/steps, dg/steps, db/steps

    for i = 0, steps, 1 do
        r0 = r0 + sr
        g0 = g0 + sg
        b0 = b0 + sb

        pwm.setduty(red, r0)
        pwm.setduty(green, g0)
        pwm.setduty(blue, b0)
        tmr.delay(200)
    end

    pwm.setduty(red, r)
    pwm.setduty(green, g)
    pwm.setduty(blue, b)
end

local function randomcolor()
    color(math.random(0xff), math.random(0xff), math.random(0xff))
end

function module.start()
    init_pins()
    math.randomseed(tmr.now())

    tmr.alarm(0, 5000, tmr.ALARM_AUTO, function() randomcolor() end)
end

return module
