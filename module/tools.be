import tools_constants as constants

var MAC_EMPTY='00:00:00:00:00:00'

def get_mac()

    var status_net=tasmota.cmd('status 5').find('StatusNET',{})
    var mac_wifi=status_net.find('Mac', MAC_EMPTY)
    var mac_ethernet=status_net.find('Ethernet', {}).find('Mac', MAC_EMPTY)

    if [MAC_EMPTY,nil].find(mac_wifi)==nil
        return mac_wifi
    elif [MAC_EMPTY,nil].find(mac_ethernet)==nil
        return mac_ethernet
    end

    raise "Couldn't get MAC address"
end

var mod = module(constants.NAME)
mod.VERSION=constants.VERSION

mod.get_mac=get_mac

log("TLS: Successfully imported tools.be version "+constants.VERSION+". You can now access it using the `tools` module, e.g. in `autoexec.be`, Berry Console, etc.")

return mod