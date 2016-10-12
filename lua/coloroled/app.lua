local module = {}

m = nil

function module.start()
    -- initialize MQTT client
    m = mqtt.Client(config.mqtt_client_id, config.mqtt_timeout)

    m:on("connect", function(client)
        print("MQTT connected.")
        while not m:subscribe(config.mqtt_topic, 0) do
            delay(1000)
            print("retrying subscription.")
        end
        print("subscribed.")
    end)
    m:on("offline", function(client)
        print("MQTT offline.")
    end)
    m:on("message", function(client, topic, message)
        display.border(255,   0, 0, 0)
        display.border(200,   0, 0, 1)
        display.border(155,   0, 0, 2)
        display.border(100,  25, 0, 3)
        display.border( 75,  50, 0, 4)
        display.border( 50,  75, 0, 5)
        display.border( 25, 100, 0, 6)
        display.border(  0, 155, 0, 7)
        display.text(255, 255, 0, message, 'large', 16)
    end)
end

function module.connected()
    print("Connnecting to mqtt "..config.mqtt_broker..":"..config.mqtt_port.."..")
    -- host, port, secure, autoreconnect
    m:connect(config.mqtt_broker, config.mqtt_port, 0, 1)
end

function module.disconnected()
end

return module
