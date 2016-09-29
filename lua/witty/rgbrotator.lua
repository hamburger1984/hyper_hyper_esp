local module = {}

-- tested on Witty Cloud board (ESP8266 + RGB-LED + LDR)

-- Color -- IO Index -- PIN
--   RED           8     15
-- GREEN           6     12
--  BLUE           7     13
PIN_R, PIN_G, PIN_B= 8, 6, 7

h, s, v = 24, 0xff, 0x10

pulse_step = 23

-- where:
--   hue         in 0..255
--   saturation  in 0..255
--   value       in 0..255
local function hsv_to_rgb(hue, saturation, value)
    -- 0..5
    local region = hue/43
    -- 0..255
    local fpart = (hue - (region*43))*6;

    local p = bit.rshift(value * (255 - saturation), 8)
    local q = bit.rshift(value * (255 - bit.rshift(saturation * fpart, 8)), 8)
    local t = bit.rshift(value * (255 - bit.rshift(saturation * (255-fpart), 8)), 8)

    if region==0 or region==6 then
        return value, t, p
    elseif region==1 then
        return q, value, p
    elseif region==2 then
        return p, value, t
    elseif region==3 then
        return p, q, value
    elseif region==4 then
        return t, p, value
    elseif region==5 then
        return value, p, q
    else return 255, 0, 0
    end
end

local function setcolor()
    local r, g, b = hsv_to_rgb(h, s, v)
    pwm.setduty(PIN_R, r*3)
    pwm.setduty(PIN_G, g*3)
    pwm.setduty(PIN_B, b*3)
end

local function do_step()
    if (v + pulse_step) > 0xff or (v + pulse_step) < 0 then
        pulse_step = -1 * pulse_step
    end
    v = v + pulse_step

    h = h+1
    if h > 255 then
        h = 0
    end

    setcolor()
end

function module.start()
    math.randomseed(tmr.now())

    pwm.setup(PIN_R, 300, 0)
    pwm.setup(PIN_G, 300, 0)
    pwm.setup(PIN_B, 300, 0)

    pwm.start(PIN_R)
    pwm.start(PIN_G)
    pwm.start(PIN_B)

    tmr.alarm(1, 100, tmr.ALARM_AUTO, function() do_step() end)
end

function module.stop()
    tmr.unregister(1)
end

return module
