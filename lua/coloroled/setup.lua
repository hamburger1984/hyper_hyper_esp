local module = {}

module.connected = false

local schedule_ap_scan
local scan_tmr = tmr.create()

local function check_access_points(scan_result)
    if module.connected then
        return
    end

    if scan_result then
        print("Scan results:")
        for ssid, data in pairs(scan_result) do
            print(" .. "..ssid.." : "..data)
        end
        for ssid, data in pairs(scan_result) do
            if config.wlan_config and config.wlan_config[ssid] then
                wifi.sta.config(ssid, config.wlan_config[ssid])
                wifi.sta.connect()
                print(">> Connecting to "..ssid..".")
                return
            end
        end
    end

    schedule_ap_scan()
end

local function scan_access_points()
    print("Scanning.")
    wifi.sta.getap(check_access_points)
end

schedule_ap_scan = function()
    if module.connected then
        return
    end

    scan_tmr:alarm(5000, tmr.ALARM_SINGLE, scan_access_points)
end

function module.start()
    print("Start setup.")

    wifi.setmode(wifi.STATION)
    print("MAC: "..wifi.sta.getmac())

    schedule_ap_scan()

    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
        module.connected = false
        print("\nWifi disconnected.")
        app.disconnected()
        schedule_ap_scan()
    end)

    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
        module.connected = true
        print("\nIP assigned: "..T.IP.." (Gateway: "..T.gateway..")")

        display.text(0, 0, 0, ".", "large", 20) -- hack to clear line
        display.text(0, 255, 0, "Connected.", "regular", 16)
        display.text(0, 255, 0, T.IP, "small", 42)
        tmr.delay(400000) -- another hack

        app.connected()
    end)
end

return module
