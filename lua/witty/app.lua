local module = {}

-- Color -- IO Index -- PIN
--   RED           8     15
-- GREEN           6     12
--  BLUE           7     13
PIN_R, PIN_G, PIN_B= 8, 6, 7

r, g, b, l = 0, 0, 0, 500


local function setbrightness(component)
    return (component * l) / 1024
end

local function setcolor()
    --tmr.stop(0)
    --tmr.stop(1)

    pwm.setduty(PIN_R, setbrightness(r))
    pwm.setduty(PIN_G, setbrightness(g))
    pwm.setduty(PIN_B, setbrightness(b))

    --tmr.start(0)
    --tmr.start(1)
end

local function randomcolor()
    r, g, b = math.random(0x400), math.random(0x400), math.random(0x400)
    setcolor()
end

local function adjustbrightness()
    newl = adc.read(0)
    if newl ~= l then
        print(newl)
        l = newl
        setcolor()
    end
end

function module.start()
    math.randomseed(tmr.now())

    if adc.force_init_mode(adc.INIT_ADC) then
        node.restart()
        return
    end

    pwm.setup(PIN_R, 100, 100)
    pwm.setup(PIN_G, 100, 0)
    pwm.setup(PIN_B, 100, 0)

    pwm.start(PIN_R)
    pwm.start(PIN_G)
    pwm.start(PIN_B)

    tmr.alarm(0, 5000, tmr.ALARM_AUTO, function() randomcolor() end)
    tmr.alarm(1, 100, tmr.ALARM_AUTO, function() adjustbrightness() end)
end

return module
