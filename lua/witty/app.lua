local module = {}

m = nil
published_b = nil

local function report_brightness()
    b = adc.read(0)
    if published_b == nil or published_b ~= b then
        print("Publishing "..b.." to "..config.mqtt_topic)
        m:publish(config.mqtt_topic, b, 0, 0)
        published_b = b
    end
end

function module.start()
    rgb.setspeed(75)
    rgb.start()

    -- initialize MQTT client
    m = mqtt.Client(config.mqtt_client_id, config.mqtt_timeout)

    m:on("connect", function(client)
        print("MQTT connected.")
        tmr.alarm(2, 10000, tmr.ALARM_AUTO, function() report_brightness() end)
    end)
    m:on("offline", function(client)
        print("MQTT offline.")
        tmr.unregister(2)
    end)
end

function module.connected()
    print("Connected.")
    rgb.setspeed(22)


    print("Connnecting to mqtt "..config.mqtt_broker..":"..config.mqtt_port.."..")
    -- host, port, secure, autoreconnect
    m:connect(config.mqtt_broker, config.mqtt_port, 0, 0)
end

function module.disconnected()
    print("Disconnected.")
    rgb.setspeed(75)
end

return module
