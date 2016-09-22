local module = {}

MAX = 0x400

-- Color -- IO Index -- PIN
--   RED           8     15
-- GREEN           6     12
--  BLUE           7     13
PIN_R, PIN_G, PIN_B= 8, 6, 7

r, g, b, l = 0, MAX, 0, MAX/2

pulse, step = 0, 10
min_pulse, max_pulse = 0, MAX/2

local function scale(component)
    return (pulse * component * l) / (MAX*MAX)
end

local function setcolor()
    pwm.setduty(PIN_R, scale(r))
    pwm.setduty(PIN_G, scale(g))
    pwm.setduty(PIN_B, scale(b))
end

local function randomcolor()
    r, g, b = math.random(MAX), math.random(MAX), math.random(MAX)
    setcolor()
end

local function do_step()
    if (pulse + step) > max_pulse or (pulse + step) < min_pulse then
        step = -1 * step
    end

    pulse = pulse + step
    l = adc.read(0)

    setcolor()
end

function module.start()
    math.randomseed(tmr.now())

    if adc.force_init_mode(adc.INIT_ADC) then
        node.restart()
        return
    end

    pwm.setup(PIN_R, 300, scale(r))
    pwm.setup(PIN_G, 300, scale(g))
    pwm.setup(PIN_B, 300, scale(b))

    pwm.start(PIN_R)
    pwm.start(PIN_G)
    pwm.start(PIN_B)

    tmr.alarm(0, 2000, tmr.ALARM_AUTO, function() randomcolor() end)
    tmr.alarm(1, 50, tmr.ALARM_AUTO, function() do_step() end)
end

return module
