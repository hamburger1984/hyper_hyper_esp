local module = {}

module.connected = false

local schedule_ap_scan
local scan_tmr = tmr.create()

local function check_access_points(scan_result)
    if module.connected then
        return
    end

    if scan_result then
        for ssid, data in pairs(scan_result) do
            print(" --- "..ssid.." : "..data)
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

    if adc.force_init_mode(adc.INIT_ADC) then
        print("Restarting to apply adc mode change.")
        node.restart()
        return
    end

    wifi.setmode(wifi.STATION)
    print("MAC: "..wifi.sta.getmac())

    schedule_ap_scan()

    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
        print("\nWifi disconnected.")
        app.disconnected()
        module.connected = false
        schedule_ap_scan()
    end)

    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
        print("\nIP assigned: "..T.IP.." (Gateway: "..T.gateway..")")
        module.connected = true
        app.connected()
    end)
end

return module
