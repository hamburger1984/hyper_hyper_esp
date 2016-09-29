local module = {}

m = nil

local function report_brightness()
    b = adc.read(0)
    print("Publishing "..b.." to "..config.mqtt_topic)
    m:publish(config.mqtt_topic, b, 0, 0)
end

function module.start()
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

    print("Connnecting to mqtt "..config.mqtt_broker..":"..config.mqtt_port.."..")
    -- host, port, secure, autoreconnect
    m:connect(config.mqtt_broker, config.mqtt_port, 0, 0)
end

function module.disconnected()
    print("Disconnected.")
end

return module
