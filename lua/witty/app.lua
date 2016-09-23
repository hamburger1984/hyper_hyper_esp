local module = {}

-- Color -- IO Index -- PIN
--   RED           8     15
-- GREEN           6     12
--  BLUE           7     13
PIN_R, PIN_G, PIN_B= 8, 6, 7

h, s, v = 24, 0xff, 0x10

pulse, step = 100, 9

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

    if h==0 or h==6 then
        return value, t, p
    elseif h==1 then
        return q, value, p
    elseif h==2 then
        return p, value, t
    elseif h==3 then
        return p, q, value
    elseif h==4 then
        return t, p, value
    else
        return value, p, q
    end
end

local function setcolor()
    local r, g, b = hsv_to_rgb(h, s, (v*pulse)/0x400)
    pwm.setduty(PIN_R, r*4)
    pwm.setduty(PIN_G, g*4)
    pwm.setduty(PIN_B, b*4)
end

local function randomcolor()
    h = math.random(0xff)

    setcolor()
end

local function do_step()
    if (pulse + step) > 0xff or (pulse + step) < 0 then
        step = -1 * step
    end

    pulse = pulse + step
    v = adc.read(0)

    setcolor()
end

function module.start()
    math.randomseed(tmr.now())

    if adc.force_init_mode(adc.INIT_ADC) then
        node.restart()
        return
    end

    pwm.setup(PIN_R, 300, 0)
    pwm.setup(PIN_G, 300, 0)
    pwm.setup(PIN_B, 300, 0)

    pwm.start(PIN_R)
    pwm.start(PIN_G)
    pwm.start(PIN_B)

    randomcolor()

    tmr.alarm(0, 2000, tmr.ALARM_AUTO, function() randomcolor() end)
    tmr.alarm(1, 50, tmr.ALARM_AUTO, function() do_step() end)
end

return module
