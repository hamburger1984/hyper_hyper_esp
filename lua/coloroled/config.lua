local module = {}

module.wlan_config = {}
module.wlan_config["MySSID"] = "MyPassword"
module.wlan_config["MyOtherSSID"] = "MyOtherPassword"

module.mqtt_client_id = string.format("nodemcu-%06x", node.chipid())
module.mqtt_timeout = 30
module.mqtt_broker = "broker.hivemq.com"
module.mqtt_port = 1883
module.mqtt_topic = "nodemcu/#"

return module
